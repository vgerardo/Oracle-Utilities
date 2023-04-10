 --
 -- este query retorna la OC asociada a una Factura
 --

select 
       h.segment1 num_oc
     , lc.location_code
     , h.creation_date  
     , v.segment1, v.vendor_name
     , d.line_num
     , (itm.segment1||'.'||itm.segment2||'.'||itm.segment3) item
     ,d.item_description, d.unit_price
     , itm.purchasing_tax_code
     , pll.quantity_received
     , pll.quantity_billed
     , (pll.quantity_received * d.unit_price) Received_amount
     , (pll.quantity_billed * d.unit_price) Billed_amount   
     , pia.invoice_num
     , h.po_header_id
     , lc.inventory_organization_id
     , d.item_id
from po_headers_all 	h
    ,po_lines_all   	d
    ,po_distributions_all   pd
    ,hr_locations_all       lc
    ,po_line_locations_all  pll
    ,po_vendors     	    v
    ,ap_invoice_distributions_all aid
    ,mtl_system_items_B     itm
    ,zx_input_classifications_v     zxic
    ,ap_invoices_all        pia
where 1=1
  and h.po_header_id 	= d.po_header_id
  and h.org_id          = d.org_id
  and h.bill_to_location_id = lc.location_id
  and d.po_header_id    = pll.po_header_id
  and d.po_line_id      = pll.po_line_id   
  and d.item_id         = itm.inventory_item_id
  and lc.inventory_organization_id = itm.organization_id
  and itm.purchasing_tax_code = zxic.lookup_code
  and zxic.lookup_type = 'ZX_INPUT_CLASSIFICATIONS'
  and h.vendor_id 	= v.vendor_id
  and h.po_header_id  	= pd.po_header_id
  AND pd.po_distribution_id = aid.po_distribution_id (+)
  and aid.invoice_id 	= pia.invoice_id (+)
  --and h.segment1 	= '17215'
  and h.segment1 	= '17217'
  and h.org_id      = 85
;



select * from  zx_input_classifications_v 
where lookup_type = 'ZX_INPUT_CLASSIFICATIONS'
 and LOOKUP_CODE LIKE 'FISURG AP 16% IVA';
 
 
