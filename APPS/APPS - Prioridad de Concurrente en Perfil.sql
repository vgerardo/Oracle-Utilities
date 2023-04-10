
--
-- Devuelve la prioridad asignada en el Perfil del usuario (Application Administrador->Profile).
-- para la ejecución de concurrentes.
--
-- Si el usuario no se encuentra en esta lista, entonces por default su prioridad es 50.
--
SELECT  decode (pov.level_id
                 , 10001, 'Site'
                 , 10002, 'Application'
                 , 10003, 'Responsabilidad'
                 , 10004, 'User'
                 , ' '
               ) Tipo
       , pov.PROFILE_OPTION_VALUE
      --, T.VISIBLE_OPTION_VALUE
      , USR.USER_NAME
      , rsp.responsibility_name      
      , POV.last_update_date      
      , usr2.user_name last_updated_by                
FROM 
     fnd_profile_options_tl     potl
   , fnd_profile_options        po
   , fnd_profile_option_values  pov
   ,  fnd_responsibility_tl        rsp
   , fnd_user                   usr
   , fnd_user                   usr2
WHERE 
      po.PROFILE_OPTION_NAME = potl.PROFILE_OPTION_NAME
  AND potl.LANGUAGE = 'ESA'  
  AND pov.PROFILE_OPTION_ID = po.PROFILE_OPTION_ID
  and pov.application_id    = po.application_id
  and pov.level_value = rsp.responsibility_id (+)
  and pov.level_value_application_id  = rsp.application_id (+)
  and 'ESA'           = rsp.language (+)
  AND pov.level_value = usr.user_id (+)  
  --AND po.PROFILE_OPTION_ID=1991
  AND UPPER (USER_PROFILE_OPTION_NAME) = 'CONCURRENTE: PRIORIDAD DE SOLICITUDES'
  AND pov.last_updated_by  = usr2.user_id (+)
  --and usr.user_name like 'CORP-ACASTILLOA'
ORDER BY USR.USER_NAME



SELECT *
FROM FND_USER
WHERE USER_ID = 39485




--
-- Valor asignado al profile 'MO: Unidad Operativa'
--
SELECT POV.PROFILE_OPTION_VALUE, OU.NAME, RES.RESPONSIBILITY_KEY
 FROM FND_PROFILE_OPTIONS_TL T
    , FND_PROFILE_OPTIONS    po
    , FND_PROFILE_OPTION_VALUES  POV
    , HR_ALL_ORGANIZATION_UNITS  OU
    , FND_RESPONSIBILITY_VL      RES
WHERE po.PROFILE_OPTION_NAME = T.PROFILE_OPTION_NAME
    AND pov.PROFILE_OPTION_ID = po.PROFILE_OPTION_ID   
    and t.language = 'ESA'
     AND UPPER (USER_PROFILE_OPTION_NAME) = UPPER('MO: Unidad Operativa')
     AND pov.PROFILE_OPTION_VALUE = OU.ORGANIZATION_ID || ''    
--   and pov.last_update_date > sysdate - 10 
   and LEVEL_ID = 10003  -- 10001=Sucursal   10003=Responsabilidad     
 AND RES.RESPONSIBILITY_ID = POV.LEVEL_VALUE
   AND RES.RESPONSIBILITY_KEY LIKE 'CMXR_PAGOS_USUARIO_%'   
   
  
