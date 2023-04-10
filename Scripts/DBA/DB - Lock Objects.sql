SELECT * FROM DBA_BLOCKERS ;
select * from DBA_DDL_LOCKS WHERE name like '%XXCMX%CCP%';
SELECT * FROM DBA_DML_LOCKS WHERE NAME LIKE '%XXCMX%CCP%';
SELECT * FROM DBA_LOCK_INTERNAL WHERE SESSION_ID = 279 AND LOCK_ID1 IN ('17963087','17664842','6291473');
SELECT * FROM DBA_LOCKS WHERE SESSION_ID  =279;
SELECT * FROM DBA_WAITERS;


SELECT obj.object_id, obj.object_name
     , vlo.process
     , DECODE(vlo.locked_mode
                  ,0, 'NONE: Lock requested but not yet obtained'
                  ,1, 'NULL'
                  ,2, 'ROWS_S (SS): Row Share Lock'
                  ,3, 'ROW_X (SX): Row Exclusive Table Lock'
                  ,4, 'SHARE (S): Share Table Lock'
                  ,5, 'S/ROW-X (SSX): Share Row Exclusive Table Lock' 
                  ,6, 'Exclusive (X): Exclusive Table Lock'
                  ,''
         )                                                                          locked_mode
     , vs.username, vs.status, vs.osuser
     , ('ALTER SYSTEM KILL SESSION '''||vs.sid ||','|| vs.serial#||''' IMMEDIATE;') Kill_Session
FROM all_objects        obj
    ,v$locked_object    vlo
    ,v$session          vs
where obj.object_id = vlo.object_id
 and vlo.session_id = vs.sid (+)
 -- -- -- -- -- -- -- -- -- -- -- -- --
 and obj.object_name in (
                        'XXCMX_WSH_CCP_CALLBACK_ALL'
                       )
ORDER BY obj.object_name
;

ALTER SYSTEM KILL SESSION '1900,47427' IMMEDIATE;
