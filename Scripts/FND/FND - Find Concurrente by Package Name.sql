
--
-- Queries para obtener el Concurrente que hace uso del "Objeto" (tabla, vista, queueu, etc)
--

--
-- 1ro... buscar el paquete que contiene el objeto
--
SELECT distinct name
FROM all_source
WHERE upper(TEXT) LIKE upper('%xxcmx_wms_confordhdrplsp_all%')
;
      
xxcmx.xxcmx_wms_confordlnrplsp_all; surtido plantas
xxcmx.xxcmx_wms_condhdrplantpe_all; surtido plantas
xxcmx.xxcmx_wms_condlnrplantpe_all; surtido plantas


--
-- 2do... buscar el concurrente
--
SELECT
       cpt.user_concurrent_program_name
     , cp.enabled_flag
     , decode(ex.execution_method_code, 'P', 'Oracle Reports', 
                                        'I', 'PL/SQL Stored Procedure',
                                        'K', 'Java Concurrent Program',
                                        'Otro') method_code
     , ex.execution_file_name
     
FROM fnd_executables            ex
   , fnd_concurrent_programs    cp
   , fnd_concurrent_programs_tl cpt
WHERE 1=1
  and ex.executable_id = cp.executable_id
  and cp.concurrent_program_id  = cpt.concurrent_program_id  
  and cpt.language             = 'US'--ENV('LANG')
  --and ex.execution_file_name like '%XXCMX_WMS_PLANTAS_PKG%'
  and cpt.user_concurrent_program_name like 'XXCMX - WSH % Confirm con WMS'
;



