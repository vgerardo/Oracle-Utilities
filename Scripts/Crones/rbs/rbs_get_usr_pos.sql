set feed off
set verify off
set pagesize 0
set linesize 900


spool /conectum/Areas/TI/crones/rbs/posadas_usr.txt

select '#' 
    ||'"'|| person_id                                   || '"|'
    ||'"'||  to_char(effective_start_date,'yyyy-mm-dd') || '"|'
    ||'"'||  to_char(effective_end_date,'yyyy-mm-dd')   || '"|'
    ||'"'||  replace(replace(last_name,'|',''),chr(50065),'~1') || '"|'
    ||'"'||  replace(email_address,'|','')              || '"|'
    ||'"'||  employee_number                            || '"|'
    ||'"'||  replace(first_name,'|','')                 || '"|'
    ||'"'||  national_identifier                        || '"|'
    ||'"'||  office_number                              || '"|'
    ||'"'||  imss                      || '"|'
    ||'"'||  rfc                       || '"|'
    ||'"'||  assignment_id             || '"|'
    ||'"'||  grade_id                  || '"|'
    ||'"'||  position_id               || '"|'
    ||'"'||  payroll_id                || '"|'
    ||'"'||  supervisor_id                          || '"|'
    ||'"'||  employee_category                      || '"|'
    ||'"'||  replace(oracle_user,chr(13),'')        || '"|'
    ||'"'||  replace(telephone_number_1,chr(13),'') || '"|'
    ||'"'||  replace (ldap_user,chr(13),'')         || '"|'
    ||'"'||  password                               || '"|'
    ||'"'||  id_empresa_tct                         || '"|'
    ||'"'||  nomina                                 || '"|'
    ||'"'||  id_empresa_supervisor                  || '"|'
from CSA_PEOPLE_INTEGRA_V a
where a.effective_end_date = (select MAX(b.effective_end_date) 
                              from CSA_PEOPLE_INTEGRA_V b
                              where b.person_id = a.person_id
                             )
/

spool off
/

spool /conectum/Areas/TI/crones/rbs/posadas_grados.txt

select distinct 
      '#'
    ||'"'|| 1       || '"|'
    ||'"'|| grade_id  || '"|'
    ||'"'|| name      || '"|'
from per_grades pg
UNION
select '#"1"|"0"|"sin grado"|' from dual
/

spool off
/

spool /conectum/Areas/TI/crones/rbs/posadas_posiciones.txt

select distinct
       '#'
     ||'"'||  1           || '"|'
     ||'"'||  position_id  || '"|'
     ||'"'||  name         || '"|'
from hr_all_positions_f
UNION
select '#"1"|"0"|"sin posicion"|' from dual
/

spool off
/

spool /conectum/Areas/TI/crones/rbs/posadas_nominas.txt

select distinct
      '#'
    ||'"'||  1          || '"|'
    ||'"'||  payroll_id  || '"|'  
    ||'"'||  payroll_name|| '"|' 
from pay_all_payrolLs_f pay
UNION
select '#"1"|"0"|"sin nomina"|' from dual
/

spool off
/



exit
/

