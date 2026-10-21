begin;
create table public.lessors (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null references auth.users(id) on delete cascade,
 name text not null check(length(trim(name))>0),email text,phone text,address text,created_at timestamptz not null default now(),unique(id,owner_id)
);
create table public.drivers (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id) on delete cascade,
 name text not null check(length(trim(name))>0),email text,phone text,license_expiry date,
 status text not null default 'Disponible' check(status in ('Disponible','En mission','Absent')),created_at timestamptz not null default now(),unique(id,owner_id)
);
create table public.vehicles (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id) on delete cascade,
 registration text not null check(length(trim(registration))>0),model text not null,lessor_id uuid,
 monthly_rent numeric(12,2) not null default 0 check(monthly_rent>=0),status text not null default 'Disponible' check(status in ('Disponible','En mission','Maintenance')),
 created_at timestamptz not null default now(),unique(id,owner_id),unique(owner_id,registration),foreign key(lessor_id,owner_id) references public.lessors(id,owner_id)
);
create table public.trips (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id) on delete cascade,
 reference text not null,client text not null,origin text not null,destination text not null,departure_date date not null,
 vehicle_id uuid,driver_id uuid,distance_km numeric(12,2) not null default 0 check(distance_km>=0),
 revenue numeric(12,2) not null check(revenue>=0),subcontract_cost numeric(12,2) not null default 0 check(subcontract_cost>=0),other_cost numeric(12,2) not null default 0 check(other_cost>=0),
 status text not null default 'Planifié' check(status in ('Planifié','En cours','Terminé','Annulé')),created_at timestamptz not null default now(),
 unique(id,owner_id),unique(owner_id,reference),foreign key(vehicle_id,owner_id) references public.vehicles(id,owner_id),foreign key(driver_id,owner_id) references public.drivers(id,owner_id)
);
create table public.fuel (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id) on delete cascade,
 vehicle_id uuid not null,trip_id uuid,date date not null,liters numeric(12,2) not null check(liters>0),amount numeric(12,2) not null check(amount>=0),odometer numeric(12,2) not null default 0 check(odometer>=0),
 created_at timestamptz not null default now(),foreign key(vehicle_id,owner_id) references public.vehicles(id,owner_id),foreign key(trip_id,owner_id) references public.trips(id,owner_id)
);
create table public.invoices (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id) on delete cascade,
 number text not null,trip_id uuid,client text not null,issue_date date not null,due_date date not null,amount numeric(12,2) not null check(amount>=0),vat_rate numeric(5,2) not null default 20 check(vat_rate between 0 and 100),
 status text not null default 'Brouillon' check(status in ('Brouillon','Émise','Payée','Annulée')),created_at timestamptz not null default now(),
 unique(owner_id,number),check(due_date>=issue_date),foreign key(trip_id,owner_id) references public.trips(id,owner_id)
);
-- Composite foreign keys prevent linking records owned by another account.
do $$ declare t text; begin
 foreach t in array array['lessors','drivers','vehicles','trips','fuel','invoices'] loop
 execute format('alter table public.%I enable row level security',t);
 execute format('revoke all on table public.%I from anon, authenticated',t);
 execute format('grant select, insert, update, delete on table public.%I to authenticated',t);
 execute format('create index %I on public.%I(owner_id)',t||'_owner_idx',t);
 execute format('create policy own_select on public.%I for select to authenticated using ((select auth.uid())=owner_id)',t);
 execute format('create policy own_insert on public.%I for insert to authenticated with check ((select auth.uid())=owner_id)',t);
 execute format('create policy own_update on public.%I for update to authenticated using ((select auth.uid())=owner_id) with check ((select auth.uid())=owner_id)',t);
 execute format('create policy own_delete on public.%I for delete to authenticated using ((select auth.uid())=owner_id)',t);
 end loop;
end $$;
create index trips_departure_idx on public.trips(owner_id,departure_date);
create index fuel_trip_idx on public.fuel(trip_id);
commit;
