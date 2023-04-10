

--
-- Usuarios y Asignaciones de Responsabilidades
--
--select distinct
--       usr.user_name
--     , pap.full_name     
--     , USR.END_DATE USR_FIN     
--     , asig.start_date ASIG_INICIO, asig.end_date ASIG_FIN     
--     , resp.end_date RESP_FIN
--     , apps.application_name
--     , apps.application_short_name
--     , apps.product_code
     
SELECT  DECODE (NVL(WEB_HOST_NAME,apps.application_name)
                     ,'General Ledger', 'Finanzas'
                     ,'Payables',  'Finanzas'
                     ,'Receivables',  'Finanzas'
                     ,'Cash Management', 'Finanzas'
                     ,'Web Applications Desktop Integrator', 'Finanzas'
                     ,'Human Resources', 'Human Resources'
                     ,'Assets', 'Activo Fijo'
                     ,'Self-Service Web Applications', 'Human Resources'
                     ,'Inventory', 'Inventarios'   
                     ,'Treasury', 'Tesoreria'
                     ,'Purchasing', 'Compras'      
                     ,'Order Management', 'OM'                       
                     ,'Discover', 'Discover'   
                     , 'Sin Clasificar'
                     ) Modulo
            , resp.responsibility_name         
            , usr.user_name
            , COUNT(DISTINCT usr.USER_NAME)                                        
FROM FND_USER                     usr
   , PER_ALL_PEOPLE_F             pap
   , apps.FND_USER_RESP_GROUPS_DIRECT  asig
   , apps.FND_RESPONSIBILITY_VL        resp
   , apps.FND_APPLICATION_VL           apps
where usr.user_id = asig.user_id  
  and usr.employee_id = pap.person_id (+) 
  and asig.responsibility_id = resp.responsibility_id
  and resp.application_id = apps.application_id   
  and user_name not in ('AUTOINSTALL', 'SYSADMIN')
  --and nvl(asig.end_date,sysdate+1) >= sysdate
  --and nvl(usr.end_date,sysdate+1) >= sysdate
  --and user_name like 'HCMR%' 
  --and resp.responsibility_name like 'CMXR CASH INQUIRY_CGOR'  
  AND NVL(USR.END_DATE,SYSDATE+1) > SYSDATE
  AND NVL(resp.end_date,SYSDATE+1) > SYSDATE
  AND NVL(asig.end_date, sysdate+1) > SYSDATE
  AND usr.user_name like 'CONE-%'
  --AND resp.responsibility_name  = 'CMXR_PO_PROVEEDORES_CCRM'
  --and apps.application_name = 'Treasury'
GROUP BY       
DECODE (NVL(WEB_HOST_NAME,apps.application_name)
                     ,'General Ledger', 'Finanzas'
                     ,'Payables',  'Finanzas'
                     ,'Receivables',  'Finanzas'
                     ,'Cash Management', 'Finanzas'
                     ,'Web Applications Desktop Integrator', 'Finanzas'
                     ,'Human Resources', 'Human Resources'
                     ,'Assets', 'Activo Fijo'
                     ,'Self-Service Web Applications', 'Human Resources'                                   
                     ,'Inventory', 'Inventarios'
                     ,'Treasury', 'Tesoreria'
                     ,'Purchasing', 'Compras'                     
                     ,'Order Management', 'OM'
                     ,'Discover', 'Discover'
                     ,'Sin Clasificar'
                     )
          , resp.responsibility_name
          , usr.user_name  

