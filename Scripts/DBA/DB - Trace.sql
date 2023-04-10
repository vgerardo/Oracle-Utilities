/*
HTTPS://techgoeasy.com/how-to-get-trace-for-issue-in-oracle/

1. Habilitar Profile  FND: Diagnostics = Yes (a nivel usuario o site)
2. Ingrear al EBS, y la Forma que se desea analizar
3. En el menú Help -> Diagnostics -> Trace
   Seleccionar "Trace with binds and waits"
4. Anotar la ruta que muestra el Pop-up
5. Trabajar en la forma
6. Volver al menú del Trace y seleecionar "No Trace"
7. Recuperar el archivo generado 
8. Analizar el archivo con TKPROF

-- Esta ruta la genera el ERP, pero "el dba" me dice que no existe ".../DEV2/trace..."
/u04/app/oracle/DEV/11.2.0.3/admin/DEV_cmxoebsglbd2/diag/rdbms/dev/DEV2/trace/DEV_ora_23274_H808091_0217_170547.trc

-- Me salí del ERP y volví a ingresar, y ahora me mostró una ruta diferente ".../DEV1/trace..."
-- y esta sí la encontró "el dba" :) ¡uju!
/u04/app/oracle/DEV/11.2.0.3/admin/DEV_cmxoebsglbd2/diag/rdbms/dev/DEV1/trace/DEV_ora_11465_H808091_0218_131536.trc

*/

--
-- https://docs.oracle.com/cd/E18727_01/doc.121/e13488/T2650T402391.htm
-- En teoria, las siguientes intrucciones deberían servir para lo mismo (obtener el trace)
-- sin embargo, nunca pudimos localizar el "supuesto" archivo que se genera.
--

--
-- 1ro Hay que localizar el SID y SERIAL correspondiete a la session que se desea trazar
--

-- Para saber el SID de MI session
select sys_context ('USERENV', 'SID') from dual;

--
-- Para una session de un Programa del ERP
-- System Administrator -> Security -> User -> Monitor
-- ahi busqué mi user H808091 y obtuve el "Oracle Process"
--
select p.pid, p.spid, s.sid, s.serial#, s.username
from v$process p 
   , v$session s            --para entornos RAC usar GV$SESSION
where p.addr = s.paddr 
   and p.pid = 798
;

-- 2do Obtener el nombre del archivo que se generará
--
--
SELECT s.module, s.client_identifier, s.sid, s.serial#, p.spid, p.tracefile, pa.value
FROM v$session s    
   , v$process  p
   , v$parameter pa
WHERE 1=1
  and s.paddr = p.addr
  and pa.name in ( 'user_dump_dest' /*, 'diagnostic_dest'*/ )
  --and s.audsid = SYS_CONTEXT ('USERENV', 'SESSIONID')
  and s.sid = 726
 -- and s.serial# = 39415
;

--
-- 3ro Habilitar el Trace, con alguna de las dos Formas
--
EXECUTE DBMS_SYSTEM.Set_Sql_Trace_In_Session ( sid=>726, serial#=>25979, sql_trace=>TRUE);
--OR
BEGIN
        DBMS_MONITOR.session_trace_enable (
                 session_id     => 1350
                ,serial_num     => 20243
                ,waits          => true
                ,binds          => true
                ,plan_stat      => 'all_executions'
        );
END;
/

--
--4to Deshabilitar el Trace con alguna de las dos formas
--Cuando se terminen las Acciones en la session, hay que deshabilitar el Trace para que se generé el archivo.
--
EXECUTE DBMS_SYSTEM.Set_Sql_Trace_In_Session ( sid=>726, serial#=>25979, sql_trace=>FALSE);
--OR
EXECUTE DBMS_MONITOR.Session_Trace_Disable (session_id => 726, serial_num => 25979);
/


--
-- 5to En Linux, formatera la salida para que sea humanamente legible :)
--
tkprof <in archivo.trc> <out archivo.txt> sys=no waits=yes aggregate=no width=180



