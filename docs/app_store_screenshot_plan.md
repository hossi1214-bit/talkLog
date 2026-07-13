# App Store Screenshot Plan

TalkLogのApp Store / TestFlight向けスクリーンショット準備メモです。

Apple公式のApp Store Connectヘルプでは、スクリーンショットはアプリの画面を表示し、各デバイス種別ごとに最大10枚までアップロードできます。TalkLogの初回リリースでは、撮影済みの01〜08を採用セットとし、09〜10は任意の追加候補にします。

## 現在の採用セット

撮影済みの以下8枚を初回リリース候補にします。

| No | 画面 | 目的 | 訴求文 | ファイル名 |
|---:|---|---|---|---|
| 1 | ホーム / 進捗 | アプリの価値を最初に伝える | 自分の声で、成長を記録 | `screenshots/ios/01-home-progress.png` |
| 2 | 録音画面 | メイン機能を伝える | 話した英語をすぐ録音 | `screenshots/ios/02-recording-helper.png` |
| 3 | 録音履歴 | 継続利用の価値を伝える | 1週間前の自分と比べられる | `screenshots/ios/03-history.png` |
| 4 | AI添削結果 | AI価値を伝える | 文字起こしと添削で振り返る | `screenshots/ios/04-ai-feedback.png` |
| 5 | 単語ランキング / 単語帳 | 学習の積み上げを伝える | よく使う単語を見える化 | `screenshots/ios/05-word-ranking.png` |
| 6 | Premium案内 | プラン導線を伝える | 制限を気にせず学習を続ける | `screenshots/ios/06-premium.png` |
| 7 | 言語設定 | 言語別管理を伝える | 学習言語ごとに記録を整理 | `screenshots/ios/07-language-settings.png` |
| 8 | 単語帳 | 復習機能を伝える | 気になった表現を復習 | `screenshots/ios/08-vocabulary.png` |

## 任意の追加候補

今回は01〜08で十分です。必要になった場合だけ、以下を追加撮影します。

| No | 画面 | 訴求文 | ファイル名 |
|---:|---|---|---|
| 9 | 容量メーター | 音声ログを安心して管理 | `screenshots/ios/09-storage-meter.png` |
| 10 | 録音補助 | 何を話すか迷っても大丈夫 | `screenshots/ios/10-speaking-draft.png` |

## 基本方針

- 初回リリースでは01〜08を使う
- 個人情報や実在メールアドレスは写さない
- テスト用アカウント、テスト用録音、テスト用添削結果を使う
- スクショ内の文章は短く、機能説明より利用価値を優先する
- 課金未実装のため、Premium登録完了を示す画面は撮らない
- App Store Connectにアップロードする前に、必要サイズへ調整する
- 撮影済み画像の寸法管理は screenshots/ios/README.md を参照する

## 撮影用デモデータ

撮影用データの作成手順は以下を参照します。

- `docs/app_store_screenshot_demo_data.md`
- `docs/app_store_screenshot_demo_data.sql`

撮影用アカウント:

```text
Email: screenshot-test@example.com
Role: TESTER
Language: 英語
```

## 撮影前チェックリスト

- [ ] 本番・個人メールアドレスが画面に出ていない
- [ ] APIキー、Supabase URL、内部IDが画面に出ていない
- [ ] 赤いエラー文が残っていない
- [ ] 録音履歴の日付が日本時間で自然
- [ ] FREE上限エラーなどネガティブな画面を撮っていない
- [ ] Premium登録完了のような未実装表現を出していない
- [ ] ボタンや文字が切れていない
- [ ] ステータスバーの時刻・電池表示が不自然でない
- [ ] スクショ内の言語が日本語で統一されている
- [ ] 音声や個人情報を含む実データではなくデモデータを使っている

## App Store Connect入力時のメモ

- 最初の1枚はアプリの価値が一目で分かる画面にする
- 同じような画面を並べすぎない
- iPhone用のスクショから先に用意する
- iPad対応を有効にする場合はiPad用スクショも必要になる可能性がある
- iPadを積極対応しない場合、iPhone中心の表示崩れ確認を優先する

## 次にやること

1. 01〜08の画像サイズを確認する
2. 個人情報や見切れがないか確認する
3. App Store Connect用サイズへ必要に応じて調整する
4. Apple Developer承認後、App Store Connectへアップロードする
