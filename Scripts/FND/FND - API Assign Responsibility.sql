
DECLARE
TYPE t_array_resp_name IS VARRAY(1000) OF VARCHAR2(150);
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
p_user_name     VARCHAR2(50):= 'L625927'; -- y  
p_resp_name     t_array_resp_name := t_array_resp_name (
 'MX AC INV KRO Operador de Interface CWMS'
,'MX AC INV KRO Operador de Interface'
,'MX AC INV AGA Operador de Interface'
,'MX AC INV KRO Operador de Interface CWMS'
,'MX AC INV KRO Operador de Interface'
)
; 

l_resp_appl_short_name  VARCHAR2(100);
l_responsibility_key    VARCHAR2(100);
l_security_group_key    varchar2(100);

BEGIN


    /*FOR r IN (
            select regexp_substr (p_resp_name, '[^,]+', 1, level) resp
            from dual
            connect by level <= length(regexp_replace(p_resp_name, '[^,]+'))+1 
        )*/
    FOR r IN p_resp_name.first .. p_resp_name.last
    LOOP
        
        begin
        SELECT favl.application_short_name,
               frvl.responsibility_key
        INTO l_resp_appl_short_name, l_responsibility_key
        FROM fnd_responsibility_vl frvl,
             fnd_application_vl favl
        WHERE 1 =1
          AND frvl.application_id = favl.application_id
          AND frvl.responsibility_name = p_resp_name (r)
        ;
    
        fnd_user_pkg.addresp ( 
                        username        => p_user_name
                        ,resp_app        => l_resp_appl_short_name
                        ,resp_key        => l_responsibility_key
                        ,security_group  => 'STANDARD'
                        ,description     => NULL
                        ,start_date      => sysdate - .1
                        ,end_date        => sysdate + 120
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