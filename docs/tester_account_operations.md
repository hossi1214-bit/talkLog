# Tester Account Operations

TestFlightや事前検証でテスターに `TESTER` 権限を付与するための運用メモです。

## 基本方針

- テスターはアプリ上で自分のメールアドレスとパスワードを登録する
- 管理者は登録済みメールアドレスを受け取り、Supabase側で `TESTER` を付与する
- テスター自身がアプリから `role` を変更できるようにはしない
- 少人数の初期テストでは、1人ずつ手動付与で運用する

## テスター追加手順

| 手順 | 担当 | 内容 |
|---:|---|---|
| 1 | テスター | アプリでメールアドレス・パスワード登録 |
| 2 | テスター | 登録したメールアドレスを管理者へ連絡 |
| 3 | 管理者 | Supabase SQL Editorで `TESTER` 権限を付与 |
| 4 | テスター | アプリを再起動、またはログアウトして再ログイン |
| 5 | 管理者/テスター | 設定画面などで権限表示を確認 |

## TESTER付与SQL

`profiles` に `email` カラムがない場合でも動くように、`auth.users` と結合して更新します。

```sql
update public.profiles p
set role = 'TESTER'
from auth.users u
where p.id = u.id
  and u.email = 'tester@example.com';
```

## 複数人に付与するSQL

```sql
update public.profiles p
set role = 'TESTER'
from auth.users u
where p.id = u.id
  and u.email in (
    'tester1@example.com',
    'tester2@example.com',
    'tester3@example.com'
  );
```

## 権限確認SQL

```sql
select
  u.email,
  p.role,
  p.updated_at
from public.profiles p
join auth.users u on u.id = p.id
where u.email in (
  'tester@example.com'
)
order by u.email;
```

## TESTER解除SQL

テスト期間が終わったら `FREE` に戻します。

```sql
update public.profiles p
set role = 'FREE'
from auth.users u
where p.id = u.id
  and u.email = 'tester@example.com';
```

## 注意

- `ADMIN` や `TESTER` の付与はSupabase管理画面または管理者用APIだけで行う
- アプリ画面からユーザー自身が `role` を変更できないようにする
- RLSでは、ユーザー自身が自分のプロフィールを読めても `role` は更新できない設計にする
- テスターが権限変更後もFREE表示のままなら、アプリ再起動またはログアウト・再ログインを案内する
