SET SERVEROUTPUT ON
DECLARE

TYPE type_req_groups IS VARRAY (100)   OF VARCHAR2(80);

l_request_group       type_req_groups	:= type_req_groups (
 'XXCMX - INV Planta Master User'
); 

 v_concurrent_name     varchar2(100) 	:= 'XXCMX WMS Enviar GME Orden Produccion WIP (MS DW)';
 
 l_group_application   VARCHAR2(50);
 --v_app_id              number(15)		:= 200;
 l_program_short_name  VARCHAR2(200);
 l_program_application VARCHAR2(200); 
 l_check               VARCHAR2(2);
 v_conc_id             number(15);
  --
BEGIN
  
    select cp.concurrent_program_id, cp.concurrent_program_name, app.application_short_name
    into v_conc_id, l_program_short_name, l_program_application
    from fnd_concurrent_programs_tl tl,
         fnd_concurrent_programs    cp,
         fnd_application           app
    where 1=1
     and tl.concurrent_program_id = cp.concurrent_program_id
     and cp.application_id = app.application_id
     and language = 'ESA'
     and user_concurrent_program_name = v_concurrent_name
    ;
  
    DBMS_OUTPUT.Put_Line ('v_conc_id = '||v_conc_id);
  
  FOR r IN l_request_group.FIRST .. l_request_group.LAST LOOP
    
        select app.application_short_name
        into l_group_application
        from fnd_request_groups  rg
            ,fnd_application     app
        where rg.application_id = app.application_id
          and request_group_name = l_request_group (r)
        ;
        
        --
        --Calling API to assign concurrent program to a reqest group
        --
        apps.fnd_program.ADD_TO_GROUP (
                                    program_short_name  => l_program_short_name,
                                    program_application => l_program_application,
                                    request_group       => l_request_group (r),
                                    group_application   => l_group_application                            
                                     );  
  
  END LOOP;
  
  --
  COMMIT;
  --
END;
/

---
--Validación
--
    select rg.request_group_name
    from  fnd_request_groups      rg
         ,fnd_request_group_units rgu
    where 1=1
      and rg.request_group_id = rgu.request_group_id
     and request_unit_id = 478394
    ;
