# iOS / TestFlight Release Guide with Codemagic

Codemagic を使えば、Windows環境でもクラウド上のmacOSビルドマシンで iOS IPA を作成し、TestFlight へアップロードできます。

## 1. 必要なもの

- Apple Developer Program 登録済みアカウント
- App Store Connect に作成済みの talkLog アプリ
- iOS Bundle ID
- App Store Connect API Key
- Codemagic アカウント
- GitHub の `hossi1214-bit/talkLog` リポジトリ連携
- Supabase の `SUPABASE_URL`
- Supabase の `SUPABASE_ANON_KEY`

## 2. Bundle ID

現在の iOS Bundle ID は以下です。

```text
com.example.talklog
```

TestFlight / App Store に出す前に、独自のIDへ変更してください。

例:

```text
jp.yourname.talklog
```

一度 App Store Connect に登録した Bundle ID は後から気軽に変更できないため、最初に決めてください。

## 3. App Store Connect API Key を作成

1. App Store Connect を開く
2. `ユーザーとアクセス` を開く
3. `統合` -> `App Store Connect API` を開く
4. `+` からAPI Keyを作成
5. 権限は `App Manager` を選択
6. `.p8` ファイルをダウンロード
7. 以下を控える
   - Issuer ID
   - Key ID
   - `.p8` ファイル

`.p8` は一度しかダウンロードできません。安全な場所に保存してください。

## 4. Codemagic にGitHubリポジトリを追加

1. Codemagic にログイン
2. `Add application` を選択
3. GitHub を連携
4. `hossi1214-bit/talkLog` を選択
5. Flutter app として追加

## 5. Codemagic の環境変数

Codemagic の Environment variables に以下を設定します。

| Variable | 値 | Secret |
|---|---|---|
| `SUPABASE_URL` | Supabase Project URL | 任意 |
| `SUPABASE_ANON_KEY` | Supabase anon key | Secret推奨 |
| `APP_STORE_CONNECT_PRIVATE_KEY` | `.p8` の中身 | Secret |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID | Secret |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | Secret |

Codemagic の Apple Developer Portal integration を使う場合は、API KeyをIntegrationとして保存し、`codemagic.yaml` から integration 名を参照できます。

## 6. iOS Code Signing

Codemagicでは App Store Connect API Key を使って、必要な証明書と Provisioning Profile を自動取得・作成できます。

必要な署名タイプ:

```text
IOS_APP_STORE
```

## 7. codemagic.yaml を追加する場合

リポジトリに `codemagic.yaml` を追加すると、Codemagic上で以下を自動化できます。

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- iOS code signing
- `flutter build ipa`
- TestFlight へのアップロード

ただし、自動アップロード設定を有効にすると、条件次第でビルド成果物がApp Store Connectへ送信されます。追加前に運用方針を決めてください。

## 8. 初回TestFlight前に必要なApp Store Connect設定

- アプリ名
- Bundle ID
- SKU
- カテゴリ
- 年齢制限
- プライバシーポリシーURL
- App Privacy
- 暗号化に関する質問
- スクリーンショット
- テスターグループ

## 9. 現在の未完了項目

- 独自Bundle IDの決定
- App Store Connectアプリ作成
- App Store Connect API Key作成
- Codemagicリポジトリ連携
- Codemagic環境変数登録
- `codemagic.yaml` の追加判断
- iOS TestFlight初回アップロード
## 10. 現在のcodemagic.yaml

このリポジトリの `codemagic.yaml` は安全版です。

- ワークフロー名: `ios-build-check`
- 実行方法: Codemagic画面から手動実行
- 実行内容: `flutter pub get` / `flutter analyze` / `flutter test` / `flutter build ios --release --no-codesign`
- TestFlight自動アップロード: 無効
- App Store Connect publishing: 未設定

TestFlightへ自動アップロードする場合は、Bundle ID、App Store Connect API Key、iOS code signing の準備後に publishing 設定を追加します。
