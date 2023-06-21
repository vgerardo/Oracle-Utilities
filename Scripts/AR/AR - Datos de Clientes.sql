

select customer_name, customer_number, taxpayer_id RFC, customer_id
from AR_CUSTOMERS
where status = 'A'
and customer_name like 'VIAJES EL CORTE INGLES SA DE CV'
order by 1
;

select hzp.party_name, hzp.customer_key, hzp.jgzz_fiscal_code
from hz_parties hzp     
where hzp.status = 'A'
  and nvl(hzp.application_id,0) <> 200
  and exists (select 1 
                from ar_customers arc
                where arc.customer_key = hzp.customer_key
                  and arc.customer_name = hzp.party_name
            )
and hzp.party_name like 'VIAJES EL CORTE INGLES SA DE CV'
order by 1;


--
-- Datos de Clientes de AR
--
select cust.cust_account_id, 
       acct.cust_acct_site_id, acct.orig_system_reference,
       ship.site_use_id, ship.primary_flag,
       party_site.party_site_id,
       loc.location_id,
       party.party_name
       ,PARTY.jgzz_fiscal_code
FROM hz_cust_accounts       cust,
     hz_cust_acct_sites_all acct,
     hz_cust_site_uses_all  ship,
     hz_party_sites         party_site,
     hz_locations           loc,
     hz_parties party
WHERE cust.cust_account_id   = acct.cust_account_id
  and acct.cust_acct_site_id = ship.cust_acct_site_id
  and acct.org_id            = ship.org_id
  and loc.location_id = party_site.location_id
  and acct.party_site_id = party_site.party_site_id
  and cust.party_id = party.party_id
  and ship.site_use_code = 'BILL_TO'
  --and ship.org_id = 651
  --and cust.account_number = '86896703'
  and party.party_name like 'VIAJES EL CORTE INGLES SA DE CV'
  and jgzz_fiscal_code = 'GERARDO1'
  ;

    
SELECT c.name, cp.party_id
FROM ar_collectors          c
     ,hz_customer_profiles   cp     
WHERE c.collector_id = cp.collector_id
 and c.status = 'A'
 and cp.status = 'A'
 and cp.cust_account_id = 3806
;