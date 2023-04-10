
/* Formatted on 2009/01/29 12:11:29 p.m. (QP5 v5.115.810.9015) */
--
-- Pagos a proveedores - Resumen por forma de pago
-- 16 de Enero 2009
--

SELECT proveedor
, rfc
, familia
, subfamilia
, SUM( decode (tipo_pago, 'CADENAS', propio_mxp, 0 )) propio_cadenas_mxp
, SUM( decode (tipo_pago, 'CHEQUE', propio_mxp, 0 )) propio_cheque_mxp
, SUM( decode (tipo_pago, 'TRANSFER', propio_mxp, 0 )) propio_transfer_mxp
, SUM( decode (tipo_pago, 'CADENAS', arrendado_mxp, 0 )) arrendado_cadenas_mxp
, SUM( decode (tipo_pago, 'CHEQUE', arrendado_mxp, 0 )) arrendado_cheque_mxp
, SUM( decode (tipo_pago, 'TRANSFER', arrendado_mxp, 0 )) arrendado_transfer_mxp
, SUM( decode (tipo_pago, 'CADENAS', administrado_mxp, 0 )) administrado_cadenas_mxp 
, SUM( decode (tipo_pago, 'CHEQUE', administrado_mxp, 0 )) administrado_cheque_mxp
, SUM( decode (tipo_pago, 'TRANSFER', administrado_mxp, 0 )) administrado_transfer_mxp
, SUM( decode (tipo_pago, 'CADENAS', corpos_mxp, 0 )) corpos_cadenas_mxp
, SUM( decode (tipo_pago, 'CHEQUE', corpos_mxp, 0 )) corpos_cheque_mxp
, SUM( decode (tipo_pago, 'TRANSFER', corpos_mxp, 0 )) corpos_transfer_mxp
, SUM( decode (tipo_pago, 'CADENAS', propio_mxp+arrendado_mxp+administrado_mxp+corpos_mxp, 0 )) global_cadenas_mxp
, SUM( decode (tipo_pago, 'CHEQUE', propio_mxp+arrendado_mxp+administrado_mxp+corpos_mxp, 0 )) global_cheque_mxp
, SUM( decode (tipo_pago, 'TRANSFER', propio_mxp+arrendado_mxp+administrado_mxp+corpos_mxp, 0 )) global_transfer_mxp
FROM (

  SELECT   pov.vendor_name proveedor,
           pov.segment1 rfc,
           pov.attribute1 familia,
           pov.attribute2 subfamilia,
           ( DECODE (cat.cat02
                        , 'PROPIO',  DECODE (api.payment_currency_code, 'MXP', api.amount_paid, api.amount_paid * api.exchange_rate)
                        ,0
               )) propio_mxp,
           ( DECODE (cat.cat02                        
                        , 'ARRENDADO',  DECODE (api.payment_currency_code, 'MXP', api.amount_paid, api.amount_paid * api.exchange_rate)
                        , 0
               )) arrendado_mxp,
           ( DECODE (cat.cat02
                        , 'ADMINISTRADO',  DECODE (api.payment_currency_code, 'MXP', api.amount_paid, api.amount_paid * api.exchange_rate)
                        , 0
               )) administrado_mxp,                              
           ( DECODE (cat.cat02
                        , 'PROPIO',  0
                        , 'ARRENDADO',  0
                        , 'ADMINISTRADO', 0
                        , DECODE (api.payment_currency_code, 'MXP', api.amount_paid, api.amount_paid * api.exchange_rate)
               )) corpos_mxp
        , decode (substr(api.pay_group_lookup_code,1,3), 'CAD', 'CADENAS'
                        , decode (api.payment_method_lookup_code
                                   ,'EFT', 'TRANSFER'
                                   ,'CHECK', 'CHEQUE') )  tipo_pago                                                                                    
    FROM   ap_invoices_all      api
         , po_vendors           pov
         , gl_code_combinations gcc
         , csa_cias_ctgrias     cat
   WHERE       api.cancelled_date IS NULL
           AND api.vendor_id = pov.vendor_id
           AND api.invoice_amount <> 0
           AND api.amount_paid IS NOT NULL
           AND api.amount_paid > 0
           AND api.invoice_date BETWEEN :inicio AND :fin
           and api.accts_pay_code_combination_id = gcc.code_combination_id
           and gcc.segment1 = cat.segment1
          -- AND pov.segment1 = 'ABA860521RF0'           
                                         
)

GROUP BY proveedor
, rfc
, familia
, subfamilia
/*
GROUP BY   pov.vendor_name,
           pov.segment1,
           pov.attribute1,
           pov.attribute2,
           api.payment_currency_code,
           decode (substr(api.pay_group_lookup_code,1,3), 'CAD', 'CADENAS'
                        , decode (api.payment_method_lookup_code
                                   ,'EFT', 'TRANSFER'
                                   ,'CHECK', 'CHEQUE') )
         , cat.cat02
*/         
ORDER BY   1         
