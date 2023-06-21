BEGIN
    fnd_global.apps_initialize    (
        user_id        => 1134,     -- ext-gvargas
        resp_id        => 50834,    -- GRP_ALL_AR_CONE_GTE
        resp_appl_id    => 222     -- AR
    );
    mo_global.init ('AR');
    mo_global.set_policy_context('S',85);
END;
/

--
-- Recibos aplicados a Facturas en AR
--
select   acr.receipt_number     
        ,acr.amount             recibo_monto
        ,acr.status             recibo_status
        ,acr.deposit_date       fechaPago
        --,acr.comments           recibo_comments
        ,acr.currency_code      Moneda
        ,acr.exchange_rate      tipoCambio
        
        ,ps.amount_due_original
        ,ps.amount_due_remaining
        
        ,app.amount_applied     Monto
        ,app.line_applied
        ,app.tax_applied

        ,rct.trx_number         fctra_number
        ,rct.attribute1         fctra_UUID
        ,rct.customer_Trx_id

--SELECT app.*
from ar_cash_receipts_all               acr,
     ar_receivable_applications_all     app,
     ar_payment_schedules_all           ps,
     ra_customer_Trx_all                rct    
where 1=1            
  and acr.cash_receipt_id         = app.cash_receipt_id
  and app.payment_schedule_id     = ps.payment_schedule_id
  AND app.applied_customer_trx_id = rct.customer_Trx_id (+)
  and app.status IN ( 'APP', 'ACTIVITY')  
  --AND ara.DISPLAY                 = 'Y'        
  --and rct.attribute1              is not null --UUID
  --and rct.customer_trx_id         =  8503923
  and acr.cash_receipt_id         = 8294875
ORDER BY app.receivable_application_id   
 ;
 
 


SELECT    
    receivable_application_id,    
    applied_flag,
    trx_number,
    rec_activity_name,
    installment,
    amount_due_remaining,
    apply_date,
    amount_applied,
    discount,
    invoice_currency_code,
    customer_number,
    gl_date,
    reversal_gl_date,
    amount_applied_from,
    exchange_gain_loss,
    days_late,
    line_number,
    trx_class_name,
    trx_type_name,
    ussgl_transaction_code,
    discounts_unearned,
    discounts_earned,
    customer_name,
    comments,
    customer_reference,
    customer_reason,
    gl_posted_date,
    trx_doc_sequence_value,
    due_date,
    location_name,
    trx_date,
    acctd_amount_applied_to,
    acctd_amount_applied_from,
    acctd_amount_due_remaining,
    secondary_application_ref_type,
    application_ref_id,
    secondary_application_ref_num,
    application_ref_reason,
    amount_due_original,
    purchase_order,
    transaction_category,
    cash_receipt_id,
    receipt_number,
    discount_taken_earned,
    discount_taken_unearned,
    customer_id,
    bill_to_site_use_id,
    applied_payment_schedule_id,
    customer_trx_id,
    cust_trx_type_id,
    customer_trx_line_id,
    trx_class_code,
    exchange_rate,
    creation_sign,
    amount_line_items_original,
    term_id,
    amount_in_dispute,
    trx_batch_source_name,
    amount_adjusted,
    amount_adjusted_pending,
    amount_line_items_remaining,
    freight_original,
    freight_remaining,
    receivables_charges_remaining,
    tax_original,
    tax_remaining,
    ussgl_transaction_code_context,
    selected_for_receipt_batch_id,
    allow_overapplication_flag,
    calc_discount_on_lines_flag,
    partial_discount_flag,
    natural_application_only_flag,   
    receivables_trx_id,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    on_acct_cust_id,
    on_acct_cust_site_use_id,
    on_acct_po_num
FROM
    ar_receivable_applications_v
WHERE
    ( ( applied_flag = 'Y'
        AND cash_receipt_id = 8294875 ) )
    AND - 1 = - 1
ORDER BY
    applied_flag,
    decode(
        applied_payment_schedule_id, - 1,
        1,
        0
    ),
    trx_number,
    customer_name,
    installment
    ;

