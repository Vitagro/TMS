create or replace function tms_private.assign_invoice_number() returns trigger language plpgsql security definer set search_path='' as $$
declare sequence_number bigint;invoice_year integer;
begin
 if (select auth.uid()) is null or (select auth.uid()) is distinct from new.owner_id then raise exception 'Invoice owner must match the authenticated user' using errcode='42501';end if;
 invoice_year=extract(year from new.issue_date)::integer;
 insert into tms_private.invoice_counters(owner_id,year,last_number) values(new.owner_id,invoice_year,1)
 on conflict(owner_id,year) do update set last_number=tms_private.invoice_counters.last_number+1
 returning last_number into sequence_number;
 new.number='FAC-'||invoice_year::text||'-'||case when pg_catalog.length(sequence_number::text)<6 then pg_catalog.lpad(sequence_number::text,6,'0') else sequence_number::text end;
 return new;
end $$;
revoke all on function tms_private.assign_invoice_number() from public,anon,authenticated;
