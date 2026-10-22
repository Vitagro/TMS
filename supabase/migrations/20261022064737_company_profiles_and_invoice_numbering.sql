begin;
create table public.company_profiles (
 id uuid primary key default gen_random_uuid(),owner_id uuid not null unique references auth.users(id) on delete cascade,
 name text not null check(length(trim(name))>0),address text not null,legal_form text,city text,country text,postal_code text,email text,phone text,website text,
 ice text,tax_identifier text,commercial_register text,patente text,cnss text,capital text,bank_details text,payment_terms text,invoice_notes text,
 default_vat_rate numeric(5,2) check(default_vat_rate between 0 and 100),logo_data_url text,
 created_at timestamptz not null default now(),updated_at timestamptz not null default now(),
 constraint profile_logo_check check(logo_data_url is null or (length(logo_data_url)<=350000 and logo_data_url ~ '^data:image/(png|jpeg|webp);base64,[A-Za-z0-9+/=]+$'))
);
alter table public.company_profiles enable row level security;
revoke all on public.company_profiles from anon,authenticated;
grant select,insert,update,delete on public.company_profiles to authenticated;
create policy own_select on public.company_profiles for select to authenticated using((select auth.uid())=owner_id);
create policy own_insert on public.company_profiles for insert to authenticated with check((select auth.uid())=owner_id);
create policy own_update on public.company_profiles for update to authenticated using((select auth.uid())=owner_id) with check((select auth.uid())=owner_id);
create policy own_delete on public.company_profiles for delete to authenticated using((select auth.uid())=owner_id);
alter table public.invoices add column client_id uuid,add column issuer_legal_form text,add column issuer_patente text,add column issuer_cnss text,add column issuer_capital text,add column issuer_website text,add column issuer_logo_data_url text,
 add column client_phone text,add column client_tax_identifier text,add column client_commercial_register text,
 add foreign key(client_id,owner_id) references public.clients(id,owner_id),
 add constraint invoice_logo_check check(issuer_logo_data_url is null or (length(issuer_logo_data_url)<=350000 and issuer_logo_data_url ~ '^data:image/(png|jpeg|webp);base64,[A-Za-z0-9+/=]+$'));
create index invoices_client_idx on public.invoices(client_id,owner_id);
create schema if not exists tms_private;
revoke all on schema tms_private from public,anon,authenticated;
create table tms_private.invoice_counters(owner_id uuid not null references auth.users(id) on delete cascade,year integer not null,last_number bigint not null check(last_number>0),primary key(owner_id,year));
alter table tms_private.invoice_counters enable row level security;
revoke all on tms_private.invoice_counters from public,anon,authenticated;
insert into tms_private.invoice_counters(owner_id,year,last_number)
 select owner_id,substring(number from 5 for 4)::integer,max(split_part(number,'-',3)::bigint) from public.invoices
 where number ~ '^FAC-[0-9]{4}-[0-9]{1,12}$' group by owner_id,substring(number from 5 for 4)::integer;
-- A private, narrowly scoped trigger alone can increment the protected counter.
create function tms_private.assign_invoice_number() returns trigger language plpgsql security definer set search_path='' as $$
declare sequence_number bigint;invoice_year integer;
begin
 if (select auth.uid()) is null or (select auth.uid()) is distinct from new.owner_id then raise exception 'Invoice owner must match the authenticated user' using errcode='42501';end if;
 invoice_year=extract(year from new.issue_date)::integer;
 insert into tms_private.invoice_counters(owner_id,year,last_number) values(new.owner_id,invoice_year,1)
 on conflict(owner_id,year) do update set last_number=tms_private.invoice_counters.last_number+1
 returning last_number into sequence_number;
 new.number='FAC-'||invoice_year::text||'-'||pg_catalog.lpad(sequence_number::text,pg_catalog.greatest(6,pg_catalog.length(sequence_number::text)),'0');
 return new;
end $$;
revoke all on function tms_private.assign_invoice_number() from public,anon,authenticated;
create trigger invoice_number_before_insert before insert on public.invoices for each row execute function tms_private.assign_invoice_number();
create function tms_private.protect_invoice_number() returns trigger language plpgsql security invoker set search_path='' as $$
begin
 if new.number is distinct from old.number or new.owner_id is distinct from old.owner_id then raise exception 'Invoice number and owner cannot be changed';end if;
 if extract(year from new.issue_date)<>extract(year from old.issue_date) then raise exception 'The issue year of a numbered invoice cannot be changed';end if;
 return new;
end $$;
revoke all on function tms_private.protect_invoice_number() from public,anon,authenticated;
create trigger invoice_number_before_update before update on public.invoices for each row execute function tms_private.protect_invoice_number();
commit;
