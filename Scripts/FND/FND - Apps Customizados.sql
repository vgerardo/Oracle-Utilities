--
-- Copyright 2012 Gerardo's Advanced Technology Corporation
--
-- Query que devuelve un listado de todos los programas customizados
-- Los clasifica en Concurrentes y Formas
--
SELECT 
         user_concurrent_program_name
       , b.concurrent_program_name      program_name
       , exe.executable_name  
       , exe.execution_file_name
       , 'Concurrente' Tipo
       , Decode ( b.execution_method_code
                , 'P', 'Informes Oracle'
                , 'I', 'Procedimiento PL/SQL'
                , 'H', 'Computadora Central'
                , 'L', 'SQL*Loader'
                , 'Q', 'SQL*Plus'
                , 'K', 'XML Publisher'
                , b.execution_method_code
                ) Sub_Tipo       
       , usr.user_name Creador
       , t.description
       , To_char ( t.creation_date, 'yyyy-mm-dd' ) fecha_creacion       
             --           
    FROM fnd_concurrent_programs_tl t 
        ,fnd_concurrent_programs b
        ,fnd_executables_vl exe
        ,fnd_user           usr
        ,fnd_application    app
   WHERE b.application_id = t.application_id
     and app.application_id = t.application_id
     and app.application_short_name = 'XBOL'
     AND b.concurrent_program_id = t.concurrent_program_id
     AND t.LANGUAGE = 'ESA'
     AND enabled_flag = 'Y'
     and b.executable_id = exe.executable_id  
     AND usr.user_id = t.created_by              
     --and app.zd_edition_name like 'V_20150421_1135'
--   
UNION ALL


SELECT 
         t2.user_form_name  
       , null
       , b2.form_name
       , b2.form_name       
       , 'Formulario'    Tipo
       , 'FORM'          Subtipo
       , usr.user_name   Creado_por
       , t2.description       
       , to_char ( b2.creation_date, 'yyyy-mm-dd' ) fecha_creacion                     
from fnd_form_tl t2, fnd_form b2, fnd_user usr
     ,fnd_application app
where 1=1
  and t2.LANGUAGE = 'ESA'
  AND b2.application_id = t2.application_id
  and app.application_id = t2.application_id
  and app.application_short_name = 'XBOL'
  AND b2.form_id = t2.form_id
   AND usr.user_id = b2.created_by               
   --
   -- devuelve solo si existe una función relacionada a la pantalla
   --
   and exists (select 1
               from fnd_form_functions x
               where x.form_id = b2.form_id
               )
   -- --------------------------------------------------------
     --and app.zd_edition_name like 'V_20150421_1135'
        
ORDER BY 1, -- tipo
         7 desc, -- fecha creación
         2, --sub tipo       
         3, --user_name 
         4 -- nombre de la aplicacion 
;         
     

