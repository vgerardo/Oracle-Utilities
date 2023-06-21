--
-- Pagos Programados de Facturas
----
SELECT 
        inv.invoice_num, inv.payment_method_code, 
        ps.creation_date, ps.amount_remaining, ps.due_date, ps.hold_flag, ps.payment_status_flag,       
        ps.payment_method_code, 
        pay.amount payment_amount, 
        ch.check_date,        
        ch.amount check_monto,
        CH.status_lookup_code,
        inv.pay_group_lookup_code,
        inv.org_id
        ,inv.invoice_id
        ,inv.external_bank_account_id        

FROM AP_INVOICES_ALL            inv,
     AP_PAYMENT_SCHEDULES_ALL   ps,
     AP_INVOICE_PAYMENTS_ALL    pay,
     ap_checks_all               ch
     
WHERE 1=1
  and inv.invoice_id = ps.invoice_id (+)
  and inv.invoice_id = pay.invoice_id (+)
  and pay.check_id   = ch.check_id (+)
  --and nvl(CH.status_lookup_code,'x') <> 'VOIDED'
  and inv.vendor_id in (
                    select vendor_id
                    from ap_suppliers
                    where segment1 like 'VAPG7211052F3'
                    )
  and ps.DUE_DATE > to_date ('2020-07-01', 'YYYY-MM-DD')                    
--
--group by  INV.description
--ORDER BY ps.DUE_DATE desc, ps.invoice_id desc
--
;

