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
| 本番Bundle ID | 未確定 | ユーザー決定待ち |
| App Store Connectアプリ | 未確認 | ユーザー作成待ち |
| Codemagic署名設定 | 未確認 | ユーザー設定待ち |

## ユーザー側で必要な準備

1. Apple Developer Programへ登録する
2. 本番Bundle IDを決める
3. App Store ConnectでTalkLogアプリを作成する
4. App Store Connect API Keyを作成する
5. CodemagicにGitHubリポジトリを接続する
6. Codemagicの環境変数グループ `talklog_app` を作る
7. `SUPABASE_URL` と `SUPABASE_ANON_KEY` を登録する
8. App Store Connect API Key関連の値をCodemagicに登録する
9. CodemagicでiOS code signingを設定する
10. `ios-build-check` を実行する

## 開発側で次にやること

本番Bundle IDが決まった後に以下を行います。

1. `PRODUCT_BUNDLE_IDENTIFIER` を本番Bundle IDへ変更する
2. 必要ならアプリ名・SKU・バージョンを調整する
3. Codemagicの署名付きIPA作成workflowを追加する
4. CodemagicでIPA作成を確認する
5. 成功後、TestFlightアップロードを有効にする

## Bundle ID候補

例です。Apple Developer側で使えるか確認してから決定してください。

```text
jp.hossi1214.talklog
```

現在の初期値:

```text
com.example.talklog
```

`com.example.talklog` はリリース用には変更推奨です。
