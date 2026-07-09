-- TalkLog migration: language-aware stats and word usage ranking
-- Run this in the Supabase SQL editor for the target project.

alter table public.vocabulary
  add column if not exists language text not null default 'スペイン語';

alter table public.learning_stats
  add column if not exists language text not null default 'すべて';

alter table public.daily_streaks
  add column if not exists language text not null default 'すべて';

update public.vocabulary v
set language = r.language
from public.recordings r
where v.recording_id = r.id
  and (v.language is null or v.language = 'スペイン語');

alter table public.learning_stats
  drop constraint if exists learning_stats_user_id_key;

alter table public.daily_streaks
  drop constraint if exists daily_streaks_user_id_learning_date_key;

create unique index if not exists learning_stats_user_language_unique
  on public.learning_stats(user_id, language);

create unique index if not exists daily_streaks_user_language_date_unique
  on public.daily_streaks(user_id, language, learning_date);

create index if not exists vocabulary_language_idx on public.vocabulary(language);
create index if not exists learning_stats_user_language_idx on public.learning_stats(user_id, language);
create index if not exists daily_streaks_user_language_date_idx on public.daily_streaks(user_id, language, learning_date desc);

create table if not exists public.word_usage (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  language text not null,
  word text not null,
  count integer not null default 0 check (count >= 0),
  alternative_words jsonb not null default '[]'::jsonb,
  advice text not null default '',
  updated_at timestamptz not null default now(),
  unique (user_id, language, word)
);

create index if not exists word_usage_user_language_count_idx
  on public.word_usage(user_id, language, count desc);

alter table public.word_usage enable row level security;

grant select, insert, update, delete on table public.word_usage to authenticated;

drop policy if exists "word_usage_select_own" on public.word_usage;
drop policy if exists "word_usage_insert_own" on public.word_usage;
drop policy if exists "word_usage_update_own" on public.word_usage;
drop policy if exists "word_usage_delete_own" on public.word_usage;

create policy "word_usage_select_own" on public.word_usage
  for select using (user_id = auth.uid());

create policy "word_usage_insert_own" on public.word_usage
  for insert with check (user_id = auth.uid());

create policy "word_usage_update_own" on public.word_usage
  for update using (user_id = auth.uid()) with check (user_id = auth.uid());

create policy "word_usage_delete_own" on public.word_usage
  for delete using (user_id = auth.uid());
