--
-- UDM
--
  SELECT          
         UNIT_OF_MEASURE,
         UNIT_OF_MEASURE_TL,
         UOM_CODE,
         DESCRIPTION,
         BASE_UOM_FLAG,
         UOM_CLASS,
         DISABLE_DATE,         
         CREATION_DATE         
    FROM MTL_UNITS_OF_MEASURE_VL
ORDER BY uom_class, unit_of_measure



--
-- CATEGORIAS
--
  SELECT STRUCTURE_NAME,
         DESCRIPTION,
         DISABLE_DATE,                           
         CATEGORY_ID,
         STRUCTURE_ID,
         CATEGORY_CONCAT_SEGS,
         SEGMENT1 CATEGORIA,
         SEGMENT2 SUBCATEGORIA, 
         SEGMENT3,
         SEGMENT4,
         SUMMARY_FLAG,
         ENABLED_FLAG,
         START_DATE_ACTIVE,
         END_DATE_ACTIVE
    FROM MTL_CATEGORIES_V
   WHERE (STRUCTURE_ID = 101)
ORDER BY structure_name, category_concat_segs




--
-- CODIGOS DE IMPUESTOS
--
  SELECT               
         SET_OF_BOOKS_ID,
         TAX_TYPE,
         TAX_CODE_COMBINATION_ID,
         NAME,
         TAX_RATE,
         START_DATE,
         INACTIVE_DATE,
         ENABLED_FLAG,
         TAX_RECOVERY_RATE,
         DESCRIPTION,
         WEB_ENABLED_FLAG,
         TAX_RECOVERY_RULE_ID,
         OFFSET_TAX_CODE_ID,
         AWT_PERIOD_TYPE,
         AWT_PERIOD_LIMIT,
         SUPPRESS_ZERO_AMOUNT_FLAG,
         TAX_ID         
    FROM AP_TAX_CODES_ALL
   WHERE TAX_TYPE <> 'TAX_GROUP' AND (SET_OF_BOOKS_ID = 1002)
ORDER BY TAX_TYPE, NAME



--
-- SUBINVENTARIOS
--
/* Formatted on 09/08/2010 02:44:04 p.m. (QP5 v5.139.911.3011) */
  SELECT B.NAME ORG_NAME,
         A.ORGANIZATION_ID,
         A.REQUISITION_APPROVAL_TYPE,
         A.SECONDARY_INVENTORY_NAME,
         A.DESCRIPTION,
         STATUS_ID,
         STATUS_CODE,
         DEFAULT_COST_GROUP_ID,
         DEFAULT_COST_GROUP_NAME,
         SUBINVENTORY_TYPE,
         QUANTITY_TRACKED,
         ASSET_INVENTORY,
         DEPRECIABLE_FLAG,
         INVENTORY_ATP_CODE,
         RESERVABLE_TYPE,
         AVAILABILITY_TYPE,
         LPN_CONTROLLED_FLAG,
         CARTONIZATION_FLAG,
         PLANNING_LEVEL,
         ENABLE_BULK_PICK,
         DEFAULT_COUNT_TYPE_CODE,
         LOCATOR_TYPE,
         DEFAULT_LOC_STATUS_ID,
         DEFAULT_LOC_STATUS_CODE,
         PICKING_ORDER,
         DROPPING_ORDER,
         pick_uom_code,
         DISABLE_DATE,
         SOURCE_TYPE,
         SOURCE_ORGANIZATION_ID,
         SOURCE_ORGANIZATION_CODE,
         SOURCE_SUBINVENTORY,
         PREPROCESSING_LEAD_TIME,
         PROCESSING_LEAD_TIME,
         POSTPROCESSING_LEAD_TIME,
         MATERIAL_ACCOUNT,
         OUTSIDE_PROCESSING_ACCOUNT,
         MATERIAL_OVERHEAD_ACCOUNT,
         OVERHEAD_ACCOUNT,
         RESOURCE_ACCOUNT,
         A.EXPENSE_ACCOUNT,
         A.ENCUMBRANCE_ACCOUNT,
         A.NOTIFY_LIST,
         A.NOTIFY_LIST_ID,
         A.LOCATION_CODE,
         A.LOCATION_ID,
         DEMAND_CLASS
    FROM MTL_SECONDARY_INVENTORIES_FK_V A        
         ,HR_ALL_ORGANIZATION_UNITS      B
    WHERE A.ORGANIZATION_ID = B.ORGANIZATION_ID      
ORDER BY 1, secondary_inventory_name
 

--
-- ORGANIZACIONES DE INVENTARIO
--
SELECT ORGANIZATION_ID, LOCATION_ID, NAME, DATE_TO
FROM HR_ALL_ORGANIZATION_UNITS
WHERE NAME LIKE '%_INV'      


--
-- COMBINACIONES CONTABLES
--
SELECT CODE_COMBINATION_ID,
    ACCOUNT_TYPE,
    ENABLED_FLAG,
    lpad(SEGMENT1,4,'0') ||'.'||
    lpad(SEGMENT2,4,'0') ||'.'||
    lpad(SEGMENT3,7,'0') ||'.'||
    lpad(SEGMENT4,3,'0') ||'.'||
    lpad(SEGMENT5,4,'0') ||'.'||
    lpad(SEGMENT6,3,'0') ||'.'||
    lpad(SEGMENT7,3,'0') CUENTA
    ,START_DATE_ACTIVE        
FROM GL_CODE_COMBINATIONS
ORDER BY SEGMENT1, SEGMENT2, SEGMENT3

--
-- ARTICULOS X ORGANIZACION
--
SELECT A.SEGMENT1, A.DESCRIPTION, B.NAME 
FROM MTL_SYSTEM_ITEMS A,
     HR_ALL_ORGANIZATION_UNITS B
WHERE A.ORGANIZATION_ID = B.ORGANIZATION_ID
AND A.ORGANIZATION_ID <> 517
ORDER BY A.SEGMENT1, B.NAME      


--
-- PROVEEDORES X SUCURSAL
--
SELECT A.SEGMENT1, A.VENDOR_NAME, B.VENDOR_SITE_CODE
FROM PO_VENDORS A
   , PO_VENDOR_SITES_ALL B
WHERE A.VENDOR_ID = B.VENDOR_ID   


