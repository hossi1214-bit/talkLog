alter table public.word_usage
  add column if not exists advice_i18n jsonb;

update public.word_usage
set advice_i18n = case
  when coalesce(advice, '') = '' then '{}'::jsonb
  else jsonb_build_object('ja', advice)
end
where advice_i18n is null;

alter table public.word_usage
  alter column advice_i18n set default '{}'::jsonb,
  alter column advice_i18n set not null;
