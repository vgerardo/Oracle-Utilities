
--
-- CUENTAS DE CASH
--         
SELECT distinct 
 a.bank_name, a.bank_branch_name, b.bank_account_name, b.bank_account_num
,b.currency_code, b.account_type, b.org_id, C.NAME 
    FROM AP_BANK_BRANCHES       A
        ,AP_BANK_ACCOUNTS_ALL   B
        ,HR_ALL_ORGANIZATION_UNITS C
WHERE A.BANK_BRANCH_ID = B.BANK_BRANCH_ID             
AND B.ORG_ID = C.ORGANIZATION_ID    
AND account_type != 'PAYROLL' AND account_type != 'TREASURY'
ORDER BY a.bank_branch_name


