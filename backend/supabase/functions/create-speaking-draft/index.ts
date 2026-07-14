import { createClient } from "https://esm.sh/@supabase/supabase-js@2.46.1";

type DraftRequest = {
  japaneseText?: string;
  language?: string;
};

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
    return json({ error: "Method not allowed" }, 405);
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const openAiApiKey = Deno.env.get("OPENAI_API_KEY");

    if (!supabaseUrl || !supabaseAnonKey) {
      return json({ error: "Supabase environment variables are missing" }, 500);
    }
    if (!openAiApiKey) {
      return json({ error: "OPENAI_API_KEY is not configured" }, 500);
    }

    const authorization = request.headers.get("Authorization");
    if (!authorization) {
      return json({ error: "Authorization header is required" }, 401);
    }

    const supabase = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authorization } },
    });
    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();
    if (userError || !user) {
      return json({ error: "Invalid user session" }, 401);
    }

    const body = (await request.json().catch(() => ({}))) as DraftRequest;
    const japaneseText = body.japaneseText?.trim() ?? "";
    const language = body.language?.trim() || "English";

    if (!japaneseText) {
      return json({ error: "japaneseText is required" }, 400);
    }
    if (japaneseText.length > 500) {
      return json({ error: "japaneseText is too long" }, 400);
    }

    const draft = await createDraft({
      apiKey: openAiApiKey,
      japaneseText,
      language,
    });

    return json({ draft });
  } catch (error) {
    return json({ error: error instanceof Error ? error.message : String(error) }, 500);
  }
});

async function createDraft({
  apiKey,
  japaneseText,
  language,
}: {
  apiKey: string;
  japaneseText: string;
  language: string;
}): Promise<string> {
  const response = await fetch("https://api.openai.com/v1/responses", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: Deno.env.get("OPENAI_TEXT_MODEL") ?? "gpt-4.1-mini",
      input: [
        {
          role: "system",
          content: [
            "You create short speaking-practice drafts for language learners.",
            "Translate the user's Japanese intent into the target language.",
            "Return only the target-language draft. No explanations, labels, markdown, or Japanese.",
            "Use natural, simple spoken language. Keep it within 1 to 3 short sentences.",
          ].join(" "),
        },
        {
          role: "user",
          content: `Target language: ${language}\nJapanese intent: ${japaneseText}`,
        },
      ],
    }),
  });

  const payload = await response.json().catch(() => null) as Record<string, unknown> | null;
  if (!response.ok) {
    throw new Error(errorMessageFromOpenAi(payload) ?? `OpenAI draft failed: ${response.status}`);
  }

  const draft = extractOutputText(payload)?.trim() ?? "";
  if (!draft) {
    throw new Error("Draft response was empty");
  }
  return draft;
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
      if (
        isRecord(contentItem) &&
        contentItem.type === "output_text" &&
        typeof contentItem.text === "string"
      ) {
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

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json; charset=utf-8",
    },
  });
}
