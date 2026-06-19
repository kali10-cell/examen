create extension if not exists pgcrypto;

create table if not exists public.pedido (
  id text primary key,
  name text not null,
  description text not null,
  price_cents integer not null,
  currency text not null default 'eur',
  type text not null default 'digital',
  created_at timestamptz not null default now()
);


alter table public.pedidos enable row level security;
alter table public.pedido_items enable row level security;

drop policy if exists "autenticado: crear pedidos" on public.pedidos;
create policy "autenticado: crear pedidos"
  on public.pedidos for insert
  with check (
    auth.role() = 'authenticated'
    and cliente_id = auth.uid()
  );

drop policy if exists "cliente: insertar items" on public.pedido_items;
create policy "cliente: insertar items"
  on public.pedido_items for insert
  with check (
    exists (
      select 1
      from public.pedidos
      where pedidos.id = pedido_items.pedido_id
        and pedidos.cliente_id = auth.uid()
    )
  );
