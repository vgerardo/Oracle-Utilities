
select fcpt.user_concurrent_program_name
     , cp.CONCURRENT_PROGRAM_NAME
     , exe.execution_file_name     
     , cp.enabled_flag
     , fcpt.creation_date
     , (SELECT USER_NAME FROM FND_USER WHERE USER_ID =FCPT.CREATED_BY) CREADO_POR
     , FRGU.REQUEST_UNIT_TYPE
     , FRGU.REQUEST_UNIT_ID
     , FRG.REQUEST_GROUP_NAME
     , FRT.RESPONSIBILITY_NAME     
  FROM APPS.FND_CONCURRENT_PROGRAMS_TL FCPT
     , APPS.FND_CONCURRENT_PROGRAMS    CP
     , APPS.FND_REQUEST_GROUP_UNITS    FRGU
     , APPS.FND_REQUEST_GROUPS         FRG        
     , APPS.FND_RESPONSIBILITY         FR
     , APPS.FND_RESPONSIBILITY_TL      FRT
     , apps.fnd_executables_vl         exe       
 WHERE 1=1
   AND FCPT.CONCURRENT_PROGRAM_ID = FRGU.REQUEST_UNIT_ID  (+)
   AND FCPT.CONCURRENT_PROGRAM_ID = CP.CONCURRENT_PROGRAM_ID (+)
   AND FRGU.REQUEST_GROUP_ID      = FRG.REQUEST_GROUP_ID  (+)
   AND FRG.REQUEST_GROUP_ID       = FR.REQUEST_GROUP_ID   (+)
   and FR.RESPONSIBILITY_ID       = FRT.RESPONSIBILITY_ID (+)
   AND cp.executable_id           = exe.executable_id     (+)
   --AND UPPER(FCPT.USER_CONCURRENT_PROGRAM_NAME) like UPPER(:conc_program_name)||'%'
   and fcpt.language = 'ESA'
   AND UPPER(FCPT.USER_CONCURRENT_PROGRAM_NAME) like upper('GRP XTR Cuenta Corriente - Intereses x Capitalizar')
 ORDER BY 1;
 
 