begin;
create table public.clients (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id) on delete cascade,
 name text not null check(length(trim(name))>0),contact_name text,email text,phone text,address text,ice text,tax_identifier text,commercial_register text,payment_terms text,bank_details text,
 pricing_basis text not null default 'Trajet' check(pricing_basis in ('Trajet','Kilomètre','Jour','Semaine','Mois')),
 unit_rate numeric(12,2) not null default 0 check(unit_rate>=0),payment_method text not null default 'Virement' check(payment_method in ('Virement','Chèque','Espèces','Autre')),
 payment_due_days integer not null default 0 check(payment_due_days>=0),created_at timestamptz not null default now(),unique(id,owner_id)
);
alter table public.clients enable row level security;
revoke all on public.clients from anon,authenticated;
grant select,insert,update,delete on public.clients to authenticated;
create index clients_owner_idx on public.clients(owner_id);
create policy own_select on public.clients for select to authenticated using((select auth.uid())=owner_id);
create policy own_insert on public.clients for insert to authenticated with check((select auth.uid())=owner_id);
create policy own_update on public.clients for update to authenticated using((select auth.uid())=owner_id) with check((select auth.uid())=owner_id);
create policy own_delete on public.clients for delete to authenticated using((select auth.uid())=owner_id);
alter table public.lessors add column pricing_basis text not null default 'Trajet' check(pricing_basis in ('Trajet','Kilomètre','Jour','Semaine','Mois')),add column unit_rate numeric(12,2) not null default 0 check(unit_rate>=0),add column payment_method text not null default 'Virement' check(payment_method in ('Virement','Chèque','Espèces','Autre')),add column payment_due_days integer not null default 0 check(payment_due_days>=0),add column bank_details text;
alter table public.trips add column client_id uuid,add column lessor_id uuid,
 add column sale_basis text not null default 'Trajet' check(sale_basis in ('Trajet','Kilomètre','Jour','Semaine','Mois')),add column sale_rate numeric(12,2) check(sale_rate>=0),add column sale_quantity numeric(12,2) not null default 1 check(sale_quantity>0),
 add column purchase_basis text not null default 'Trajet' check(purchase_basis in ('Trajet','Kilomètre','Jour','Semaine','Mois')),add column purchase_rate numeric(12,2) check(purchase_rate>=0),add column purchase_quantity numeric(12,2) not null default 1 check(purchase_quantity>0),
 add foreign key(client_id,owner_id) references public.clients(id,owner_id),add foreign key(lessor_id,owner_id) references public.lessors(id,owner_id);
create index trips_client_idx on public.trips(client_id,owner_id);
create index trips_lessor_idx on public.trips(lessor_id,owner_id);
create function public.calculate_trip_pricing() returns trigger language plpgsql security invoker set search_path='' as $$
begin
 if new.sale_rate is not null then new.revenue=pg_catalog.round(new.sale_rate*new.sale_quantity,2); end if;
 if new.purchase_rate is not null then new.subcontract_cost=pg_catalog.round(new.purchase_rate*new.purchase_quantity,2); end if;
 return new;
end $$;
revoke all on function public.calculate_trip_pricing() from public,anon,authenticated;
create trigger trip_pricing_before_write before insert or update on public.trips for each row execute function public.calculate_trip_pricing();
commit;
