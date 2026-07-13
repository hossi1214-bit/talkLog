# Screenshot Demo Data Setup

App Storeスクリーンショット撮影用のデモデータ準備手順です。

## 目的

スクリーンショット撮影時に、以下の画面が空にならないようにします。

- ホーム / 学習進捗
- 録音履歴
- AI添削結果
- 単語帳
- よく使う単語ランキング
- 容量メーター

## 事前準備

1. アプリを起動する
2. 撮影用メールアカウントを作成する
3. そのアカウントでログインする
4. Supabaseの `profiles` に行が作成されたことを確認する

推奨メール例:

```text
screenshot-test@example.com
```

実際にメール認証が必要な設定の場合は、受信できる撮影用メールアドレスを使ってください。

## SQL実行

Supabase SQL Editorで以下を開きます。

```text
docs/app_store_screenshot_demo_data.sql
```

SQL先頭の `v_email` を撮影用アカウントのメールアドレスに変更します。

```sql
v_email text := 'screenshot-test@example.com';
```

その後、SQL全体を実行します。

## 作成されるデータ

- 撮影用ユーザーの `role` を `TESTER` に変更
- 学習言語を `英語` に変更
- 録音履歴4件を作成
- 文字起こし4件を作成
- AI添削4件を作成
- 単語帳6件を作成
- 単語ランキング用データを作成
- 学習進捗データを作成
- 連続学習日数用データを作成

## 注意

このSQLは、対象ユーザーの `local_audio_path = 'screenshot-demo'` の録音履歴を削除してから作り直します。

実際の録音音声ファイルはStorageに作成しません。そのため、履歴再生の確認ではなく、スクリーンショット撮影用の表示データとして使います。

## 撮影前確認

SQL実行後、アプリで以下を確認します。

- 設定画面で権限が `TESTER` になっている
- ホームで録音数、連続日数、容量メーターが表示される
- 履歴に複数件の録音が表示される
- 録音詳細で添削結果が表示される
- 単語帳に複数単語が表示される
- ランキングに単語とアドバイスが表示される

## データを消したい場合

同じSQLを再実行すると、スクショ用録音履歴は一度削除されて作り直されます。

完全に削除したい場合は、Supabase SQL Editorで以下を実行します。

```sql
delete from public.recordings
where local_audio_path = 'screenshot-demo'
  and user_id = (
    select id from public.profiles where email = 'screenshot-test@example.com'
  );
```

`recordings` に紐づく `transcripts`、`feedbacks`、`vocabulary` は外部キーの `on delete cascade` で削除されます。`word_usage`、`learning_stats`、`daily_streaks` は必要に応じて個別削除してください。
