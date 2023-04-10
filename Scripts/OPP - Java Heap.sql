--
-- DocID: 737311.1, 1410160.1
--
-- OPP - Output Post Processor 
-- Java Heap Memory
--
select service_id, service_handle, developer_parameters
from fnd_cp_services
where 1=1
 and service_id = (
            select manager_type from fnd_concurrent_queues
            where concurrent_queue_name = 'FNDCPOPP'
            )
;

--
-- Since EBS uses a 32-bit JRE using values greater than 2GB is not going to help.
--
UPDATE fnd_cp_services SET
developer_parameters = 'J:oracle.apps.fnd.cp.gsf.GSMServiceController:-Xmx3072M'
WHERE service_id = 1080 -- Este ID se optiene con el query de arriba
;


--
-- Para obtener el archivo LOG del OPP
-- Ej. /u01/oracle/DEV/fs_ne/inst/DEV_cmxoebsdev/logs/appl/conc/log/FNDOPP93536.txt
--
SELECT fcpp.concurrent_request_id req_id
     , fcp.node_name, fcp.logfile_name
FROM fnd_conc_pp_actions fcpp, fnd_concurrent_processes fcp
WHERE fcpp.processor_id = fcp.concurrent_process_id
AND fcpp.action_type = 6
AND fcpp.concurrent_request_id = 157955691
;
