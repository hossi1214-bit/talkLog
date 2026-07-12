# iOS / TestFlight Release Guide with Codemagic

Windows環境でも、CodemagicのmacOSビルド環境を使えば iOS のビルド確認や TestFlight 向けIPA作成まで進められます。

このリポジトリの `codemagic.yaml` は、現在は安全版です。TestFlightへ自動アップロードせず、`flutter build ios --release --no-codesign` でiOSビルド確認だけを行います。

## 現在完了していること

- Flutter iOSプロジェクト作成済み
- iOS表示名を `TalkLog` に設定
- マイク利用説明を設定済み
- URL Scheme `talklog` を設定済み
- iOS LaunchScreen 設定あり
- AppIcon アセット枠あり
- Codemagic安全版ワークフロー `ios-build-check` あり
- Supabase接続値は `--dart-define` で渡す構成

## まだ必要なもの

| 項目 | 担当 | 状態 |
|---|---|---|
| Apple Developer Program登録 | ユーザー | 必要 |
| App Store Connectでアプリ作成 | ユーザー | 必要 |
| 本番Bundle ID決定 | ユーザー | 必要 |
| Xcode/Codemagic側のBundle ID反映 | 開発 | Bundle ID決定後 |
| App Store Connect API Key作成 | ユーザー | 必要 |
| CodemagicにGitHub連携 | ユーザー | 必要 |
| Codemagic環境変数登録 | ユーザー | 必要 |
| Codemagic iOS code signing設定 | ユーザー | 必要 |
| TestFlightアップロード用workflow追加 | 開発 | 署名準備後 |

## 1. Bundle IDを決める

現在のBundle IDはFlutter初期値です。

```text
com.example.talklog
```

このままではApp Store向けには使わない方がよいです。Apple Developerで使う独自IDを決めてください。

例:

```text
jp.hossi1214.talklog
```

Bundle IDはApp Store Connectに登録後、気軽に変更できません。決めたら以下へ反映します。

- `app/ios/Runner.xcodeproj/project.pbxproj`
- App Store ConnectのBundle ID
- Codemagicの署名設定

## 2. App Store Connectでアプリを作る

App Store Connectで新規アプリを作成します。

入力する主な項目:

- アプリ名: `TalkLog`
- プライマリ言語: 日本語
- Bundle ID: 手順1で決めたID
- SKU: 例 `talklog-ios`
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
| `IOS_BUNDLE_ID` | 本番Bundle ID | いいえ |

## 5. 現在のCodemagic workflow

現在のworkflowは安全版です。

```yaml
ios-build-check
```

実行内容:

- Flutter / Xcode バージョン確認
- `flutter pub get`
- `flutter analyze`
- `flutter test`
- `flutter build ios --release --no-codesign`

このworkflowはTestFlightへアップロードしません。署名設定前でもiOSビルドが通るか確認するためのものです。

## 6. TestFlightへ進む直前に追加すること

Bundle ID、App Store Connect API Key、Codemagic署名設定が完了したら、次にTestFlightアップロード用workflowを追加します。

追加予定の処理:

- App Store配布用の証明書とProvisioning Profile取得
- `flutter build ipa --release`
- IPAを成果物として保存
- 必要に応じてTestFlightへアップロード

自動アップロードを有効にすると、workflow実行時にApp Store Connectへ送信されます。最初は「IPA作成まで」にして、成功確認後にTestFlightアップロードを有効にするのが安全です。

## 7. 初回TestFlight前のApp Store Connect設定

TestFlight配信前に最低限確認する項目です。

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

Codemagic側では `ios-build-check` を手動実行してください。

## 9. 次にユーザー側でやること

1. Apple Developer Programに登録する
2. 本番Bundle IDを決める
3. App Store ConnectでTalkLogアプリを作る
4. App Store Connect API Keyを作る
5. CodemagicにGitHubリポジトリを接続する
6. Codemagicの `talklog_app` グループへ環境変数を登録する
7. Codemagicで `ios-build-check` を実行する

ここまで終わったら、次に署名付きIPA作成workflowを追加できます。
