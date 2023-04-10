BEGIN
 -- ------------------------------------------------------
    -- Inicializa Entorno
    FND_GLOBAL.apps_initialize ( 
                             user_id      => 1123   -- CONE-LGOMEZ
                            ,resp_id      => 50833  -- GRP_ALL_AP_CONE_GTE
                            ,resp_appl_id => 200    -- SQLAP
                           );        
    --MO_GLOBAL.set_policy_context('S', 85); 
    MO_GLOBAL.init('SQLAP'); -- product short name: AR, SQLAP
    CEP_STANDARD.init_security; --The table CE_SECURITY_PROFILES_GT is populated through this call 
    -- ------------------------------------------------------
END;
/


--
-- Pagos Programados de Facturas
----
SELECT 
     prepay.invoice_type_lookup_code
    ,(select name from hr_all_organization_units where organization_id= prepay.org_id) unidad_operativa
    ,prv.vendor_name
    ,prepay.pay_group_lookup_code Sucursal
    , prepay.invoice_num
    , prepay.invoice_date
    , prepay.invoice_amount
    , prepay.description    
    , ch.check_date
    , site.vendor_site_code
    , ch.bank_account_name
    , ch.check_number
    , decode(ch.payment_method_code, 'EFT', 'Electrónico', ch.payment_method_code) Metodo_Pago
--    , pay.amount
    , ch.currency_code
    , ch.status_lookup_code    
    
    ,(select bank_account_num
    from iby_ext_bank_accounts ibybnk
    where 1=1    
    and ibybnk.ext_bank_account_id  = prepay.external_bank_account_id    
    ) Cnta_Remitio
    
    , prv.segment1 rfc_proveedor
  
    , (select segment1||'.'||segment2||'.'||segment3||'.'||segment4||'.'||segment5||'.'||segment6||'.'||segment7||'.'||segment8
       from gl_code_combinations where code_combination_id = prepay.accts_pay_code_combination_id) cta_pasivo
    , prepay.voucher_num
    , prepay.invoice_currency_code
    , prepay.gl_date      
    
    , app.invoice_num fact_invoice_num
    , fac_aa.invoice_date
    , fac_aa.invoice_amount
    , fac_aa.invoice_currency_code
    , fac_aa.invoice_type_lookup_code
    , fac_aa.voucher_num 
    , fac_aa.description
    , fac_aa.gl_date
    --, app.prepay_amount_applied
--    , app.description    
    , app.vendor_name
    , app.vendor_number
    , app.vendor_site_code    
    
    ,(select 
      LISTAGG (poh.segment1, ' ') WITHIN GROUP (ORDER BY poh.segment1 ) Ordenes
    from ap_invoice_lines_all  ln,
      po_headers_all        poh
    where 1=1
    and ln.po_header_id = poh.po_header_id (+)
    and ln.invoice_id = app.invoice_id
    ) "Orden(es)"
    
    --, prepay.invoice_id       
    --, prepay.ORG_ID
FROM AP_INVOICES_ALL                prepay,
     ap_suppliers                   prv,
     ap_supplier_sites_all          site,
     --AP_PAYMENT_SCHEDULES_ALL       ps,
     AP_INVOICE_PAYMENTS_ALL        pay,
     ap_checks_all                  ch,
     ap_view_prepays_fr_prepay_v    app, -- Facturas Aplicadas al Anticipo (pre-pagadas)
     ap_invoices_all                fac_aa -- Facturas Aplicadas al Anticipo (pre-pagadas)
WHERE 1=1
  and prepay.vendor_id = prv.vendor_id
  and prepay.vendor_site_id = site.vendor_site_id
  and prepay.invoice_id = app.prepay_id
  and prepay.vendor_id = app.vendor_id
  and app.invoice_id = fac_aa.invoice_id
  --and prepay.invoice_id = ps.invoice_id (+)
  and prepay.invoice_id = pay.invoice_id
  and pay.check_id   = ch.check_id
  --and ps.payment_status_flag = 'Y'     
  and CH.status_lookup_code <> 'VOIDED'
  and prepay.invoice_type_lookup_code = 'PREPAYMENT'
  -----------------
  --AND prepay.invoice_num = 'SMTYG-08FEB18-NOM'
  and prv.segment1 = 'VIA060502C53'
  --and prepay.invoice_id = 2297177
  --and ch.check_date > to_date ('01-01-2018', 'dd-mm-yyyy')
  -----------------
ORDER BY ch.check_date desc
;


