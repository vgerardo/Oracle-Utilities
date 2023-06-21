
--
-- Pa LOZANO
--
SELECT 
        pap.employee_number                      num_emp
      , case 
        when instr(paa.assignment_number,'-') = 0 
         then '1'
         else substr(paa.assignment_number, instr(paa.assignment_number,'-')+1)  
        end                                      posicion
      , pap.full_name                            nombre     
      , FLOOR((sysdate - pap.date_of_birth)/365) edad
      , decode(pap.marital_status
                , 'M', 'CASADO/A'
                , 'S', 'SOLTERO/A'
                , 'No Capturado')                edo_civil          
      , decode(pap.sex
               , 'F', 'Femenino'
               , 'M', 'Masculino'
               , 'No Capturado')                 sexo         
      , pap.email_address                        email
      , pa.telephone_number_1                    telefono_1
      , pa.telephone_number_2                    telefono_2               
      ,(select employer_name
          from per_previous_employers pem
          where person_id = pap.person_id
            and end_date = (select max(end_date) 
                            from per_previous_employers p 
                            where p.person_id = pem.person_id
                             ) 
            and rownum < 2)                      Trabajo_anterior
    ,pap.effective_start_date                    Ingreso_RHNET
    ,pap.original_date_of_hire                   Ingreso_Grupo_Actual    
    ------------------------------------DATOS RH-NET -------------------
       , pac.segment1  Carro
       , pac.segment2  Emergencia 
       , pac.segment3  Ocupacion
       , pac.segment4  Hijos
       , pac.segment5  Areas_Interes
       , pac.segment6  Enfermedades
       , pac.segment7  Alergias
       , pac.segment8  Hobbies
       , pac.segment13 Promedio_Carrera
       , pac.segment14 Cursos_Maestria
       , pac.segment9  Grupo_Actual
       , pac.segment15 Carrera
       , pac.segment10 Conocidos_Konexo
       , pac.segment11 Primer_Trabajo
       , pac.segment12 Otro_Trabajo    
    ------------------------------------DATOS IDIOMAS -------------------
       , decode(pac2.segment1
                ,'IN', 'INGLES'
                ,'ES', 'ESPAÑOL'            
                )                              idioma
       , DECODE(pac2.segment2
                ,'B','BASICO'
                ,'I','INTERMEDIO'
                ,'A','AVANZADO'            
               )                               nivel    
    , est.name                                 escuela          -- ¿ultima escual o todas?   
    --,'x' Turno
    --,'*' Vive_con    
FROM per_all_people_f       pap
       , per_all_assignments_f  paa
       , pay_all_payrolls_f     pay
       , per_addresses          pa 
       , per_previous_employers pem        
       --, per_phones            pp  
       , per_establishment_attendances esa
       , per_establishments     est   
       , per_person_analyses    ppa     -- RH-Net
       , per_analysis_criteria  pac
       , per_person_analyses    ppa2    -- Idiomas
       , per_analysis_criteria  pac2   
WHERE pap.person_id = paa.person_id
      and paa.payroll_id = pay.payroll_id  
      and pap.effective_end_date > sysdate
      and paa.effective_end_date > sysdate
      and paa.payroll_id = 850  -- Nomina RHNET Quincenal
      --and paa.payroll_id = 173  -- PRUEBA
      --and pap.person_id = 87407 
      and pap.person_id = pa.person_id (+)
      and 'Y' = pa.primary_flag (+)
      and pap.person_id = pem.person_id (+)
      and pap.person_id = esa.person_id (+)
      and esa.establishment_id = est.establishment_id(+)
      and pap.person_id = ppa.person_id (+)
      and pap.person_id = ppa2.person_id (+)
      and ppa.analysis_criteria_id  = pac.analysis_criteria_id (+)
      and ppa2.analysis_criteria_id = pac2.analysis_criteria_id (+)      
      and ppa.id_flex_num          = pac.id_flex_num (+)
      and ppa2.id_flex_num         = pac2.id_flex_num (+)  
      and 50321 = ppa.id_flex_num (+)   -- Datos de RH-NET            
      and 50239 = ppa2.id_flex_num (+)   -- Datos de IDIOMAS        
ORDER BY pap.employee_number 

    