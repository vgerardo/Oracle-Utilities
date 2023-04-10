
execute DBMS_SESSION.Set_Identifier ('GVARGAS');

select sys_context ('userenv', 'client_identifier') from dual;
select sys_context ('userenv', 'sid') from dual;
select sys_context ('userenv', 'sessionid') from dual;
select sys_context ('userenv', 'db_name') from dual;
select sys_context ('userenv', 'instance_name') from dual;
select sys_context ('userenv', 'service_name') from dual;
--select sys_context ('userenv', 'group_no') from dual;
select sys_context ('userenv', 'os_user') from dual;
select sys_context ('userenv', 'host') my_lap from dual;
select sys_context ('userenv', 'server_host') from dual;
select sys_context ('userenv', 'language') from dual;

select serial# 
from gv$session 
where 1=1
  and sid    = (select sys_context ('userenv', 'sid') from dual)
  and audsid = (select sys_context ('userenv', 'sessionid') from dual)
  ;
  
select *
from dba_profiles
where resource_name in ('IDLE_TIME', 'CONNECT_TIME');
