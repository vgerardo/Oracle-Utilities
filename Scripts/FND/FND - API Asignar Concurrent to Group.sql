SET SERVEROUTPUT ON

/*********************************************************
*PURPOSE: To Add a Concurrent Program to a Request Group *
*         from backend                                   *
*AUTHOR: Shailender Thallam                              *
**********************************************************/
DECLARE

 v_concurrent_name     varchar2(100) 	:= 'CSA AP Anticipos Facturas y Ordenes';
 l_request_group       VARCHAR2 (200)	:= 'All Reports';
 l_group_application   VARCHAR2 (200)	:= 'SQLAP';
 v_app_id              number(15)		:= 200;
 
 l_program_short_name  VARCHAR2 (200);
 l_program_application VARCHAR2 (200); 
 l_check               VARCHAR2 (2);
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


  
  
  
--select rg.application_id, rg.request_group_id, rga.application_short_name, rga.application_id
--from fnd_responsibility_vl  rsp
--   , fnd_request_groups     rg
--   , fnd_application        rga
--where 1=1
-- and rsp.request_group_id  = rg.request_group_id
-- and rg.application_id     = rga.application_id
-- --and responsibility_name LIKE 'GPDA_PAGOS_%'
-- and rsp.responsibility_id  in  (50273, 50274)
--;
  
  
    
  --
  --Calling API to assign concurrent program to a reqest group
  --
   apps.fnd_program.ADD_TO_GROUP (program_short_name  => l_program_short_name,
                                  program_application => l_program_application,
                                  request_group       => l_request_group,
                                  group_application   => l_group_application                            
                                 );  
  --
  COMMIT;
  --

    BEGIN  
        select 1
        into l_check
        from fnd_request_group_units frgu
        where 1=1
         and application_id = v_app_id --200=SQLAP
         and request_unit_id = v_conc_id
        ;
        DBMS_OUTPUT.put_line ('Todo Chido-One!');    
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.put_line ('No se asignó el concurrente');
    END;
  
  
  
END;