# App Store Metadata Draft

TalkLogをApp Store Connectへ登録するための掲載情報最終下書きです。実際の申請時は、App Store Connectの入力欄で文字数と最新表示を確認してください。

## Final Copy Set

初回提出では、まず以下の文言を使う想定です。

| 項目 | 入力内容 |
|---|---|
| App Name | `TalkLog` |
| Subtitle | `自分の声で続ける英語スピーキング練習` |
| Promotional Text | `録音したスピーキング練習を履歴として残し、AI添削、単語ランキング、学習進捗で成長を見える化できます。` |
| Keywords | `英語,英会話,スピーキング,録音,AI添削,発音,単語帳,学習記録,語学,リスニング` |
| Category | 教育 |
| Secondary Category | 仕事効率化 |
| Bundle ID | `jp.hossi1214.talklog` |
| SKU | `talklog-ios` |
| Privacy Policy URL | `https://hossi1214-bit.github.io/talkLog/privacy.html` |
| Support URL | `https://hossi1214-bit.github.io/talkLog/support.html` |

## App Name

```text
TalkLog
```

## Subtitle

採用案:

```text
自分の声で続ける英語スピーキング練習
```

代替案:

```text
録音とAI添削で話す力を記録
```

```text
昨日の自分より話せる英語ログ
```

## Promotional Text

採用案:

```text
録音したスピーキング練習を履歴として残し、AI添削、単語ランキング、学習進捗で成長を見える化できます。
```

代替案:

```text
自分の声を学習ログとして残し、AI添削と単語ランキングで毎日のスピーキング練習を振り返れます。
```

## Description

```text
TalkLogは、自分の声でスピーキング練習を記録し、英語力の成長を実感するための音声ログアプリです。

AIに添削してもらって終わりではなく、録音した声を学習履歴として積み上げていくことを大切にしています。1週間前、1か月前の自分の話し方を振り返ることで、少しずつ話せるようになっている変化を確認できます。

主な機能:

- スピーキング練習の録音と再生
- 録音履歴の保存と確認
- 学習言語別の履歴管理
- AIによる文字起こしと添削
- よく使う単語ランキング
- 単語の言い換えアドバイス
- 単語帳への保存と復習チェック
- 学習日数や録音数の進捗表示
- 音声ストレージ使用量の確認
- 何を話すか迷ったときの練習文作成

こんな人におすすめ:

- 英語を話す練習を習慣化したい人
- 自分の発話を録音して振り返りたい人
- AI添削で自然な表現を学びたい人
- よく使う単語や表現のクセを知りたい人
- 日々の学習記録を残して成長を実感したい人

TalkLogは、英語を学ぶだけのアプリではありません。
英語で話した自分を記録し、成長を耳で実感するためのアプリです。

毎日の短い録音を積み重ねて、自分だけのスピーキング学習ログを作っていきましょう。
```

## Keywords

100文字以内に収める必要があります。スペースは入れず、カンマ区切りで入力します。

採用案:

```text
英語,英会話,スピーキング,録音,AI添削,発音,単語帳,学習記録,語学,リスニング
```

代替案:

```text
英語,英会話,スピーキング,音声,録音,AI添削,単語帳,語学学習,発音,リスニング
```

## Category

第一候補:

```text
教育
```

第二候補:

```text
仕事効率化
```

## Content Rights

アプリ内の音声や学習データは、ユーザー自身が録音・入力した内容を扱います。アプリ側で第三者著作物を配信する設計ではありません。

## Age Rating Notes

想定:

- 成人向けコンテンツ: なし
- 暴力表現: なし
- ギャンブル: なし
- Webアクセス: なし
- ユーザー生成コンテンツ: ユーザー自身の録音あり。ただし公開・共有機能はなし

## Review Notes

App Store審査メモに貼る文言です。

```text
TalkLogは、ユーザーがスピーキング練習を録音し、履歴として保存できる語学学習アプリです。

ログイン後、録音画面から音声を録音できます。録音履歴の詳細画面からAI添削を実行すると、Supabase Edge Functions経由でOpenAI APIを呼び出し、文字起こしと添削結果を表示します。

マイク権限は録音機能のために使用します。録音データはユーザーの学習履歴としてSupabase Storageに保存され、ユーザー自身が削除できます。

現在のPremium登録ボタンはプラン案内と比較表の表示用です。App Store課金処理はまだ有効化していないため、テスト中に実際の購入は発生しません。
```

## Test Account

審査提出時に必要であれば、App Store ConnectのReview Notesにテストアカウントを記載します。

```text
Email: screenshot-test@example.com
Password: REVIEW_TEST_PASSWORD
```

テストアカウントには、必要に応じてSupabaseの `profiles.role` で `TESTER` または `ADMIN` を付与します。

```sql
update public.profiles p
set role = 'TESTER'
from auth.users u
where p.id = u.id
  and u.email = 'screenshot-test@example.com';
```

## App Privacy Summary

App Privacy入力の詳細は `docs/app_privacy_answers.md` を参照します。

初回提出時の方針:

- 録音音声、文字起こし、AI添削結果、単語帳はユーザーに紐づくデータとして扱う
- メールアドレスとSupabase User IDをアカウント管理に使用する
- OpenAI APIへはAI処理に必要な音声・テキストを送信する
- 他社アプリやWebサイトを横断したトラッキング目的では利用しない
- 位置情報、連絡先、金融情報、広告データは収集しない

## URLs

Privacy Policy URL:

```text
https://hossi1214-bit.github.io/talkLog/privacy.html
```

Support URL:

```text
https://hossi1214-bit.github.io/talkLog/support.html
```

## Support Email

未確定です。公開用の問い合わせメールアドレスを決めてください。

## Submission Checklist

- [ ] App Nameが `TalkLog` になっている
- [ ] Bundle IDが `jp.hossi1214.talklog` になっている
- [ ] SKUが `talklog-ios` になっている
- [ ] Privacy Policy URLが開ける
- [ ] Support URLが開ける
- [ ] スクリーンショット01〜08を登録する
- [ ] App Privacy回答が実装内容と一致している
- [ ] Review Notesにテストアカウントを記載する
- [ ] Premium課金が未実装であることを審査メモに明記する
- [ ] 公開用問い合わせメールアドレスを決める
