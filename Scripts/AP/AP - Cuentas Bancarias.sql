
           SELECT distinct 
                   ou.name
                  , apbb.bank_name                   
                  , apbb.bank_branch_name                   
                  , apba.BANK_ACCOUNT_NAME
                  , apba.BANK_ACCOUNT_NUM
                  , apba.CURRENCY_CODE
                  , apba.ACCOUNT_TYPE
                  , apba.inactive_date                  
           FROM ap_bank_accounts_all apba
              , ap_bank_branches apbb
              , hr_all_organization_units ou
           WHERE apba.bank_branch_id = apbb.bank_branch_id
             and apba.org_id = ou.organization_id 
           ORDER BY ou.name, apbb.bank_name
                        
