--
-- VISTA:  fnd_flex_values_vl
--
SELECT fvt.LANGUAGE, flex_value_meaning, FVT.description, instr(fvt.description,'-')
FROM fnd_flex_values_tl     fvt
     , fnd_flex_values      fv
     , fnd_flex_value_sets  fvs   
WHERE 1=1
   and fvt.flex_value_id = fv.flex_value_id
   and fv.flex_value_set_id = fvs.flex_value_set_id
   and fvt.LANGUAGE in ( 'ESA')
   and fvs.flex_value_set_name IN (
                           'GRP_CIA', --segment1
                           'GRP_CC', --segment2
                           'GRP_CTA', --segment3
                           'GRP_SUBCTA', --segment4
                           'GRP_SUB_SUBCTA', --segment5
                           'GRP-INTERCO', --segment6
                           'GRP-IDENTIFICADOR' --segment7
                        )   
    and fvs.flex_value_set_name =  'GRP_CIA'                       
   and fvt.flex_value_meaning LIKE '6%'
   AND fvt.description IS NOT NULL
 
order by fvt.flex_value_meaning   
   ;
   
   --GPO - GRUPO POSADAS, S.A.B. DE C.V.
   --C1XALA – ADMINISTRACIONES CEDRO, SA DE CV
 
 