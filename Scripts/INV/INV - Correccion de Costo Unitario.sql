
CMR_INV_FIS_CONTEO_ajuste_gvp

--
----CMR_INV_FIS_CONTEO_ajuste_gvp

--
-- Corrección de COSTO UNITARIO
--
-- Esto afecta al reporte de CMR Diferencias de Inventario
--
UPDATE CMR_INV_FIS_CONTEO_ajuste A set
    costo_unitario =
            (
            select 
            x.item_cost
            from cst_item_costs x, MTL_SYSTEM_ITEMS_B y
            where  x.organization_id = y.organization_id
               and x.inventory_item_id = y.inventory_item_id
               and y.organization_id =  a.organization_id
               and y.segment1 = a.item
               )        
WHERE 1=1  
  and   (a.organization_id, a.item, a.PHYSICAL_INVENTORY_ID) IN
      ( 
      
        SELECT   Ax.organization_id, Ax.item,  Ax.PHYSICAL_INVENTORY_ID
        FROM  CMR_INV_FIS_CONTEO_ajuste        Ax
            , CMR_INV_FIS_CONTEO_AJUSTE_H      Bx
            , MTL_SYSTEM_ITEMS_B               Cx  
            , cst_item_costs                   cicx        
            , hr_all_organization_units        oux   
        where 1=1
          and Ax.PHYSICAL_INVENTORY_ID = Bx.PHYSICAL_INVENTORY_ID
          AND Ax.ORGANIZATION_ID = Bx.ORGANIZATION_ID  
          AND Bx.PHYSICAL_INVENTORY_DATE >= TO_DATE ('2010/11/15', 'YYYY/MM/DD')
          AND Ax.ITEM                = Cx.SEGMENT1
          AND bx.ORGANIZATION_ID     = Cx.ORGANIZATION_ID
          and bx.ORGANIZATION_ID     = oux.organization_id
          and round(Ax.costo_unitario,4) <> round(cicx.item_cost,4)
          and to_char(cicx.last_update_date,'yyyy-mm-dd') = '2010-11-30'
          and cicx.inventory_item_id = cx.inventory_item_id
          and cicx.organization_id   = cx.organization_id
          and cicx.item_cost <> 0  
          and oux.name like 'FPOLA%'
                                    
    )




