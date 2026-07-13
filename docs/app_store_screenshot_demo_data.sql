-- TalkLog screenshot demo data
-- Supabase SQL Editorで実行します。
-- 1) 先にアプリから撮影用ユーザーでメール登録/ログインしてください。
-- 2) v_email を撮影用ユーザーのメールアドレスに変更してください。
-- 3) 実行すると、そのユーザーにスクショ用デモデータを作成します。

begin;

-- Existing projects may not have the latest vocabulary review columns yet.
alter table public.vocabulary
  add column if not exists review_count integer not null default 0 check (review_count >= 0),
  add column if not exists last_reviewed_at timestamptz;

do $$
declare
  v_email text := 'screenshot-test@example.com';
  v_user_id uuid;
  v_rec_morning uuid := gen_random_uuid();
  v_rec_work uuid := gen_random_uuid();
  v_rec_weekend uuid := gen_random_uuid();
  v_rec_travel uuid := gen_random_uuid();
begin
  select id into v_user_id
  from public.profiles
  where email = v_email;

  if v_user_id is null then
    raise exception 'Profile not found for %. Log in with this email first, then run this SQL.', v_email;
  end if;

  update public.profiles
  set
    role = 'TESTER',
    learning_language = '英語',
    updated_at = now()
  where id = v_user_id;

  insert into public.settings (user_id, learning_language, notification_enabled, theme, updated_at)
  values (v_user_id, '英語', false, 'system', now())
  on conflict (user_id) do update set
    learning_language = excluded.learning_language,
    notification_enabled = excluded.notification_enabled,
    theme = excluded.theme,
    updated_at = now();

  delete from public.recordings
  where user_id = v_user_id
    and local_audio_path = 'screenshot-demo';

  insert into public.recordings (
    id,
    user_id,
    language,
    audio_path,
    local_audio_path,
    audio_size_bytes,
    duration_seconds,
    created_at,
    updated_at
  ) values
    (v_rec_morning, v_user_id, '英語', null, 'screenshot-demo', 1230000, 48, now() - interval '1 hour', now() - interval '1 hour'),
    (v_rec_work, v_user_id, '英語', null, 'screenshot-demo', 1640000, 64, now() - interval '1 day', now() - interval '1 day'),
    (v_rec_weekend, v_user_id, '英語', null, 'screenshot-demo', 980000, 36, now() - interval '3 days', now() - interval '3 days'),
    (v_rec_travel, v_user_id, 'スペイン語', null, 'screenshot-demo', 1410000, 52, now() - interval '6 days', now() - interval '6 days');

  insert into public.transcripts (recording_id, original_text, language, created_at) values
    (v_rec_morning, 'Today I want to practice English before work. I feel a little nervous, but I want to keep going.', '英語', now() - interval '1 hour'),
    (v_rec_work, 'I was tired after work, but I still practiced speaking for a few minutes.', '英語', now() - interval '1 day'),
    (v_rec_weekend, 'This weekend I am going to meet my friend and talk about our travel plans.', '英語', now() - interval '3 days'),
    (v_rec_travel, 'Quiero practicar frases para registrarme en el hotel durante mi viaje.', 'スペイン語', now() - interval '6 days');

  insert into public.feedbacks (
    recording_id,
    corrected_text,
    natural_expression,
    translation_ja,
    grammar_feedback,
    vocabulary_feedback,
    score,
    comment,
    created_at
  ) values
    (
      v_rec_morning,
      'Today, I want to practice English before work. I feel a little nervous, but I want to keep going.',
      'I would like to practice English before work today. I am a little nervous, but I want to keep it up.',
      '今日は仕事の前に英語を練習したいです。少し緊張していますが、続けていきたいです。',
      '["want to は自然ですが、would like to にすると少し丁寧です。", "keep going は継続したい気持ちを表す自然な表現です。"]'::jsonb,
      '["nervous: 緊張している", "keep it up: 続ける、維持する"]'::jsonb,
      86,
      '短い文章でも気持ちがよく伝わっています。継続できているのがとても良いです。',
      now() - interval '55 minutes'
    ),
    (
      v_rec_work,
      'I was tired after work, but I still practiced speaking for a few minutes.',
      'I was exhausted after work, but I still managed to practice speaking for a few minutes.',
      '仕事の後で疲れていましたが、それでも数分間スピーキング練習ができました。',
      '["still を入れることで、それでも続けたニュアンスが出ています。", "managed to は、難しい中でも何とかできた時に便利です。"]'::jsonb,
      '["exhausted: とても疲れた", "manage to: 何とか〜する"]'::jsonb,
      89,
      '疲れている日でも練習できていて素晴らしいです。',
      now() - interval '1 day'
    ),
    (
      v_rec_weekend,
      'This weekend, I am going to meet my friend and talk about our travel plans.',
      'This weekend, I am meeting a friend to talk about our travel plans.',
      '今週末、友人に会って旅行の計画について話す予定です。',
      '["be going to でも正しいですが、予定が決まっている場合は am meeting も自然です。"]'::jsonb,
      '["travel plans: 旅行の計画", "meet a friend: 友人に会う"]'::jsonb,
      82,
      '予定を説明する表現が自然に使えています。',
      now() - interval '3 days'
    ),
    (
      v_rec_travel,
      'Quiero practicar frases para registrarme en el hotel durante mi viaje.',
      'Quiero practicar algunas frases para hacer el check-in en el hotel durante mi viaje.',
      '旅行中にホテルでチェックインするための表現を練習したいです。',
      '["algunas frases を入れると、いくつかの表現という自然な響きになります。", "hacer el check-in はホテルでよく使う表現です。"]'::jsonb,
      '["hacer el check-in: チェックインする", "durante mi viaje: 旅行中に"]'::jsonb,
      84,
      '旅行場面を想定した実用的な練習になっています。',
      now() - interval '6 days'
    );

  insert into public.vocabulary (
    recording_id,
    language,
    word,
    meaning,
    example,
    is_reviewed,
    review_count,
    last_reviewed_at,
    created_at
  ) values
    (v_rec_morning, '英語', 'nervous', '緊張している', 'I feel a little nervous before speaking English.', true, 2, now() - interval '1 day', now() - interval '55 minutes'),
    (v_rec_morning, '英語', 'keep it up', '続ける、維持する', 'You are doing well. Keep it up.', false, 0, null, now() - interval '55 minutes'),
    (v_rec_work, '英語', 'exhausted', 'とても疲れた', 'I was exhausted after work.', true, 1, now() - interval '12 hours', now() - interval '1 day'),
    (v_rec_work, '英語', 'manage to', '何とか〜する', 'I managed to practice today.', false, 0, null, now() - interval '1 day'),
    (v_rec_weekend, '英語', 'travel plans', '旅行の計画', 'We talked about our travel plans.', false, 0, null, now() - interval '3 days'),
    (v_rec_travel, 'スペイン語', 'hacer el check-in', 'チェックインする', 'Quiero hacer el check-in en el hotel.', false, 0, null, now() - interval '6 days');

  insert into public.word_usage (user_id, language, word, count, alternative_words, advice, updated_at) values
    (v_user_id, '英語', 'practice', 10, '["work on", "train", "keep practicing"]'::jsonb, 'practice は自然ですが、work on を使うと「取り組む」ニュアンスになります。', now()),
    (v_user_id, '英語', 'tired', 8, '["exhausted", "worn out", "drained"]'::jsonb, 'tired の代わりに exhausted を使うと「とても疲れた」が伝わります。', now()),
    (v_user_id, '英語', 'work', 7, '["job", "task", "project"]'::jsonb, 'work は広い表現です。内容に応じて task や project に言い換えられます。', now()),
    (v_user_id, '英語', 'want', 6, '["would like to", "hope to", "feel like"]'::jsonb, 'want to は会話で自然です。丁寧に言うなら would like to が便利です。', now()),
    (v_user_id, '英語', 'today', 5, '["this morning", "this evening", "earlier today"]'::jsonb, 'today に時間帯を足すと、より具体的に話せます。', now()),
    (v_user_id, 'スペイン語', 'hotel', 4, '["alojamiento", "recepción", "check-in"]'::jsonb, 'hotel に加えて recepción を覚えると旅行会話で便利です。', now())
  on conflict (user_id, language, word) do update set
    count = excluded.count,
    alternative_words = excluded.alternative_words,
    advice = excluded.advice,
    updated_at = now();

  insert into public.learning_stats (
    user_id,
    language,
    total_recordings,
    total_duration_seconds,
    current_streak,
    best_streak,
    average_score,
    updated_at
  ) values
    (v_user_id, 'すべて', 12, 720, 5, 8, 86, now()),
    (v_user_id, '英語', 9, 540, 5, 8, 86, now()),
    (v_user_id, 'スペイン語', 3, 180, 2, 3, 84, now())
  on conflict (user_id, language) do update set
    total_recordings = excluded.total_recordings,
    total_duration_seconds = excluded.total_duration_seconds,
    current_streak = excluded.current_streak,
    best_streak = excluded.best_streak,
    average_score = excluded.average_score,
    updated_at = now();

  insert into public.daily_streaks (user_id, language, learning_date, recording_count, created_at) values
    (v_user_id, 'すべて', current_date, 2, now()),
    (v_user_id, 'すべて', current_date - 1, 1, now() - interval '1 day'),
    (v_user_id, 'すべて', current_date - 2, 2, now() - interval '2 days'),
    (v_user_id, 'すべて', current_date - 3, 1, now() - interval '3 days'),
    (v_user_id, 'すべて', current_date - 4, 1, now() - interval '4 days'),
    (v_user_id, '英語', current_date, 2, now()),
    (v_user_id, '英語', current_date - 1, 1, now() - interval '1 day'),
    (v_user_id, '英語', current_date - 2, 2, now() - interval '2 days'),
    (v_user_id, '英語', current_date - 3, 1, now() - interval '3 days'),
    (v_user_id, 'スペイン語', current_date - 1, 1, now() - interval '1 day'),
    (v_user_id, 'スペイン語', current_date - 2, 1, now() - interval '2 days')
  on conflict (user_id, language, learning_date) do update set
    recording_count = excluded.recording_count;
end $$;

commit;
