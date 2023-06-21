
Oracle Receivables Reference Guide
Release 12.1
Part Number E13512-04

http://docs.oracle.com/cd/E18727_01/doc.121/e13512/T447348T383863.htm#I_intx2Dlines





--
-- Facturas en INTERFACE
--
 SELECT rail.interface_line_context
      , rail.interface_line_attribute1
      , rail.interface_line_attribute2
      , rail.interface_line_attribute3
      , rail.description
      , rail.amount
      , rail.interface_status
      , rail.sales_order
      , RAIL.trx_date
      , rail.gl_date
      ,raie.*            
 FROM RA_INTERFACE_LINES_ALL rail
    , RA_INTERFACE_ERRORS_ALL raie
 WHERE rail.interface_line_id = raie.interface_line_id (+)
   --and interface_line_context = 'INTERCOMPANY'
   --AND rail.interface_status <> 'p' -- p=procesado
   --and TRUNC(rail.gl_date) = to_date ('15122010', 'DDMMYYYY')
   and rail.INTERFACE_LINE_ATTRIBUTE1 = '8057'  -- normalmente se usa como COMPAÑIA




select interface_line_id, ORIG_SYSTEM_BILL_CUSTOMER_ID, ORIG_SYSTEM_BILL_ADDRESS_ID, customer_trx_id, trx_date
    , interface_status, tax_code, interface_line_attribute10, interface_line_attribute15, reset_trx_date_flag, warehouse_id
from  RA_INTERFACE_LINES_ALL
where interface_line_context = 'INTERCOMPANY'
  --AND interface_status IS NULL  
  and interface_line_attribute1 = '12553'
  --and interface_line_attribute2 in ('16', '9')
  --and orig_system_bill_address_id = 1044
  
order by interface_line_attribute7

orig_system_bill_address_id

insert into RA_INTERFACE_LINES_ALL ( 
     -- los "interface_line-attribute1-15" deben ser unicos por cada linea de la factura
     -- y la factura se crea de acuerdo a la regla de Agrupación definida en AR
     interface_line_context
    ,interface_line_attribute1
    ,interface_line_attribute2
    ,interface_line_attribute3
    ,interface_line_attribute4
    ,interface_line_attribute5
    ,interface_line_attribute6
    ,interface_line_attribute7
    ,interface_line_attribute8
    -- ----------------------------------------------------------------------------

    ,batch_source_name
    ,set_of_books_id
    ,line_type
    ,description
    ,currency_code
    ,amount
    ,cust_trx_type_id
    ,term_id
    ,orig_system_bill_customer_id
    ,orig_system_bill_address_id
    ,orig_system_sold_customer_id
    ,conversion_type
    ,conversion_date
    ,customer_trx_id
    ,trx_date
    ,gl_date
    ,line_number
    ,quantity
    ,quantity_ordered
    ,unit_selling_price
    ,unit_standard_price
    ,interface_status
    ,tax_code
    ,ship_date_actual
    ,primary_salesrep_id
    ,sales_order
    ,sales_order_line
    ,sales_order_date
    ,inventory_item_id
    ,uom_code
    ,interface_line_attribute10
    ,interface_line_attribute15
    ,interface_line_attribute9
    ,created_by
    ,creation_date
    ,org_id
    ,warehouse_id       
)values (
    'INTERCOMPANY'
    ,'8164'     -- oeh.order_number
    ,'9'        -- oel.line_number
    ,'508'      -- oeh.ship_from_org_id
    ,'292'      -- sil.org_id
    ,'293'      -- oeh.sold_from_org_id 
    ,21423514   -- oel.line_id
    ,1916130    -- MTL_MATERIAL_TRANSACTIONS.transaction_id
    ,'293'      -- oeh.sold_from_org_id 
    ,'Intercompany'
    ,'1002'     -- set_of_books_id
    ,'LINE'
    ,'BASKET LINER 12X12 CHILIS AC' -- dlv.item_description
    ,'MXN'      -- currency_code        = dlv.currency_code
    ,512.89     -- amount               = (dlv.shipped_quantity * round(nvl(arl.unit_selling_price,ll.operand),2))
    ,1001       -- cust_trx_type_id     = oel.line_type_id
    ,1004       -- term_id              = oel.payment_term_id
    ,1042       -- orig_system_bill_customer_id = oel.sold_to_org_id
    ,1042       -- orig_system_bill_address_id  = oel.sold_to_org_id
    ,1042       -- orig_system_sold_customer_id = oel.sold_to_org_id
    ,'Corporate' -- conversion_type
    ,to_date('31-10-2010', 'dd-mm-yyyy') --conversion_date = oel.actual_shipment_date
    ,null   --customer_trx_id
    ,null   --trx_date
    ,to_date('01-02-2011', 'dd-mm-yyyy') -- gl_date
    ,null   -- line_number
    ,1      -- quantity = dlv.shipped_quantity
    ,1      -- quantity_ordered = dlv.src_requested_quantity
    , 512.89 -- unit_selling_price   = ll.operand
    , 512.89 -- unit_standard_price  = ll.operand
    ,null   -- interface_status
    ,'IVAGR'    -- tax_code
    ,to_date('31-10-2010', 'dd-mm-yyyy') --ship_date_actual = oel.actual_shipment_date
    ,-3     --primary_salesrep_id = oel.salesrep_id
    ,8164   --sales_order = oeh.order_number
    ,9      --sales_order_line = oel.line_number
    ,to_date('28-10-2010', 'dd-mm-yyyy') --sales_order_date = oeh.ordered_date
    ,27388  -- oel.inventory_item_id
    ,'PZA'  -- dlv.requested_quantity_uom
    ,1      -- interface_line_attribute10 = no sé
    ,'Y'    -- interface_line_attribute15 = no sé
    ,9763   -- interface_line_attribute9 = dlv.source_header_id
    ,1      -- created_by
    ,sysdate    -- creation_date
    ,293    --org_id
    ,null--508    --warehouse_id = oeh.ship_from_org_id    
)