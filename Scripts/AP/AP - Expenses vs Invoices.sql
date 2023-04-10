
--
-- Join entre Expenses e Invoices
--
select erh.invoice_num
     , erh.vouchno  invoice_id
     , erl.web_parameter_id
     , erh.expense_status_code
     , erh.report_header_id
     , api.reference_key1 
     , api.product_table
     , api.invoice_type_lookup_code
     , api.source
     , apd.web_parameter_id
from ap_expense_report_headers_all#     erh
   , ap_expense_report_lines_all#       erl
   , ap_invoices_all#                   api
   , ap_invoice_distributions_all#      apd  
where 1=1
  and erh.report_header_id  = erl.report_header_id
  and erh.vouchno           = api.invoice_id
  and api.invoice_id        = apd.invoice_id
  --and api.invoice_num       = 'AQCU14005AC'
  and api.INVOICE_TYPE_LOOKUP_CODE = 'EXPENSE REPORT'  
  
  

select api.invoice_num, api.source, apd.*
from ap_invoices_all api
    ,ap_invoice_distributions_all      apd
where 1=1
 and api.invoice_id        = apd.invoice_id
 and api.INVOICE_TYPE_LOOKUP_CODE = 'EXPENSE REPORT'
 and not exists (
     select 1
     from ap_expense_report_headers_all     erh
     where 1=1
           and erh.vouchno  = api.invoice_id
     )
     
     