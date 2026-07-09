# Android Release Guide

TalkLog を Google Play の内部テストへ出すための Android リリース手順です。

## 1. 前提

- Supabase schema / migration が本番プロジェクトへ適用済み
- `analyze-recording` Edge Function が再デプロイ済み
- `OPENAI_API_KEY` が Supabase Secrets に設定済み
- Google Play Console のアプリを作成済み

## 2. アプリIDの確認

現在の `applicationId` は以下です。

```text
com.example.talklog
```

本番公開前には、Google Play で使う一意のIDへ変更してください。例:

```text
jp.yourname.talklog
```

一度 Google Play に登録した `applicationId` は後から変更できません。

## 3. Upload Keystore を作成

PowerShell で以下を実行します。

```powershell
cd C:\flutter\talkLog\app\android
keytool -genkey -v `
  -keystore upload-keystore.jks `
  -storetype JKS `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -alias upload
```

入力したパスワードは必ず安全な場所に保管してください。紛失すると同じ署名で更新版を出せません。

## 4. key.properties を作成

`app/android/key.properties.example` を `app/android/key.properties` にコピーし、実際の値を入れます。

```properties
storePassword=あなたのstorePassword
keyPassword=あなたのkeyPassword
keyAlias=upload
storeFile=../upload-keystore.jks
```

`key.properties` と `upload-keystore.jks` は `.gitignore` で除外されています。GitHub へ上げないでください。

## 5. 内部テスト用 AAB を作成

key.properties が未作成の場合でもビルド確認用の AAB は作成できますが、Google Play へアップロードする内部テスト版は必ず Upload Keystore で署名してください。

```powershell
cd C:\flutter\talkLog\app
flutter build appbundle --release `
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co `
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

このコマンドは Supabase の接続情報をアプリに埋め込むため、リリース時は必ず実際の SUPABASE_URL と SUPABASE_ANON_KEY を指定します。

生成先:

```text
C:\flutter\talkLog\app\build\app\outputs\bundle\release\app-release.aab
```

## 6. Google Play Console にアップロード

1. Google Play Console を開く
2. 対象アプリを選択
3. `テストとリリース` → `テスト` → `内部テスト`
4. 新しいリリースを作成
5. `app-release.aab` をアップロード
6. リリースノートを入力
7. 内部テストとして公開

## 7. 内部テストで確認すること

- メール登録 / ログイン / ログアウト
- 再起動後のログイン維持
- 録音 / 再生 / 履歴保存 / 削除
- `FREE` で AI添削が制限されること
- `ADMIN` / `PREMIUM` / `TESTER` で AI添削が利用できること
- Supabase `recordings`, `transcripts`, `feedbacks`, `word_usage` の保存
