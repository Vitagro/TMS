alter table public.invoices add column internal_partner_details text;
comment on column public.invoices.internal_partner_details is 'Internal client and lessor snapshot, excluded from customer invoice printing';
