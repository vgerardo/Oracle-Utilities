SELECT 'SELECT * FROM '||owner||'.'||object_name||';'
FROM ALL_OBJECTS
WHERE object_name like '%CST_ITEM_COST%'
AND object_type in ('TABLE', 'VIEW')
;

SELECT * FROM BOM.CST_COST_TYPES;
SELECT * FROM APPS.CST_COST_TYPES_V;
SELECT * FROM APPS.CST_COST_TYPES_ALL_V;
SELECT * FROM BOM.CST_ITEM_COST_DETAILS where /*cost_type_id=1 and*/ organization_id = 742 and inventory_item_id = 1247022;
SELECT * FROM BOM.CST_ITEM_COSTS where /*cost_type_id=1 and*/ organization_id = 742 and inventory_item_id = 1247022;
SELECT * FROM APPS.CST_ITEM_COSTS_VIEW where cost_type_id=1 and organization_id = 742 and inventory_item_id = 1247022;
SELECT * FROM APPS.CST_ITEM_COST_DETAILS_V where cost_type_id=1 and organization_id = 742 and inventory_item_id = 1247022;

--esta vista es la que utiliza la pantalla
--Inventory -> Costs -> Item Costs
SELECT cost_type,item_cost, material_cost 
FROM APPS.CST_ITEM_COST_TYPE_V 
WHERE organization_id = 742 
  and ITEM_NUMBER = '20C-CA00199' 
  and inventory_item_id = 1247022
  
  --and cost_type = 'Frozen'
  --and cost_type_id = 1 --Frozen
  
;

