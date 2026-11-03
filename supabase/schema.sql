-- POOPLE scoreboard schema for Supabase.
-- Run this once in the Supabase SQL editor, then run seed.sql.
-- Safe to re-run: it drops and recreates the function and view, and keeps scores.

-- Words the game accepts, and the daily start word list (same order as index.html).
create table if not exists public.words (
  word text primary key check (word ~ '^[a-z]{4}$')
);

create table if not exists public.start_words (
  idx  int primary key,
  word text not null references public.words (word),
  par  int not null check (par > 0)
);

-- One row per player per day. Only the first finish counts.
create table if not exists public.scores (
  user_id    uuid not null references auth.users (id) on delete cascade,
  day        date not null,
  nick       text not null check (char_length(nick) between 1 and 20),
  start_word text not null,
  path       text[] not null,
  steps      int not null,
  par        int not null,
  created_at timestamptz not null default now(),
  primary key (user_id, day)
);
create index if not exists scores_day_steps on public.scores (day, steps, created_at);

-- Row level security: anyone can read scores; nobody writes directly.
-- Scores are only written through submit_score(), which checks the ladder.
alter table public.words       enable row level security;
alter table public.start_words enable row level security;
alter table public.scores      enable row level security;

drop policy if exists "scores are public" on public.scores;
create policy "scores are public" on public.scores for select using (true);

-- All-time table: average steps over par per player.
drop view if exists public.leaderboard_all;
create view public.leaderboard_all with (security_invoker = true) as
select
  user_id,
  (array_agg(nick order by day desc))[1]             as nick,
  count(*)::int                                      as days,
  count(*) filter (where steps <= par)::int          as pars,
  round(avg(steps - par)::numeric, 2)                as avg_over_par
from public.scores
group by user_id;

grant select on public.scores, public.leaderboard_all to anon, authenticated;

-- Validate a finished ladder and record it.
-- p_day is the player's puzzle date; today or yesterday (Israel time) is accepted,
-- so a game started just before midnight can still be posted.
drop function if exists public.submit_score(text, date, text[]);
create function public.submit_score(p_nick text, p_day date, p_path text[])
returns public.scores
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid   uuid := auth.uid();
  -- Shifts which start word each day gets. Must match WORD_OFFSET in index.html.
  v_offset int := 1;
  v_today date := (now() at time zone 'Asia/Jerusalem')::date;
  v_count int;
  v_idx   int;
  v_start text;
  v_par   int;
  v_len   int := coalesce(array_length(p_path, 1), 0);
  v_diff  int;
  v_row   public.scores;
begin
  if v_uid is null then
    raise exception 'Not signed in';
  end if;

  p_nick := btrim(coalesce(p_nick, ''));
  if char_length(p_nick) not between 1 and 20 then
    raise exception 'Name must be 1 to 20 characters';
  end if;

  if p_day is null or p_day not in (v_today, v_today - 1) then
    raise exception 'That puzzle is closed';
  end if;

  select count(*) into v_count from start_words;
  v_idx := (((p_day - date '2026-11-03' + v_offset) % v_count) + v_count) % v_count;
  select word, par into v_start, v_par from start_words where idx = v_idx;

  if v_len < 2 or p_path[1] <> v_start or p_path[v_len] <> 'poop' then
    raise exception 'The ladder must go from % to poop', upper(v_start);
  end if;

  if (select count(distinct w) from unnest(p_path) as w) <> v_len then
    raise exception 'A word repeats in the ladder';
  end if;

  if exists (select 1 from unnest(p_path) as w where w not in (select word from words)) then
    raise exception 'The ladder has a word that is not in the list';
  end if;

  for i in 2 .. v_len loop
    v_diff := 0;
    for j in 1 .. 4 loop
      if substr(p_path[i], j, 1) <> substr(p_path[i - 1], j, 1) then
        v_diff := v_diff + 1;
      end if;
    end loop;
    if v_diff <> 1 then
      raise exception 'Step % changes % letters', i - 1, v_diff;
    end if;
  end loop;

  insert into scores (user_id, day, nick, start_word, path, steps, par)
  values (v_uid, p_day, p_nick, v_start, p_path, v_len - 1, v_par)
  on conflict (user_id, day) do nothing
  returning * into v_row;

  if not found then
    select * into v_row from scores where user_id = v_uid and day = p_day;
  end if;
  return v_row;
end;
$$;

revoke all on function public.submit_score(text, date, text[]) from public, anon;
grant execute on function public.submit_score(text, date, text[]) to authenticated;
