# Supabase Setup

TalkLog の Phase 5 用 Supabase 準備メモです。

## 1. Supabase プロジェクトで行うこと

1. Supabase プロジェクトを作成する。
2. SQL Editor で `docs/supabase_schema.sql` を実行する。
3. Storage に `recordings` bucket が作られていることを確認する。
4. Authentication のログイン方式を決める。

現時点の Flutter 側は、Supabase 未設定でもローカル保存で動きます。

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

## 3. 接続準備済みのFlutterファイル

- `lib/core/config/supabase_config.dart`
  - `SUPABASE_URL` と `SUPABASE_ANON_KEY` を読みます。
- `lib/core/services/supabase_service.dart`
  - 値が設定されている時だけ `Supabase.initialize()` を実行します。
- `lib/features/recording/repositories/recording_repository.dart`
  - 録音メタデータ保存・削除のRepository骨組みです。
- `lib/features/correction/repositories/correction_repository.dart`
  - 文字起こし・AI添削結果保存のRepository骨組みです。

## 4. 次に実装すること

Phase 5B で以下を実装します。

- ログイン画面または匿名ログイン
- ローカル録音ファイルを Supabase Storage にアップロード
- `recordings.audio_path` にStorageパスを保存
- AI添削結果を `transcripts` / `feedbacks` に保存
- ローカル履歴とクラウド履歴の同期

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

## 6. 匿名ログインを有効にする

Phase 5 の最初は匿名ログインで `auth.uid()` を作ります。

Supabase Dashboard で以下を確認してください。

1. `Authentication`
2. `Sign In / Providers`
3. `Anonymous sign-ins` を有効化

有効化されていない場合、アプリの設定画面に「匿名ログインに失敗しました」と表示されます。

匿名ログインが成功すると、設定画面の `クラウド同期` に `匿名ログイン中 / ID: xxxxxxxx` のように表示されます。
## 7. 録音同期の確認

匿名ログインが成功した状態で新しく録音すると、以下が実行されます。

1. 音声ファイルをローカル保存
2. Supabase Storage の `recordings` bucket へアップロード
3. `recordings` テーブルへメタデータ保存

設定画面の `ローカル履歴を同期` を押すと、ローカルに残っている履歴の再同期を試します。

注意: 古いローカル履歴はIDがUUIDではない場合があるため、クラウド同期対象外になることがあります。新規録音はUUIDで作成されます。

## 8. AI添削結果同期の確認

履歴詳細から `AI添削を見る` を開くと、ダミー添削結果が表示され、可能であれば以下へ保存されます。

- `transcripts`
- `feedbacks`

対象の録音がまだ `recordings` に存在しない場合、クラウド保存はスキップされますが、画面表示は継続します。