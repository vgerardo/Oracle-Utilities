--SELECT
--    count( "Ejecucion (min)" )          Ejecuciones,
--    max ("Ejecucion (min)" )            Ejec_tiempo_max,
--    min ("Ejecucion (min)" )            Ejec_tiempo_min,
--    round(avg ( "Ejecucion (min)" ),2)  Ejec_tiempo_avg,
--    round(stddev ( "Ejecucion (min)" ),2) Ejec_desviacion_std,
--    round(max ("Espera (min)" ),2)      Wait_tiempo_max,
--    min ("Espera (min)" )               Wait_tiempo_min,
--    round(avg ("Espera (min)"),2)       Wait_tiempo_avg,
--    round(stddev ("Espera (min)"),2)    Wait_desviacion_std
--FROM (
    SELECT
        /*+ parallel(fnd_concurrent_requests 8) */
        cr.request_id,
        pr.user_concurrent_program_name programa,
        cp.CONCURRENT_PROGRAM_NAME,
        --cr.description,

        TO_CHAR (cr.requested_start_date, 'YYYY.MM.DD HH24:MI:SS') request_start_date,
        --(ROUND ( ( (cr.actual_start_date - cr.requested_start_date) * 1440), 2)) "Espera (min)",
        TO_CHAR (cr.actual_start_date, 'YYYY.MM.DD HH24:MI:SS') start_date,
        TO_CHAR (cr.actual_completion_date, 'YYYY.MM.DD hh24:mi') completion_date,        
        (ROUND ( ( (cr.actual_completion_date - cr.actual_start_date) * 1440), 2)) "Ejecucion (min)",
        
        DECODE (cr.status_code, 'A', 'Waiting', 'B', 'Resuming', 'C', 'Normal', 'D', 'Cancelled', 'E', 'Errored', 'F', 'Scheduled', 'G', 'Warning', 'H', 'On Hold', 'I', 'Normal', 'M', 'No Manager', 'Q', 'Standby', 'R', 'Normal', 'S', 'Suspended', 'T', 'Terminating', 'U', 'Disabled', 'W', 'Paused', 'X', 'Terminated', 'Z', 'Waiting', 'no se') status,
        DECODE (cr.phase_code, 'R', 'Running', 'P', 'Pending', 'C', 'Complete', 'I', 'Inactive', cr.phase_code) phase,
        cr.argument_text,
        usr.user_name
        --,SUBSTR (usr.user_name, 1, INSTR (usr.user_name, '-') - 1) cia,
        --NVL (paf.full_name, usr.description) nombre,
        --cr.PRIORITY,
        ,exe.execution_file_name
        --DECODE (exe.execution_method_code, 'I', 'PL/SQL', 'P', 'Reports', 'H', 'HOST', 'A', 'Producido', exe.execution_method_code) TIPO,        
        --cr.ORACLE_SESSION_ID,
        ,('ALTER SYSTEM KILL SESSION ''' ||vs.SID||','||VS.SERIAL#||''';') ASESINAR
--        cr.NLS_LANGUAGE,
--        cr.NLS_TERRITORY,
--        (SELECT user_name
--        FROM fnd_user   
--        WHERE user_id = exe.created_by
--        ) created_by,
--        exe.creation_date,
        ,cr.responsibility_id
        
--        cr.ofile_size,
--        outfile_name,
--        cr.logfile_name,
--        cp.MULTI_ORG_CATEGORY,
--        queue.user_concurrent_queue_name,
--        pro.oracle_process_id,
--        pro.os_process_id
--        --,cr.org_id
         ,cr.parent_request_id
         ,cr.description
         
    FROM fnd_concurrent_requests cr, -- contains a complete history of all concurrent requests.    
        fnd_concurrent_programs_tl pr,
        fnd_concurrent_programs cp,
        apps.fnd_executables_vl exe,
        fnd_run_requests rr, -- stores information about the reports in the report set and the parameter values for each report.    
        fnd_request_sets_tl rs, -- information about Report Sets    
        fnd_concurrent_processes pro,
        fnd_concurrent_queues_vl queue,
        v$session vs,
        fnd_user usr
    WHERE cr.program_application_id  = pr.application_id
        AND cr.concurrent_program_id = pr.concurrent_program_id
        AND pr.application_id        = cp.application_id
        AND pr.concurrent_program_id = cp.concurrent_program_id
        AND pr.language              IN ('ESA')
        and cp.application_id        = exe.application_id (+)
        AND cp.executable_id         = exe.executable_id(+)
        AND cr.parent_request_id     = rr.parent_request_id(+)
        AND rr.request_set_id        = rs.request_set_id(+)
        AND cr.controlling_manager   = pro.CONCURRENT_PROCESS_ID (+)
        and pro.CONCURRENT_QUEUE_ID  = queue.CONCURRENT_QUEUE_ID (+)
        --AND NVL (rs.language, 'ESA') = 'ESA'
        AND cr.ORACLE_SESSION_ID     = vs.audsid(+)
        --and cr.requested_by          > 0
        AND cr.requested_by          = usr.user_id(+)

        AND cr.actual_start_date BETWEEN TO_DATE ('2021-01-01 00:00:01', 'YYYY-MM-DD HH24:MI:SS') 
                                     AND TO_DATE ('2023-05-29 23:53:59', 'YYYY-MM-DD HH24:MI:SS')    
        
        AND pr.user_concurrent_program_name LIKE 'XXCMX WSH - Análisis de Embarque Surtido y Facturado'
                 
        --and argument_text like '%80%'
        --
        --and cr.phase_code <> 'C'  -- R=Running
        --and cr.status_code <> 'D' --D=Cancelled
        --and cr.priority < 50
        --AND usr.user_name IN ('CORP-AGODINEZ')
        --and cr.request_id = 54792537
        --and cr.description like  'SET - GRP GL EF Procesar Formulación Corp%'
--and  TO_CHAR (cr.actual_start_date, 'YYYY.MM.DD hh24:mi:ss') = '2019.07.02 12:26:18'
        ORDER BY
          7 desc, 4 desc
          --,cr.actual_start_date DESC
          --.cr.actual_completion_date DESC    
--   )
--WHERE "Ejecucion (min)" > 10
    ;

select *
from fnd_responsibility_tl
where responsibility_id  =54296;