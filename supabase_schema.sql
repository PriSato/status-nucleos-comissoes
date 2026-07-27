-- ============================================================
-- Controle de Núcleos e Comissões — backend (Supabase)
-- Reaproveita o MESMO projeto do app principal, mas em tabelas
-- PRÓPRIAS (prefixo ncom_), isoladas das demais auditorias.
--
-- Papéis: qualquer usuário autenticado LÊ (somente leitura);
-- apenas os e-mails na lista ncom_admins podem GRAVAR (editar).
--
-- Como rodar: painel do Supabase > SQL Editor > New query >
-- cole tudo > Run. Pode rodar novamente sem problema (idempotente).
-- ============================================================

-- 1) Tabela de dados (chave/valor), separada do kv_store das outras auditorias
create table if not exists public.ncom_store (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

-- 2) Lista de administradores (editores). Só estes e-mails podem gravar.
create table if not exists public.ncom_admins (
  email text primary key
);

-- Semeia os 2 editores (troque/adicione e-mails aqui quando precisar):
insert into public.ncom_admins (email) values
  ('prikams@yahoo.com.br'),
  ('lucasaraujo74164@gmail.com')
on conflict (email) do nothing;

-- 3) Função utilitária de updated_at (reaproveita se já existir do outro app)
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_ncom_store_updated_at on public.ncom_store;
create trigger trg_ncom_store_updated_at
  before update on public.ncom_store
  for each row execute function public.set_updated_at();

-- 4) O usuário logado é administrador? (security definer p/ ler ncom_admins sem RLS)
create or replace function public.ncom_is_admin()
returns boolean as $$
  select exists (
    select 1 from public.ncom_admins a
    where lower(a.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$ language sql stable security definer;

-- 5) RLS na tabela de dados: leitura p/ autenticados, escrita só p/ admins
alter table public.ncom_store enable row level security;

drop policy if exists "ncom_store_select" on public.ncom_store;
create policy "ncom_store_select" on public.ncom_store
  for select using (auth.role() = 'authenticated');

drop policy if exists "ncom_store_insert" on public.ncom_store;
create policy "ncom_store_insert" on public.ncom_store
  for insert with check (public.ncom_is_admin());

drop policy if exists "ncom_store_update" on public.ncom_store;
create policy "ncom_store_update" on public.ncom_store
  for update using (public.ncom_is_admin()) with check (public.ncom_is_admin());

drop policy if exists "ncom_store_delete" on public.ncom_store;
create policy "ncom_store_delete" on public.ncom_store
  for delete using (public.ncom_is_admin());

-- 6) ncom_admins: autenticados podem LER (p/ o app saber se é admin).
--    Não há policy de escrita → a lista só é alterada aqui pelo SQL Editor.
alter table public.ncom_admins enable row level security;

drop policy if exists "ncom_admins_select" on public.ncom_admins;
create policy "ncom_admins_select" on public.ncom_admins
  for select using (auth.role() = 'authenticated');
