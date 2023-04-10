
--
-- Cheques y Cuentas Bancarias
--
SELECT acc.bank_account_name, acc.bank_account_num
      ,bnco.bank_name
      ,suc.bank_branch_name
      ,ch.check_number      
FROM CE_BANK_ACCOUNTS       acc
    ,CE_BANK_ACCT_USES_ALL  bau
    ,AP_CHECKS_all#         ch
    ,CE_BANKS_V             bnco
    ,CE_BANK_BRANCHES_V     suc
WHERE 1=1
 and acc.BANK_ACCOUNT_ID = bau.BANK_ACCOUNT_ID
 and bau.bank_acct_use_id = ch.ce_bank_acct_use_id 
 and acc.bank_id          = bnco.bank_party_id
 and acc.bank_branch_id   = suc.branch_party_id
 