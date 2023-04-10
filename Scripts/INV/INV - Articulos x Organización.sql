--
-- Artículos x Organización
--
SELECT   
         MSI.ORGANIZATION_ID      ORG_ID
       , OU.NAME                 ORG_NAME
       , MSI.segment1             item                      
       , MSI.Description
       , MSI.purchasing_tax_code  tax_code      
       , replace(substr(OU.NAME, instr(OU.name,'_')+1, 100), '_INV') Sucursal 
       , substr(MSI.purchasing_tax_code, 1, instr(MSI.purchasing_tax_code, ' ')-1) tax
       , MSI.list_price_per_unit
       , MSI.END_DATE_ACTIVE ITEM_END_DATE
       , ( GCC.SEGMENT1 ||'.'||GCC.SEGMENT2 ||'.'||GCC.SEGMENT3 ||'.'||GCC.SEGMENT4 ||'.'||GCC.SEGMENT5 ||'.'||GCC.SEGMENT6 ||'.'||GCC.SEGMENT7) Cuenta_Gasto
       , (mc.segment1 ||'.'|| mc.segment2) Categoria
       , inv_rec.subinventory_code  dflt_subinventory
       , SUM (MOH.on_hand)    Cantidad_En_Mano
       , msi.inventory_item_id
 FROM 
      MTL_SYSTEM_ITEMS_B        MSI 
    , mtl_item_categories       mic
    , mtl_categories            mc
    , HR_ALL_ORGANIZATION_UNITS OU
    , GL_CODE_COMBINATIONS      GCC 
    , MTL_ONHAND_TOTAL_MWB_V    MOH 
    , MTL_ITEM_SUB_DEFAULTS     inv_rec
    -- , MTL_ITEM_SUB_INVENTORIES sub_inv
    WHERE 1=1    
          AND MSI.ORGANIZATION_ID   = OU.ORGANIZATION_ID
          AND MSI.ORGANIZATION_ID   = MIC.ORGANIZATION_ID
          AND MSI.INVENTORY_ITEM_ID = MIC.INVENTORY_ITEM_ID          
          AND MIC.CATEGORY_ID       = MC.CATEGORY_ID          (+)  
          AND MSI.EXPENSE_ACCOUNT   = GCC.CODE_COMBINATION_ID (+)
          and msi.organization_id   = inv_rec.organization_id (+)
          and msi.inventory_item_id = inv_rec.inventory_item_id (+)
          and msi.organization_id   = sub_inv.organization_id (+)
          and msi.inventory_item_id = sub_inv.inventory_item_id (+)
          AND MSI.INVENTORY_ITEM_ID = MOH.INVENTORY_ITEM_ID (+)
          AND MSI.ORGANIZATION_ID   = MOH.ORGANIZATION_ID   (+)
          AND MSI.ORGANIZATION_ID <> 517    -- no muestra la maestra
          AND MSI.ORGANIZATION_ID = 418
          and msi.segment1 like 'ICR00471'
          --and ou.name like '%MPJUA _INV'
          --and  MC.segment1 like '%GASTOS%'
 GROUP BY
         MSI.ORGANIZATION_ID      
       , OU.NAME                 
       , MSI.segment1   
       , msi.inventory_item_id                                 
       , MSI.Description
       , MSI.purchasing_tax_code        
       , replace(substr(OU.NAME, instr(OU.name,'_')+1, 100), '_INV')  
       , substr(MSI.purchasing_tax_code, 1, instr(MSI.purchasing_tax_code, ' ')-1) 
       , MSI.list_price_per_unit
       , MSI.END_DATE_ACTIVE 
       , ( GCC.SEGMENT1 ||'.'||GCC.SEGMENT2 ||'.'||GCC.SEGMENT3 ||'.'||GCC.SEGMENT4 ||'.'||GCC.SEGMENT5 ||'.'||GCC.SEGMENT6 ||'.'||GCC.SEGMENT7) 
       , (mc.segment1 ||'.'|| mc.segment2) 
       , inv_rec.subinventory_code         
 ORDER BY 2, 3        
          
