
DECLARE
--Application Developer
--System Administrator
--XML Publisher Administrator
--Desktop Integration Manager
--
--Receivables Administrador     requiere profile: "HR:User Type"
--Order Management Super User
--MX CRP INV Config Inventory
--MX AC GMD Admin Perfiles Seguridad
--
p_user_name     VARCHAR2(50):= 'E280938';
p_resp_name     VARCHAR2(3072):= 
 'MX AC OM APR Configuracion,'||
 'MX AC OM FPU Configuracion,'||
 'MX AC OM PES Configuracion,'||
 'MX AC OM TPX Configuracion,'||
 'MX AC OM AGA Configuracion'
; 

l_resp_appl_short_name VARCHAR2(100);
l_responsibility_key VARCHAR2(100);
l_security_group_key    varchar2(100);

BEGIN


    FOR r IN (
            select regexp_substr (p_resp_name, '[^,]+', 1, level) resp
            from dual
            connect by level <= length(regexp_replace(p_resp_name, '[^,]+'))+1 
        )
    LOOP
        
        begin
        SELECT favl.application_short_name,
               frvl.responsibility_key
        INTO l_resp_appl_short_name, l_responsibility_key
        FROM fnd_responsibility_vl frvl,
             fnd_application_vl favl
        WHERE 1 =1
          AND frvl.application_id = favl.application_id
          AND frvl.responsibility_name = R.RESP
        ;
    
        fnd_user_pkg.addresp ( 
                        username        => p_user_name
                        ,resp_app        => l_resp_appl_short_name
                        ,resp_key        => l_responsibility_key
                        ,security_group  => 'STANDARD'
                        ,description     => NULL
                        ,start_date      => sysdate - .5
                        ,end_date        => sysdate + 365
                    );
        
        COMMIT;

        exception
            when NO_DATA_FOUND THEN
                NULL;
        end;

    END LOOP;

    COMMIT;

END;
/