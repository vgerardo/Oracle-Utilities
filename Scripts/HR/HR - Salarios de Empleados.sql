NOTA:
To enable the View in HRMS, in TOAD execute this statement first -

insert into fnd_sessions values (userenv('SESSIONID'),SYSDATE) 


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
