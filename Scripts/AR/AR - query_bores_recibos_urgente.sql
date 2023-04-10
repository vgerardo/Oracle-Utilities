SELECT DISTINCT  
         to_char (acra.actual_value_date, 'YYYYMM') mes_reportado
         , hp2.tax_reference                cve_realiza_act_vulner
         , 'MPC'                            Clave_Act_Vlnrble         
         , hl2.postal_code                  cp
         , hp2.party_name                   nombre_realiza_act_vlnrble
         , '1'                              Prioridad_Aviso
         , '100'                            TipoAlerta         
         , hp.party_name                    cliente
         , hp.tax_reference                 rfc_cte
         , hp.country                       pais_cte
         , hl.address1
         , hl.address2
         , hl.address3
         , hl.city
         , hl.state
         , hl.country
         , hl.postal_code
         , acra.currency_code
         , decode (acra.currency_code, 'MXP', 1, 'USD', 2, 0) MonedaXML
         , acra.doc_sequence_value                            receipt_number
         , acra.receipt_number                                reference_number
         , to_char(NVL (acra.amount, 0),'FM999999999.00')           importe_ingresado
         , to_char(NVL (acra.amount, 0) * NVL (acra.exchange_rate, 1),'FM999999999.00') importe_functional
         , arm.NAME payment_method
         , to_char (to_date(acra.actual_value_date), 'YYYYMMDD') fecha_pago
         , '8'                                                   Instrumento_Monetario
         ,( SELECT 
                '|'|| xar.ACCT_LINE_TYPE_NAME              
              ||'|'|| (gcc.segment1||'.'||gcc.segment2||'.'||gcc.segment3||'.'||gcc.segment4||'.'||gcc.segment5||'.'||gcc.segment6||'.'||gcc.segment7) 
              ||'|'|| to_char(xar.accounting_date,'yyyy-mm-dd')
              ||'|'|| xar.GL_TRANSFER_STATUS            
          FROM apps.XLA_AR_REC_AEL_SL_V xar
               ,gl_code_combinations     gcc
         WHERE xar.application_id = 222 
           AND xar.set_of_books_id = 1 
           AND xar.trx_hdr_table = 'CR'     
           and xar.acct_line_type in ('REC') -- Cuentas a Cobrar
           and xar.code_combination_id = gcc.code_combination_id
           AND xar.trx_hdr_id = acra.cash_receipt_id
           and rownum < 2   -- quieren solo el primer registro
          ) 
          
          ||'|'||
          
          ( SELECT 
                '|'|| xar.ACCT_LINE_TYPE_NAME              
              ||'|'|| (gcc.segment1||'.'||gcc.segment2||'.'||gcc.segment3||'.'||gcc.segment4||'.'||gcc.segment5||'.'||gcc.segment6||'.'||gcc.segment7) 
              ||'|'|| to_char(xar.accounting_date,'yyyy-mm-dd') 
              ||'|'|| xar.GL_TRANSFER_STATUS            
              ||'|'|| to_char(nvl(xar.ACCOUNTED_DR,0),'FM999999999.00')
              ||'|'|| to_char(nvl(xar.ACCOUNTED_CR,0),'FM999999999.00')       
          FROM apps.XLA_AR_REC_AEL_SL_V xar
               ,gl_code_combinations     gcc
         WHERE xar.application_id = 222 
           AND xar.set_of_books_id = 1 
           AND xar.trx_hdr_table = 'CR'     
           and xar.acct_line_type in ('CASH') -- Efectivo
           and xar.code_combination_id = gcc.code_combination_id
           AND xar.trx_hdr_id = acra.cash_receipt_id
           and rownum < 2 -- quieren solo el primer registro
           )     datos_adicionales
           
    FROM  ar_cash_receipts_all acra
         ,ar_receipt_methods arm
         ,ap_bank_accounts_all abaa
         ,ap_bank_branches abb
         ,hz_cust_accounts hca
         ,hz_cust_accounts hca2
         ,hz_parties hp
         ,hz_parties hp2
         ,hz_locations hl
         ,hz_locations hl2
         ,hz_party_sites hps
         ,hz_party_sites hps2
         --,hz_cust_acct_sites_all hcsa
         --,hz_cust_acct_sites_all hcsa2
         --,hz_cust_site_uses_all hcsu
         --,hz_cust_site_uses_all hcsu2
   WHERE acra.pay_from_customer          = hca.cust_account_id(+)
     and acra.org_id                     = abaa.org_id(+)
     and acra.actual_value_date between to_date('01/09/2013 00:00:00', 'DD/MM/YYYY HH24:MI:SS')
                                    and to_date('30/11/2013 00:00:00', 'DD/MM/YYYY HH24:MI:SS')
     and hca.party_id                    = hp.party_id(+)
     and acra.receipt_method_id          = arm.receipt_method_id
     and acra.remittance_bank_account_id = abaa.bank_account_id
     and abaa.bank_branch_id             = abb.bank_branch_id
     and replace(substr(arm.name, 0,(instr (arm.name, '_')-1)),'-','') =  hca2.account_number
     and hca2.party_id          = hp2.party_id
     and hp.party_id            = hps.party_id
     and hps.location_id        = hl.location_id
     and hps.creation_date      = (
                                    select max(creation_date) 
                                    from hz_party_sites 
                                    where party_id = hp.party_id
                                  ) -- 03/Dic/2013
     and hp2.party_id           = hps2.party_id          
     and hps2.location_id       = hl2.location_id
     --and hcsa2.party_site_id    = hps2.party_site_id
     --and hcsu.cust_acct_site_id = hcsa.cust_acct_site_id
     --and hcsu2.cust_acct_site_id = hcsa2.cust_acct_site_id
     --and hca.cust_account_id    = hcsa.cust_account_id
     --and hca2.cust_account_id   = hcsa2.cust_account_id
     and hp.party_name      not in ('AMEXCO', 'VISA', 'EFECTIVO')
     and acra.status        not in ('REV') -- No revertido
--and acra.receipt_number like ' F/1596-09092013'
     ;
