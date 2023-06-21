SELECT
    r.description
       ,pr.user_concurrent_program_name programa    
    ,r.priority
    ,r.controlling_manager, 
    q.USER_CONCURRENT_QUEUE_NAME
       , to_char(r.request_date,  'yyyy-mm-dd hh24:mm')    "F.Solicitud"
       , to_char(r.actual_start_date,  'yyyy-mm-dd hh24:mm') "F.Inicio"
       , round((r.actual_start_date-r.request_date)*1440,2) "En Espera  (min)"      
       ,ROUND ( ( (r.actual_completion_date - r.actual_start_date) * 1440), 2) "Ejecucion (min)"
       
FROM
    fnd_concurrent_queues_vl   q,
    fnd_concurrent_requests    r,
    fnd_concurrent_processes   p,
    fnd_concurrent_programs_tl pr
WHERE
     p.concurrent_queue_id = q.concurrent_queue_id
    AND queue_application_id = q.application_id
    AND r.controlling_manager = p.concurrent_process_id
    AND r.phase_code = 'C'
    AND pr.concurrent_program_id = r.concurrent_program_id    
    and r.request_date > to_date('2019-05-04 9:07:59',  'yyyy-mm-dd hh24:mi:ss') 
    --AND r.description like 'SET - GRP GL EF Procesar Formulación%'    
    --and user_concurrent_program_name like 'Juego Informes' 
    AND user_concurrent_queue_name like 'POSADAS: Estados Financieros Manager'
    --and user_concurrent_program_name like 'GRP GL EF %' 
    --and r.request_date <> r.requested_start_date
ORDER BY 4, r.actual_start_date desc    
    ;
    