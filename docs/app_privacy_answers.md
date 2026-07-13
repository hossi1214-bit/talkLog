# App Privacy Answers Draft

App Store Connect の App Privacy 入力用の下書きです。実際の申請時は、Appleの最新の質問文に合わせて確認してください。

## 基本方針

TalkLogは、ユーザーの録音、文字起こし、添削結果、学習履歴をアカウントに紐づけて保存します。広告トラッキング目的のデータ収集は現時点では行いません。

## Data Linked to the User

以下はユーザーアカウントに紐づくデータです。

| Appleカテゴリ候補 | TalkLogでの内容 | 用途 |
|---|---|---|
| Contact Info | メールアドレス | アカウント作成、ログイン、問い合わせ対応 |
| User ID | Supabase AuthのユーザーID | ユーザー識別、データ同期、アクセス制御 |
| User Content | 録音音声、文字起こし、AI添削結果、単語帳 | 学習履歴、AI添削、再生、復習 |
| Usage Data | AI添削回数、保存容量、学習進捗 | プラン制限、容量表示、進捗表示 |
| Diagnostics | エラー情報、不具合調査情報 | アプリ改善、障害対応 |

## Data Not Used for Tracking

現時点では、他社アプリやWebサイトを横断したトラッキング目的でデータを利用しません。

```text
Do you use this data for tracking purposes? No
```

## Data Collection Details

### Contact Info

| 項目 | 回答案 |
|---|---|
| Email Address | 収集する |
| Linked to user | はい |
| Tracking | いいえ |
| Purpose | App Functionality, Account Management |

### Identifiers

| 項目 | 回答案 |
|---|---|
| User ID | 収集する |
| Linked to user | はい |
| Tracking | いいえ |
| Purpose | App Functionality, Account Management |

### User Content

| 項目 | 回答案 |
|---|---|
| Audio Data | 収集する |
| Other User Content | 文字起こし、添削結果、単語帳を収集する |
| Linked to user | はい |
| Tracking | いいえ |
| Purpose | App Functionality, Product Personalization |

補足:

- 音声はユーザー自身のスピーキング練習として保存する
- 文字起こし・添削結果は学習履歴として表示する
- OpenAI APIへ処理に必要な範囲で送信される

### Usage Data

| 項目 | 回答案 |
|---|---|
| Product Interaction | 収集する可能性あり |
| Linked to user | はい |
| Tracking | いいえ |
| Purpose | App Functionality, Analytics |

TalkLog内の例:

- AI添削回数
- 保存容量
- 録音数
- 学習日数

### Diagnostics

| 項目 | 回答案 |
|---|---|
| Crash Data | 現時点では明示的な外部クラッシュ解析未導入 |
| Performance Data | 現時点では明示的な外部解析未導入 |
| Other Diagnostic Data | 不具合調査のため取得する可能性あり |
| Tracking | いいえ |
| Purpose | App Functionality |

## Sensitive Info

現時点では、Appleが定義するセンシティブ情報を意図的に収集しません。ただし、ユーザーが録音内で個人情報や機微情報を話す可能性はあります。そのため、プライバシーポリシーでは録音内容に個人情報を含めないよう注意喚起することも検討します。

## Location

位置情報は使用しません。

```text
Location: Not collected
```

## Contacts

端末の連絡先は使用しません。

```text
Contacts: Not collected
```

## Purchases

現時点ではApp Store課金未実装です。課金実装後はPurchasesを収集する扱いになる可能性があります。

```text
Purchases: Not collected yet
```

課金実装後の候補:

```text
Purchases: Collected / Linked to user / Not used for tracking / Purpose: App Functionality
```

## Financial Info

支払い情報はApple/Googleが処理し、TalkLogがクレジットカード情報を直接取得する設計ではありません。

```text
Financial Info: Not collected
```

## Health and Fitness

使用しません。

```text
Health and Fitness: Not collected
```

## Browsing History / Search History

使用しません。

```text
Browsing History: Not collected
Search History: Not collected
```

## Advertising Data

通常広告は現時点で導入していません。

```text
Advertising Data: Not collected
```

将来リワード広告を導入する場合は、広告SDKのデータ収集内容に合わせて更新が必要です。

## 最終確認チェック

- [ ] 実際に導入しているSDKを確認する
- [ ] Supabaseの取得データと一致しているか確認する
- [ ] OpenAIへ送るデータをプライバシーポリシーに明記する
- [ ] リワード広告導入前にApp Privacyを再更新する
- [ ] App Store課金実装後にPurchases項目を再確認する
