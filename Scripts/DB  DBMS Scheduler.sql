SET SERVEROUTPUT ON

CREATE TABLE My_Table (id number);

CREATE OR REPLACE PROCEDURE My_Procedure (id number) AS
BEGIN
    DBMS_OUTPUT.put_line ('id = ' || id);
    INSERT INTO My_Table VALUES (id);
    COMMIT;
END;
/

DECLARE

CURSOR c_items 
IS 
    SELECT *
    FROM mtl_system_items_b
    WHERE rownum < 10000
    ;

v_rows number(15) := 0;
v_job_name varchar2(100);

BEGIN

    FOR itm IN c_items LOOP

        v_rows := v_rows + 1;

        IF mod (v_rows, 1000) = 0 THEN
        
            v_job_name := 'GVP_TEST_' || v_rows;
            
            DBMS_SCHEDULER.Create_Job (
                                 job_name           => v_job_name
                                ,job_type           => 'STORED_PROCEDURE'    --PLSQL_BLOCK, CHAIN, EXECUTABLE
                                --,job_action => 'BEGIN My_Procedure(1234); END;'
                                ,job_action         => 'apps.My_Procedure'
                                ,number_of_arguments=> 1
                                ,comments           => 'My First Test'
                                ,auto_drop          => true
                                );
                                
            DBMS_SCHEDULER.Set_Job_Argument_Value (
                                job_name           => v_job_name
                                ,argument_position => 1
                                ,argument_value    => v_rows
                                );
                                
                                
            DBMS_SCHEDULER.Enable (v_job_name);

        END IF;
    
    END LOOP;
    
END;
/


SELECT job_name, status, actual_start_date, run_duration, additional_info 
FROM DBA_SCHEDULER_JOB_RUN_DETAILS 
WHERE job_name like 'GVP_TEST%'
order by log_date desc;

SELECT * FROM My_Table;