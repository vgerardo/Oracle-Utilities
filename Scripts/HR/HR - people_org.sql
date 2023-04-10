SELECT   
        houv.name
        , pef.full_name        
        ,pg.NAME    grado
        --,job.NAME   job
        ,hapf.NAME  posicion
        ,to_char ( pro1.proposed_salary_N , 'FM9,999,990.00' ) salario                                        
        , change_date      
        ,(SELECT TO_CHAR(pro2.proposed_salary_N, 'FM9,999,990.00') 
              FROM per_pay_proposals pro2 
              WHERE pro2.assignment_id = paf.assignment_id
                and pro2.change_date = pro1.last_change_date) sal_ant  
        , to_char( (pro1.proposed_salary_N /
             (SELECT pro2.proposed_salary_N 
              FROM per_pay_proposals pro2 
              WHERE pro2.assignment_id = paf.assignment_id
                and pro2.change_date = pro1.last_change_date
            )-1)*100,'FM90.0') porcentaje    
        ,pro1.proposal_reason razon    
        ,pro1.approved                
        ,paf.assignment_id
        ,pef.effective_end_date person_end_date        
        ,paf.last_update_date asig_last_update
        ,paf.effective_end_date asig_end_date
        ,paf.payroll_id
        ,pef.person_type_id 
        
        --select hapf.*                       
FROM     per_all_people_f pef
        ,per_all_assignments_f paf
        ,per_grades pg
        ,per_jobs job
        ,hr_all_positions_f hapf    
        ,hr_all_organization_units_tl houv
        ,per_pay_proposals pro1
        ,per_periods_of_service pps        
WHERE 1=1                     
and      pef.person_id = paf.person_id
and      pef.effective_end_date = (
                        select max(pefx.effective_end_date)
                        from per_all_people_f pefx
                        where pefx.person_id = pef.person_id
                    )
and      paf.effective_end_date  = (
                        select max(pafx.effective_end_date)
                        from per_all_assignments_f pafx
                        where pafx.person_id = paf.person_id
                    )
and      paf.effective_end_date between hapf.effective_start_date and hapf.effective_end_date                    
and      paf.grade_id = pg.grade_id
AND      paf.job_id = job.job_id
AND      paf.business_group_id = job.business_group_id
and      paf.position_id = hapf.position_id
and      paf.organization_id = houv.organization_id
AND      houv.language = 'ESA'
and      paf.period_of_service_id = pps.period_of_service_id
and      paf.business_group_id = pro1.business_group_id (+) 
and      paf.assignment_id = pro1.assignment_id (+)
and      ( pro1.change_date IS NULL
           OR
           pro1.change_date =
               (SELECT MAX ( pro2.change_date )
                FROM   per_pay_proposals_v2 pro2
                WHERE  pro2.assignment_id = pro1.assignment_id
                )
          )                            
and pef.effective_end_date > SYSDATE - 30
AND paf.effective_end_date > SYSDATE - 30
AND pef.person_type_id = 123
--AND paf.payroll_id = 88
AND PEF.FULL_NAME LIKE 'TERAN%RAFAEL%' 
--
and paf.payroll_id not in (/* hoteles */
                           68, 69, 70, 71, 72, 74, 
                           101, 108, 109, 110, 111, 112, 129, 130, 131, 132, 133, 134, 135, 136, 137, 
                           138, 145, 147, 150, 151, 152, 153, 155, 157, 158, 159, 160, 161, 163, 164,
                           165, 167, 168, 170, 171, 173, 177, 189, 
                           210, 211, 229, 250, 
                           309, 369, 
                           409, 429, 469, 
                           529, 549, 569, 589, 
                           624,  
                           705, 726, 727, 729,730, 750, 770, 790,
                           810, 830, 850, 870, 890, 
                           930, 950, 970, 
                           1010, 1011, 1050, 1070, 1090, 1110, 1130, 1150, 1151, 1170, 1190, 1230, 1250, 1270, 1290,                           
                           1310, 1311, 1333, 1336, 1350, 1370, 1390, 1391, 1392, 1393,                            
                           1410, 1411, 1412, 1430, 1431, 1432, 1433, 1450, 1451, 1452, 1453, 1454, 1455, 1457, 1470, 1471, 1472, 1473, 1490,                                                     
                           1510, 1511, 1512, 1530, 1531, 1532, 1533, 1534, 1535, 1536, 1537, 1538, 1539, 1540, 1541, 1542, 1543, 1544, 1548, 1549, 
                           1550, 1551, 1552, 1553, 1554, 1555, 1556, 1557, 1558, 1559, 1560, 1570, 1590,
                           1610, 1630, 1650, 1670, 1671, 1690,
                           1710, 1730, 1750, 1770, 1771, 1772, 1773, 1790,
                           1810, 1830, 1850, 1870, 1890,
                           1931, 1950, 1990,
                           2010, 2030
                          )
ORDER BY 15, paf.effective_end_date desc, 6 desc, pro1.proposed_salary_N


