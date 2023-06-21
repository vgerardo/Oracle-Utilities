
SELECT *
from  WSH.wsh_locations  loc
WHERE 1=1
  --and wsh_location_id = 55944
  aND location_code like 'KMX%'
;



select  loc.wsh_location_id         location_id
        ,ou.name                    ou_name
        ,null                       org_code
        ,loc.ui_location_code
        ,loc.address1                calle
        ,loc.country
        ,loc.postal_code
        ,ou.organization_id     ou_org_id
        ,xr.registration_number    rfc
        ,OU.*
        ;
        select loc.*
  from
     --hr_organization_units   ou
      wsh.wsh_locations       loc
      --,xle_registrations  xr
      --,xle_entity_profiles     ep
 where 1=1
   --and ou.location_id = loc.wsh_location_id
   --and loc.wsh_location_id = xr.location_id   
   --and xr.source_id = ep.legal_entity_id
   --and xr.source_table = 'XLE_ENTITY_PROFILES'
  --and ep.le_information_context = 'MX'
  -- -----------------------------
--  --and ou.organization_id = 107
  AND loc.wsh_location_id = 42026
  -- -----------------------------  
;


select *
from xle_le_ou_ledger_v
where operating_unit_id = 108
--  and legal_entity_id = 24281
;


SELECT * FROM WSH_LOCATIONS_HR_V;


SELECT * 
FROM WSH_SHIP_TO_LOCATIONS_V
where WSH_LOCATION_ID = 55944
;

SELECT *
FROM WSH_SHIP_FROM_ORG_LOCATIONS_V
where organization_code in ( 'KMX', 'E1')
--organization_id = 108
;

SELECT 
          wsf.wsh_location_id               wsh_location_id
        , wsf.location_id  
        , wsf.organization_id           org_id
        , wsf.organization_code         org_code        
        , wsf.organization_name         ou_name 
        --, xr.registration_number      rfc
        , wsf.postal_code
        , wsf.address1                  calle
        , wsf.city
        , wsf.state
        , wsf.country
        , wsf.ui_location_code
        , xr.registration_number    rfc
        ,wsf.set_of_books_id
FROM wsh_ship_from_locations_v      wsf
    ,org_organization_definitions   ood
    ,xle_registrations              xr
WHERE 1=1
  and wsf.organization_id = ood.organization_id (+)
  and ood.legal_entity   = xr.source_id (+)
  and wsf.set_of_books_id = 2021
--  and wsf.wsh_location_id = 165
;


SELECT L.LOCATION_ID
    from
         hr_locations                   l
       , hr_all_organization_units      ou
       , org_organization_definitions   ood
       , xle_entity_profiles            xep
       , apps.xle_registrations         xr
       , hz_parties                     hp
    where 1=1
      and ou.location_id     = l.location_id
      and ou.organization_id = ood.organization_id
      and ood.legal_entity   = xep.legal_entity_id
      and xep.legal_entity_id=  xr.source_id
      and xep.party_id       = hp.party_id
     
      and xr.SOURCE_TABLE    = 'XLE_ENTITY_PROFILES'
      and xr.identifying_flag= 'Y'
     -- and ou.type            = 'INVENTORY ORGANIZATION'
      and ood.set_of_books_id = 2021 --solo méxico
      --and l.location_id      = 183 --ship_from_location_id = 183
    ;

SELECT *
FROM AR_CUSTOMERS
WHERE customer_number IN ( 'E535704', '186732')
;

select *
from HZ_CUST_ACCOUNTS
WHERE ACCOUNT_NUMBER IN ( 'E535704', '186732')
;

select *
from HZ_CUST_SITE_USES_ALL
WHERE LOCATION IN ( 'E535704', '186732')
;

SELECT * FROM HZ_CUST_ACCT_SITES_ALL
;

SELECT * FROM HZ_CUST_SITE_USES_ALL
WHERE LOCATION IN ( 'E535704', '186732')
;

SELECT *
FROM HZ_LOCATIONS
WHERE 1=1
  AND address1 = 'E1' --'E535704'
 -- AND LOCATION_ID = 42026
;

    select wl.wsh_location_id
         , p.party_name
         , p.jgzz_fiscal_code           rfc
         , wl.address1 
         , wl.address2                  street
         , wl.city
         , wl.state
         , wl.postal_code
         , wl.country
         , wl.ui_location_code          Address
         ;
         
         select psu.site_use_code
    FROM wsh_locations_hz_v     wl
       , hz_party_sites         ps
       , hz_cust_acct_sites_all cas
       , hz_cust_site_uses_all  psu
       , hz_parties             p
    WHERE 1=1    
      and wl.wsh_location_id = ps.location_id
      and ps.party_site_id = cas.party_site_id
      and cas.cust_acct_site_id = psu.cust_acct_site_id
      And psu.site_use_code  in ( 'SHIP_TO', 'DELIVER_TO')
      and ps.party_id = p.party_id
      --and ps.status = 'A'      
      --and wl.address1 like 'E1'  
  and    wl.wsh_location_id= 55944
      ;

SELECT *
FROM wsh_locations_hz_v
WHERE wsh_location_id= 55944
;