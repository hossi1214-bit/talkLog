-- Add review history fields to vocabulary.
-- Run this in the Supabase SQL editor once for existing projects.

alter table public.vocabulary
  add column if not exists review_count integer not null default 0 check (review_count >= 0),
  add column if not exists last_reviewed_at timestamptz;

create index if not exists vocabulary_review_status_idx
  on public.vocabulary(language, is_reviewed, last_reviewed_at desc);