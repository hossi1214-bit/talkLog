-- TalkLog recording audio size migration
-- Run this in the Supabase SQL editor to support cloud storage usage meters.

alter table public.recordings
  add column if not exists audio_size_bytes bigint not null default 0;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'recordings_audio_size_bytes_check'
      and conrelid = 'public.recordings'::regclass
  ) then
    alter table public.recordings
      add constraint recordings_audio_size_bytes_check
      check (audio_size_bytes >= 0);
  end if;
end $$;

-- Existing rows stay at 0 until the app re-syncs the recording.
-- New uploads set recordings.audio_size_bytes from the local audio file size.
