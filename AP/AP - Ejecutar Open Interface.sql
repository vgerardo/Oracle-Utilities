
--ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL'; 
--ALTER SESSION SET NLS_LANGUAGE = 'LATIN AMERICAN SPANISH';

SET SERVEROUTPUT ON
 
DECLARE

v_req_id number(15);
v_org_id  number(15) := 241;
v_msg   varchar2(1000);

BEGIN
    
    /*
    SELECT usr.USER_ID, usr.RESPONSIBILITY_ID, usr.RESPONSIBILITY_APPLICATION_ID, usr.SECURITY_GROUP_ID, res.responsibility_id
    FROM FND_USER_RESP_GROUPS  usr,
         FND_RESPONSIBILITY_VL res
    WHERE USER_ID = (SELECT USER_ID
                    FROM FND_USER
                    WHERE USER_NAME = 'CONE-JCASTILLO')
      AND usr.RESPONSIBILITY_ID = res.RESPONSIBILITY_ID
      and res.RESPONSIBILITY_NAME = 'GRP_ALL_AP_CONE_GTE'
                                        ;
    ; 
    */
        
    --apps.mo_global.INIT ('SQLAP');
    
    apps.Fnd_Global.APPS_INITIALIZE ( 
                             user_id      => 3747  -- CONE-JCASTILLO user must have access to the responsibility
                            ,resp_id      => 50833 -- GRP_ALL_AP_CONE_GTE
                            ,resp_appl_id => 200
                            ,security_group_id => 0
                           );
--                              
--    apps.mo_global.SET_POLICY_CONTEXT('S',v_org_id);
--   
--    commit;   
   
--        v_req_id := apps.fnd_request.SUBMIT_REQUEST (
--                                            /* application =>*/ 'SQLAP', 
--                                            /* program      =>*/ 'APXIIMPT', 
--                                            /* description  =>*/ 'Importación de Interface Abierta de Cuentas a Pagar', 
--                                                                  SYSDATE,
--                                            /* sub_request  =>*/ FALSE,  -- subrequest
--                                            /* argument1   =>*/  86,  -- Operating Unit                                                                         
--                                            /* argument2   =>*/ 'FACEL',   -- invoice_source                                                                            
--                                            /* ARGUMENT3   =>*/ 'PRUEBA_1', -- group_id (make sure the records have the same group id in the interface tables)                                                                                       
--                                            /* argument4   =>*/ 'FAHP-ENE17',     --Batch_name                                                                                        
--                                            /* argument5   =>*/ NULL,              -- Hold Name
--                                            /* argument6   =>*/ NULL,            -- Hold Reason
--                                            /* argument7   =>*/ TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'),  -- GL_Date NULL, --,
--                                            /* argument8   =>*/ 'Y',                   -- Purge
--                                            /* argument9   =>*/ 'N',            -- Trace switch
--                                            /* argument10  =>*/ 'N',            -- debug switch
--                                            /* argument11  =>*/ 'N',         -- summarize report
--                                            /* argument12  =>*/ '1000',                                             
--                                            '','','','','','','','','','',
--                                            '','','','','','','','','','',
--                                            '','','','','','','','','','',
--                                            '','','','','','','','','','',
--                                            '','','','','','','','','','',
--                                            '','','','','','','','','','',
--                                            '','','','','','','','','','',
--                                            '','','','','','','','','','',
--                                            '','','','','','','',''
--                                          );
--
--    COMMIT;   

        DBMS_OUTPUT.put_line ('Concurrente ID = '||v_req_id);

    IF v_req_id = 0 THEN        
        apps.fnd_message.RETRIEVE (MSGOUT => v_msg);
        DBMS_OUTPUT.put_line ('NO se ejecutó: '|| v_msg);
        --apps.fnd_message.error;
    ELSE
        DBMS_OUTPUT.put_line ('****   ¡Orales! Sí se ejecutó!! :)   ****');
    END IF;
    
end;                           
/

SHOW ERR;

