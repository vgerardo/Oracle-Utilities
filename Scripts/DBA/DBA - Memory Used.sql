
--
-- Most Memory
--
SELECT
     s.osuser
    ,s.program
    ,s.machine
    ,s.module
    ,s.action    
    ,s.username
    ,s.sid
    ,s.serial#
    ,to_char(p.pga_used_mem / 1024, 'FM999,999,990.00') used_mem_KB        
    ,to_char(sq.runtime_mem/1024, 'FM999,999,990.00')   run_time_mem_KB
    ,to_char(sq.sharable_mem/1024, 'FM999,999,990.00')  SHARABLE_MEM_KB
    ,to_char(sq.Persistent_Mem/1024, 'FM999,999,990.00') PERSISTENT_MEM_mem_KB
    ,TO_CHAR(sq.optimizer_cost, 'FM999,999,990') Cost
    ,sq.program_line#
    ,s.sql_id 
    ,sq.program_id
    
    ,to_char(sq.elapsed_time/1000000,'FM999,999,999,990')       "Elapsed Time (Seg)"
    ,to_char(sq.user_io_wait_time/1000000,'FM999,999,999,990')  "User IO Wait Time (Seg)"
    ,to_char(sq.cpu_time/1000000,'FM999,999,999,990')           "CPU Time (Seg)"
    ,to_char(sq.disk_reads,'FM999,999,999,990')                 "Disk Reads"
    , sq.sql_Text
FROM gv$session  s
    ,gv$process  p
    ,gv$sql       sq
WHERE 1=1
  and s.paddr  = p.addr(+)
  and s.sql_id = sq.sql_id (+)
  --and s.module like '%XXCMX_WMS_MS_UP_WSH_REV_EMB'
  --and s.sid   = 412
  --and s.serial# = 49762
  --and s.osuser = 'H808091'
  and sq.disk_reads is not null
ORDER BY
    sq.disk_reads desc
    ,p.pga_used_mem 
;


SELECT *
FROM gv$sqltext
WHERE sql_id = 'bvr71t1bh6ky3'
;