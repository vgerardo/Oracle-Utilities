/*
==========================================
PROPOSITO:
  Permisos necesarios para ejecutar SUBMIT_REQUEST desde un  usuario distinto a APPS.
  Como puede ser Bolinf.

ORIGINAL:
   PACKAGE MO_GLOBAL   AUTHID CURRENT_USER
   package FND_REQUEST AUTHID CURRENT_USER
   
LO CAMBIÉ POR:         AUTHID DEFINER 
==========================================
*/
grant EXECUTE on apps.FND_GLOBAL        to next_accnt;
grant EXECUTE on apps.FND_DATE          to next_accnt;
grant EXECUTE on apps.FND_MESSAGE       to next_accnt;
grant EXECUTE on apps.FND_REQUEST       to next_accnt;
grant EXECUTE on apps.MO_GLOBAL         to next_accnt;
grant SELECT  on applsys.FND_USER       to next_accnt;
grant SELECT  on applsys.FND_LANGUAGES   to next_accnt;
grant SELECT  on applsys.FND_APPLICATION to next_accnt;

create or replace synonym next_accnt.FND_GLOBAL     for apps.FND_GLOBAL;
create or replace synonym next_accnt.FND_DATE       for apps.FND_DATE;
create or replace synonym next_accnt.FND_MESSAGE    for apps.FND_MESSAGE;
create or replace synonym next_accnt.FND_REQUEST    for apps.FND_REQUEST;
create or replace synonym next_accnt.MO_GLOBAL      for apps.MO_GLOBAL;
create or replace synonym next_accnt.FND_USER       for applsys.FND_USER;
create or replace synonym next_accnt.FND_LANGUAGES  for applsys.FND_LANGUAGES;
create or replace synonym next_accnt.FND_APPLICATION for applsys.FND_APPLICATION;
create or replace synonym next_accnt.FND_CLIENT_INFO for apps.FND_CLIENT_INFO;
create or replace synonym next_accnt.FND_CONC_DEFERRED_ARGUMENTS for apps.FND_CONC_DEFERRED_ARGUMENTS;

--==============================
-- PARECE QUE ESTOS NO SON NECESARIOS
--==============================
grant execute on FND_CORE_LOG to next_accnt;
grant execute on fnd_client_info to NEXT_ACCNT;
grant execute on fnd_profile to NEXT_ACCNT;
grant execute on app_exception to NEXT_ACCNT;
grant execute on fnd_log_repository to NEXT_ACCNT;
grant execute on fnd_log to NEXT_ACCNT;
grant execute on hr_signon to NEXT_ACCNT;
grant execute on jg_context to NEXT_ACCNT;
grant select on fnd_responsibility_vl to NEXT_ACCNT;
grant select on fnd_lookup_types to NEXT_ACCNT;
grant select on applsys.fnd_product_groups to NEXT_ACCNT;
grant select on fnd_profile_options_vl to NEXT_ACCNT;
grant select on fnd_new_messages to NEXT_ACCNT;
grant select on fnd_data_group_units to NEXT_ACCNT;
grant select on fnd_oracle_userid to NEXT_ACCNT;
grant select on fnd_product_initialization to NEXT_ACCNT;
grant select on fnd_product_init_condition to NEXT_ACCNT;
grant select on fnd_product_init_dependency to NEXT_ACCNT;
grant select on fnd_product_installations to NEXT_ACCNT;
grant select on fnd_profile_options to NEXT_ACCNT;
grant select on fnd_profile_option_values to NEXT_ACCNT;
grant select on fnd_security_groups_vl to NEXT_ACCNT;
grant select on fnd_user_resp_groups to NEXT_ACCNT;
grant select on icx_parameters to NEXT_ACCNT;
grant select on fnd_cache_versions to NEXT_ACCNT;
grant all on fnd_log_messages to NEXT_ACCNT;

create or replace synonym next_accnt.fnd_product_groups for applsys.fnd_product_groups;
create synonym next_accnt.fnd_profile for apps.fnd_profile;
create synonym next_accnt.app_exception for apps.app_exception;
create synonym next_accnt.fnd_log_repository for apps.fnd_log_repository;
create synonym next_accnt.fnd_log for apps.fnd_log;
create synonym next_accnt.hr_signon for apps.hr_signon;
create synonym next_accnt.jg_context for apps.jg_context;
create synonym next_accnt.fnd_application_vl for apps.fnd_application_vl;
create synonym next_accnt.fnd_responsibility_vl for apps.fnd_responsibility_vl;
create synonym next_accnt.fnd_lookup_types for apps.fnd_lookup_types;
create synonym next_accnt.fnd_profile_options_vl for apps.fnd_profile_options_vl;
create synonym next_accnt.fnd_new_messages for apps.fnd_new_messages;
create synonym next_accnt.fnd_data_group_units for apps.fnd_data_group_units;
create synonym next_accnt.fnd_oracle_userid for apps.fnd_oracle_userid;
create synonym next_accnt.fnd_product_initialization for apps.fnd_product_initialization;
create synonym next_accnt.fnd_product_init_condition for apps.fnd_product_init_condition;
create synonym next_accnt.fnd_product_init_dependency for apps.fnd_product_init_dependency;
create synonym next_accnt.fnd_product_installations for apps.fnd_product_installations;
create synonym next_accnt.fnd_profile_options for apps.fnd_profile_options;
create synonym next_accnt.fnd_profile_option_values for apps.fnd_profile_option_values;
create synonym next_accnt.fnd_security_groups_vl for apps.fnd_security_groups_vl;
create synonym next_accnt.fnd_user_resp_groups for apps.fnd_user_resp_groups;
create synonym next_accnt.icx_parameters for apps.icx_parameters;
create synonym next_accnt.fnd_log_messages for apps.fnd_log_messages;
create synonym next_accnt.fnd_cache_versions for apps.fnd_cache_versions;




