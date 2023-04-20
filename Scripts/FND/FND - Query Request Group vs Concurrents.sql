
SELECT cptl.concurrent_program_id, user_concurrent_program_name
     , rg.request_group_name
     , rtl.responsibility_name
FROM fnd_concurrent_programs_tl  cptl
   , fnd_request_group_units     rgu
   , fnd_request_groups          rg
   , fnd_responsibility          r
   , fnd_responsibility_tl       rtl
WHERE 1=1
  and cptl.concurrent_program_id = rgu.request_unit_id
  and rg.request_group_id        = rgu.request_group_id
  and r.request_group_id         = rg.request_group_id
  and r.responsibility_id        = rtl.responsibility_id
  and cptl.language = USERENV ('LANG')
  and rtl.language = USERENV ('LANG')
  -- ---------------------------------------
  and cptl.user_concurrent_program_name like 'XXCMX - OE Confirmacion de RMA WMS a ORACLE'
;



SELECT rssf.stage_name, user_concurrent_program_name
     , e.executable_name, e.execution_file_name
     , rg.request_group_name
FROM fnd_request_sets_vl        rs
   , fnd_req_set_stages_form_v  rssf
   , fnd_request_set_programs   rsp
   , fnd_concurrent_programs_vl cp
   , fnd_executables            e
   , fnd_request_group_units    rgu
   , fnd_request_groups         rg   
WHERE 1=1
  and rs.application_id            = rssf.set_application_id
  and rs.request_set_id            = rssf.request_set_id
  and rssf.set_application_id      =  rsp.set_application_id
  and rssf.request_set_id          = rsp.request_set_id
  and rssf.request_set_stage_id    = rsp.request_set_stage_id
  and rsp.program_application_id   = cp.application_id
  and rsp.concurrent_program_id    = cp.concurrent_program_id
  and cp.executable_id             = e.executable_id
  and cp.executable_application_id = e.application_id
  and rs.request_set_id            = rgu.request_unit_id
  and rgu.request_unit_type        = 'S'  --SET
  and rgu.request_group_id         = rg.request_group_id
  ---
  and rs.user_request_set_name like 'XXCMX - WSH - Pick/Ship con WMS'

ORDER BY rssf.display_sequence
;


select *
from fnd_request_group_units
where request_unit_type <>'P'
  AND request_unit_id =1113
;

select *
from fnd_request_sets_vl
where request_set_id = 39
;