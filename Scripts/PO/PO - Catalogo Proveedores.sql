
--
-- Proveedores
--
select distinct
    hou.name  org_name 
  , pv.vendor_name, pv.segment1 RFC
  , pv.vendor_type_lookup_code
  , pvs.vendor_site_code
  , pvs.STATE
  , pvs.CITY  
  , pvs.vat_code CODIGO_IVA  
  , (c.segment1 ||'.'|| c.segment2 ||'.'|| c.segment3 ||'.'|| c.segment4 ||'.'|| c.segment5 ||'.'|| c.segment6 ||'.'|| c.segment7) pasivo  
  , (d.segment1 ||'.'|| d.segment2 ||'.'|| d.segment3 ||'.'|| d.segment4 ||'.'|| d.segment5 ||'.'|| d.segment6 ||'.'|| d.segment7) anticipo     
  , pvs.email_address
  , apba.bank_account_name
  , apba.bank_account_num    
  , pv.END_DATE_ACTIVE  pv_end_date
  , pvs.inactive_date   pvs_end_date
from po_vendors                 PV
  , po_vendor_sites_all         pvs
  , hr_organization_units       hou
  , gl_code_combinations        C
  , gl_code_combinations        D
  , AP_BANK_ACCOUNT_USES_ALL    apbau
  , ap_bank_accounts_all        apba        
where 1=1 
 and pv.vendor_id = pvs.vendor_id 
 and pvs.org_id    = hou.organization_id
 and pvs.accts_pay_code_combination_id = c.code_combination_id (+)
 and pvs.prepay_code_combination_id    = d.code_combination_id (+)
 and pvs.vendor_id                     = apbau.vendor_id   (+)
 and pvs.vendor_site_id                = apbau.vendor_site_id (+)
 and apbau.external_bank_account_id  = apba.bank_account_id (+)
 and apbau.org_id                    = apba.org_id (+)
 --and pvs.email_address is null
 --and pvs.last_update_date              >=to_date('19-08-2010 11:15:00', 'dd-mm-yyyy hh24:mi:ss')  
-- and pvs.vendor_site_code = 'IYED'



