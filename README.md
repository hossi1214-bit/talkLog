# TalkLog

TalkLog は、録音したスピーキング練習を保存し、履歴・学習進捗・AI添削につなげる Flutter アプリです。

## 実装済み

- メール登録 / メールログイン / ログアウト
- ログイン状態の保持
- 未ログイン時は設定画面のみ利用可能
- ユーザー権限 `FREE / PREMIUM / TESTER / ADMIN`
- `profiles.role` による有料機能制御
- 録音、再生、履歴保存
- 履歴削除前の確認、複数削除
- 学習言語の変更
- Supabase Storage / Table への録音同期
- クラウド履歴の取り込み
- Supabase Edge Functions 経由のAI添削
- OpenAI APIキー設定後の文字起こし・添削処理
- Edge Function 側の権限チェック
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
既存DBへ権限設計だけ追加する場合は `docs/supabase_migration_user_roles.sql` を実行します。
容量メーターをSupabase保存容量ベースで使う場合は `docs/supabase_migration_recording_audio_size.sql` も実行します。

### 権限

| role | 説明 | 有料機能 |
|---|---|---|
| `FREE` | 無料ユーザー | 利用不可 |
| `PREMIUM` | 有料ユーザー | 利用可 |
| `TESTER` | βテスター | 利用可 |
| `ADMIN` | 管理者 | 利用可 |

`ADMIN` / `TESTER` / `PREMIUM` の付与はアプリからは行いません。Supabase Dashboard または service-role を使う管理者専用処理で変更します。

自分を管理者にする例:

```sql
update public.profiles
set role = 'ADMIN'
where email = 'YOUR_EMAIL@example.com';
```

## Edge Function デプロイ

Supabase CLI を直接入れていない場合は `npx supabase@latest` を使います。

```powershell
cd C:\flutter\talkLog\backend\supabase
npx supabase@latest link --project-ref YOUR_PROJECT_REF
npx supabase@latest functions deploy analyze-recording
```

OpenAI を使う場合は Supabase Secrets に APIキーを登録します。

```powershell
npx supabase@latest secrets set OPENAI_API_KEY=YOUR_OPENAI_API_KEY
```

## Android リリース

内部テスト用 AAB の作成手順は以下を参照してください。

- `docs/android_release.md`

## 検証コマンド

```powershell
cd C:\flutter\talkLog\app
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```
