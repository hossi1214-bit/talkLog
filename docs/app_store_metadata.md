# App Store Metadata Draft

TalkLogをApp Store Connectへ登録するための掲載情報下書きです。実際の申請時は、App Store Connectの最新入力欄に合わせて調整します。

## App Name

```text
TalkLog
```

## Subtitle

候補:

```text
自分の声で続ける英語スピーキング練習
```

別案:

```text
録音とAI添削で話す力を記録
```

## Promotional Text

```text
録音したスピーキング練習を履歴として残し、AI添削、単語ランキング、学習進捗で成長を見える化できます。
```

## Description

```text
TalkLogは、自分の声でスピーキング練習を記録し、英語力の成長を実感するための音声ログアプリです。

ただAIに添削してもらうだけではなく、録音した声を学習履歴として積み上げていくことを大切にしています。1週間前、1か月前の自分の話し方を振り返ることで、少しずつ話せるようになっている変化を確認できます。

主な機能:

- スピーキング練習の録音と再生
- 録音履歴の保存と検索
- 学習言語別の履歴管理
- AIによる文字起こしと添削
- よく使う単語ランキング
- 単語の言い換えアドバイス
- 単語帳への保存と復習チェック
- 学習日数や録音数の進捗表示
- 音声ストレージ使用量の確認
- 何を話すか迷ったときの練習文作成

TalkLogは、英語を学ぶアプリではなく、英語で話した自分を記録し、成長を耳で実感するためのアプリです。
毎日の短い録音を積み重ねて、自分だけのスピーキング学習ログを作っていきましょう。
```

## Keywords

100文字以内に収める必要があります。スペースは入れず、カンマ区切りで入力します。

```text
英語,英会話,スピーキング,録音,AI添削,発音,単語帳,学習記録,語学,リスニング
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

```text
TalkLogは、ユーザーがスピーキング練習を録音し、履歴として保存できる語学学習アプリです。

ログイン後、録音画面から音声を録音できます。録音履歴の詳細画面からAI添削を実行すると、Supabase Edge Functions経由でOpenAI APIを呼び出し、文字起こしと添削結果を表示します。

現在のPremium登録ボタンはプラン案内の表示までで、App Store課金処理はまだ有効化していません。課金商品を有効にする前のテストビルドでは、課金完了を必要とする購入処理は行われません。

マイク権限は録音機能のために使用します。録音データはユーザーの学習履歴としてSupabase Storageに保存され、ユーザー自身が削除できます。
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

## Privacy Policy URL

```text
https://hossi1214-bit.github.io/talkLog/privacy.html
```

## Support URL

```text
https://hossi1214-bit.github.io/talkLog/support.html
```

## Support Email

未確定です。公開用の問い合わせメールアドレスを決めてください。
