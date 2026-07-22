alter table public.vocabulary
  add column if not exists learning_language text,
  add column if not exists base_locale text,
  add column if not exists example_translation text,
  add column if not exists language_metadata jsonb;

update public.vocabulary
set
  learning_language = coalesce(learning_language, language),
  base_locale = coalesce(base_locale, 'ja'),
  language_metadata = coalesce(language_metadata, '{}'::jsonb);

alter table public.vocabulary
  alter column learning_language set not null,
  alter column base_locale set default 'ja',
  alter column base_locale set not null,
  alter column language_metadata set default '{}'::jsonb,
  alter column language_metadata set not null;

create index if not exists vocabulary_language_locale_idx
  on public.vocabulary (learning_language, base_locale, word);
