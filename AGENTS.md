\# AGENTS.md



\## 目的



このファイルは、Codex / AIエージェントが TalkLog を開発する際の行動指針です。



AIは単にコードを生成するのではなく、既存設計を尊重し、保守しやすく、将来拡張しやすいFlutterアプリとして実装してください。



\---



\# プロジェクト概要



\## アプリ名



TalkLog



\## 概要



TalkLogは、外国語の独り言を録音し、AIによる添削・フィードバック・成長記録を提供するスピーキング学習アプリです。



ユーザーは毎日、自分の言葉で話し、その音声・文字起こし・AI添削・成長履歴を蓄積します。



\---



\# プロダクトコンセプト



話すたび、成長が記録される。



TalkLogは、問題を解く語学アプリではなく、毎日のスピーキング練習を記録する「語学版ライフログ」です。



\---



\# 開発方針



\## 最優先事項



\- MVPを早く完成させる

\- ただし雑なコードにしない

\- 将来のSupabase / Dify / AI連携を見据える

\- 画面とロジックを分離する

\- 機能ごとに責務を分ける

\- 既存ファイル構成を尊重する



\---



\# 技術スタック



\## フロントエンド



\- Flutter

\- Dart

\- Material 3



\## 状態管理



\- Riverpodを基本方針とする

\- ただし一時的なUI状態はStatefulWidgetを許可する



\## ルーティング



\- MVPではBottomNavigationBarを使用

\- ログイン、AI結果詳細、履歴詳細などが増えたらGoRouterを導入する



\## バックエンド予定



\- Supabase Auth

\- Supabase Database

\- Supabase Storage

\- Supabase Edge Functions



\## AI予定



\- Dify

\- Whisper / Speech-to-Text

\- LLMによる添削・自然表現・文法解説



\---



\# 対象プラットフォーム



優先対象:



\- Android

\- iOS



非優先:



\- Windows Desktop

\- macOS Desktop

\- Linux Desktop

\- Web



Flutterで動作しても、MVPではAndroid/iOS向けの設計を優先してください。



\---



\# ディレクトリ方針



基本構成:



```text

lib/

├── app/

├── core/

├── features/

├── shared/

└── main.dart

