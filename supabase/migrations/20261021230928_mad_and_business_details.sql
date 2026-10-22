begin;
do $$ begin
 if exists(select 1 from public.trips) or exists(select 1 from public.fuel) or exists(select 1 from public.vehicles) or exists(select 1 from public.invoices) then
 raise exception 'Existing monetary records require an explicit currency conversion plan'; end if;
end $$;
alter table public.trips add column currency text not null default 'MAD' check(currency='MAD'),add column order_reference text,add column subcontractor text,add column cargo text,add column weight_tons numeric(12,2) check(weight_tons>=0),add column delivery_date date,add column loading_address text,add column delivery_address text,add column contact_phone text,add column notes text,add constraint trips_delivery_order check(delivery_date is null or delivery_date>=departure_date);
alter table public.fuel add column currency text not null default 'MAD' check(currency='MAD'),add column station text,add column receipt_reference text,add column notes text;
alter table public.vehicles add column currency text not null default 'MAD' check(currency='MAD'),add column category text,add column capacity_tons numeric(12,2) check(capacity_tons>=0),add column insurance_expiry date,add column inspection_expiry date,add column notes text;
alter table public.lessors add column contact_name text,add column ice text,add column tax_identifier text,add column commercial_register text,add column payment_terms text;
alter table public.drivers add column license_number text,add column license_category text,add column notes text;
alter table public.invoices add column currency text not null default 'MAD' check(currency='MAD'),add column description text,add column issuer_name text,add column issuer_address text,add column issuer_email text,add column issuer_phone text,add column issuer_ice text,add column issuer_tax_identifier text,add column issuer_commercial_register text,add column client_address text,add column client_ice text,add column client_email text,add column payment_method text check(payment_method is null or payment_method in ('Virement','Chèque','Espèces','Autre')),add column payment_terms text,add column bank_details text,add column paid_date date,add column notes text;
alter table public.invoices alter column vat_rate drop default;
commit;
