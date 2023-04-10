
================
DBMS_HPROF
================
BEGIN
  DBMS_HPROF.start_profiling (location => 'GRP_OUTGOING', filename => 'ego_api.txt');
  do_something_1(p_times => 10);
  DBMS_HPROF.stop_profiling;
END;
/

--
-- With the profile complete we can run the ANALYZE function to analyze the raw data and place it in the hierarchical profiler tables.
--
SET SERVEROUTPUT ON
DECLARE
  l_runid  NUMBER;
BEGIN
  l_runid := DBMS_HPROF.analyze (
               location    => 'GRP_OUTGOING',
               filename    => 'profiler.txt',
               run_comment => 'Test run.');
                    
  DBMS_OUTPUT.put_line('l_runid=' || l_runid);
END;
/

SELECT runid,
       run_timestamp,          
       total_elapsed_time,    
       run_comment          
FROM   dbmshp_runs
ORDER BY runid;

--
--We can combine this with the information from the dbmshp_parent_child_info table to display the hierarchical view of the data. for the specific RUNID.
--
SELECT RPAD(' ', (level-1)*2, ' ') || a.name AS name,
       a.subtree_elapsed_time,
       a.function_elapsed_time,
       a.calls
FROM   (SELECT fi.symbolid,
               pci.parentsymid,
               RTRIM(fi.owner || '.' || fi.module || '.' || NULLIF(fi.function,fi.module), '.') AS name,
               NVL(pci.subtree_elapsed_time, fi.subtree_elapsed_time) AS subtree_elapsed_time,
               NVL(pci.function_elapsed_time, fi.function_elapsed_time) AS function_elapsed_time,
               NVL(pci.calls, fi.calls) AS calls
        FROM   dbmshp_function_info fi
               LEFT JOIN dbmshp_parent_child_info pci ON fi.runid = pci.runid AND fi.symbolid = pci.childsymid
        WHERE  fi.runid = 1
        AND    fi.module != 'DBMS_HPROF') a
CONNECT BY a.parentsymid = PRIOR a.symbolid
START WITH a.parentsymid IS NULL;



================
DBMS_PROFILER
================
DECLARE
  l_result  BINARY_INTEGER;
BEGIN
  l_result := DBMS_PROFILER.start_profiler(run_comment => 'do_something: ' || SYSDATE);
  do_something(p_times => 100);
  l_result := DBMS_PROFILER.stop_profiler;
END;
/


SELECT runid,
       run_date,
       run_comment,
       round((run_total_time/1000000000),2) segundos
FROM   plsql_profiler_runs
ORDER BY runid;

SELECT 
       --u.runid
       --,u.unit_number
       --,d.line#
       u.unit_type,
       u.unit_owner,
       u.unit_name,       
       sum(d.total_occur),
       round(sum(d.total_time) / 1000000000, 2) total_segundos, --Origen en Nanosegundos       
       round(sum(d.min_time) / 1000000000, 2) min_time,
       round(sum(d.max_time) / 1000000000, 2) max_time
FROM   plsql_profiler_units u,
       plsql_profiler_data d 
WHERE 1=1
  AND d.runid = u.runid (+)
  AND d.unit_number = u.unit_number(+)
  AND d.runid = 6
GROUP BY 
       u.unit_type,
       u.unit_owner,
       u.unit_name       
ORDER BY 5 desc, 4 desc
;


================
DMBS_TRACER
================
DBMS_TRACE.set_plsql_trace (DBMS_TRACE.trace_all_calls);
DBMS_TRACE.set_plsql_trace (DBMS_TRACE.trace_all_sql);
DBMS_TRACE.set_plsql_trace (DBMS_TRACE.trace_all_lines);

SELECT runid, run_date, run_owner
FROM plsql_trace_runs;

SELECT event_seq, stack_depth, module, proc_unit, proc_line
FROM plsql_trace_events;