
SELECT DISTINCT
     API.INVOICE_ID
    ,INVOICE_TYPE_LOOKUP_CODE   TIPO
    ,POV.SEGMENT1               RFC
    ,POV.VENDOR_NAME            PROVEEDOR
    ,PVS.VENDOR_SITE_CODE       SUCURSAL
    ,API.INVOICE_NUM            FACTURA
    ,API.INVOICE_CURRENCY_CODE  DIVISA
    ,api.INVOICE_AMOUNT         IMPORTE
    ,DECODE(API.INVOICE_CURRENCY_CODE, 'MXN', api.INVOICE_AMOUNT, api.INVOICE_AMOUNT*api.exchange_rate) IMP_FUNCIONAL
    ,api.exchange_rate          TC 
    ,API.GL_DATE
    ,OU.NAME                    ORG_NAME            
   , (gcc.segment1 ||'.'||gcc.segment2 ||'.'|| gcc.segment3 ||'.'|| gcc.segment4 ||'.'|| gcc.segment5 ||'.'|| gcc.segment6 ||'.'|| gcc.segment7) cuenta
   , APTAX.NAME TAX_CODE     
   , PAY.*
FROM AP_INVOICES_ALL                API
    ,PO_VENDORS                     POV
    ,PO_VENDOR_SITES_ALL            PVS
    ,HR_ALL_ORGANIZATION_UNITS      OU
    ,GL_CODE_COMBINATIONS           GCC
    ,AP_INVOICE_DISTRIBUTIONS_ALL   APID
    ,AP_TAX_CODES_ALL               APTAX    
    , AP_INVOICE_PAYMENTS_ALL       PAY
WHERE API.VENDOR_ID                 = POV.VENDOR_ID
  AND API.VENDOR_SITE_ID            = PVS.VENDOR_SITE_ID
  AND API.ORG_ID                    = OU.ORGANIZATION_ID
  AND api.INVOICE_AMOUNT            <> 0
  --AND TO_CHAR(GL_DATE,'MM-YYYY')    = '07-2010'
  AND API.accts_pay_code_combination_id = gcc.code_combination_id
  --and API.INVOICE_CURRENCY_CODE = 'USD'
  AND API.INVOICE_ID                = APID.INVOICE_ID     
  AND APID.TAX_CODE_ID              = APTAX.TAX_ID   (+)
  AND API.INVOICE_ID                = PAY.INVOICE_ID (+)
  AND API.VENDOR_ID = 83471;
  
  
  SELECT *
  FROM AP_PAYMENT_SCHEDULES_ALL
  WHERE INVOICE_ID = 1403751;
  
  

  
  
  