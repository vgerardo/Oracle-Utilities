
declare

v_user_id       number(15);
v_resp_id       number(15);
v_app_id        number(15);
v_org_id        number(15);

begin


    select distinct user_id
    into v_user_id
    from fnd_user
    where user_name like 'CONE-LGOMEZ'
    ;

    SELECT distinct responsibility_id
    into v_resp_id
    FROM fnd_responsibility_tl
    WHERE RESPONSIBILITY_NAME LIKE 'GRP_ALL_AP_CONE_GTE'
    ;
    
    select distinct application_id
    into v_app_id
    from fnd_application
    where application_short_name like 'SQLAP'
    ;


    select organization_id
    into v_org_id
    from hr_operating_units
    where name like 'POS_OU_GPO'
    ;


    DBMS_OUTPUT.put_line ('v_org_id  = ' || v_org_id);
    DBMS_OUTPUT.put_line ('v_user_id = ' || v_user_id);
    DBMS_OUTPUT.put_line ('v_resp_id = ' || v_resp_id);
    DBMS_OUTPUT.put_line ('v_app_id  = ' || v_app_id);
    

    DBMS_OUTPUT.put_line ('Initializing Context');

    FND_GLOBAL.apps_initialize ( 
                             user_id      => v_user_id   -- user must have access to the responsibility
                            ,resp_id      => v_resp_id
                            ,resp_appl_id => v_app_id    
                           );

    

    DBMS_OUTPUT.put_line ('Setting Policy Context');
    
    MO_GLOBAL.set_policy_context('S',v_org_id);
    --MO_GLOBAL.set_policy_context('M'); -- multiples orgs

    
    --
    --It will check whether the new Multi Org Security Profile is set 
    --
    MO_GLOBAL.init('SQLAP'); -- product short name: AR, SQLAP
      
      
    --
    -- Solo para Cash se necesita ejecutar "cep_standard.init_security"
    --
    
    DBMS_OUTPUT.put_line ('Setting cash security');
    CEP_STANDARD.init_security; --The table CE_SECURITY_PROFILES_GT is populated through this call 


    DBMS_OUTPUT.put_line ('Getting OrgID');
    
    select MO_GLOBAL.get_current_org_id()
    into v_org_id 
    from dual;

    dbms_output.put_line ('v_org_id = ' || v_org_id);

    -- para antes de ejecutar un concurrente
     fnd_request.set_org_id(v_org_id);

    --fnd_global.set_nls_context(v_nls_lang);
    --select * from all_policies where object_name='PO_HEADERS'

end;