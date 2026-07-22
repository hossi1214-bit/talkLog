alter table public.feedbacks
  drop constraint if exists feedbacks_recording_id_key;

alter table public.feedbacks
  add constraint feedbacks_recording_language_locale_prompt_key
  unique (recording_id, learning_language, base_locale, prompt_version);

create index if not exists feedbacks_current_result_lookup_idx
  on public.feedbacks (
    recording_id,
    learning_language,
    base_locale,
    prompt_version,
    created_at desc
  );
