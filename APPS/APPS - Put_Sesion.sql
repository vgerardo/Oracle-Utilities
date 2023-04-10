
/*-------------------------------------------------------------
Hay algunas vistas del E-Bussines que no se ven datos almenos que el 
lenguaje se ponga como AMERICANO. Esto se puede hacer desde el REGEDIT 
cambiando la variable NLS_LANG = AMERICAN_AMERICA.UTF8
o ejecutando los siguientes comandos:
-------------------------------------------------------------*/

To enable the View in HRMS, in TOAD execute this statement first -

insert into fnd_sessions values (userenv('SESSIONID'),SYSDATE) 

EJ:
===
SELECT pap.full_name
      ,ppp.proposed_salary_n
      ,pap.person_type_id
FROM per_all_people   pap
   , per_all_assignments  paa
   , per_pay_proposals ppp
WHERE 1=1
 and pap.person_id = paa.person_id (+)
 and paa.assignment_id = ppp.assignment_id (+) 
 and nvl(ppp.date_to,sysdate) >= sysdate
 --and pap.full_name like 'LOPEZ%NU_EZ%ALBERTO'
;


-- ESA
--
--ALTER SESSION SET NLS_DATE_LANGUAGE = 'LATIN AMERICAN SPANISH'
ALTER SESSION SET NLS_LANGUAGE = 'LATIN AMERICAN SPANISH';
ALTER SESSION SET NLS_TERRITORY='MEXICO';


-- US
--
 ALTER SESSION SET NLS_LANGUAGE='AMERICAN'; 
 ALTER SESSION SET NLS_TERRITORY='AMERICA';


begin

 dbms_session.set_nls('NLS_LANGUAGE','AMERICAN');
 dbms_session.set_nls('NLS_TERRITORY','AMERICA');

 execute immediate 'ALTER SESSION SET NLS_LANGUAGE=''LATIN AMERICAN SPANISH''';

end;