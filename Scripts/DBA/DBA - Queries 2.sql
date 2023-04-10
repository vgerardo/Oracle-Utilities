
select sid,username,sql_id,event current_event,p1text,p1,p2text,p2,p3text,p3
from v$session
where 1=1
and osuser like 'gvarg'
--and client_identifier like 'EXT-GVARGAS'
--and sid=644
--and event='row cache lock'
;


select *
from v$session_wait
where sid=22
;




select *
from v$session_wait_history
where sid=22
;


seleCt event,
       total_waits,
       (time_waited/1000) time_waited_segundos
from V$SESSION_EVENT
where sid = 22
order by time_waited desc
;

select sqlarea.user_io_wait_time, sqlarea.optimizer_cost, sqlarea.module, sqlarea.sql_fulltext
from   v$sqlarea sqlarea
      ,v$session x
where  x.sql_hash_value = sqlarea.hash_value
and    x.sql_address    = sqlarea.address
and    x.username       is not null
and    x.sid = 22
;

 
select *
from dba_extents
 where file_id = 236
 and 60925 between block_id and block_id + blocks - 1
 ;
 
 select *
 from all_tables
 where table_name like 'ICX_CAT_ITEMS_CTX_DTLS_TLP'
;

select count(*) from eni.ENI_OLTP_ITEM_STAR;

select * from eGO_BULKLOAD_INTF;

select * from v$waitstat
WHERE 1=1
and class in ('utl_file I/O')
order by time desc;

select *
from v$event_name 
where 1=1
and name in ( 'utl_file I/O', 'row cache lock', 'gc current request')
;


SELECT 
  eq_name "Enqueue", 
  ev.name "Enqueue Type", 
  eq.req_description "Description"
FROM v$enqueue_statistics eq, v$event_name ev
WHERE eq.event#=ev.event#
 and ev.name in ( 'utl_file I/O', 'row cache lock', 'gc current request')
ORDER BY ev.name;



select *
from  v$rowcache
where cache# in (255, 13,5)
order by getmisses desc
;


select * 
from v$lock 
where sid=644
;


select     OS_USER_NAME os_user, 
       PROCESS os_pid, 
       ORACLE_USERNAME oracle_user, 
       l.SID oracle_id, 
       decode(TYPE, 
               'MR', 'Media Recovery', 
               'RT', 'Redo Thread', 
               'UN', 'User Name', 
               'TX', 'Transaction', 
            'TM', 'DML', 
             'UL', 'PL/SQL User Lock', 
             'DX', 'Distributed Xaction', 
             'CF', 'Control File', 
             'IS', 'Instance State', 
             'FS', 'File Set', 
             'IR', 'Instance Recovery', 
             'ST', 'Disk Space Transaction', 
             'TS', 'Temp Segment', 
             'IV', 'Library Cache Invalidation', 
             'LS', 'Log Start or Switch', 
             'RW', 'Row Wait', 
             'SQ', 'Sequence Number', 
             'TE', 'Extend Table', 
             'TT', 'Temp Table', type) lock_type, 
     decode(LMODE, 
             0, 'None', 
             1, 'Null', 
             2, 'Row-S (SS)', 
             3, 'Row-X (SX)', 
             4, 'Share', 
             5, 'S/Row-X (SSX)', 
             6, 'Exclusive', lmode) lock_held, 
     decode(REQUEST, 
             0, 'None', 
             1, 'Null', 
             2, 'Row-S (SS)', 
             3, 'Row-X (SX)', 
             4, 'Share', 
             5, 'S/Row-X (SSX)', 
             6, 'Exclusive', request) lock_requested, 
     decode(BLOCK, 
             0, 'Not Blocking', 
             1, 'Blocking', 
             2, 'Global', block) status, 
     OWNER, 
     OBJECT_NAME 
  from v$locked_object lo, 
       dba_objects do, 
       v$lock l 
  where lo.OBJECT_ID = do.OBJECT_ID 
    AND l.SID = lo.SESSION_ID
    and l.sid=644
  ;
