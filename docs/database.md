\# DATABASE.md



\# TalkLog データベース設計書



\## 目的



本ドキュメントは、TalkLogで使用するデータベース設計を定義する。



MVPではローカル保存を許可するが、正式版ではSupabase PostgreSQLを利用することを前提とする。



\---



\# データベース構成



TalkLogでは以下のデータを管理する。



\- ユーザー

\- 録音

\- 音声ファイル

\- 文字起こし

\- AI添削

\- 語彙

\- 学習統計

\- 学習ストリーク

\- 設定



\---



\# ER図



```text

User

│

├── Recordings

│       │

│       ├── Transcript

│       │

│       ├── AI Feedback

│       │

│       └── Vocabulary

│

└── Learning Stats

```



\---



\# テーブル一覧



| テーブル名 | 説明 |

|------------|------|

| profiles | ユーザー情報 |

| recordings | 録音情報 |

| transcripts | 文字起こし |

| feedbacks | AI添削 |

| vocabulary | AI抽出単語 |

| learning\_stats | 学習統計 |

| daily\_streaks | 学習ストリーク |

| settings | ユーザー設定 |



\---



\# profiles



ユーザー情報



```sql

id uuid primary key



email text



display\_name text



learning\_language text



created\_at timestamp



updated\_at timestamp

```



\---



\# recordings



録音情報



```sql

id uuid primary key



user\_id uuid



language text



audio\_path text



duration\_seconds integer



created\_at timestamp



updated\_at timestamp

```



\---



\## 説明



audio\_path



例



```text

recordings/user\_id/2026/07/sample.m4a

```



\---



\# transcripts



文字起こし



```sql

id uuid primary key



recording\_id uuid



original\_text text



language text



created\_at timestamp

```



\---



\# feedbacks



AI添削



```sql

id uuid primary key



recording\_id uuid



corrected\_text text



natural\_expression text



translation\_ja text



grammar\_feedback text



score integer



comment text



created\_at timestamp

```



\---



\## grammar\_feedback



JSON形式を推奨



例



```json

\[

&#x20; {

&#x20;   "title":"過去形",

&#x20;   "description":"ir の活用"

&#x20; }

]

```



\---



\# vocabulary



AIが抽出した語彙



```sql

id uuid primary key



recording\_id uuid



word text



meaning text



example text



is\_reviewed boolean



created\_at timestamp

```



\---



\# learning\_stats



学習統計



```sql

id uuid primary key



user\_id uuid



total\_recordings integer



total\_duration\_seconds integer



current\_streak integer



best\_streak integer



average\_score integer



updated\_at timestamp

```



\---



\# daily\_streaks



学習ストリーク



```sql

id uuid primary key



user\_id uuid



learning\_date date



recording\_count integer



created\_at timestamp

```



\---



\# settings



ユーザー設定



```sql

id uuid primary key



user\_id uuid



learning\_language text



notification\_enabled boolean



notification\_time time



theme text



created\_at timestamp



updated\_at timestamp

```



\---



\# リレーション



profiles



↓



recordings



```text

profiles.id



↓



recordings.user\_id

```



\---



recordings



↓



transcripts



```text

recordings.id



↓



transcripts.recording\_id

```



\---



recordings



↓



feedbacks



```text

recordings.id



↓



feedbacks.recording\_id

```



\---



recordings



↓



vocabulary



```text

recordings.id



↓



vocabulary.recording\_id

```



\---



profiles



↓



learning\_stats



```text

profiles.id



↓



learning\_stats.user\_id

```



\---



profiles



↓



settings



```text

profiles.id



↓



settings.user\_id

```



\---



\# Storage



音声ファイルはDBではなくStorageへ保存する。



Bucket



```text

recordings

```



保存例



```text

recordings/



└── user\_id/



&#x20;     └── 2026/



&#x20;            └── 07/



&#x20;                  recording\_id.m4a

```



DBにはパスのみ保存する。



\---



\# インデックス



追加を推奨



recordings



```sql

user\_id



created\_at DESC

```



\---



feedbacks



```sql

recording\_id

```



\---



transcripts



```sql

recording\_id

```



\---



vocabulary



```sql

recording\_id

```



\---



learning\_stats



```sql

user\_id

```



\---



\# Row Level Security



全テーブルでRLSを有効化する。



\---



profiles



```sql

id = auth.uid()

```



\---



recordings



```sql

user\_id = auth.uid()

```



\---



transcripts



recording経由で本人のみ取得可能。



\---



feedbacks



recording経由で本人のみ取得可能。



\---



vocabulary



recording経由で本人のみ取得可能。



\---



settings



```sql

user\_id = auth.uid()

```



\---



\# 削除ルール



録音削除時



以下も削除する。



\- transcript

\- feedback

\- vocabulary

\- Storage音声



\---



\# 将来追加予定



\## ai\_reports



AI週次レポート



```sql

id



user\_id



week



summary



created\_at

```



\---



\## prompts



AIお題



```sql

id



language



level



prompt



created\_at

```



\---



\## achievements



バッジ



```sql

id



user\_id



badge\_name



earned\_at

```



\---



\## subscriptions



課金



```sql

id



user\_id



plan



started\_at



expires\_at

```



\---



\# 正規化方針



MVPではシンプルさを優先する。



必要以上にテーブルを分割しない。



将来的にデータ量が増えた段階で見直す。



\---



\# バックアップ



Supabase標準バックアップを利用する。



重要データ



\- profiles

\- recordings

\- feedbacks



は定期バックアップ対象とする。



\---



\# データ保持



音声データはユーザーが削除するまで保持する。



ユーザー退会時



以下を全削除する。



\- ユーザー情報

\- 録音

\- AI添削

\- 語彙

\- 音声ファイル

\- 学習履歴



\---



\# 将来の拡張



追加予定



\- 発音評価

\- CEFR判定

\- AIチャット履歴

\- 学習目標

\- カレンダー

\- シャドーイング履歴

\- 単語帳

\- 通知履歴



現在の設計は、それらの機能追加にも対応できる構成とする。


---

# 実装用SQL

Supabaseへ投入する初期スキーマは以下を正本とする。

```text
docs/supabase_schema.sql
```

セットアップ手順は以下を参照する。

```text
docs/supabase_setup.md
```