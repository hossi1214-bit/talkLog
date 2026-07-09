\# ARCHITECTURE.md



\# TalkLog システムアーキテクチャ



\## 目的



このドキュメントは、TalkLogのシステム構成・ディレクトリ構成・責務分離・データフローを定義する。



TalkLogはMVPを素早く完成させつつ、将来的な機能追加・保守・リファクタリングを容易にすることを目的とする。



\---



\# 設計方針



TalkLogでは以下を重視する。



\- Feature First Architecture

\- 責務の分離（Separation of Concerns）

\- UIとロジックの分離

\- 小さなWidget

\- 小さなService

\- 小さなController

\- 保守性

\- 拡張性



\---



\# アーキテクチャ概要



```text

Flutter App

│

├── Presentation(UI)

│

├── Controller

│

├── Service

│

├── Repository（将来）

│

├── Local Storage

│

├── Supabase

│

└── Dify

```



\---



\# ディレクトリ構成



```text

lib/

│

├── app/

│

├── core/

│

├── features/

│

├── shared/

│

└── main.dart

```



\---



\# app/



アプリ全体に関わる設定を管理する。



例



```text

app/

├── app.dart

├── router.dart

├── navigation.dart

└── app\_theme.dart

```



責務



\- MaterialApp

\- Theme

\- Navigation

\- Route管理

\- 初期化



\---



\# core/



アプリ全体で利用する共通機能を管理する。



例



```text

core/

├── constants/

├── theme/

├── utils/

├── services/

└── widgets/

```



責務



\- 共通Theme

\- 定数

\- Helper

\- Utility

\- 共通Widget

\- 共通Service



\---



\# shared/



複数Featureで共有するUIやModelを配置する。



例



```text

shared/

├── widgets/

├── models/

├── extensions/

└── enums/

```



例



\- PrimaryButton

\- AppCard

\- LoadingIndicator



\---



\# features/



機能ごとに管理する。



```text

features/

├── home/

├── recording/

├── history/

├── progress/

└── settings/

```



各Featureは可能な限り独立させる。



\---



\# Home Feature



```text

home/

├── controllers/

├── models/

├── services/

├── widgets/

└── home\_page.dart

```



責務



\- 今日のお題表示

\- 学習ストリーク

\- 今日の録音数

\- 録音画面への導線



\---



\# Recording Feature



```text

recording/

├── controllers/

│   └── record\_controller.dart

│

├── models/

│   └── record\_entry.dart

│

├── services/

│   ├── record\_service.dart

│   ├── audio\_player\_service.dart

│   └── speech\_service.dart

│

├── widgets/

│   └── record\_button.dart

│

└── record\_page.dart

```



責務



\- 録音

\- 再生

\- 保存

\- AI解析開始



\---



\# History Feature



```text

history/

├── controllers/

├── models/

├── services/

├── widgets/

└── history\_page.dart

```



責務



\- 録音一覧

\- AI結果表示

\- 録音削除

\- 録音再生



\---



\# Progress Feature



```text

progress/

├── controllers/

├── models/

├── services/

├── widgets/

└── progress\_page.dart

```



責務



\- 学習統計

\- グラフ表示

\- ストリーク表示

\- AIスコア推移



\---



\# Settings Feature



```text

settings/

├── controllers/

├── models/

├── services/

├── widgets/

└── settings\_page.dart

```



責務



\- 学習言語

\- 通知設定

\- テーマ

\- アカウント



\---



\# データフロー



基本構成



```text

Widget



↓



Controller



↓



Service



↓



Repository（将来）



↓



Supabase / Local Storage



↓



Controller



↓



Widget

```



Widgetから直接Supabaseへアクセスしない。



\---



\# AIデータフロー



```text

録音開始



↓



音声保存



↓



Speech-to-Text



↓



文字起こし



↓



Edge Function



↓



Dify



↓



AI添削



↓



DB保存



↓



結果表示

```



\---



\# 状態管理



基本



Riverpod



使用例



\- 録音状態

\- ログイン状態

\- 履歴一覧

\- 学習統計

\- 設定



一時的UI状態のみStatefulWidgetを許可する。



例



\- タイマー

\- アニメーション

\- ExpansionTile



\---



\# Navigation



MVP



BottomNavigationBar



画面



\- Home

\- Speak

\- History

\- Progress

\- Settings



将来



GoRouterへ移行する。



対象



\- Login

\- Onboarding

\- AI結果詳細

\- 録音詳細

\- Subscription



\---



\# Repository



MVPでは省略可能。



正式版では導入する。



例



```text

repositories/



record\_repository.dart



history\_repository.dart



user\_repository.dart

```



責務



\- DBアクセス

\- キャッシュ

\- API呼び出し



\---



\# Service



Serviceは外部との通信を担当する。



例



RecordService



\- 録音開始

\- 録音停止



AudioPlayerService



\- 再生

\- 停止



SpeechService



\- 文字起こし



AiFeedbackService



\- Dify通信



SupabaseService



\- DB保存



\---



\# Controller



ControllerはUIとServiceを仲介する。



役割



\- 状態更新

\- バリデーション

\- エラー制御

\- UI通知



ControllerからWidgetを操作しない。



\---



\# Widget



Widgetは表示のみ担当する。



禁止



\- API通信

\- DBアクセス

\- 複雑なビジネスロジック



\---



\# Model



Modelはデータ構造のみ保持する。



例



```dart

RecordEntry



HistoryEntry



Feedback



UserProfile

```



Modelに画面制御を書かない。



\---



\# Local Storage



MVPでは以下を保存する。



\- 一時録音

\- キャッシュ

\- ダミーデータ



将来的にはHiveやIsarなども検討する。



\---



\# Cloud Storage



Supabase Storage



保存対象



\- 音声

\- AI生成データ

\- 将来は画像



\---



\# Database



Supabase



保存対象



\- User

\- Recording

\- Transcript

\- Feedback

\- Vocabulary

\- Statistics



\---



\# AI



Dify



責務



\- 添削

\- 自然表現

\- 日本語訳

\- 文法解説

\- スコア

\- 励ましコメント



\---



\# エラー設計



各Serviceは例外をUIへ直接返さない。



Controllerがエラーを受け取り、



SnackBar



Dialog



Error Widget



などへ変換する。



\---



\# ログ



将来的に以下を追加する。



\- Crashlytics

\- Analytics

\- Logging



\---



\# パフォーマンス方針



\- 不要なWidget再生成を避ける

\- constを積極利用

\- ListView.builderを利用

\- 非同期処理はawaitで管理

\- 大きなbuild()を書かない



\---



\# テスト方針



将来的に



\- Unit Test

\- Widget Test

\- Integration Test



を追加する。



ControllerとServiceはテスト可能な設計にする。



\---



\# コーディング原則



\- Single Responsibility Principle

\- DRY

\- KISS

\- YAGNI

\- Composition over Inheritance



\---



\# 将来追加予定



\- Repository Pattern

\- Offline Mode

\- キャッシュ同期

\- Push通知

\- AIチャット

\- シャドーイング

\- 発音分析

\- CEFR判定

\- サブスクリプション



\---



\# 長期ビジョン



TalkLogは、録音・AI添削・学習記録を統合したスピーキング学習プラットフォームを目指す。



機能追加を続けても保守性が落ちないよう、本アーキテクチャに従って実装を進める。

