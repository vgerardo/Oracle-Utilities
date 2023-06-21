
-- 
-- Informes de Gastos Intercompañía, creados con el proceso de "Crear Facturas AP Entre Compañías";
-- y su respectiva factura en AP, creada con "Importación de Informe de Gastos"
-- El prerequisito, es que previamente se hayan creado las facturas en AR.
--
SELECT apeh.invoice_num
     , apeh.vouchno     ap_vouchno
     , api.invoice_num  ap_invoice_num
     , apeh.total
     , apeh.source
     , apeh.accounting_date
     , apeh.description
     , apel.item_description
     , apel.amount
     , apel.line_type_lookup_code
     , apel.item_description
     , apel.amount
     , apel.vat_code
     , api.*
FROM ap_expense_report_headers_all  apeh
   , ap_expense_report_lines_all    apel
   , ap_invoices_all                api
WHERE apeh.report_header_id = apel.report_header_id
  and apeh.vouchno          = api.invoice_id (+)
  and apeh.source = 'Intercompany'
  and apeh.invoice_num in ('13097-293')
  

