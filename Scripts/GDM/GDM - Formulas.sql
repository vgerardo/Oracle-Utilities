--
--MX AC GMD Admin Perfiles Seguridad
--   Organization = PPR 

BEGIN
     FND_GLOBAL.apps_initialize (user_id=>16776, resp_id =>51808, resp_appl_id=>552);
END;
/


select * from fm_form_mst;

--
--Este query asume que las uom de la formula siempre serán KG o PZ 
--y que los Items-Ingredientes siempre serán KG
--
SELECT 
     decode (fd.detail_uom, 'kg', fd.qty
                            , 'pz', decode (itm.weight_uom_code, 'kg', fd.qty * itm.unit_weight, 0 )
                            , 0                               
               )                                    peso_kg
     ,itm.segment1
FROM fm_form_mst            fm
   , gmd.fm_matl_dtl        fd
   , mtl_system_items_b  itm
WHERE fm.formula_id = fd.formula_id
  and fd.inventory_item_id = itm.inventory_item_id
  and fd.organization_id   = itm.organization_id
 -- AND fm.formula_status = 700                   --700=Approved for General Use
  --AND fm.formula_type   = 1                     -- 1 = Packaging
  --and fd.line_type = -1                         -- Ingredientes
  --AND fd.contribute_yield_ind = 'N'
  and fm.formula_no like '19A1402439' 
;
