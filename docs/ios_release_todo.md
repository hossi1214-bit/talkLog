# iOS Release TODO

TalkLogをTestFlightへ出すまでのTODOです。

## 現在の状態

| 項目 | 状態 | 備考 |
|---|---|---|
| iOSプロジェクト | 完了 | `app/ios` 作成済み |
| アプリ表示名 | 完了 | `TalkLog` |
| マイク利用説明 | 完了 | 日本語文言に設定済み |
| URL Scheme | 完了 | `talklog` |
| LaunchScreen | 完了 | iOS側設定あり |
| AppIcon枠 | 完了 | アセット定義あり |
| Codemagic安全版 | 完了 | `ios-build-check` |
| TestFlight自動アップロード | 未対応 | 署名準備後に追加 |
| 本番Bundle ID | 完了 | `jp.hossi1214.talklog` |
| App Store Connectアプリ | 未確認 | ユーザー作成待ち |
| Codemagic署名設定 | 未確認 | ユーザー設定待ち |

## ユーザー側で必要な準備

1. Apple Developer Programの承認完了を待つ
2. Apple DeveloperのIdentifiersに `jp.hossi1214.talklog` を登録する
3. App Store ConnectでTalkLogアプリを作成する
4. App Store Connect API Keyを作成する
5. CodemagicにGitHubリポジトリを接続する
6. Codemagicの環境変数グループ `talklog_app` を作る
7. `SUPABASE_URL` と `SUPABASE_ANON_KEY` を登録する
8. App Store Connect API Key関連の値をCodemagicに登録する
9. CodemagicでiOS code signingを設定する
10. `ios-build-check` を実行する

## 開発側で次にやること

本番Bundle IDは `jp.hossi1214.talklog` に決定済みです。iOSプロジェクト側への反映も完了しています。

次に以下を行います。

1. Apple Developer / App Store Connect側で `jp.hossi1214.talklog` が登録できたことを確認する
2. 必要ならアプリ名、SKU、バージョンを調整する
3. Codemagicの署名付きIPA作成workflowを追加する
4. CodemagicでIPA作成を確認する
5. 成功後、TestFlightアップロードを有効にする

## Bundle ID

決定済みのBundle IDです。

```text
jp.hossi1214.talklog
```

変更前のFlutter初期値:

```text
com.example.talklog
```

iOSプロジェクト側は `jp.hossi1214.talklog` へ変更済みです。

## テスター運用メモ

TestFlightテスターのアカウント登録と `TESTER` 権限付与は以下を参照します。

- `docs/tester_account_operations.md`

## GitHub Pages公開候補

GitHub Pagesを `docs/` から公開する場合、App Store Connectには以下を入力できます。

```text
Privacy Policy URL: https://hossi1214-bit.github.io/talkLog/privacy.html
Support URL: https://hossi1214-bit.github.io/talkLog/support.html
```

公開前にGitHubリポジトリの Settings > Pages で、Sourceを `Deploy from a branch`、Branchを `main`、Folderを `/docs` に設定してください。
