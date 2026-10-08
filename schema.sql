-- À coller une seule fois dans Supabase > SQL Editor > New query > Run.
-- Une ligne par jour et par utilisateur. Chaque personne ne voit et ne modifie que ses propres pesées.

create table if not exists public.weights (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  day date not null,
  kg numeric(4,1) not null check (kg >= 20 and kg <= 400),
  updated_at timestamptz not null default now(),
  primary key (user_id, day)
);

alter table public.weights enable row level security;

drop policy if exists "weights_select_own" on public.weights;
drop policy if exists "weights_insert_own" on public.weights;
drop policy if exists "weights_update_own" on public.weights;
drop policy if exists "weights_delete_own" on public.weights;

create policy "weights_select_own" on public.weights
  for select to authenticated using ((select auth.uid()) = user_id);

create policy "weights_insert_own" on public.weights
  for insert to authenticated with check ((select auth.uid()) = user_id);

create policy "weights_update_own" on public.weights
  for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "weights_delete_own" on public.weights
  for delete to authenticated using ((select auth.uid()) = user_id);

-- Aucun accès pour les visiteurs non connectés.
revoke all on public.weights from anon;
grant select, insert, update, delete on public.weights to authenticated;
