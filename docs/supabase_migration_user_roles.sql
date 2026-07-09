-- TalkLog user role migration
-- Run this in the Supabase SQL editor after the base schema is applied.

alter table public.profiles
  add column if not exists role text not null default 'FREE';

update public.profiles
set role = 'FREE'
where role is null or role not in ('FREE', 'PREMIUM', 'TESTER', 'ADMIN');

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'profiles_role_check'
      and conrelid = 'public.profiles'::regclass
  ) then
    alter table public.profiles
      add constraint profiles_role_check
      check (role in ('FREE', 'PREMIUM', 'TESTER', 'ADMIN'));
  end if;
end $$;

create or replace function public.current_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid()
$$;

revoke insert, update on table public.profiles from authenticated;
grant select, delete on table public.profiles to authenticated;
grant insert (id, email, display_name, learning_language, created_at, updated_at) on table public.profiles to authenticated;
grant update (id, email, display_name, learning_language, updated_at) on table public.profiles to authenticated;

drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;
drop policy if exists "profiles_update_own_basic" on public.profiles;
drop policy if exists "profiles_select_admin" on public.profiles;
drop policy if exists "profiles_update_admin" on public.profiles;
drop policy if exists "profiles_delete_own" on public.profiles;

create policy "profiles_select_own"
on public.profiles for select
using (id = auth.uid());

create policy "profiles_select_admin"
on public.profiles for select
using (public.current_user_role() = 'ADMIN');

create policy "profiles_insert_own"
on public.profiles for insert
with check (id = auth.uid());

create policy "profiles_update_own_basic"
on public.profiles for update
using (id = auth.uid())
with check (id = auth.uid());

create policy "profiles_update_admin"
on public.profiles for update
using (public.current_user_role() = 'ADMIN')
with check (public.current_user_role() = 'ADMIN');

create policy "profiles_delete_own"
on public.profiles for delete
using (id = auth.uid());

-- Role changes should be done from the Supabase dashboard or a service-role/admin-only API.
-- Normal authenticated users do not receive INSERT/UPDATE privileges for profiles.role.
