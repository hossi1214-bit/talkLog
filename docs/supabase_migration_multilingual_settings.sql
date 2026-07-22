-- Add the user's base locale and normalize language values to stable codes.
-- Run this once in the Supabase SQL editor for existing projects.

alter table public.settings
  add column if not exists base_locale text not null default 'ja';

update public.settings
set learning_language = case learning_language
  when '日本語' then 'ja'
  when '英語' then 'en'
  when 'スペイン語' then 'es'
  when 'フランス語' then 'fr'
  when 'ドイツ語' then 'de'
  when 'イタリア語' then 'it'
  when '韓国語' then 'ko'
  when '中国語' then 'zh-Hans'
  else learning_language
end;

update public.profiles
set learning_language = case learning_language
  when '日本語' then 'ja'
  when '英語' then 'en'
  when 'スペイン語' then 'es'
  when 'フランス語' then 'fr'
  when 'ドイツ語' then 'de'
  when 'イタリア語' then 'it'
  when '韓国語' then 'ko'
  when '中国語' then 'zh-Hans'
  else learning_language
end;

update public.settings
set learning_language = 'es'
where learning_language not in ('ja', 'en', 'es', 'fr', 'de', 'it', 'ko', 'zh-Hans');

update public.profiles
set learning_language = 'es'
where learning_language not in ('ja', 'en', 'es', 'fr', 'de', 'it', 'ko', 'zh-Hans');

-- Existing Japanese learners receive English as a safe non-conflicting
-- learning language because the new default base locale is Japanese.
update public.settings
set learning_language = 'en'
where learning_language = base_locale;

alter table public.settings
  alter column learning_language set default 'es',
  alter column base_locale set default 'ja';

alter table public.profiles
  alter column learning_language set default 'es';

alter table public.settings
  drop constraint if exists settings_base_locale_check,
  drop constraint if exists settings_learning_language_check,
  drop constraint if exists settings_language_pair_check;

alter table public.settings
  add constraint settings_base_locale_check
    check (base_locale in ('ja', 'en', 'es')),
  add constraint settings_learning_language_check
    check (learning_language in ('ja', 'en', 'es', 'fr', 'de', 'it', 'ko', 'zh-Hans')),
  add constraint settings_language_pair_check
    check (base_locale <> learning_language);

alter table public.profiles
  drop constraint if exists profiles_learning_language_check;

alter table public.profiles
  add constraint profiles_learning_language_check
    check (learning_language in ('ja', 'en', 'es', 'fr', 'de', 'it', 'ko', 'zh-Hans'));
