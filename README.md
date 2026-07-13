# TalkLog

TalkLogは、録音したスピーキング練習を保存し、履歴・学習進捗・AI添削につなげるFlutterアプリです。

## 実装済み

- メール登録 / メールログイン / ログアウト
- パスワード再設定メール送信
- ログイン状態の保持
- 未ログイン時は設定画面のみ利用可能
- ユーザー権限 `FREE / PREMIUM / TESTER / ADMIN`
- `profiles.role` によるプラン制御
- 録音、録音キャンセル、再生、履歴保存
- 録音中に見られる一時的な読み上げメモ作成
- 日本語で言いたいことを入力し、設定言語の練習文へ変換
- 録音履歴の新しい順表示
- 履歴削除前の確認、複数削除
- 学習言語の変更
- 言語別の録音・単語帳・ランキング管理
- Supabase Storage / Table への録音同期
- クラウド履歴の取得
- Supabase Edge Functions 経由のAI添削
- OpenAI APIキー設定後の文字起こし・添削処理
- 音声を認識できない場合のエラー表示
- 保存済みAI添削結果の再表示
- 添削メモから単語帳への追加
- 単語帳一覧と復習済みチェック
- 文字起こしテキスト由来のよく使う単語ランキング
- 単語ランキングの言い換えアドバイス
- 録音履歴の検索・言語フィルタ・添削済みフィルタ
- 録音詳細のクラウド同期状態・添削状態表示
- 学習進捗の集計、連続日数、過去7日グラフ
- Supabase保存容量ベースの音声ストレージメーター
- Premium案内画面とFree / Premium比較表
- スプラッシュ画像、録音中画像、Premium画像の表示
- 設定画面のクラウド同期

## プラン仕様

| 項目 | FREE | PREMIUM / TESTER / ADMIN |
|---|---:|---:|
| AI添削 | 1日5回 | 無制限 |
| AI翻訳 | 制限あり | 無制限 |
| 音声保存 | 200MB | 無制限相当 |
| 添削履歴 | 利用可 | 利用可 |
| 単語ランキング | 利用可 | 利用可 |
| 広告 | 将来リワード広告予定 | なし予定 |

FREEのAI添削回数はSupabase側の `feedbacks` / `recordings` を日本時間の日次範囲で集計します。同じアカウントであれば、ログアウト、再ログイン、別端末でも使用回数は引き継がれます。

Premium登録ボタンと比較表は実装済みですが、Google Play Billing / App Store課金との接続は未実装です。

## Flutter実行

```powershell
cd C:\flutter\talkLog\app
flutter run `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

## Supabase

初回はSupabase SQL Editorで `docs/supabase_schema.sql` を実行します。既存DBへ追加する場合は、各migrationファイルを必要に応じて実行します。

主なmigration:

- `docs/supabase_migration_user_roles.sql`
- `docs/supabase_migration_recording_audio_size.sql`
- `docs/supabase_migration_word_usage.sql`
- `docs/supabase_migration_vocabulary_review.sql`

### 権限

| role | 説明 | 有料機能 |
|---|---|---|
| `FREE` | 無料ユーザー | 制限付き |
| `PREMIUM` | 有料ユーザー | 利用可 |
| `TESTER` | βテスター | 利用可 |
| `ADMIN` | 管理者 | 利用可 |

`ADMIN` / `TESTER` / `PREMIUM` の付与はアプリからは行いません。Supabase Dashboardまたはservice-roleを使う管理者処理で変更します。

自分を管理者にする例:

```sql
update public.profiles
set role = 'ADMIN'
where email = 'YOUR_EMAIL@example.com';
```

## Edge Functionデプロイ

Supabase CLIを直接入れていない場合は `npx supabase@latest` を使います。

```powershell
cd C:\flutter\talkLog\backend
npx supabase@latest functions deploy analyze-recording --project-ref YOUR_PROJECT_REF
npx supabase@latest functions deploy create-speaking-draft --project-ref YOUR_PROJECT_REF
```

OpenAIを使う場合はSupabase SecretsにAPIキーを登録します。

```powershell
npx supabase@latest secrets set OPENAI_API_KEY=YOUR_OPENAI_API_KEY --project-ref YOUR_PROJECT_REF
```

## 実機テスト

実機テストケース:

- `docs/device_test_cases.csv`

ログイン、録音、録音キャンセル、履歴、AI添削、Free回数制限、Premium案内、容量メーター、クラウド同期、実機インストール確認を含みます。

## Androidリリース

内部テスト用AABの作成手順:

- `docs/android_release.md`

## iOS / TestFlight

Codemagicを使ったiOS/TestFlight準備手順:

- `docs/ios_testflight_codemagic.md`
- `docs/ios_release_todo.md`

App Store掲載・審査準備:

- `docs/app_store_metadata.md`
- `docs/app_privacy_answers.md`
- `docs/privacy_policy_draft.md`
- `docs/testflight_review_notes.md`

## 検証コマンド

```powershell
cd C:\flutter\talkLog\app
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
```
