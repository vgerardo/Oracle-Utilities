SELECT
      usr.user_name             
    , pap.full_name 
    , frt.responsibility_name 
    , TO_CHAR(furg.START_DATE,'DD-MON-YYYY') resp_attched_date
    , TO_CHAR(furg.END_DATE,'DD-MON-YYYY') resp_remove_date
FROM
      fnd_user                      usr
    , per_all_people_f              pap  
    , fnd_user_resp_groups_direct   furg
    , fnd_responsibility_tl         frt
WHERE 1=1
    and usr.employee_id = pap.person_id
    and usr.user_id = furg.user_id
    and NVL(usr.end_date,sysdate+1) > sysdate        
    and frt.responsibility_id = furg.responsibility_id
    and frt.language = 'US'
    and nvl(furg.end_date,sysdate+1) > sysdate
    --
    and frt.responsibility_name like 'MX%Creacion CCP'
    --
ORDER BY
    usr.USER_NAME;
