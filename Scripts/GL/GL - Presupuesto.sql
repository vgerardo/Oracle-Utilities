
--
-- Configuración de RANGO de Cuntas de PRESUPUESTO
--
SELECT 
       --decode (gbe.budget_entity_id, 1000, 'PPTO 2010', 1001, 'PLAN 2010', 1002, 'PLAN 2011', 'OTRO') TIPO
       gbe.name
     , ( gbar.segment1_low ||'.'||
         gbar.segment2_low ||'.'||
         gbar.segment3_low ||'.'||
         gbar.segment4_low ||'.'||
         gbar.segment5_low ||'.'||
         gbar.segment6_low ||'.'||
         gbar.segment7_low 
     ) cuenta_low
     , ( gbar.segment1_high ||'.'||
         gbar.segment2_high ||'.'||
         gbar.segment3_high ||'.'||
         gbar.segment4_high ||'.'||
         gbar.segment5_high ||'.'||
         gbar.segment6_high ||'.'||
         gbar.segment7_high 
     ) cuenta_high     
     , gbar.currency_code     
FROM GL_BUDGET_ENTITIES             gbe
    ,GL_BUDGET_ASSIGNMENT_RANGES_V  gbar 
WHERE gbe.BUDGET_ENTITY_ID= gbar.BUDGET_ENTITY_ID
  AND status_code != 'D'
  --and gbe.BUDGET_ENTITY_ID BETWEEN 1000 AND 1002  
ORDER BY gbe.BUDGET_ENTITY_ID



select  
        gcc.segment1 cia
      , decode (substr(gcc.segment3, 1,1),
                 '6', 'GASTO',
                 '4', 'INGRESO',
                 '7', 'ESTADISTICO',
                 '5', 'COSTO'
               ) tipo
      , glb.period_year
      , glb.CURRENCY_CODE
      , decode(glb.budget_version_id,1000,'PPTO 2010', 1001,'PLAN 2010', 1002, 'PLAN 2011') Presupuesto
      , to_char(sum(period_net_dr),'999,999,999,990.00') debito
      , to_char(sum(period_net_cr),'999,999,999,990.00') credito                                   
from gl_balances glb
,    gl_code_combinations gcc
where glb.code_combination_id = gcc.code_combination_id 
 AND glb.actual_flag = 'B'  
-- and glb. period_year = 2011
GROUP BY
        gcc.segment1                  
      , glb.CURRENCY_CODE
      , glb.period_year
      , decode(glb.budget_version_id,1000,'PPTO 2010', 1001,'PLAN 2010', 1002, 'PLAN 2011') 
      , decode (substr(gcc.segment3, 1,1),
                 '6', 'GASTO',
                 '4', 'INGRESO',
                 '7', 'ESTADISTICO',
                 '5', 'COSTO'
               )
order by 1, 2, 3, 4      

