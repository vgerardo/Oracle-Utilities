--
-- Ordenes de Compra, con artículos de tipo CAPEX pero sin un CAPEX ASIGNADO.
--
SELECT distinct pv.vendor_site_code, poh.segment1 Num_OC, poh.comments
FROM po_headers_all poh
 , po_lines_all pol
 , po_vendor_sites_all pv
WHERE poh.po_header_id = pol.po_header_id
  and poh.vendor_id = pv.vendor_id
  and poh.vendor_site_id = pv.vendor_site_id
  and pol.item_description like 'CAPEX%'
  and poh.authorization_status like 'APPROVED'
  and nvl(poh.cancel_flag,'N') = 'N'
  AND poh.creation_date >= to_date ('01012010', 'ddmmyyyy')
  AND poh.attribute1 is null
  --and rownum < 2   
ORDER BY 1, 2  