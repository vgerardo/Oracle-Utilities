/* Formatted on 27/02/2013 06:54:44 p.m. (QP5 v5.240.12305.39446) */
SELECT a.request_id,
       d.sid,
       d.serial#,
       d.osuser,
       d.process,
       c.spid,
       cp.*
  FROM apps.fnd_concurrent_requests a,
       apps.fnd_concurrent_processes b,
       v$process c,
       v$session d,
       fnd_concurrent_programs_tl cp
 WHERE     a.controlling_manager = b.concurrent_process_id
       AND c.pid = b.oracle_process_id
       AND b.session_id = d.audsid
       --AND a.request_id = 25243616
       AND d.sid = 2631
       AND cp.concurrent_program_id = a.concurrent_program_id
       AND cp.language = 'US'
       AND a.phase_code = 'R';