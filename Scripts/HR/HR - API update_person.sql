SET SERVEROUTPUT ON

DECLARE

 -- Local Variables 
 -- ----------------------- 
  ln_object_version_number  PER_ALL_PEOPLE_F.OBJECT_VERSION_NUMBER%TYPE ;-- := 7; 
  lc_dt_ud_mode             VARCHAR2(100)  := NULL; 
  ln_assignment_id          PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_ID%TYPE; --     := 33564; 
  lc_employee_number        PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%TYPE; --  := 'PRAJ_01';

  -- Out Variables for Find Date Track Mode API
  -- ----------------------------------------------------------------
  lb_correction             BOOLEAN;
  lb_update                 BOOLEAN; 
  lb_update_override        BOOLEAN; 
  lb_update_change_insert   BOOLEAN;

  -- Out Variables for Update Employee API
  -------------------------------------------------------------
  ld_effective_start_date   date;
  ld_effective_end_date     DATE;
  lc_full_name              PER_ALL_PEOPLE_F.FULL_NAME%TYPE;
  ln_comment_id             PER_ALL_PEOPLE_F.COMMENT_ID%TYPE;
  lb_name_combination_warning  BOOLEAN;
  lb_assign_payroll_warning BOOLEAN;
  lb_orig_hire_warning      BOOLEAN;
    
  Cursor c1 
  is
  select      
       pap.object_version_number
      ,pap.employee_number
      ,pap.effective_start_date
      ,pap.person_id
      --, Ass.*
  from per_all_people_f             pap
      ,hr_employee_assignments_v    ass 
  WHERE 1=1
    AND pap.person_id = ass.person_id (+)
    --AND B.effective_end_date = TO_DATE ('12/31/4712', 'MM/DD/RRRR')
    --and trunc(sysdate) between b.effective_start_date and b.effective_end_date
    --AND A.EMPLOYEE_NUMBER IN('E01549','E00007')
    --AND A.EMPLOYEE_NUMBER IN('E01577','S01112')
    --AND ROWNUM < 2
    AND pap.person_id = 276
    ;

BEGIN


    for rec in c1    loop

        -- Update Employee API
        -- --------------------------------- 
        HR_PERSON_API.update_person
          (   -- ------------------------------ 
              -- Input Data Elements
              -- ------------------------------
              p_effective_date          => rec.effective_start_date,
              p_datetrack_update_mode   => 'CORRECTION',
              p_person_id               => REC.PERSON_ID,
              p_middle_names            => 'MIDDLE',
              p_first_name              => 'FIRST',              
              p_last_name               => 'LAST',
              p_email_address           => 'DUMMY@dummy.com',
              p_national_identifier     => 'XYZA123456HDFNDN02',
              p_per_information1        => 'X',                 -- Maternal Last
              p_per_information3        => '11-22-33-4444-5',     --Social Security ID
              p_attribute8              => 'DUMMY@dummy.com',
              
              --p_marital_status       => 'M',
              -- ----------------------------------
              -- Output Data Elements
              -- ----------------------------------
             p_employee_number          => rec.employee_number,
             p_object_version_number    => REC.object_version_number,
             p_effective_start_date     => ld_effective_start_date,
             p_effective_end_date       => ld_effective_end_date,
             p_full_name                => lc_full_name,
             p_comment_id               => ln_comment_id,
             p_name_combination_warning => lb_name_combination_warning,
             p_assign_payroll_warning   => lb_assign_payroll_warning,
             p_orig_hire_warning        => lb_orig_hire_warning
          );
        
        COMMIT;
        dbms_output.put_line('UPDATED FOR-'||rec.object_version_number||'-Full Name= '||lc_full_name);
    
  END LOOP;
  
  EXCEPTION
    WHEN OTHERS THEN
           ROLLBACK;
           dbms_output.put_line(SQLERRM);

END;
