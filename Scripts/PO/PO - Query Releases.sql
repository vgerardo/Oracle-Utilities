
SELECT * FROM HR_ORGANIZATION_INFORMATION WHERE org_information3 = '107';
SELECT * FROM hr_organization_units where organization_id = 107;
SELECT * FROM HR_ORGANIZATION_UNITS WHERE organization_id = 107;
SELECT * FROM HR_ORGANIZATION_UNITS_V WHERE organization_id = 107;
SELECT * FROM HR_ALL_ORGANIZATION_UNITS_VL WHERE organization_id = 107;
SELECT * FROM org_organization_definitions where operating_unit = 107 and organization_id = 177;   
select * from mtl_parameters; where organization_id = '107';
select * from hr_locations_all_v where location_id =207;
select * from hr_locations_all where location_id =207;
select * from wsh_ship_from_locations_v where location_id = 177;
select * from hr_organization_units where location_id =207;
select * from po_releases_all;
release_num
SELECT ood.organization_code
FROM po_headers_all         poh
   , po_lines_all           pol
   , po_line_locations_all  pll
   , po_releases_all        por
   , mtl_system_items       itm
   , org_organization_definitions   ood
WHERE 1=1
  and poh.po_header_id  = pol.po_header_id
  and pol.po_header_id  = pll.po_header_id
  and pol.po_line_id    = pll.po_line_id
  and pll.po_release_id = por.po_release_id
  and pll.org_id                  = ood.operating_unit
  and pll.ship_to_organization_id = ood.organization_id
  and pol.item_id       = itm.inventory_item_id
  and pol.cancel_flag   = 'N'
  and itm.organization_id = 118 --Master Comex
  --
  and poh.segment1      = 451300
  and por.release_num   = 6
  --
  and pol.item_id is not null
  and (select count(*) from po_lines_all where po_header_id = poh.po_header_id) > 10
;