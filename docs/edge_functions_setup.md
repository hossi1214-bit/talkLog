# Supabase Edge Functions Setup

TalkLog の音声文字起こし・AI添削は、Flutter から直接 OpenAI API を呼ばず、Supabase Edge Functions 経由で実行します。

## 現在できること

`backend/supabase/functions/analyze-recording` は以下に対応しています。

1. Flutter から録音IDを受け取る
2. Supabase Auth のユーザーを確認する
3. `recordings` テーブルから対象録音を取得する
4. Storage の `recordings` bucket から音声ファイルを取得する
5. `OPENAI_API_KEY` がある場合、OpenAIで文字起こしとAI添削を実行する
6. `OPENAI_API_KEY` がない場合、デモ添削結果を返す
7. `transcripts` と `feedbacks` に結果を保存する

Flutter 側は Edge Function が未デプロイ、未設定、またはエラーの場合、アプリ内のデモ添削へフォールバックします。

## デプロイ準備

Supabase CLI を使える環境で、以下を実行します。

```powershell
cd C:\flutter\talkLog\backend\supabase
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase functions deploy analyze-recording
```

`YOUR_PROJECT_REF` は Supabase Project URL の `https://xxxx.supabase.co` の `xxxx` 部分です。

## OpenAI APIキーの登録

OpenAI APIキーは Flutter アプリや Git 管理ファイルには書かず、Supabase Secrets に登録します。

```powershell
supabase secrets set OPENAI_API_KEY=YOUR_OPENAI_API_KEY
```

任意でモデルを差し替えられます。

```powershell
supabase secrets set OPENAI_TRANSCRIPTION_MODEL=gpt-4o-mini-transcribe
supabase secrets set OPENAI_FEEDBACK_MODEL=gpt-4.1-mini
```

未設定の場合は以下を使います。

| Secret | 既定値 | 用途 |
|---|---|---|
| `OPENAI_TRANSCRIPTION_MODEL` | `gpt-4o-mini-transcribe` | 音声文字起こし |
| `OPENAI_FEEDBACK_MODEL` | `gpt-4.1-mini` | 添削JSON生成 |

## Flutter 側の確認

アプリで録音履歴の詳細を開き、`AI添削を見る` を押します。

- Edge Function + OpenAI が動いた場合: `解析方法: Edge Function`
- Edge Function が未デプロイまたは失敗した場合: `解析方法: デモ添削`

Supabase 側では以下を確認します。

- `transcripts` に文字起こし結果が入る
- `feedbacks` に添削結果、自然表現、日本語訳、メモ、スコアが入る

## 実装メモ

OpenAI文字起こしは `audio/transcriptions` に音声ファイルを `multipart/form-data` で送ります。

AI添削は Responses API に transcript と学習言語を渡し、JSON schema で以下の形に固定しています。

```json
{
  "correctedText": "...",
  "naturalExpression": "...",
  "japaneseTranslation": "...",
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
    "japaneseTranslation": "...",
    "grammarNotes": ["..."],
    "vocabularyNotes": ["..."],
    "score": 82,
    "encouragement": "..."
  }
}
```

## 注意

Edge Function は Storage の `recordings` bucket に保存済みの音声を使います。先に録音履歴をクラウド同期して、`recordings.audio_path` と Storage ファイルが存在している必要があります。