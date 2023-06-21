
--
-- Inserta datos de pedidos de venta con "Tipo Destino = GASTO"
-- En la tabla de Interfaz de AR
--
insert into RA_INTERFACE_LINES_ALL ( 
     interface_line_context
    ,interface_line_attribute1
    ,interface_line_attribute2
    ,interface_line_attribute3
    ,interface_line_attribute4
    ,interface_line_attribute5
    ,interface_line_attribute6
    ,interface_line_attribute7
    ,interface_line_attribute8
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
)

--
-- Muestra los Pedidos de Venta que han sido embarcados 
-- y muestra si han sido facturas en AR 
-- y también las recepciones de dichos pedidos.
--
select  distinct
      'INTERCOMPANY'
    , oeh.order_number                  
    , oel.line_number
    , oeh.ship_from_org_id
    , sil.org_id
    , oeh.sold_from_org_id 
    , oel.line_id
    , mt.transaction_id
    , oeh.sold_from_org_id 
    , 'Intercompany'
    , '1002' set_of_books_id
    , 'LINE'
    , dlv.item_description
    , dlv.currency_code
    , (dlv.shipped_quantity * round(ll.operand,2))
    , oel.line_type_id
    , oel.payment_term_id
    , oel.sold_to_org_id
    , csu.cust_acct_site_id
    , oel.sold_to_org_id
    ,'Corporate' 
    , oel.actual_shipment_date
    ,null   --customer_trx_id
    ,null   --trx_date
    ,mt.transaction_date    --gl_date
    ,null   -- line_number
    , dlv.shipped_quantity
    , dlv.src_requested_quantity
    , ll.operand
    , ll.operand
    , null   -- interface_status
    , oel.tax_code --tax_code
    , oel.actual_shipment_date
    , oel.salesrep_id
    , oeh.order_number
    , oel.line_number
    , oeh.ordered_date
    , oel.inventory_item_id
    , dlv.requested_quantity_uom
    , 1      -- interface_line_attribute10 = no sé
    , 'Y'    -- interface_line_attribute15 = no sé
    , dlv.source_header_id
    , 1      -- created_by
    ,sysdate    -- creation_date
    ,293    --org_id
    ,null--508    --warehouse_id = oeh.ship_from_org_id          
from wsh_deliverables_v             dlv
   , oe_order_headers_all           oeh
   , oe_order_lines_all             oel
   , po_requisition_headers_all     sih
   , po_requisition_lines_all       sil
   , po_req_distributions_all       sid
   , hz_cust_site_uses_all          csu -- direcciones
   , qp_list_lines_v                LL 
   , mtl_material_transactions      mt                
WHERE dlv.source_header_id    = oeh.header_id
  and oeh.source_document_id  = sih.requisition_header_id
  and oel.source_document_id  = sil.requisition_header_id
  AND oel.source_document_line_id  = sil.requisition_line_id
  and oel.price_list_id       = ll.list_header_id  (+)
  and oel.ordered_item        = ll.product_attr_val_disp (+)
  and sih.org_id              = sil.org_id 
  and sil.org_id              = sid.org_id  
  and sil.requisition_line_id = sid.requisition_line_id   
  and oeh.header_id           = oel.header_id
  and oel.invoice_to_org_id   = csu.site_use_id
  and csu.site_use_code       = 'BILL_TO'
  AND csu.org_id              = 293
  and dlv.source_line_id      = oel.line_id
  and dlv.source_header_id    = mt.TRANSACTION_REFERENCE 
  and dlv.source_line_id      = mt.TRX_SOURCE_LINE_ID
  and dlv.inventory_item_id   = mt.inventory_item_id
  and dlv.SUBINVENTORY        = mt.SUBINVENTORY_CODE
  and dlv.organization_id     = mt.ORGANIZATION_ID              
  AND dlv.RELEASED_STATUS not in ( 'D', 'B', 'R') --D=Cancelled B=Pedido Pendiente (Backordered) R=Listo para Despacho (Ready to Release)
  -- ---------------------------------------------------------------
  -- Estas 2 banderas indican estado  = INTERFACED
  --
  AND dlv.RELEASED_STATUS ='C'                    --C=Interfaced    
  and nvl(dlv.inv_interfaced_flag,'N') = 'Y'        
  -- -------------------------------------------------------- 
  -- La facturación de OM, empezó apartir del 01-Octubre-2010
  -- oel.actual_shipment_date
  and dlv.last_update_date >= to_date ('01-10-2010 00:00:00', 'DD-MM-YYYY HH24:MI:SS')
  and dlv.last_update_date <= sysdate --to_date ('17-02-2011 12:00:00', 'DD-MM-YYYY HH24:MI:SS')
  -- --------------------------------------------------------  
  and dlv.source_document_type_id = 10
  AND nvl(sih.CANCEL_FLAG,'N')    = 'N'  
  and dlv.source_code             = 'OE'
  and dlv.released_status_name like 'Shipped'  
  and sil.destination_type_code   = 'EXPENSE'
  and oeh.order_number            = '12553'  
ORDER BY 2, 3, 5
  

