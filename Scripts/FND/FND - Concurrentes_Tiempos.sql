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
        cr.request_id,
        pr.user_concurrent_program_name programa,
        cp.CONCURRENT_PROGRAM_NAME,
        TO_CHAR (cr.requested_start_date, 'YYYY-MM-DD HH24:MI:SS') request_start_date,
        (ROUND ( ( (cr.actual_start_date - cr.requested_start_date) * 1440*60), 2)) "Espera (Seg)",
        TO_CHAR (cr.actual_start_date, 'YYYY-MM-DD HH24:MI:SS') start_date,                
        DECODE (cr.status_code, 'A', 'Waiting', 'B', 'Resuming', 'C', 'Normal', 'D', 'Cancelled', 'E', 'Errored', 'F', 'Scheduled', 'G', 'Warning', 'H', 'On Hold', 'I', 'Normal', 'M', 'No Manager', 'Q', 'Standby', 'R', 'Normal', 'S', 'Suspended', 'T', 'Terminating', 'U', 'Disabled', 'W', 'Paused', 'X', 'Terminated', 'Z', 'Waiting', 'no se') status,
        DECODE (cr.phase_code, 'R', 'Running', 'P', 'Pending', 'C', 'Complete', 'I', 'Inactive', cr.phase_code) phase,
        (ROUND ( ( (nvl(cr.actual_completion_date,sysdate) - cr.actual_start_date) * 1440), 2)) "Ejecucion (min)",
        TO_CHAR (cr.actual_completion_date, 'YYYY-MM-DD hh24:mi') completion_date,        
        cr.argument_text
        ,usr.user_name
        ,exe.execution_file_name
        --DECODE (exe.execution_method_code, 'I', 'PL/SQL', 'P', 'Reports', 'H', 'HOST', 'A', 'Producido', exe.execution_method_code) TIPO,        
        --cr.ORACLE_SESSION_ID,
        ,('ALTER SYSTEM KILL SESSION ''' ||vs.SID||','||VS.SERIAL#||''';') ASESINAR
        ,cr.responsibility_id        
--        cr.ofile_size,
--        outfile_name,
--        cr.logfile_name,
--        queue.user_concurrent_queue_name,
--        pro.oracle_process_id,
--        pro.os_process_id
         ,cr.description
         
    FROM fnd_concurrent_requests cr, -- contains a complete history of all concurrent requests.    
        fnd_concurrent_programs_tl pr,
        fnd_concurrent_programs cp,
        apps.fnd_executables_vl exe,
        fnd_run_requests rr, -- stores information about the reports in the report set and the parameter values for each report.    
        fnd_request_sets_tl rs, -- information about Report Sets    
        fnd_concurrent_processes pro,
        fnd_concurrent_queues_vl queue,
        gv$session vs,
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
                                     AND TO_DATE ('2023-12-29 23:53:59', 'YYYY-MM-DD HH24:MI:SS')    
        
        AND pr.user_concurrent_program_name LIKE 'XXCMX WMS Analisis Embarque Surtido vs Facturado (MS UP)'
                 
        --and argument_text like '%80%'
        --and cr.request_id = 54792537

    ORDER BY
          4 desc, 7 
          --,cr.actual_start_date DESC
          --.cr.actual_completion_date DESC    
--   )
--WHERE completion_date > 60
--ORDER BY 2
;

