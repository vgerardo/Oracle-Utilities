
select *
from xxcmx.xxcmx_wms_dw_order_all;

select fcr.request_id
     , fcpt.user_concurrent_program_name
     , fcr.description
     , frt.responsibility_name
     , fcr.argument_text
     , fcr.request_date
     , fcr.hold_flag
     , fcr.increment_dates
     , DECODE (nvl(fcrc.class_info, 'nulo')
               , 'nulo', 'Yes: '||to_char(fcr.requested_start_date, 'yyyy-mm-dd hh24:mi:ss')
               , 'N/A')                  run_once
     , DECODE (fcrc.class_type
                , 'P', 'Repeat every: '|| fcrc.class_info
                , 'N/A')                    set_days_of_week
     , DECODE (fcrc.class_type
                , 'S', 'Days of week: '|| fcrc.class_info
                , 'N/A')                    days_of_week
from apps.fnd_concurrent_requests       fcr
   , apps.fnd_concurrent_programs       fcp
   , apps.fnd_concurrent_programs_tl    fcpt
   , apps.fnd_conc_release_classes      fcrc
   , apps.fnd_responsibility_tl         frt
where 1=1
  and fcr.concurrent_program_id = fcp.concurrent_program_id
  and fcp.application_id        = fcpt.application_id
  and fcr.concurrent_program_id = fcpt.concurrent_program_id
  and fcr.release_class_id      = fcrc.release_class_id
  and fcr.responsibility_id     = frt.responsibility_id
 -- and fcr.phase_code            = 'P'           --P=Scheduled C=Completed
  and fcpt.language             = 'US'          --ENVUSER ('LANG')
  and frt.language              = 'US'
;

--XXCMX - AR Copia Estado de Cuenta al directorio Edo_Cuenta