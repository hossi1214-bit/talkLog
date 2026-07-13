# iOS Release TODO

My TalkLogをTestFlightへ出すまでのTODOです。

## 現在の状態

| 項目 | 状態 | 備考 |
|---|---|---|
| iOSプロジェクト | 完了 | `app/ios` 作成済み |
| アプリ表示名 | 完了 | `My TalkLog` |
| マイク利用説明 | 完了 | 日本語文言に設定済み |
| URL Scheme | 完了 | `talklog` |
| LaunchScreen | 完了 | iOS側設定あり |
| AppIcon枠 | 完了 | アセット定義あり |
| Codemagic安全版 | 完了 | `ios-build-check` |
| TestFlight自動アップロード | 準備完了 | `ios-testflight-build` 追加済み |
| 本番Bundle ID | 完了 | `jp.hossi1214.talklog` |
| App Store Connectアプリ | 完了 | `My TalkLog` 作成済み |
| Codemagic署名設定 | 要確認 | 初回 `ios-testflight-build` で確認 |

## ユーザー側で必要な準備

1. Codemagicで `ios-testflight-build` を実行する
2. 署名エラーが出た場合は、CodemagicのiOS code signing設定を確認する
3. IPA作成とApp Store Connectアップロード成功後、App Store ConnectのTestFlightで処理完了を待つ
4. 内部テスターを追加して配信する

## 開発側で次にやること

署名付きIPA作成とApp Store Connectアップロード用の `ios-testflight-build` workflow は追加済みです。

残りはCodemagic側の初回実行結果確認です。署名関連で失敗した場合は、CodemagicのDeveloper Portal連携またはiOS code signing設定を見直します。

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
