--
-- BLOCKING_SESSION_STATUS:
--      VALID - there is a blocking session, and it is identified in the BLOCKING_INSTANCE and BLOCKING_SESSION columns
--      NO HOLDER - there is no session blocking this session
--
select 
       vs.module
     , to_char(vs.logon_time,'yyyy-mm-dd hh24:mi:ss') logon
     , vs.status
     , to_char(vs.sql_exec_start,'hh24:mi:ss') inicio_sql
     , vs.event, vs.state
     , wait_time_micro, time_since_last_wait_micro     
     , sq.program_line#
     , sq.sql_fulltext
     , vs.client_identifier
     , blocking_session_status, blocking_session
     , final_blocking_session_status, FINAL_BLOCKING_SESSION 
     , ('ALTER SYSTEM KILL SESSION ''' || vs.SID||','|| vs.SERIAL# || ''' IMMEDIATE') ASESINAR
from V$SESSION vs,
     V$SQL sq
where 1=1
 and vs.sql_address = sq.address (+)
 --and vs.status = 'ACTIVE'
 --and sq.open_versions > 0
 --and vs.module like 'GRP_AR_%TMBRDO%'
 and username like 'BOLINF'
;

--
-- Long Operations
--
select sl.sid, sl.serial#
     , sl.opname, sl.target
     , to_char(sl.sql_exec_start, 'yyyy-mm-dd hh24:mi:ss') exec_start
     , sl.elapsed_seconds, sl.message
     , sq.sql_fulltext
     , sq.disk_reads
     , sq.user_io_wait_time
     , ss.client_identifier
     , ss.module
     , round(elapsed_seconds * (totalwork-sofar) / sofar,2) as time_remaining 
from v$session          ss
   , v$session_longops  sl
   , v$sql              sq
where 1=1
  and ss.sid = sl.sid
  and ss.serial# = sl.serial#
  and sl.sql_id = sq.sql_id (+) 
order by sl.sql_exec_start desc
  ;

ANALYZE TABLE GL.GL_BALANCES DELETE STATISTICS;

SELECT vs.SID, vs.SERIAL#, 
       vs.PROGRAM, vs.username, vs.MACHINE, vs.PORT, vs.LOGON_TIME, 
       P.SPID, 
       obj.object_name, 
       sq.sql_fulltext,
       cr.request_id, cr.status_code, cr.requested_start_date, cr.concurrent_program_id 
     , wait.event
     , wait.wait_class
     , wait.wait_time_micro -- milisegundos
FROM v$session vs,  
     v$process P, 
     v$locked_object L, 
     All_Objects obj, 
     fnd_concurrent_requests cr,
     V$SQL SQ 
    , V$SESSION_WAIT wait
WHERE 1=1
  AND vs.PADDR     = P.ADDR 
  AND vs.SID       = L.SESSION_ID (+)  
  and L.object_id  = obj.OBJECT_ID (+)
  and vs.audsid    = cr.oracle_session_id (+)
  AND vs.sql_address = SQ.ADDRESS (+)
  and vs.sid = wait.sid (+)  
  --
  --AND VS.SID = '3243'
  AND vs.module like '%XXCE%'
  --and upper(obj.object_name) like upper('HZ_PARTIES')
;



SELECT  
      'ALTER SYSTEM KILL SESSION ''' || vs.SID||','|| vs.SERIAL# || ''' IMMEDIATE' ASESINAR
     , vs.program, vs.module, vs.username, vs.machine, vs.logon_time 
     , obj.object_name     
     , decode(vl.type,'TM', 'DML enqueue', 'TX', 'Transaction enqueue', 'UL', 'User Lock', vl.type) tipo
     , vl.ctime
     , vl.block
     --, dbms_rowid.rowid_create (1, row_wait_obj#, row_wait_file#, row_wait_block#, row_wait_row#) row_id      
     , SQ.SQL_FULLTEXT           
     , wait.event
     , wait.wait_class
     , wait.*
FROM v$session      vs
   , all_objects    obj
   , v$lock         vl
   , V$SQL          SQ
   , V$SESSION_WAIT wait
WHERE 1=1
  and vl.sid = vs.sid
  --and obj.object_id  = vs.row_wait_obj#
  and obj.object_id  = vl.id1      
  AND vs.SQL_ADDRESS = SQ.ADDRESS (+)
  and vs.sid = wait.sid (+)  
  --
  AND VS.SID = '3243'
  --and upper(obj.object_name) like upper('HZ_PARTIES')
  --
order by 1
;


SELECT DISTINCT   
   'ALTER SYSTEM KILL SESSION ''' || vs.SID||','|| vs.SERIAL# || ''' IMMEDIATE' ASESINAR,
   vlo.process, vlo.os_user_name, 
   vlo.oracle_username, obj.object_name       
   ,decode(vlo.locked_mode,1,'No Lock',
      2,'Row Share',
      3,'Row Exclusive',
      4,'Share',
      5,'Share Row Exclusive',
      6,'Exclusive',null) lmode      
      ,vel.ctime Segundos               
      --,vl.type,  vl.ctime                                         
      ,vs.module
      ,vs.action
      ,vs.osuser      
      --,vl.*
FROM     v$locked_object vlo
         ,ALL_objects obj
         ,v$session vs 
         ,V$ENQUEUE_LOCK vel
       --  ,v$lock vl                  
WHERE    vlo.object_id = obj.object_id    
    AND  vlo.session_id = vs.SID
    AND  vlo.process    = vs.process 
    AND  vlo.session_id = vel.sid (+)
    --AND  vlo.session_id = :sesion 
    --AND  vlo.process = :proceso                  
    --and vlo.oracle_username = nvl(UPPER(:apps_bolinf), vlo.oracle_username)
    AND vs.type not like 'BACKGROUND' 
    --and vs.action LIKE '%LGODINEZ%'
    and obj.object_name like 'GRP_RH_VALIDA_RFC_T'    
ORDER BY 1 desc, vel.ctime DESC, 1, OBJECT_NAME DESC, vel.ctime DESC
;


select oracle_username || ' (' || s.osuser || ')' username 
 , s.sid || ',' || s.serial# sess_id 
 , owner || '.' || object_name object 
 , object_type 
 , decode( l.block 
 , 0, 'Not Blocking' 
 , 1, 'Blocking' 
 , 2, 'Global') status 
 , decode(v.locked_mode 
 , 0, 'None' 
 , 1, 'Null' 
 , 2, 'Row-S (SS)' 
 , 3, 'Row-X (SX)' 
 , 4, 'Share' 
 , 5, 'S/Row-X (SSX)' 
 , 6, 'Exclusive', TO_CHAR(lmode)) mode_held 
 from v$locked_object v 
 , dba_objects d 
 , v$lock l 
 , v$session s 
 where v.object_id = d.object_id 
 and v.object_id = l.id1 
 and v.session_id = s.sid (+)
 AND object_name LIKE 'GRP%'
 order by oracle_username 
 , session_id; 
