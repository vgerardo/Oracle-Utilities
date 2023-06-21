
SELECT r.responsibility_key, a.application_short_name, sg.security_group_key
FROM fnd_responsibility     r
    ,fnd_responsibility_tl  rtl
    ,fnd_application        a
    ,fnd_security_groups    sg
WHERE 1=1
  AND r.responsibility_id = rtl.responsibility_id
  AND rtl.language = userenv ('LANG')
  and r.data_group_id = sg.security_group_id
  and r.application_id = a.application_id
  and rtl.responsibility_name like 'prueba'
  ;

BEGIN

    FND_USER_PKG.DelResp (
                     username => 'H808091'
                    ,resp_app => 'SQLAP'
                    ,resp_key => 'PRUEBA'
                    ,security_group => 'STANDARD'
                );
                
    COMMIT;
    
END;
/