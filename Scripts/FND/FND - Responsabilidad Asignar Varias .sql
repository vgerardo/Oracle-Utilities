
DECLARE

V_USERNAME      VARCHAR2(50) :=     'CONE-GVARGAS' ;

CURSOR C_RESPONSABILIDADES
IS
    SELECT 'fnd_user_pkg.addresp (V_USERNAME,'''|| apps.application_short_name || ''',''' || resp.RESPONSIBILITY_KEY || ''',''STANDARD'',''TI'',SYSDATE, NULL);' SCRIPT 
         , resp.RESPONSIBILITY_KEY
         , resp.Responsibility_name
         , apps.application_short_name
    FROM APPS.FND_RESPONSIBILITY_VL      resp 
        ,APPS.FND_APPLICATION_VL         apps
    WHERE resp.application_id = apps.application_id 
       and resp.responsibility_name like 'CMXR_COMPRAS_CC_____'
    ORDER BY 1
;


BEGIN
                                         
    --fnd_user_pkg.addresp (V_USERNAME,'CE','CMXR_CE_CCON','STANDARD','Asignada por API',SYSDATE, NULL);
    
    FOR C_RESP IN C_RESPONSABILIDADES LOOP
    
        fnd_user_pkg.addresp (v_username, C_RESP.application_short_name, C_RESP.RESPONSIBILITY_KEY, 'STANDARD','Asignada x TI', SYSDATE, NULL);
    
    END LOOP;
    
    COMMIT;
            
END;



