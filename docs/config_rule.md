\# CODING\_RULE.md



\# TalkLog コーディング規約



\## 目的



本ドキュメントは、TalkLogプロジェクトのコード品質を維持し、複数人やAI（Codex、GitHub Copilot、Claude Codeなど）が一貫した実装を行うためのルールを定義する。



\---



\# 基本方針



以下を最優先とする。



1\. 読みやすいコード

2\. 保守しやすい設計

3\. 拡張しやすい構成

4\. シンプルな実装

5\. MVPを素早く完成させる



短いコードより、理解しやすいコードを優先する。



\---



\# コーディング原則



TalkLogでは以下の原則を採用する。



\- KISS（Keep It Simple）

\- DRY（Don't Repeat Yourself）

\- YAGNI（You Aren't Gonna Need It）

\- Single Responsibility Principle

\- Composition over Inheritance



\---



\# Flutter方針



優先するもの



\- StatelessWidget

\- Riverpod

\- Material3

\- constコンストラクタ

\- 非同期処理はasync/await



必要な場合のみ使用するもの



\- StatefulWidget

\- Timer

\- AnimationController



\---



\# ディレクトリルール



Feature First Architectureを採用する。



```text

features/

├── home/

├── recording/

├── history/

├── progress/

└── settings/

```



各Featureは必要に応じて以下を持つ。



```text

controllers/

models/

services/

widgets/

```



\---



\# ファイル命名



必ず snake\_case を使用する。



例



```text

record\_page.dart



record\_service.dart



record\_controller.dart



record\_entry.dart

```



禁止



```text

RecordPage.dart



recordPage.dart



record-page.dart

```



\---



\# クラス命名



PascalCase



例



```dart

RecordPage



RecordService



RecordController

```



\---



\# 変数



camelCase



例



```dart

isRecording



recordDuration



currentLanguage

```



\---



\# 定数



定数は constants にまとめる。



例



```dart

const maxRecordingMinutes = 5;

```



\---



\# Widgetルール



Widgetは表示のみ担当する。



禁止



\- API通信

\- DBアクセス

\- 複雑な計算

\- Dify通信

\- Supabase通信



\---



\# build()



build()内では以下のみを書く。



\- UI

\- Widget配置

\- Theme取得



禁止



\- for文による複雑な生成

\- API呼び出し

\- await

\- ビジネスロジック

\- データ加工



\---



\# Service



Serviceの責務



\- API通信

\- 録音

\- 音声再生

\- DB保存

\- Dify通信

\- Supabase通信



ServiceはUIを知らない。



\---



\# Controller



Controllerの責務



\- 状態管理

\- Service呼び出し

\- エラー処理

\- Riverpod管理



ControllerからWidgetを操作しない。



\---



\# Model



Modelはデータのみ保持する。



例



```dart

class RecordEntry {



}

```



Modelに処理を書きすぎない。



\---



\# Riverpod



状態はRiverpodで管理する。



例



\- 録音状態

\- 履歴

\- ログイン

\- 学習統計

\- 設定



画面だけで完結する一時状態はStatefulWidgetでもよい。



\---



\# UI



Material3を使用する。



デザイン方針



\- シンプル

\- 見やすい

\- 毎日使える

\- 余白を広めに

\- タップ領域を広く



\---



\# Theme



色を直接書かない。



禁止



```dart

Colors.blue

```



推奨



```dart

AppColors.primary

```



文字サイズもThemeから取得する。



\---



\# Magic Number禁止



禁止



```dart

padding: EdgeInsets.all(17)

```



推奨



```dart

AppSpacing.md

```



\---



\# String管理



画面内に大量の文字列を書かない。



将来的には



```text

l10n

```



または



```text

constants

```



へ集約する。



\---



\# コメント



必要最小限にする。



良い例



```dart

// 録音開始

```



悪い例



```dart

// この変数は秒数を保持しています

int seconds;

```



コードで表現できる内容はコメントを書かない。



\---



\# Null安全



Null Safetyを徹底する。



無意味な



```dart

!

```



は使わない。



\---



\# 非同期処理



async/awaitを使用する。



禁止



```dart

then()

```



必要な場合を除く。



\---



\# Error Handling



try-catchを使用する。



例



```dart

try {



} catch (e) {



}

```



UIへ例外をそのまま表示しない。



\---



\# Logging



開発中のみ



```dart

debugPrint()

```



を使用する。



リリース版では不要なログを削除する。



\---



\# Git



コミットは小さくする。



推奨



```text

feat:



fix:



docs:



refactor:



style:



test:



chore:

```



例



```text

feat: add recording page



fix: recording timer bug



refactor: split record service



docs: update requirements

```



\---



\# Pull Request



1PR = 1機能



巨大PRは禁止。



\---



\# AI利用



Codex・Copilot・Claude Codeを利用する場合



以下を必ず守る。



\- 既存コードを確認する

\- 重複実装しない

\- 同じWidgetを増やさない

\- フォルダ構成を崩さない

\- 動作するコードを優先する



\---



\# 禁止事項



以下は禁止する。



\- APIキーをコードへ書く

\- SecretをGitへコミットする

\- 巨大Widgetを作る

\- build()を500行書く

\- ServiceからWidgetを操作する

\- WidgetからSupabaseへ直接アクセスする

\- WidgetからDifyを直接呼ぶ

\- 同じコードをコピーする



\---



\# ファイルサイズ目安



推奨



Widget



100〜200行



Service



150行以内



Controller



150行以内



Model



100行以内



300行を超える場合は分割を検討する。



\---



\# パフォーマンス



以下を心掛ける。



\- constを使う

\- 不要なsetStateを避ける

\- ListView.builderを使う

\- 不要な再描画を防ぐ

\- Widgetを細かく分割する



\---



\# テスト



将来的に追加する。



\- Unit Test

\- Widget Test

\- Integration Test



ServiceとControllerはテストしやすい設計にする。



\---



\# セキュリティ



Flutterアプリには



\- APIキー

\- Secret

\- Service Role Key



を書かない。



Supabase Edge Functions経由で処理する。



\---



\# MVP開発ルール



MVPでは



\- 動くこと

\- 分かりやすいこと



を優先する。



過度な抽象化は行わない。



必要になってからリファクタリングする。



\---



\# TalkLog開発理念



TalkLogは「毎日続けられるスピーキング学習アプリ」を目指す。



コードも同様に、



\- 毎日少しずつ改善できる

\- 誰が読んでも理解できる

\- AIも人も保守しやすい



ことを最も重要な価値とする。

