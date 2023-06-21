
SELECT level, supervisor_id, supervisor_name, colaborador_id, colaborador_name
FROM (    
        SELECT 
               s.person_id supervisor_id,
               s.full_name supervisor_name,
               c.person_id colaborador_id,
               c.FULL_NAME colaborador_name                                
        FROM PER_ALL_PEOPLE_F        C,
             PER_ALL_ASSIGNMENTS_F   A,
             PER_ALL_PEOPLE_F        S
        WHERE 1=1
           and c.person_id = a.person_id
           and sysdate between c.effective_start_date and c.effective_end_date
           and sysdate between a.effective_start_date and a.effective_end_date           
           and a.supervisor_id = s.person_id
           and sysdate between s.effective_start_date and s.effective_end_date           
           --AND S.FULL_NAME LIKE 'FERNANDEZ-CRUZ, AGUSTIN'           
    )          
  START WITH Supervisor_NAME like '%BORES%RODRIGO%'   --'OLVERA-MARTINEZ, MARIA VICTORIA
        --CONNECT BY s.person_id = prior a.supervisor_id
        CONNECT BY supervisor_id = prior colaborador_id  
  ORDER BY level, colaborador_name
;




    
