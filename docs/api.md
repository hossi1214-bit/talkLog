\# API.md



\# TalkLog API設計書



\## 目的



このドキュメントは、TalkLogで使用するAPI・外部連携・データ通信仕様を定義する。



TalkLogでは主に以下を利用する。



\- Supabase

\- Supabase Storage

\- Supabase Edge Functions

\- Dify

\- Speech-to-Text

\- LLMフィードバック



\---



\# 全体構成



```text

Flutter App

↓

Supabase Auth

↓

Supabase Database

↓

Supabase Storage

↓

Supabase Edge Functions

↓

Dify API

↓

LLM / Speech-to-Text


## Supabase Edge Functions

### analyze-recording

録音IDを受け取り、文字起こし・AI添削結果を返します。`OPENAI_API_KEY` が Supabase Secrets にある場合はOpenAIで本番解析し、ない場合はデモ結果を返します。

Request:

```json
{
  "recordingId": "uuid",
  "language": "英語"
}
```

Response:

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

Flutter 側は Edge Function が利用できない場合、アプリ内のデモ添削へフォールバックします。