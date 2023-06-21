--
-- Query para mostrar los detalles de las cuentas bancarias de CLIENTES
-- 
SELECT *
FROM (
    SELECT 
--           clnt.customer_name, clnt.customer_number, 
--           hcal.account_number,
--           cnta.bank_account_num,
--           bnk.bank_name,
--           uses.order_of_preference,
           hcal.*
    FROM  ar_customers              clnt, 
          hz_cust_accounts_all      hcal,
          iby_external_payers_all   pyrs,      
          iby_pmt_instr_uses_all    uses,
          iby_ext_bank_accounts     cnta,
          iby_ext_banks_v           bnk
    WHERE 1=1
     and clnt.customer_number = hcal.account_number
     AND hcal.cust_account_id = pyrs.cust_account_id  
     AND pyrs.ext_payer_id    = uses.ext_pmt_party_id
     AND uses.instrument_id   = cnta.ext_bank_account_id
     and cnta.bank_id         = bnk.bank_party_id     
     and hcal.status           = 'A'
     AND uses.instrument_type  = 'BANKACCOUNT'
     AND uses.payment_function = 'CUSTOMER_PAYMENT' 
     AND uses.payment_flow     = 'FUNDS_CAPTURE'
     AND nvl(cnta.end_date,sysdate+1) >= sysdate    
     AND nvl(uses.end_date,sysdate+1) >= sysdate
     ----------------------------------------------
     --AND hcal.account_number LIKE 'PUSA'     
     and clnt.TAXPAYER_ID = 'AUAC4601138F9'
     ----------------------------------------------
    ORDER BY uses.order_of_preference 
) WHERE ROWNUM < 2 -- Para tomar el de mayor Prioridad
;

