# iOS / TestFlight Release Guide with Codemagic

Windows環境でも、CodemagicのmacOSビルド環境を使えば、iOSのビルド確認やTestFlight向けIPA作成まで進められます。

このリポジトリの `codemagic.yaml` には、安全確認用の `ios-build-check` と、署名付きIPA作成・App Store Connectアップロード用の `ios-testflight-build` を用意しています。

## 現在完了していること

- Flutter iOSプロジェクト作成済み
- iOS表示名を `My TalkLog` に設定済み
- マイク利用説明を設定済み
- URL Scheme `talklog` を設定済み
- iOS LaunchScreen 設定あり
- AppIcon アセット枠あり
- Codemagic安全版ワークフロー `ios-build-check` あり
- Supabase接続値は `--dart-define` で渡す構成
- 本番Bundle IDを `jp.hossi1214.talklog` に決定済み
- iOSプロジェクトの `PRODUCT_BUNDLE_IDENTIFIER` を `jp.hossi1214.talklog` に反映済み
- TestFlight向けワークフロー `ios-testflight-build` あり

## まだ必要なもの

| 項目 | 担当 | 状態 |
|---|---|---|
| Apple Developer Program登録 | ユーザー | 完了 |
| App Store Connectでアプリ作成 | ユーザー | 完了: `My TalkLog` |
| 本番Bundle ID決定 | ユーザー | 完了: `jp.hossi1214.talklog` |
| Xcode/Codemagic側のBundle ID反映 | 開発 | iOSプロジェクト反映済み |
| App Store Connect API Key作成 | ユーザー | 完了 |
| CodemagicにGitHub連携 | ユーザー | 完了 |
| Codemagic環境変数登録 | ユーザー | 完了 |
| Codemagic iOS code signing設定 | ユーザー | 初回 `ios-testflight-build` で確認 |
| TestFlightアップロード用workflow追加 | 開発 | 完了: `ios-testflight-build` |

## 1. Bundle ID

決定済みのBundle IDです。

```text
jp.hossi1214.talklog
```

App Store Connect登録後は気軽に変更できません。以下のすべてで同じ値を使います。

- `app/ios/Runner.xcodeproj/project.pbxproj` 反映済み
- Apple DeveloperのIdentifiers
- App Store ConnectのBundle ID
- Codemagicの署名設定
- Codemagic環境変数 `IOS_BUNDLE_ID`

変更前のFlutter初期値は以下です。

```text
com.example.talklog
```

## 2. App Store Connectでアプリを作る

App Store Connectで新規アプリを作成します。

入力する主な項目:

- アプリ名: `My TalkLog`
- プライマリ言語: 日本語
- Bundle ID: `jp.hossi1214.talklog`
- SKU: `talklog-ios`
- ユーザーアクセス: フルアクセス

## 3. App Store Connect API Keyを作る

CodemagicからTestFlightへアップロードするためにAPI Keyを作ります。

1. App Store Connectを開く
2. `ユーザーとアクセス` を開く
3. `統合` または `App Store Connect API` を開く
4. `+` からAPI Keyを作成
5. 権限は `App Manager` を選ぶ
6. `.p8` ファイルをダウンロード
7. 以下を控える
   - Issuer ID
   - Key ID
   - `.p8` ファイル内容

`.p8` は一度しかダウンロードできません。安全な場所に保管してください。

## 4. Codemagicに登録する環境変数

CodemagicのEnvironment variablesに以下を登録します。グループ名は現在の `codemagic.yaml` に合わせて `talklog_app` にしてください。

| Variable | 内容 | Secret推奨 |
|---|---|---|
| `SUPABASE_URL` | Supabase Project URL | いいえ |
| `SUPABASE_ANON_KEY` | Supabase anon key | はい |
| `APP_STORE_CONNECT_PRIVATE_KEY` | `.p8` の中身 | はい |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID | はい |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | はい |
| `IOS_BUNDLE_ID` | `jp.hossi1214.talklog` | いいえ |

## 5. 現在のCodemagic workflow

現在のworkflowは2つあります。

```yaml
ios-build-check
ios-testflight-build
```

`ios-build-check` の実行内容:

- Flutter / Xcode バージョン確認
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build ios --release --no-codesign`

このworkflowはTestFlightへアップロードしません。署名設定前でもiOSビルドが通るか確認するためのものです。

`ios-testflight-build` の実行内容:

- Flutter / Xcode バージョン確認
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `xcode-project use-profiles`
- `flutter build ipa --release`
- App Store Connectへアップロード

## 6. TestFlightへ進む直前に確認すること

`ios-testflight-build` は追加済みです。初回実行で署名エラーが出る場合は、CodemagicのDeveloper Portal連携、App Store配布用証明書、Provisioning Profileの取得状態を確認してください。

成功すると、署名付きIPAが成果物として保存され、App Store Connectへアップロードされます。

## 7. 初回TestFlight前のApp Store Connect設定

- アプリ名
- Bundle ID
- SKU
- カテゴリ
- 年齢制限
- プライバシーポリシーURL
- App Privacy
- 暗号化に関する質問
- テスターグループ
- テスト情報
- スクリーンショット

## 8. ローカルでできる確認

WindowsではiOS実機ビルドや署名済みIPA作成はできませんが、Flutter側の基本確認はできます。

```powershell
cd C:\flutter\talkLog\app
flutter analyze
flutter test
```

Codemagic側では、まず `ios-build-check`、次に `ios-testflight-build` を手動実行してください。

## 9. 次にユーザー側でやること

1. Codemagicで `ios-testflight-build` を実行する
2. 署名エラーが出た場合は、CodemagicのiOS code signing設定を確認する
3. App Store ConnectのTestFlight画面でビルド処理完了を待つ
4. 内部テスターに配信する
