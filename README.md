# TalkLog

TalkLog は、録音したスピーキング練習を保存し、履歴・学習進捗・AI添削につなげる Flutter アプリです。

## 実装済み

- 録音、再生、履歴保存
- 履歴削除前の確認
- 学習言語の変更
- Supabase 匿名ログイン
- Supabase Storage / Table への録音同期
- クラウド履歴の取り込み
- ダミーAI添削
- Supabase Edge Functions 経由のAI添削呼び出し口
- OpenAI APIキー設定後の文字起こし・添削処理
- 保存済みAI添削結果の再表示
- AI添削の再解析
- 語彙メモから単語帳への追加
- 単語帳一覧と復習済みチェック
- 録音履歴の検索・言語フィルタ・添削済みフィルタ
- 録音詳細のクラウド同期状態・添削状態表示
- 学習進捗の集計、連続日数、過去7日グラフ
- 設定のクラウド同期

## Flutter 実行

```powershell
cd C:\flutter\talkLog\app
flutter run `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

## Supabase

初回は Supabase SQL Editor で `docs/supabase_schema.sql` を実行します。

詳細は以下を参照してください。

- `docs/supabase_setup.md`
- `docs/edge_functions_setup.md`
- `docs/api.md`

## Edge Function デプロイ

```powershell
cd C:\flutter\talkLog\backend\supabase
supabase link --project-ref YOUR_PROJECT_REF
supabase functions deploy analyze-recording
```

OpenAI を使う場合は Supabase Secrets に APIキーを登録します。

```powershell
supabase secrets set OPENAI_API_KEY=YOUR_OPENAI_API_KEY
```

APIキーを登録していない場合でも、アプリ内のデモ添削にフォールバックします。

## 検証コマンド

```powershell
cd C:\flutter\talkLog\app
dart format lib test
flutter analyze
flutter test
```