SET SERVEROUTPUT ON

DECLARE
    v_user_list        VARCHAR2(2000) :='EXT-GVARGAS'; -- 'CONE-ABEDOLLA,CONE-DFIGUEROA,CONE-GBENITEZ,CONE-OCALDERON,CONE-RBORES,CONE-SFRIAS,CONE-SORNELAS,CONE-VMORALES,CORP-CMONDRAGON,CORP-CMORA,CORP-ETORRES,CORP-IARENAS,CORP-IRIOS,CORP-JHERNANDEZH,CORP-JVELOZ,CORP-KRAMIREZ,CORP-LAYALA,CORP-MDOMINGUEZ,CORP-MFAGUILAR,CORP-MRAZO,CORP-MVAZQUEZMO,CORP-RSUAREZ,CORP-TTORRES,CORP-VSALGADO,CORP-YDIAZ,EXT-GVARGAS,';
    v_resp             VARCHAR2(100) := 'GRP_SYS_AA_CONE_SOPORTE'; --'XML Publisher Administrator'; --'GRP_ALL_AR_APLICATIVO_COBRANZA_USR GRP_SYS_AA_CONE_SOPORTE';
    v_resp_key         VARCHAR2(80);
    v_app_short_name   VARCHAR2(20);
    v_user_name         varchar2(100);
BEGIN
    BEGIN
    SELECT
        r.responsibility_key,
        a.application_short_name
    INTO v_resp_key,v_app_short_name
    FROM fnd_responsibility_vl r,
         fnd_application_vl a
    WHERE r.application_id = a.application_id
      AND  upper(r.responsibility_name) = upper(v_resp)
      ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.put_line('La responsabilidad no existe: '|| v_user_name);
    END;

    FOR usr IN (
            select trim(regexp_substr(v_user_list, '[^,]+', 1, level)) siglas
		    from dual
		    connect by level <= length(regexp_replace(v_user_list, '[^,]+')) + 1
            ) 
    LOOP
    
        BEGIN            
            SELECT user_name
            INTO v_user_name
            FROM FND_USER
            WHERE USER_NAME LIKE usr.siglas
            ;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                DBMS_OUTPUT.put_line('El usuario no existe: '|| v_user_name);
                CONTINUE;
        END;
        
        FND_USER_PKG.AddResp(
                    username        => v_user_name,
                    resp_app        => v_app_short_name,
                    resp_key        => v_resp_key,
                    security_group  => 'STANDARD',
                    description     => NULL,
                    start_date      => SYSDATE-1,
                    end_date        => null
                );

        DBMS_OUTPUT.put_line('Responsibility:'
                                 || v_resp
                                 || ' '
                                 || 'is added to the User:'
                                 || v_user_name);
    END LOOP;
    
    --commit;
    


EXCEPTION
    WHEN OTHERS THEN
    dbms_output.put_line('Error: ' ||
                         substr(
                            sqlerrm,
                            1,
                            500
                        ) );

    rollback;
END;
