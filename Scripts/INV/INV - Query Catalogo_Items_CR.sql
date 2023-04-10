
--
-- Catálogo de Artículos de COSTA RICA
--
SELECT inventory_item_id, segment1 "Item Number", description
    , (
            SELECT LISTAGG (organization_code,', ') WITHIN GROUP (ORDER BY inventory_item_id) Asignado
            FROM mtl_org_assign_v x
            WHERE x.master_organization_id = M.organization_id
              AND x.inventory_item_id = M.inventory_item_id
        ) asignado
    , inventory_item_status_code "Item Status"
FROM mtl_system_items_b M
where enabled_flag = 'Y'
  and nvl(end_date_active,sysdate+1) > sysdate
  and organization_id = 403 --MSC MASTER COSTA RICA 
ORDER BY segment1
;
