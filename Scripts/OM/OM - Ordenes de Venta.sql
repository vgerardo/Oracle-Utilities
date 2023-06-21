

--
-- Muestra los Pedidos de Venta que han sido embarcados 
-- y muestra si han sido facturas en AR 
-- y también las recepciones de dichos pedidos.
--
select  distinct
        hrl.name                       Organizacion
     , arh.trx_number                  AR_FAC
     , sih.segment1                    Sol_Interna
     , oeh.order_number                Orden_Venta
     , mt.shipment_number              Embarque               
     , oel.line_number
     , oel.ordered_item          
     , dlv.item_description
     , dlv.requested_quantity_uom     UOM    
     , dlv.released_status_name               
     , sil.need_by_date
     , OEH.ordered_date     
     , dlv.requested_quantity           cantidad_solicitada
     , nvl(dlv.cancelled_quantity,0)    cantidad_cancelada
     , dlv.shipped_quantity             cantidad_enviada    
     , nvl(rec.quantity,0)              cantidad_recibida      
     , nvl(arl.quantity_invoiced,0)     cantidad_facturada  
     , nvl(arl.unit_selling_price,ll.operand)                precio_lista     
     , dlv.currency_code
     , (dlv.shipped_quantity * round(nvl(arl.unit_selling_price,ll.operand),2))  importe
     , oel.tax_code
     , sil.source_type_code               
     , sil.destination_type_code      
     , dlv.last_update_date             dlv_last_update_date
     , dlv.latest_pickup_date     
     , dlv.inventory_item_id           
     , (gcc.segment1 ||'.'||gcc.segment2||'.'||gcc.segment3 ||'.'||gcc.segment4 ||'.'||gcc.segment5 ||'.'||gcc.segment6 ||'.'||gcc.segment7) cuenta
     , mt.transaction_id     material_transaction_id
     --, usr.user_name
     , arh.*
             
from wsh_deliverables_v             dlv
   , oe_order_headers_all           oeh
   , oe_order_lines_all             oel
   , po_requisition_headers_all     sih
   , po_requisition_lines_all       sil
   , po_req_distributions_all       sid
   , gl_code_combinations           gcc  
   , mtl_material_transactions      mt 
   , qp_list_lines_v                LL 
   , ra_customer_trx_lines_all      arl
   , ra_customer_trx_all            arh
   , rcv_transactions               rec          
   , hr_all_organization_units      hrl          
   --, FND_USER                       usr  
WHERE dlv.source_header_id    = oeh.header_id  
  and dlv.source_line_id      = oel.line_id
  and oeh.header_id           = oel.header_id
  and oeh.source_document_id  = sih.requisition_header_id
  and oel.source_document_id  = sil.requisition_header_id
  AND oel.source_document_line_id  = sil.requisition_line_id
  and sih.org_id              = sil.org_id 
  and sil.org_id              = sid.org_id  
  and sil.requisition_line_id = sid.requisition_line_id  
  and sid.code_combination_id = gcc.code_combination_id
  and dlv.source_header_id    = mt.TRANSACTION_REFERENCE 
  and dlv.source_line_id      = mt.TRX_SOURCE_LINE_ID
  and dlv.inventory_item_id   = mt.inventory_item_id
  and dlv.SUBINVENTORY        = mt.SUBINVENTORY_CODE
  and dlv.organization_id     = mt.ORGANIZATION_ID
  AND dlv.RELEASED_STATUS not in ( 'D', 'B', 'R') --D=Cancelled B=Pedido Pendiente (Backordered) R=Listo para Despacho (Ready to Release)
  -- ---------------------------------------------------------------
  -- Estas 2 banderas indican estado  = INTERFACED
  -- Posteriormente, tiene que correr los concurrentes:
  --   * Crear Facturas AR Intercompañía
  --   * Programa Principal de Facturación Automática
  --   * Crear Facturas AP Entre Compañía
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
  and oel.price_list_id       = ll.list_header_id  (+)
  and oel.ordered_item        = ll.product_attr_val_disp (+)  
  AND dlv.org_id              = arl.ORG_ID  (+)
  and dlv.source_header_number= arl.sales_order (+)           
  and dlv.inventory_item_id   = arl.inventory_item_id (+)
  and dlv.source_line_id      = arl.interface_line_attribute6 (+)
  and arl.customer_trx_id     = arh.customer_trx_id (+)  
  and sil.destination_organization_id = hrl.organization_id        
  and sid.distribution_id     = rec.req_distribution_id (+)
  AND 'RECEIVE'               = rec.transaction_type (+)
  and oeh.order_number            = '12778' --'8164' --'12553'
 -- AND SIL.REQUISITION_LINE_ID   = 154467
  --and oel.line_number             = 9
  --and oel.ordered_item            = 'ACM00041'
  --and sil.destination_type_code = 'EXPENSE'
  --and TO_CHAR(OEH.ordered_date,'MM-YYYY') = '10-2010'
  --and sih.segment1     = '1361'
  --and dlv.cancelled_quantity is not null           
ORDER BY 2, 3, 5
  


