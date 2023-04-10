
--
-- Usuarios y Asignaciones de Responsabilidades
--
SELECT distinct
        usr.user_id        
     ,  usr.user_name
     , pap.full_name
     , asig.responsibility_id
     , resp.responsibility_name
     , usr.end_date     usr_fin     
     , asig.start_date  asig_inicio
     , asig.end_date    asig_fin     
     , resp.end_date    resp_fin
--, apps.application_name, apps.application_short_name, apps.product_code     
FROM fnd_user                     usr
   , per_all_people_f             pap
   , apps.fnd_user_resp_groups_direct  asig
   , apps.fnd_responsibility_vl        resp
   , apps.fnd_application_vl           apps
WHERE usr.user_id = asig.user_id  (+)
  and usr.employee_id = pap.person_id (+) 
  and asig.responsibility_id = resp.responsibility_id (+)
  and resp.application_id = apps.application_id   (+)
  and usr.user_name not in ('AUTOINSTALL', 'SYSADMIN')
  --- ---------------------------------------------------
  -- ACTIVA
  --and nvl(asig.end_date,sysdate+1) >= sysdate
  --and nvl(usr.end_date,sysdate+1) >= sysdate
  --- ---------------------------------------------------  
  --and resp.responsibility_name like 'GPDA_DEVELOPER'
  AND usr.user_name like 'EXT-GVARGAS'
ORDER BY  1, 3 
;



select *
from wf_all_user_roles
where  1=1
--AND user_name like 'EXT-GVARGAS'
AND ROLE_ORIG_SYSTEM_id in (61015, 61035)
;


select *
--start_date, end_date, created_by, creation_date, last_updated_by, last_update_date, effective_start_Date, effective_end_date
from  wf_user_role_assignments wur
where 1=1
  --and wur.user_name = 'EXT-GVARGAS'
 and ROLE_ORIG_SYSTEM_id in (61015, 61035)
  ;
  

SELECT rsp.responsibility_key, rsp.responsibility_id
FROM fnd_user_resp_groups   urg,
     fnd_responsibility     rsp
WHERE urg.responsibility_id = rsp.responsibility_id 
 and urg.user_id = 5801
;

select *
from wf_all_user_role_assignments
where user_name like 'EXT-GVARGAS'
;

SELECT *
FROM WF_LOCAL_ROLES
WHERE 1=1
--AND DISPLAY_NAME LIKE '%APLICATIVO_COBRANZA%'
AND ORIG_SYSTEM_ID IN ( 61015, 61035)
;


SELECT *
FROM WF_LOCAL_USER_ROLES
WHERE 1=1
--and user_name like 'EXT-GVARGAS'
and ROLE_ORIG_SYSTEM_ID  IN ( 61015, 61035)
;



/*
update wf_all_user_roles set
creation_date       = to_date ('2019-11-27','yyyy-mm-dd'),
start_date          = to_date ('2019-11-27','yyyy-mm-dd'),
expiration_date     = to_date ('2019-11-28','yyyy-mm-dd'),
last_update_date    = to_date ('2019-11-28','yyyy-mm-dd'),
created_by          = 5741
where user_name like 'EXT-GVARGAS'
 and role_orig_system_id in (50704,50750,50833,50834,54296)
;

update wf_user_role_assignments wur set
creation_date       = to_date ('2019-11-27','yyyy-mm-dd'), 
start_date          = to_date ('2019-11-27','yyyy-mm-dd'), 
effective_start_date    = to_date ('2019-11-27','yyyy-mm-dd'),
end_date                = to_date ('2019-11-28','yyyy-mm-dd'),
last_update_date        = to_date ('2019-11-28','yyyy-mm-dd'),
effective_end_date      = to_date ('2019-11-28','yyyy-mm-dd'),
created_by              = 5741,
last_updated_by         = 5741
where 1=1
  and wur.user_name = 'EXT-GVARGAS'
  and wur.role_name IN (
                    select role_name
                    from wf_all_user_roles
                    where  user_name = wur.user_name
                    AND ROLE_ORIG_SYSTEM_id in (50704,50750,50833,50834,54296)
                    )
  ;

*/

