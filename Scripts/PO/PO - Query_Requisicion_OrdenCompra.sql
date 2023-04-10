
SELECT rh.segment1 req_number, rh.org_id
      , rl.item_description, rl.unit_price, rl.quantity
      , oh.segment1 po_number
      , rh.requisition_header_id, rl.requisition_line_id
FROM po_requisition_headers_all rh
    ,po_requisition_lines_all   rl
    ,po.po_line_locations_all   ll
    ,po_lines_all               ol
    ,po_headers_all             oh
WHERE 1=1
  and rh.requisition_header_id  = rl.requisition_header_id
  AND rl.line_location_id       = ll.line_location_id (+)
  AND ll.po_line_id             = ol.po_line_id(+)    
  and ol.po_header_id           = oh.po_header_id (+)
  and rh.authorization_status   = 'APPROVED'
  --and rh.requisition_header_id  = 78665
  and rh.segment1 = 20211
 ;

--
-- Ordenes de Venta
--
SELECT rh.segment1, oh.*
FROM po_requisition_headers_all rh
    ,oe_order_headers_all       oh
WHERE rh.requisition_header_id = oh.source_document_id
  and oh.order_number like '32076'
;



 SELECT rh.segment1, oh.conversion_rate, oh.transactional_curr_code, ol.source_document_line_id
FROM po_requisition_headers_all rh
    ,oe_order_headers_all       oh
    ,oe_order_lines_all         ol
WHERE rh.requisition_header_id = oh.source_document_id
  and oh.header_id = ol.header_id
  and oh.org_id = ol.org_id
  and rh.requisition_header_id   = 4175662
  and ol.source_document_line_id = 1356947 --requisition_line_id
  --and oh.order_number like '32076'
;