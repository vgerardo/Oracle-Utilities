
/*
Query que devuelve las direcciones de facturación de un CLIENTE de AR.
*/
select rc.customer_name, rc.customer_number, hcas.orig_system_reference, hcsu.cust_acct_site_id
      ,hcas.*
from ra_customers rc,   
     hz_cust_acct_sites_all hcas,
     hz_cust_site_uses_all hcsu
where 1=1
 and rc.customer_id = hcas.cust_account_id 
 and hcas.cust_acct_site_id    = hcsu.cust_acct_site_id
 and rc.customer_number        like 'CSLP3'
 and hcsu.site_use_code        = 'BILL_TO'
 
 