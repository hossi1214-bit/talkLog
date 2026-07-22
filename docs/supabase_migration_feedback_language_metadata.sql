alter table public.feedbacks
  add column if not exists learning_language text,
  add column if not exists base_locale text,
  add column if not exists prompt_version text;

update public.feedbacks as feedback
set learning_language = coalesce(feedback.learning_language, recording.language)
from public.recordings as recording
where recording.id = feedback.recording_id
  and feedback.learning_language is null;

update public.feedbacks
set
  learning_language = coalesce(learning_language, 'es'),
  base_locale = coalesce(base_locale, 'ja'),
  prompt_version = coalesce(prompt_version, 'legacy-v1');

alter table public.feedbacks
  alter column learning_language set not null,
  alter column base_locale set default 'ja',
  alter column base_locale set not null,
  alter column prompt_version set default 'legacy-v1',
  alter column prompt_version set not null;

create index if not exists feedbacks_language_metadata_idx
  on public.feedbacks (recording_id, learning_language, base_locale, prompt_version);
