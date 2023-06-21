
SELECT cp.user_concurrent_program_name      waiting_concurrente
     , cpi.user_concurrent_program_name     running_incompatible
     , round ( ( ( cr.actual_start_date - cr.requested_start_date ) * 1440 ), 2 ) waiting
     , cr.request_date                      waiting_request_date
     , cr.actual_start_date                 waiting_start_date       
     , DECODE(cr.status_code,
          'A', 'Waiting', 
          'B', 'Resuming',
          'C', 'Normal', 
          'D', 'Cancelled',
          'E', 'Errored', 
          'F', 'Scheduled',
          'G', 'Warning', 
          'H', 'On Hold',
          'I', 'Normal', 
          'M', 'No Manager',
          'Q', 'Standby', 
          'R', 'Normal',
          'S', 'Suspended', 
          'T', 'Terminating',
          'U', 'Disabled', 
          'W', 'Paused',
          'X', 'Terminated', 
          'Z', 'Waiting',
          'no se'
          )  waiting_status                                        
     , round ( ( ( cri.actual_completion_date - cri.actual_start_date ) * 1440 ), 2) running                        
     , cri.request_date                     running_request_date
     , cri.actual_start_date                running_start_date                     
     , cri.actual_completion_date           running_completion_date                            
     , DECODE(cri.status_code,
          'A', 'Waiting', 
          'B', 'Resuming',
          'C', 'Normal', 
          'D', 'Cancelled',
          'E', 'Errored', 
          'F', 'Scheduled',
          'G', 'Warning', 
          'H', 'On Hold',
          'I', 'Normal', 
          'M', 'No Manager',
          'Q', 'Standby', 
          'R', 'Normal',
          'S', 'Suspended', 
          'T', 'Terminating',
          'U', 'Disabled', 
          'W', 'Paused',
          'X', 'Terminated', 
          'Z', 'Waiting',
          'no se'
          )  running_phase
     , cr.request_id                        waiting_request_id
     , cri.request_id                       running_request_id                 
FROM      fnd_concurrent_programs_tl    cp   -- waiting
        , fnd_concurrent_requests       cr   -- waiting
        , fnd_concurrent_program_serial cps  -- incompatibles
        , fnd_concurrent_programs_tl    cpi  -- incompatibles
        , fnd_concurrent_requests       cri  -- running        
WHERE 1=1
  and cp.application_id        = cr.program_application_id
  and cp.concurrent_program_id = cr.concurrent_program_id
  and cp.application_id        = cps.running_application_id --101
  and cp.concurrent_program_id = cps.running_concurrent_program_id
  and cps.to_run_application_id = cpi.application_id
  and cps.to_run_concurrent_program_id = cpi.concurrent_program_id
  and cpi.application_id       = cri.program_application_id
  and cpi.concurrent_program_id = cri.concurrent_program_id
  and cp.user_concurrent_program_name <> cpi.user_concurrent_program_name
  AND cp.language              = 'ESA'      
  and cpi.language             = 'ESA'
  and cr.request_date BETWEEN  cri.actual_start_date AND cri.actual_completion_date 
  and cr.request_date BETWEEN TO_DATE('12-01-2013 00:00:01', 'DD-MM-YYYY HH24:MI:SS') 
                              and SYSDATE+1
                              --and TO_DATE('01-03-2011 23:59:01', 'DD-MM-YYYY HH24:MI:SS')
  --and cr.phase_code = 'P'
  --and cri.phase_code = 'R'                              
  --AND cp.user_concurrent_program_name LIKE 'Contablilización'
  --and cr.status_code not in ('Q', 'I','D', 'E', 'X', 'T')
ORDER BY 3 desc
       , cp.user_concurrent_program_name
       , cr.request_date desc
       