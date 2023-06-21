begin
    fnd_global.apps_initialize    (
        user_id        => 1671, --CONE-RBORES
        resp_id        => 50834, --GRP_ALL_AR_CONE_GTE
        resp_appl_id    => 222
    );

    mo_global.init ('AR');
end;
/
    
    
--
-- Estado de Cuenta de un RECIBO
--
SELECT      
      cr.status recibo_status
      , cr.amount
      ,rh.status 
    -- , cr.currency_code, cr.receipt_number, cr.actual_value_date           
     , sh.statement_number, sh.statement_date
    -- , sl.trx_date, sl.trx_type, sl.status, sl.bank_trx_number
    -- , sr.reference_type    
    ;
    select cr.*
FROM ar_cash_receipts_all        cr
    ,ar_cash_receipt_history_all rh
    ,ce_statement_reconcils_all  sr
    ,ce_statement_lines          sl
    ,ce_statement_headers        sh
WHERE 1=1
  and rh.cash_receipt_id     = cr.cash_receipt_id
  and rh.current_record_flag = 'Y'
  and rh.cash_receipt_history_id = sr.reference_id (+)
  and sr.reference_type      (+)= 'RECEIPT'
  and sr.statement_line_id      = sl.statement_line_id (+)
  and sl.statement_header_id    = sh.statement_header_iD (+)
  --
  AND  cr.receipt_number like 'FARFG_4117_26FEB20_9490'
  --and sl.statement_line_id in (8010032)
  ;


receipt_method_id
pay_from_customer
;

SELECT *
FROM ar_receipt_methods
WHERE 1=1
;
