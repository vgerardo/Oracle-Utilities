
SELECT    mgd.organization_id
         ,units.name
         ,mgd.segment1           Alias
         ,mgd.description       Descripcion                          
         , (gcc.segment1 ||'.'|| gcc.segment2 ||'.'|| gcc.segment3 ||'.'|| gcc.segment4 ||'.'|| gcc.segment5 ||'.'|| gcc.segment6 ||'.'|| gcc.segment7 ) cuenta
         ,gcc.enabled_flag
         ,gcc.account_type
    FROM mtl_generic_dispositions mgd
     , hr_all_organization_units units
     , gl_code_combinations gcc
   WHERE 1=1
    AND units.organization_id = mgd.organization_id
    and mgd.distribution_account = gcc.code_combination_id
    --AND gcc.enabled_flag = 'Y'
   --and gcc.segment1 = '0017'            -- cia 
   --and gcc.segment2 = '0049'        -- cc
   --and gcc.segment3 = '5112001'     -- cuenta
   --and gcc.segment4 = '000'         -- subcuenta
   --and gcc.segment5 = '0000'        -- interco
   --and gcc.segment6 = '000'         -- fut 1
   --and gcc.segment7 = '000'         -- fut 2
   AND UPPER(mgd.segment1) LIKE '%LARC%'
ORDER BY organization_id 

 


