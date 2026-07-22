# Supabase Edge Functions Setup

TalkLog の音声文字起こし・AI添削・練習文作成は、Flutter から直接 OpenAI API を呼ばず、Supabase Edge Functions 経由で実行します。

## 現在できること

### analyze-recording

`backend/supabase/functions/analyze-recording` は以下に対応しています。

1. Flutter から録音IDを受け取る
2. Supabase Auth のユーザーを確認する
3. `profiles.role` を確認する
4. `FREE` は1日5回まで、`PREMIUM` / `TESTER` / `ADMIN` は無制限で通す
5. `recordings` テーブルから対象録音を取得する
6. Storage の `recordings` bucket から音声ファイルを取得する
7. OpenAIで文字起こしとAI添削を実行する
8. 音声を認識できない場合はデモ文ではなく認識不可メッセージを返す
9. `transcripts` と `feedbacks` に結果を保存する
10. `word_usage` によく使う単語と言い換えアドバイスを保存する

### create-speaking-draft

`backend/supabase/functions/create-speaking-draft` は録音前の補助機能です。

1. Flutter から日本語の「言いたいこと」と学習言語を受け取る
2. Supabase Auth のユーザーを確認する
3. OpenAIで学習言語の短い練習文を作成する
4. Flutter に `{ draft }` を返す
5. 下書きはDBやStorageには保存しない

Flutter 側でもプラン・ログイン状態のガードを行いますが、直接APIを呼ばれても守れるように Edge Function 側でも認証と回数制限を行います。

## デプロイ準備

Supabase CLI を直接入れていない場合は `npx supabase@latest` を使います。

```powershell
cd C:\flutter\talkLog\backend
npx supabase@latest login
npx supabase@latest functions deploy analyze-recording --project-ref YOUR_PROJECT_REF
npx supabase@latest functions deploy create-speaking-draft --project-ref YOUR_PROJECT_REF
```

`YOUR_PROJECT_REF` は Supabase Project URL の `https://xxxx.supabase.co` の `xxxx` 部分です。


### talkLogプロジェクトへの再デプロイ例

例文作成が「練習文を作成できませんでした」になる場合、`create-speaking-draft` が未デプロイの可能性があります。現在のSupabase Project Refでは以下を実行します。

```powershell
cd C:\flutter\talkLog\backend
npx supabase@latest functions deploy create-speaking-draft --project-ref ddergburfzoymnpynlee
```
## OpenAI APIキーの登録

OpenAI APIキーは Flutter アプリや Git 管理ファイルには書かず、Supabase Secrets に登録します。

```powershell
npx supabase@latest secrets set OPENAI_API_KEY=YOUR_OPENAI_API_KEY --project-ref YOUR_PROJECT_REF
```

任意でモデルを差し替えられます。

```powershell
npx supabase@latest secrets set OPENAI_TRANSCRIPTION_MODEL=gpt-4o-mini-transcribe --project-ref YOUR_PROJECT_REF
npx supabase@latest secrets set OPENAI_FEEDBACK_MODEL=gpt-4.1-mini --project-ref YOUR_PROJECT_REF
npx supabase@latest secrets set OPENAI_WORD_ADVICE_MODEL=gpt-4.1-mini --project-ref YOUR_PROJECT_REF
npx supabase@latest secrets set OPENAI_TEXT_MODEL=gpt-4.1-mini --project-ref YOUR_PROJECT_REF
```

未設定の場合は以下を使います。

| Secret | 既定値 | 用途 |
|---|---|---|
| `OPENAI_TRANSCRIPTION_MODEL` | `gpt-4o-mini-transcribe` | 音声文字起こし |
| `OPENAI_FEEDBACK_MODEL` | `gpt-4.1-mini` | 添削JSON生成 |
| `OPENAI_WORD_ADVICE_MODEL` | `OPENAI_FEEDBACK_MODEL` と同じ | 単語ランキングの言い換え生成 |
| `OPENAI_TEXT_MODEL` | `gpt-4.1-mini` | 録音前の練習文作成 |

## Flutter 側の確認

録音前の補助機能は、録音画面で日本語の「言いたいこと」を入力し、学習言語の練習文を作成します。作成した練習文は画面上の読み上げメモとして表示され、録音中に見ながら話せます。このメモは保存しません。

AI添削は、録音履歴の詳細を開き、`AI添削を見る` を押します。

- `FREE`: 1日5回まで実行できる
- `PREMIUM` / `TESTER` / `ADMIN`: 回数制限なしで実行できる
- 回数上限に達した場合: 本日の回数上限に達した旨のシンプルなメッセージを表示する

Supabase 側では以下を確認します。

- `transcripts` に文字起こし結果が入る
- `feedbacks` に添削結果、自然表現、日本語訳、メモ、スコアが入る
- `word_usage` に単語ランキング用データが入る

## 403 / 429 が返る場合

`403` の場合はログイン状態や対象録音の所有者を確認します。

`429` の場合は、`FREE` ユーザーが本日の無料AI添削回数を使い切っています。

対象ユーザーの権限を確認するSQL:

```sql
select id, email, role
from public.profiles
order by updated_at desc;
```

管理者にする例:

```sql
update public.profiles
set role = 'ADMIN'
where email = 'YOUR_EMAIL@example.com';
```

## 実装メモ

OpenAI文字起こしは `audio/transcriptions` に音声ファイルを `multipart/form-data` で送ります。

AI添削は Responses API に transcript と学習言語を渡し、JSON schema で以下の形に固定しています。

```json
{
  "correctedText": "...",
  "naturalExpression": "...",
  "translation": "...",
  "grammarNotes": ["..."],
  "vocabularyNotes": ["..."],
  "score": 82,
  "encouragement": "..."
}
```

Flutter には Edge Function から以下の形で返します。

```json
{
  "source": "openai",
  "result": {
    "transcript": "...",
    "correctedText": "...",
    "naturalExpression": "...",
    "translation": "...",
    "grammarNotes": ["..."],
    "vocabularyNotes": ["..."],
    "score": 82,
    "encouragement": "..."
  }
}
```

## 注意

`analyze-recording` は Storage の `recordings` bucket に保存済みの音声を使います。先に録音履歴をクラウド同期して、`recordings.audio_path` と Storage ファイルが存在している必要があります。

`create-speaking-draft` は録音前の一時メモを作るだけなので、DBテーブルやStorageへの保存は行いません。
