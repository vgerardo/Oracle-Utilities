
--
-- Cuenta bancaria ligada a un Método de Pago
-- 
select cba.bank_account_name, cba.bank_account_num, rm.name method_name
  from 
       ce_bank_accounts               cba,
       ce_bank_acct_uses_all          ba,
       ar_receipt_method_accounts_all rma,
       ar_receipt_methods             rm       
 where 1 = 1
   AND cba.bank_account_id = ba.bank_account_id
   and ba.bank_acct_use_id = rma.remit_bank_acct_use_id
   and rma.receipt_method_id = rm.receipt_method_id
   and cba.bank_account_name like 'FIINS_CAPT LOC_7923960'      