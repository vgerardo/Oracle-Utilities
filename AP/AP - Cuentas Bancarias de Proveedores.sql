

SELECT  aps.vendor_name "VERDOR NAME",        
        ieba.BANK_ACCOUNT_NUM "BANK ACCOUNT NUMBER",
        ieba.BANK_ACCOUNT_NAME "BANK ACCOUNT NAME"        
FROM    ap.ap_suppliers aps,        
        apps.iby_account_owners iao,        
        apps.iby_ext_bank_accounts ieba
        --ap.ap_supplier_sites_all apss,        
        --apps.iby_ext_banks_v ieb,
        --apps.iby_ext_bank_branches_v iebb
WHERE   1=1
    and aps.party_id  = iao.account_owner_party_id
    and iao.ext_bank_account_id = ieba.ext_bank_account_id
    --and aps.vendor_id = apss.vendor_id
    --and ieb.bank_party_id = iebb.bank_party_id
    --and ieba.branch_id = iebb.branch_party_id
    --and ieba.bank_id = ieb.bank_party_id
    AND aps.vendor_id in ( 2093, 28112)
        ;