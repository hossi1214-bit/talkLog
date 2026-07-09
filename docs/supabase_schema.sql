-- TalkLog Supabase schema
-- Run this in the Supabase SQL editor for the target project.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  email text,
  display_name text,
  learning_language text not null default 'スペイン語',
  role text not null default 'FREE' check (role in ('FREE', 'PREMIUM', 'TESTER', 'ADMIN')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.recordings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  language text not null,
  audio_path text,
  local_audio_path text,
  duration_seconds integer not null default 0 check (duration_seconds >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.transcripts (
  id uuid primary key default gen_random_uuid(),
  recording_id uuid not null references public.recordings(id) on delete cascade,
  original_text text not null,
  language text not null,
  created_at timestamptz not null default now(),
  unique (recording_id)
);

create table if not exists public.feedbacks (
  id uuid primary key default gen_random_uuid(),
  recording_id uuid not null references public.recordings(id) on delete cascade,
  corrected_text text not null,
  natural_expression text not null,
  translation_ja text not null,
  grammar_feedback jsonb not null default '[]'::jsonb,
  vocabulary_feedback jsonb not null default '[]'::jsonb,
  score integer not null default 0 check (score between 0 and 100),
  comment text not null default '',
  created_at timestamptz not null default now(),
  unique (recording_id)
);

create table if not exists public.vocabulary (
  id uuid primary key default gen_random_uuid(),
  recording_id uuid not null references public.recordings(id) on delete cascade,
  language text not null,
  word text not null,
  meaning text not null,
  example text,
  is_reviewed boolean not null default false,
  review_count integer not null default 0 check (review_count >= 0),
  last_reviewed_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.learning_stats (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  language text not null default 'すべて',
  total_recordings integer not null default 0,
  total_duration_seconds integer not null default 0,
  current_streak integer not null default 0,
  best_streak integer not null default 0,
  average_score integer not null default 0 check (average_score between 0 and 100),
  updated_at timestamptz not null default now(),
  unique (user_id, language)
);

create table if not exists public.daily_streaks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  language text not null default 'すべて',
  learning_date date not null,
  recording_count integer not null default 0,
  created_at timestamptz not null default now(),
  unique (user_id, language, learning_date)
);


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
create table if not exists public.settings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  learning_language text not null default 'スペイン語',
  notification_enabled boolean not null default false,
  notification_time time,
  theme text not null default 'system',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id)
);

create index if not exists recordings_user_created_idx on public.recordings(user_id, created_at desc);
create index if not exists transcripts_recording_idx on public.transcripts(recording_id);
create index if not exists feedbacks_recording_idx on public.feedbacks(recording_id);
create index if not exists vocabulary_recording_idx on public.vocabulary(recording_id);
create index if not exists learning_stats_user_idx on public.learning_stats(user_id);
create index if not exists daily_streaks_user_date_idx on public.daily_streaks(user_id, learning_date desc);
create index if not exists settings_user_idx on public.settings(user_id);
create index if not exists vocabulary_language_idx on public.vocabulary(language);
create index if not exists vocabulary_review_status_idx on public.vocabulary(language, is_reviewed, last_reviewed_at desc);
create index if not exists learning_stats_user_language_idx on public.learning_stats(user_id, language);
create index if not exists daily_streaks_user_language_date_idx on public.daily_streaks(user_id, language, learning_date desc);
create index if not exists word_usage_user_language_count_idx on public.word_usage(user_id, language, count desc);
grant usage on schema public to anon, authenticated;
grant select, delete on table public.profiles to authenticated;
grant insert (id, email, display_name, learning_language, created_at, updated_at) on table public.profiles to authenticated;
grant update (id, email, display_name, learning_language, updated_at) on table public.profiles to authenticated;
grant select, insert, update, delete on table public.recordings to authenticated;
grant select, insert, update, delete on table public.transcripts to authenticated;
grant select, insert, update, delete on table public.feedbacks to authenticated;
grant select, insert, update, delete on table public.vocabulary to authenticated;
grant select, insert, update, delete on table public.learning_stats to authenticated;
grant select, insert, update, delete on table public.daily_streaks to authenticated;
grant select, insert, update, delete on table public.settings to authenticated;
grant select, insert, update, delete on table public.word_usage to authenticated;
grant usage, select on all sequences in schema public to authenticated;

alter table public.profiles enable row level security;
alter table public.recordings enable row level security;
alter table public.transcripts enable row level security;
alter table public.feedbacks enable row level security;
alter table public.vocabulary enable row level security;
alter table public.learning_stats enable row level security;
alter table public.daily_streaks enable row level security;
alter table public.settings enable row level security;
alter table public.word_usage enable row level security;

create or replace function public.current_user_role()
returns text
language sql
stable
security definer
set search_path = public
as $$
  select role from public.profiles where id = auth.uid()
$$;

create policy "profiles_select_own" on public.profiles for select using (id = auth.uid());
create policy "profiles_select_admin" on public.profiles for select using (public.current_user_role() = 'ADMIN');
create policy "profiles_insert_own" on public.profiles for insert with check (id = auth.uid());
create policy "profiles_update_own_basic" on public.profiles for update using (id = auth.uid()) with check (id = auth.uid());
create policy "profiles_update_admin" on public.profiles for update using (public.current_user_role() = 'ADMIN') with check (public.current_user_role() = 'ADMIN');
create policy "profiles_delete_own" on public.profiles for delete using (id = auth.uid());

create policy "recordings_select_own" on public.recordings for select using (user_id = auth.uid());
create policy "recordings_insert_own" on public.recordings for insert with check (user_id = auth.uid());
create policy "recordings_update_own" on public.recordings for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "recordings_delete_own" on public.recordings for delete using (user_id = auth.uid());

create policy "transcripts_select_own" on public.transcripts for select using (
  exists (select 1 from public.recordings where recordings.id = transcripts.recording_id and recordings.user_id = auth.uid())
);
create policy "transcripts_insert_own" on public.transcripts for insert with check (
  exists (select 1 from public.recordings where recordings.id = transcripts.recording_id and recordings.user_id = auth.uid())
);
create policy "transcripts_update_own" on public.transcripts for update using (
  exists (select 1 from public.recordings where recordings.id = transcripts.recording_id and recordings.user_id = auth.uid())
) with check (
  exists (select 1 from public.recordings where recordings.id = transcripts.recording_id and recordings.user_id = auth.uid())
);
create policy "transcripts_delete_own" on public.transcripts for delete using (
  exists (select 1 from public.recordings where recordings.id = transcripts.recording_id and recordings.user_id = auth.uid())
);

create policy "feedbacks_select_own" on public.feedbacks for select using (
  exists (select 1 from public.recordings where recordings.id = feedbacks.recording_id and recordings.user_id = auth.uid())
);
create policy "feedbacks_insert_own" on public.feedbacks for insert with check (
  exists (select 1 from public.recordings where recordings.id = feedbacks.recording_id and recordings.user_id = auth.uid())
);
create policy "feedbacks_update_own" on public.feedbacks for update using (
  exists (select 1 from public.recordings where recordings.id = feedbacks.recording_id and recordings.user_id = auth.uid())
) with check (
  exists (select 1 from public.recordings where recordings.id = feedbacks.recording_id and recordings.user_id = auth.uid())
);
create policy "feedbacks_delete_own" on public.feedbacks for delete using (
  exists (select 1 from public.recordings where recordings.id = feedbacks.recording_id and recordings.user_id = auth.uid())
);

create policy "vocabulary_select_own" on public.vocabulary for select using (
  exists (select 1 from public.recordings where recordings.id = vocabulary.recording_id and recordings.user_id = auth.uid())
);
create policy "vocabulary_insert_own" on public.vocabulary for insert with check (
  exists (select 1 from public.recordings where recordings.id = vocabulary.recording_id and recordings.user_id = auth.uid())
);
create policy "vocabulary_update_own" on public.vocabulary for update using (
  exists (select 1 from public.recordings where recordings.id = vocabulary.recording_id and recordings.user_id = auth.uid())
) with check (
  exists (select 1 from public.recordings where recordings.id = vocabulary.recording_id and recordings.user_id = auth.uid())
);
create policy "vocabulary_delete_own" on public.vocabulary for delete using (
  exists (select 1 from public.recordings where recordings.id = vocabulary.recording_id and recordings.user_id = auth.uid())
);

create policy "learning_stats_select_own" on public.learning_stats for select using (user_id = auth.uid());
create policy "learning_stats_insert_own" on public.learning_stats for insert with check (user_id = auth.uid());
create policy "learning_stats_update_own" on public.learning_stats for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "learning_stats_delete_own" on public.learning_stats for delete using (user_id = auth.uid());

create policy "daily_streaks_select_own" on public.daily_streaks for select using (user_id = auth.uid());
create policy "daily_streaks_insert_own" on public.daily_streaks for insert with check (user_id = auth.uid());
create policy "daily_streaks_update_own" on public.daily_streaks for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "daily_streaks_delete_own" on public.daily_streaks for delete using (user_id = auth.uid());

create policy "settings_select_own" on public.settings for select using (user_id = auth.uid());
create policy "settings_insert_own" on public.settings for insert with check (user_id = auth.uid());
create policy "settings_update_own" on public.settings for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "settings_delete_own" on public.settings for delete using (user_id = auth.uid());


create policy "word_usage_select_own" on public.word_usage for select using (user_id = auth.uid());
create policy "word_usage_insert_own" on public.word_usage for insert with check (user_id = auth.uid());
create policy "word_usage_update_own" on public.word_usage for update using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "word_usage_delete_own" on public.word_usage for delete using (user_id = auth.uid());
insert into storage.buckets (id, name, public)
values ('recordings', 'recordings', false)
on conflict (id) do nothing;

create policy "recording_files_select_own" on storage.objects for select using (
  bucket_id = 'recordings' and auth.uid()::text = (storage.foldername(name))[1]
);
create policy "recording_files_insert_own" on storage.objects for insert with check (
  bucket_id = 'recordings' and auth.uid()::text = (storage.foldername(name))[1]
);
create policy "recording_files_update_own" on storage.objects for update using (
  bucket_id = 'recordings' and auth.uid()::text = (storage.foldername(name))[1]
) with check (
  bucket_id = 'recordings' and auth.uid()::text = (storage.foldername(name))[1]
);
create policy "recording_files_delete_own" on storage.objects for delete using (
  bucket_id = 'recordings' and auth.uid()::text = (storage.foldername(name))[1]
);
