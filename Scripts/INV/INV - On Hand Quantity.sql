
SELECT *
FROM INV.mtl_onhand_quantities_detail
where 1=1
 and organization_id = 422
 and inventory_item_id = 478989
;

SELECT * 
FROM MTL_ONHAND_QUANTITIES 
where 1=1
 and organization_id = 422
 and inventory_item_id = 478989;
 
SELECT * FROM MTL_ONHAND_ITEMS_V 
where 1=1
 and organization_id = 422
 and inventory_item_id = 478989
 ;
 
SELECT * 
FROM MTL_ONHAND_LOCATOR_V 
where 1=1
 and organization_id = 422
 and inventory_item_id = 478989;

SELECT * 
FROM MTL_ONHAND_SUB_V
where 1=1
 and organization_id = 422
 and inventory_item_id = 478989;

SELECT * FROM MTL_ONHAND_TOTAL_V
where 1=1
 and organization_id = 422
 and inventory_item_id = 478989;

select *
from mtl_onhand_total_mwb_v
where 1=1
  and organization_id = 422
  and inventory_item_id = 478989
;

SELECT sum(reservation_quantity)
FROM mtl_reservations
where 1=1
  and organization_id = 422
  and inventory_item_id = 478989
  and subinventory_code = 'DISPONIBLE'
;
