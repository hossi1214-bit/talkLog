import { createClient } from "https://esm.sh/@supabase/supabase-js@2.46.1";

type AnalyzeRequest = {
  recordingId?: string;
  language?: string;
  learningLanguage?: string;
  baseLocale?: string;
};

type RecordingRow = {
  id: string;
  language: string | null;
  audio_path: string | null;
};

type UserRole = "FREE" | "PREMIUM" | "TESTER" | "ADMIN";

type CorrectionResult = {
  transcript: string;
  correctedText: string;
  naturalExpression: string;
  translation: string;
  grammarNotes: string[];
  vocabularyNotes: string[];
  score: number;
  encouragement: string;
};

type WordAdvice = {
  alternatives: string[];
  advice: string;
};

declare const EdgeRuntime: {
  waitUntil(promise: Promise<unknown>): void;
};

const freeDailyAiCorrectionLimit = 5;
const promptVersion = "2026-07-23-v1";
const supportedLearningLanguages = new Set([
  "ja", "en", "es", "fr", "de", "it", "ko", "zh-Hans",
]);
const supportedBaseLocales = new Set(["ja", "en", "es"]);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return json({ error: "INVALID_REQUEST" }, 405);
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
    if (!supabaseUrl || !supabaseAnonKey) {
      return json({ error: "ANALYSIS_FAILED" }, 500);
    }

    const authorization = request.headers.get("Authorization");
    if (!authorization) {
      return json({ error: "AUTH_REQUIRED" }, 401);
    }

    const body = (await request.json().catch(() => ({}))) as AnalyzeRequest;
    if (!body.recordingId) {
      return json({ error: "INVALID_REQUEST" }, 400);
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authorization } },
    });

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();
    if (userError || !user) {
      return json({ error: "AUTH_REQUIRED" }, 401);
    }

    const roleResult = await loadUserRole(supabase, user.id);
    if (roleResult.error) {
      return json({ error: "ANALYSIS_FAILED" }, 500);
    }
    const quotaResult = await checkAiCorrectionQuota(supabase, user.id, roleResult.role);
    if (quotaResult.error) {
      return json({ error: "ANALYSIS_FAILED" }, 500);
    }
    if (!quotaResult.allowed) {
      return json({
        error: "DAILY_LIMIT_REACHED",
        role: roleResult.role,
        limit: quotaResult.limit,
        used: quotaResult.used,
        remaining: 0,
      }, 429);
    }
    const { data: recordingData, error: recordingError } = await supabase
      .from("recordings")
      .select("id, language, audio_path")
      .eq("id", body.recordingId)
      .eq("user_id", user.id)
      .maybeSingle();

    if (recordingError) {
      return json({ error: "ANALYSIS_FAILED" }, 500);
    }
    if (!recordingData) {
      return json({ error: "RECORDING_NOT_FOUND" }, 404);
    }

    const recording = recordingData as RecordingRow;
    const learningLanguage = normalizeLanguageCode(
      body.learningLanguage ?? body.language ?? recording.language ?? "es",
    );
    const baseLocale = normalizeLanguageCode(body.baseLocale ?? "ja");
    if (!supportedLearningLanguages.has(learningLanguage) ||
        !supportedBaseLocales.has(baseLocale) ||
        learningLanguage === baseLocale) {
      return json({ error: "UNSUPPORTED_LANGUAGE" }, 400);
    }
    const openAiApiKey = Deno.env.get("OPENAI_API_KEY");
    const result = openAiApiKey
      ? await analyzeWithOpenAI({
        apiKey: openAiApiKey,
        supabase,
        recording,
        learningLanguage,
        baseLocale,
      })
      : buildDemoResult(learningLanguage);

    await saveResult({
      supabase,
      recordingId: body.recordingId,
      language: learningLanguage,
      baseLocale,
      result,
    });

    EdgeRuntime.waitUntil(
      updateWordUsage({
        supabase,
        userId: user.id,
        language: learningLanguage,
        baseLocale,
        transcript: result.transcript,
        vocabularyNotes: result.vocabularyNotes,
        apiKey: openAiApiKey ?? undefined,
      }).catch((error) => {
        const message = error instanceof Error ? error.message : String(error);
        console.warn(`Word usage update failed: ${message}`);
      }),
    );

    return json({
      source: openAiApiKey ? "openai" : "demo",
      result: {
        ...result,
        learningLanguage,
        baseLocale,
        promptVersion,
      },
      wordUsageWarning: null,
    });
  } catch (error) {
    const code = stableErrorCode(error);
    return json({ error: code }, code === "AUTH_REQUIRED" ? 401 : 500);
  }
});

async function analyzeWithOpenAI({
  apiKey,
  supabase,
  recording,
  learningLanguage,
  baseLocale,
}: {
  apiKey: string;
  supabase: ReturnType<typeof createClient>;
  recording: RecordingRow;
  learningLanguage: string;
  baseLocale: string;
}): Promise<CorrectionResult> {
  if (!recording.audio_path) {
    throw new Error("NO_RECOGNIZABLE_SPEECH");
  }

  const transcript = await transcribeAudio({
    apiKey,
    supabase,
    recording,
    learningLanguage,
  });
  const result = await createCorrection({
    apiKey,
    transcript,
    learningLanguage,
    baseLocale,
  });
  return { ...result, transcript };
}

async function transcribeAudio({
  apiKey,
  supabase,
  recording,
  learningLanguage,
}: {
  apiKey: string;
  supabase: ReturnType<typeof createClient>;
  recording: RecordingRow;
  learningLanguage: string;
}): Promise<string> {
  const { data: audioBlob, error } = await supabase.storage
    .from("recordings")
    .download(recording.audio_path!);
  if (error) {
    throw new Error(`Failed to download audio: ${error.message}`);
  }

  const filename = recording.audio_path!.split("/").pop() ?? `${recording.id}.m4a`;
  const file = new File([audioBlob], filename, {
    type: audioBlob.type || "audio/mp4",
  });
  const formData = new FormData();
  formData.append("file", file);
  formData.append("model", Deno.env.get("OPENAI_TRANSCRIPTION_MODEL") ?? "gpt-4o-mini-transcribe");
  formData.append("response_format", "json");
  formData.append("language", transcriptionLanguageCode(learningLanguage));

  const response = await fetch("https://api.openai.com/v1/audio/transcriptions", {
    method: "POST",
    headers: { Authorization: `Bearer ${apiKey}` },
    body: formData,
  });

  const payload = await response.json().catch(() => null) as { text?: string; error?: { message?: string } } | null;
  if (!response.ok) {
    throw new Error(payload?.error?.message ?? `OpenAI transcription failed: ${response.status}`);
  }
  const transcript = payload?.text?.trim() ?? "";
  if (!transcript) {
    throw new Error("NO_RECOGNIZABLE_SPEECH");
  }
  return transcript;
}

async function createCorrection({
  apiKey,
  transcript,
  learningLanguage,
  baseLocale,
}: {
  apiKey: string;
  transcript: string;
  learningLanguage: string;
  baseLocale: string;
}): Promise<Omit<CorrectionResult, "transcript">> {
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: Deno.env.get("OPENAI_FEEDBACK_MODEL") ?? "gpt-4.1-mini",
      input: [
        {
          role: "system",
          content:
            "You are TalkLog, a supportive multilingual speaking coach. Return only valid JSON that matches the schema. Keep feedback concise, specific, and encouraging.",
        },
        {
          role: "user",
          content: [
            `Learning language: ${learningLanguage}`,
            `Explanation language: ${baseLocale}`,
            `Transcript: ${transcript}`,
            "Keep correctedText and naturalExpression in the learning language. Put the translation, grammar notes, vocabulary explanations, and encouragement in the explanation language. Score the utterance from 0 to 100.",
            "Each vocabularyNotes item must include both the target word or phrase and an explanation in the explanation language, formatted as: word or phrase: explanation. Do not return a word alone.",
          ].join("\n"),
        },
      ],
      text: {
        format: {
          type: "json_schema",
          name: "talklog_correction",
          strict: true,
          schema: correctionSchema,
        },
      },
    }),
  });

  const payload = await response.json().catch(() => null) as Record<string, unknown> | null;
  if (!response.ok) {
    const message = errorMessageFromOpenAi(payload) ?? `OpenAI feedback failed: ${response.status}`;
    throw new Error(message);
  }

  const text = extractOutputText(payload);
  if (!text) {
    throw new Error("OpenAI feedback response did not include output text");
  }

  const parsed = JSON.parse(text) as Partial<CorrectionResult>;
  return normalizeCorrectionResult(parsed);
}

async function saveResult({
  supabase,
  recordingId,
  language,
  baseLocale,
  baseLocale,
  result,
}: {
  supabase: ReturnType<typeof createClient>;
  recordingId: string;
  language: string;
  baseLocale: string;
  baseLocale: string;
  result: CorrectionResult;
}) {
  const { error: transcriptError } = await supabase.from("transcripts").upsert(
    {
      recording_id: recordingId,
      original_text: result.transcript,
      language,
      created_at: new Date().toISOString(),
    },
    { onConflict: "recording_id" },
  );
  if (transcriptError) {
    throw new Error(transcriptError.message);
  }

  const { error: feedbackError } = await supabase.from("feedbacks").upsert(
    {
      recording_id: recordingId,
      corrected_text: result.correctedText,
      natural_expression: result.naturalExpression,
      translation_ja: result.translation,
      grammar_feedback: result.grammarNotes,
      vocabulary_feedback: result.vocabularyNotes,
      score: result.score,
      comment: result.encouragement,
      learning_language: language,
      base_locale: baseLocale,
      prompt_version: promptVersion,
      created_at: new Date().toISOString(),
    },
    {
      onConflict:
        "recording_id,learning_language,base_locale,prompt_version",
    },
  );
  if (feedbackError) {
    throw new Error(feedbackError.message);
  }
}

async function updateWordUsage({
  supabase,
  userId,
  language,
  transcript,
  vocabularyNotes,
  apiKey,
}: {
  supabase: ReturnType<typeof createClient>;
  userId: string;
  language: string;
  transcript: string;
  vocabularyNotes: string[];
  apiKey?: string;
}) {
  const counts = countWords(transcript, language);
  if (counts.size === 0) {
    addVocabularyNoteWords(counts, vocabularyNotes);
  }
  if (counts.size === 0) {
    return;
  }

  const words = [...counts.keys()].slice(0, 40);
  const generatedAdvice = apiKey
    ? await createWordAdviceMap({ apiKey, language, baseLocale, transcript, words: words.slice(0, 10) }).catch(() => new Map<string, WordAdvice>())
    : new Map<string, WordAdvice>();

  const { data: existingRows, error: selectError } = await supabase
    .from("word_usage")
    .select("word, count, advice, advice_i18n")
    .eq("user_id", userId)
    .eq("language", language)
    .in("word", words);
  if (selectError) {
    throw new Error(selectError.message);
  }

  const existingCounts = new Map<string, number>();
  const existingAdvice = new Map<string, string>();
  const existingAdviceI18n = new Map<string, Record<string, string>>();
  for (const row of existingRows ?? []) {
    if (isRecord(row) && typeof row.word === "string" && typeof row.count === "number") {
      existingCounts.set(row.word, row.count);
      if (typeof row.advice === "string") {
        existingAdvice.set(row.word, row.advice);
      }
      if (isRecord(row.advice_i18n)) {
        existingAdviceI18n.set(
          row.word,
          Object.fromEntries(
            Object.entries(row.advice_i18n).filter((entry): entry is [string, string] => typeof entry[1] === "string"),
          ),
        );
      }
    }
  }

  const rows = words.map((word) => {
    const advice = generatedAdvice.get(word) ?? adviceFor(word, language, baseLocale);
    const localizedAdvice = {
      ...(existingAdviceI18n.get(word) ?? {}),
      [baseLocale]: advice.advice,
    };
    return {
      user_id: userId,
      language,
      word,
      count: (existingCounts.get(word) ?? 0) + (counts.get(word) ?? 0),
      alternative_words: advice.alternatives,
      advice: baseLocale === "ja" ? advice.advice : (existingAdvice.get(word) ?? ""),
      advice_i18n: localizedAdvice,
      updated_at: new Date().toISOString(),
    };
  });

  const { error: upsertError } = await supabase
    .from("word_usage")
    .upsert(rows, { onConflict: "user_id,language,word" });
  if (upsertError) {
    throw new Error(upsertError.message);
  }
}

async function createWordAdviceMap({
  apiKey,
  language,
  baseLocale,
  transcript,
  words,
}: {
  apiKey: string;
  language: string;
  baseLocale: string;
  transcript: string;
  words: string[];
}): Promise<Map<string, WordAdvice>> {
  if (words.length === 0) {
    return new Map();
  }

  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: Deno.env.get("OPENAI_WORD_ADVICE_MODEL") ?? Deno.env.get("OPENAI_FEEDBACK_MODEL") ?? "gpt-4.1-mini",
      input: [
        {
          role: "system",
          content:
            `You are TalkLog, a concise vocabulary coach. Return only valid JSON. Suggest natural paraphrases for the learner's target language and write advice in the explanation language (${baseLocale}).`,
        },
        {
          role: "user",
          content: [
            `Learning language: ${language}`,
            `Explanation language: ${baseLocale}`,
            `Transcript: ${transcript}`,
            `Words: ${words.join(", ")}`,
            "For each word, provide 1 to 3 alternative words or expressions in the learning language and one short advice sentence in the explanation language about nuance or how to vary the expression.",
          ].join("\n"),
        },
      ],
      text: {
        format: {
          type: "json_schema",
          name: "talklog_word_advice",
          strict: true,
          schema: wordAdviceSchema,
        },
      },
    }),
  });

  const payload = await response.json().catch(() => null) as Record<string, unknown> | null;
  if (!response.ok) {
    const message = errorMessageFromOpenAi(payload) ?? `OpenAI word advice failed: ${response.status}`;
    throw new Error(message);
  }

  const text = extractOutputText(payload);
  if (!text) {
    throw new Error("OpenAI word advice response did not include output text");
  }

  const parsed = JSON.parse(text) as { items?: unknown[] };
  const adviceMap = new Map<string, WordAdvice>();
  for (const item of parsed.items ?? []) {
    if (!isRecord(item) || typeof item.word !== "string") {
      continue;
    }
    const word = item.word.trim().toLowerCase();
    if (!words.includes(word)) {
      continue;
    }
    adviceMap.set(word, {
      alternatives: stringArray(item.alternatives).slice(0, 3),
      advice: stringValue(item.advice),
    });
  }
  return adviceMap;
}

function countWords(text: string, language: string): Map<string, number> {
  if (["日本語", "韓国語", "中国語"].includes(language)) {
    return new Map();
  }

  const stopWords = stopWordsFor(language);
  const counts = new Map<string, number>();
  const normalized = text
    .toLowerCase()
    .normalize("NFKC")
    .replace(/[’]/g, "'")
    .replace(/[^\p{L}\p{N}'-]+/gu, " ");

  for (const rawToken of normalized.split(/\s+/)) {
    const word = rawToken.replace(/^[-']+|[-']+$/g, "");
    if (word.length < 3 || stopWords.has(word) || /^\d+$/.test(word)) {
      continue;
    }
    counts.set(word, (counts.get(word) ?? 0) + 1);
  }

  return new Map([...counts.entries()].sort((a, b) => b[1] - a[1]));
}

function addVocabularyNoteWords(counts: Map<string, number>, notes: string[]) {
  for (const note of notes) {
    const word = note.split(/[:：]/)[0]?.trim();
    if (!word || word.length < 2) {
      continue;
    }
    counts.set(word, (counts.get(word) ?? 0) + 1);
  }
}

function stopWordsFor(language: string): Set<string> {
  const common = ["and", "the", "for", "with", "that", "this", "was", "were", "are", "you", "your"];
  const byLanguage: Record<string, string[]> = {
    英語: ["today", "went", "very", "really", "some", "have", "had", "did"],
    スペイン語: ["que", "con", "para", "una", "unos", "unas", "muy", "hoy", "fui", "fue", "estoy", "esta", "este", "del", "los", "las"],
    フランス語: ["avec", "pour", "dans", "une", "des", "tres", "aujourd'hui", "c'etait", "suis", "alle"],
    ドイツ語: ["und", "ich", "bin", "ein", "eine", "sehr", "heute", "war", "habe"],
    イタリア語: ["con", "per", "una", "sono", "oggi", "era", "molto", "andato", "ho"],
  };
  return new Set([...(byLanguage[language] ?? []), ...common]);
}

function adviceFor(word: string, language: string, baseLocale: string): WordAdvice {
  if (baseLocale !== "ja") {
    const advice = baseLocale === "es"
      ? `${word} aparece con frecuencia. Intenta añadir un detalle o una razón la próxima vez.`
      : `${word} appears often. Try adding one detail or reason next time.`;
    return { alternatives: [], advice };
  }
  const dictionaries: Record<string, Record<string, WordAdvice>> = {
    英語: {
      good: {
        alternatives: ["great", "nice", "excellent"],
        advice: "good は便利ですが、気持ちの強さに合わせて great や nice を使うと表現が少し自然になります。",
      },
      like: {
        alternatives: ["enjoy", "love", "be into"],
        advice: "like が続くと単調になりやすいので、趣味なら enjoy、強い好みなら love も試せます。",
      },
      think: {
        alternatives: ["feel", "believe", "guess"],
        advice: "think は意見、feel は感覚、believe は確信に近いニュアンスで使い分けできます。",
      },
      want: {
        alternatives: ["would like", "hope to", "feel like"],
        advice: "want は直接的なので、丁寧に言いたい時は would like を使うとやわらかくなります。",
      },
      cafe: {
        alternatives: ["coffee shop", "local cafe", "place"],
        advice: "場所を少し具体化すると会話が広がります。local cafe のように情報を足すのもおすすめです。",
      },
    },
    スペイン語: {
      bueno: {
        alternatives: ["rico", "excelente", "agradable"],
        advice: "bueno は万能ですが、食べ物や飲み物なら rico、体験なら agradable も自然です。",
      },
      bien: {
        alternatives: ["genial", "perfecto", "bastante bien"],
        advice: "bien に強弱をつけたい時は genial や bastante bien を使うと気持ちが伝わりやすくなります。",
      },
      quiero: {
        alternatives: ["me gustaria", "tengo ganas de", "quisiera"],
        advice: "quiero ははっきりした言い方です。丁寧にしたい時は me gustaria が便利です。",
      },
      cafe: {
        alternatives: ["cafeteria", "bar", "un lugar tranquilo"],
        advice: "cafe が続く時は、場所なら cafeteria、飲み物なら cafe と文脈で分けると伝わりやすいです。",
      },
    },
    フランス語: {
      bon: {
        alternatives: ["excellent", "agreable", "delicieux"],
        advice: "bon は広く使えます。食べ物なら delicieux、体験なら agreable も使えます。",
      },
    },
    ドイツ語: {
      gut: {
        alternatives: ["toll", "angenehm", "lecker"],
        advice: "gut は便利です。食べ物や飲み物なら lecker、感想なら toll も自然です。",
      },
    },
    イタリア語: {
      buono: {
        alternatives: ["ottimo", "delizioso", "piacevole"],
        advice: "buono 以外に、食べ物なら delizioso、体験なら piacevole を使えます。",
      },
    },
  };

  const specific = dictionaries[language]?.[word];
  if (specific) {
    return specific;
  }

  return {
    alternatives: [],
    advice: `${word} がよく出ています。次回は前後に形容詞や理由を1つ足して、より具体的に話してみましょう。`,
  };
}

async function loadUserRole(
  supabase: ReturnType<typeof createClient>,
  userId: string,
): Promise<{ role: UserRole; error?: string }> {
  const { data, error } = await supabase
    .from("profiles")
    .select("role")
    .eq("id", userId)
    .maybeSingle();
  if (error) {
    return { role: "FREE", error: error.message };
  }
  return { role: parseUserRole(isRecord(data) ? data.role : null) };
}


async function checkAiCorrectionQuota(
  supabase: ReturnType<typeof createClient>,
  userId: string,
  role: UserRole,
): Promise<{ allowed: boolean; used: number; limit: number | null; error?: string }> {
  if (canUsePremiumFeature(role)) {
    return { allowed: true, used: 0, limit: null };
  }

  const { start, end } = japanDayUtcRange(new Date());
  const { count, error } = await supabase
    .from("feedbacks")
    .select("id, recordings!inner(user_id)", { count: "exact", head: true })
    .eq("recordings.user_id", userId)
    .gte("created_at", start.toISOString())
    .lt("created_at", end.toISOString());

  if (error) {
    return { allowed: false, used: 0, limit: freeDailyAiCorrectionLimit, error: error.message };
  }

  const used = count ?? 0;
  return {
    allowed: used < freeDailyAiCorrectionLimit,
    used,
    limit: freeDailyAiCorrectionLimit,
  };
}

function japanDayUtcRange(now: Date): { start: Date; end: Date } {
  const japanTime = new Date(now.getTime() + 9 * 60 * 60 * 1000);
  const start = new Date(Date.UTC(
    japanTime.getUTCFullYear(),
    japanTime.getUTCMonth(),
    japanTime.getUTCDate(),
    -9,
    0,
    0,
    0,
  ));
  const end = new Date(start.getTime() + 24 * 60 * 60 * 1000);
  return { start, end };
}

function parseUserRole(value: unknown): UserRole {
  const normalized = typeof value === "string" ? value.trim().toUpperCase() : "FREE";
  if (["PREMIUM", "TESTER", "ADMIN"].includes(normalized)) {
    return normalized as UserRole;
  }
  return "FREE";
}

function normalizeLanguageCode(value: string): string {
  const normalized = value.trim();
  const legacyLabels: Record<string, string> = {
    "日本語": "ja",
    "英語": "en",
    "スペイン語": "es",
    "フランス語": "fr",
    "ドイツ語": "de",
    "イタリア語": "it",
    "韓国語": "ko",
    "中国語": "zh-Hans",
  };
  return legacyLabels[normalized] ?? normalized;
}

function transcriptionLanguageCode(language: string): string {
  return language === "zh-Hans" ? "zh" : language;
}

function canUsePremiumFeature(role: UserRole): boolean {
  return ["PREMIUM", "TESTER", "ADMIN"].includes(role);
}

function stableErrorCode(error: unknown): string {
  const message = error instanceof Error ? error.message : String(error);
  if (message.includes("NO_RECOGNIZABLE_SPEECH")) {
    return "NO_RECOGNIZABLE_SPEECH";
  }
  if (message.includes("UNSUPPORTED_LANGUAGE")) {
    return "UNSUPPORTED_LANGUAGE";
  }
  if (message.includes("AUTH_REQUIRED") ||
      message.includes("Invalid user session") ||
      message.toLowerCase().includes("jwt")) {
    return "AUTH_REQUIRED";
  }
  if (message.includes("429") || message.includes("Too Many Requests")) {
    return "DAILY_LIMIT_REACHED";
  }
  return "ANALYSIS_FAILED";
}

function isAdmin(role: UserRole): boolean {
  return role === "ADMIN";
}

function json(payload: unknown, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}

function extractOutputText(payload: Record<string, unknown> | null): string | null {
  if (!payload) {
    return null;
  }
  if (typeof payload.output_text === "string") {
    return payload.output_text;
  }

  const output = payload.output;
  if (!Array.isArray(output)) {
    return null;
  }

  for (const item of output) {
    if (!isRecord(item)) {
      continue;
    }
    const content = item.content;
    if (!Array.isArray(content)) {
      continue;
    }
    for (const contentItem of content) {
      if (isRecord(contentItem) && contentItem.type === "output_text" && typeof contentItem.text === "string") {
        return contentItem.text;
      }
    }
  }
  return null;
}

function errorMessageFromOpenAi(payload: Record<string, unknown> | null): string | null {
  const error = payload?.error;
  if (isRecord(error) && typeof error.message === "string") {
    return error.message;
  }
  return null;
}

function normalizeCorrectionResult(value: Partial<CorrectionResult>): Omit<CorrectionResult, "transcript"> {
  return {
    correctedText: stringValue(value.correctedText),
    naturalExpression: stringValue(value.naturalExpression),
    translation: stringValue(value.translation),
    grammarNotes: stringArray(value.grammarNotes),
    vocabularyNotes: stringArray(value.vocabularyNotes),
    score: clampScore(value.score),
    encouragement: stringValue(value.encouragement),
  };
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function stringValue(value: unknown): string {
  return typeof value === "string" ? value : "";
}

function stringArray(value: unknown): string[] {
  return Array.isArray(value) ? value.map((item) => String(item)) : [];
}

function clampScore(value: unknown): number {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    return 0;
  }
  return Math.max(0, Math.min(100, Math.round(value)));
}

const wordAdviceSchema = {
  type: "object",
  additionalProperties: false,
  required: ["items"],
  properties: {
    items: {
      type: "array",
      minItems: 0,
      maxItems: 10,
      items: {
        type: "object",
        additionalProperties: false,
        required: ["word", "alternatives", "advice"],
        properties: {
          word: { type: "string" },
          alternatives: {
            type: "array",
            minItems: 0,
            maxItems: 3,
            items: { type: "string" },
          },
          advice: { type: "string" },
        },
      },
    },
  },
} as const;

const correctionSchema = {
  type: "object",
  additionalProperties: false,
  required: [
    "correctedText",
    "naturalExpression",
    "translation",
    "grammarNotes",
    "vocabularyNotes",
    "score",
    "encouragement",
  ],
  properties: {
    correctedText: { type: "string" },
    naturalExpression: { type: "string" },
    translation: { type: "string" },
    grammarNotes: {
      type: "array",
      minItems: 1,
      maxItems: 4,
      items: { type: "string" },
    },
    vocabularyNotes: {
      type: "array",
      minItems: 1,
      maxItems: 4,
      items: {
        type: "string",
        description:
          "Format each item as 'word or phrase: Japanese explanation'. Never return only the word.",
      },
    },
    score: { type: "integer", minimum: 0, maximum: 100 },
    encouragement: { type: "string" },
  },
} as const;

function buildDemoResult(language: string): CorrectionResult {
  const transcript = transcriptFor(language);
  return {
    transcript,
    correctedText: correctedTextFor(language),
    naturalExpression: naturalExpressionFor(language),
    translation: "今日はカフェに行ってコーヒーを飲みました。とてもおいしかったです。",
    grammarNotes: grammarNotesFor(language),
    vocabularyNotes: vocabularyNotesFor(language),
    score: 82,
    encouragement: "短い文でも最後まで話せています。次は理由や感想を一文足すと、もっと自然なスピーキングになります。",
  };
}

function transcriptFor(language: string) {
  switch (language) {
    case "英語":
      return "Today I went to a cafe and I drank coffee. It was very good.";
    case "フランス語":
      return "Aujourd'hui je suis alle dans un cafe et j'ai bu un cafe. C'etait tres bon.";
    case "ドイツ語":
      return "Heute bin ich in ein Cafe gegangen und habe Kaffee getrunken. Es war sehr gut.";
    case "イタリア語":
      return "Oggi sono andato in un bar e ho bevuto un caffe. Era molto buono.";
    case "韓国語":
      return "오늘 저는 카페에 가서 커피를 마셨어요. 정말 좋았어요.";
    case "中国語":
      return "今天我去了咖啡店，喝了一杯咖啡。感觉很好。";
    default:
      return "Hoy fui a una cafeteria y tome cafe. Fue muy bueno.";
  }
}

function correctedTextFor(language: string) {
  switch (language) {
    case "英語":
      return "Today, I went to a cafe and had some coffee. It was really good.";
    case "韓国語":
      return "오늘 저는 카페에 가서 커피를 마셨어요. 정말 좋았어요.";
    case "中国語":
      return "今天我去了一家咖啡店，喝了一杯咖啡。感觉很好。";
    default:
      return transcriptFor(language);
  }
}

function naturalExpressionFor(language: string) {
  switch (language) {
    case "英語":
      return "I stopped by a cafe today and had a really nice coffee.";
    case "韓国語":
      return "오늘 카페에 들러서 커피를 한 잔 마셨어요.";
    case "中国語":
      return "我今天去了一家咖啡店，喝了一杯很好喝的咖啡。";
    default:
      return correctedTextFor(language);
  }
}

function grammarNotesFor(language: string) {
  if (language === "英語") {
    return [
      "drink coffee でも通じますが、体験として話す時は had coffee のほうが自然です。",
      "Today の後にカンマを入れると、文の流れが読みやすくなります。",
    ];
  }
  return [
    "意味は十分伝わっています。冠詞や動詞の選び方を少し整えると、より自然になります。",
    "短い文を並べるだけでなく、理由や感想を足すと会話らしくなります。",
  ];
}

function vocabularyNotesFor(language: string) {
  if (language === "英語") {
    return ["stop by: 少し立ち寄る", "really nice: とても良い、感じが良い"];
  }
  return [
    "日常の出来事を自然に話すために、立ち寄る・味がよいに近い表現を覚えると便利です。",
    "感想を具体化すると、表現がより豊かになります。",
  ];
}
