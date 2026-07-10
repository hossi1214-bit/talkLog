# Supabase Setup

TalkLog の Supabase 準備メモです。

## 1. Supabase プロジェクトで行うこと

1. Supabase プロジェクトを作成する。
2. SQL Editor で `docs/supabase_schema.sql` を実行する。
3. 既存DBに権限設計を追加する場合は `docs/supabase_migration_user_roles.sql` を実行する。
4. 既存DBで容量メーターを使う場合は `docs/supabase_migration_recording_audio_size.sql` を実行する。
5. Storage に `recordings` bucket が作られていることを確認する。
6. Authentication でメールログインを利用できるようにする。

現在の Flutter 側は、未ログイン時は設定画面のみ利用できます。録音・履歴・単語帳・進捗はメールログイン後に利用します。

## 2. Flutter に渡す値

Supabase の Project Settings から以下を確認します。

- Project URL
- anon public key

Flutter 実行時に `--dart-define` で渡します。

```powershell
flutter run `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR_ANON_PUBLIC_KEY
```

APIキーを Dart ファイルへ直接書かないでください。

## 3. 権限設計

`profiles.role` でアカウント権限を管理します。

| role | 説明 | AI添削などの有料機能 |
|---|---|---|
| `FREE` | 無料ユーザー | 利用不可 |
| `PREMIUM` | 有料ユーザー | 利用可 |
| `TESTER` | βテスター | 利用可 |
| `ADMIN` | 管理者 | 利用可 |

通常ユーザーは自分の `role` を更新できません。`ADMIN` や `TESTER` の付与は Supabase Dashboard、または service-role を使う管理者専用APIで行います。

自分を `ADMIN` にする例:

```sql
update public.profiles
set role = 'ADMIN'
where email = 'YOUR_EMAIL@example.com';
```

## 4. 接続準備済みのFlutterファイル

- `lib/core/config/supabase_config.dart`
  - `SUPABASE_URL` と `SUPABASE_ANON_KEY` を読みます。
- `lib/core/services/supabase_service.dart`
  - 値が設定されている時だけ `Supabase.initialize()` を実行します。
- `lib/core/services/auth_session_service.dart`
  - ログイン状態と `profiles.role` を保持します。
- `lib/features/recording/repositories/recording_repository.dart`
  - 録音メタデータ保存・削除を行います。
- `lib/features/correction/repositories/correction_repository.dart`
  - 文字起こし・AI添削結果保存を行います。

## 5. Storage パス規約

音声ファイルは以下の形式で保存します。

```text
{user_id}/{year}/{month}/{recording_id}.m4a
```

例:

```text
0d3f...a92/2026/07/recording-id.m4a
```

Storage RLS は、パス先頭の `{user_id}` が `auth.uid()` と一致する場合のみ操作可能にしています。

## 6. 録音同期の確認

メールログイン後に新しく録音すると、以下が実行されます。

1. 音声ファイルをローカル保存
2. Supabase Storage の `recordings` bucket へアップロード
3. `recordings` テーブルへメタデータ保存

設定画面の `録音履歴をクラウドと同期` を押すと、クラウド同期を再実行します。

## 7. AI添削結果同期の確認

`PREMIUM` / `TESTER` / `ADMIN` のユーザーで履歴詳細から `AI添削を見る` を開くと、Edge Function 経由でAI添削を実行します。

保存先:

- `transcripts`
- `feedbacks`
- `word_usage`

`FREE` ユーザーの場合は有料機能の案内が表示され、Edge Function 側でも `403` で拒否されます。
