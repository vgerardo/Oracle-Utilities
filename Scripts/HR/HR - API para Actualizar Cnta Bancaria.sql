SET SERVEROUTPUT ON

DECLARE

    ln_method_id        pay_personal_payment_methods_f.personal_payment_method_id%TYPE;
    ln_ext_acc_id       pay_external_accounts.external_account_id%TYPE;
    ln_obj_ver_num      pay_personal_payment_methods_f.object_version_number%TYPE;
    ld_eff_start_date   DATE;
    ld_eff_end_date     DATE;
    ln_comment_id       NUMBER;
    
    CURSOR c1 IS 
    SELECT
        pm.assignment_id,
        pm.object_version_number,
        pm.personal_payment_method_id,        
        ac.segment2,
        ac.segment12,
        pm.effective_start_date,
        pm.effective_end_date,                
        pm.external_account_id
        --ass.effective_start_date, ASS.effective_end_date
    FROM 
        per_all_assignments_f          ass,
        pay_personal_payment_methods_f pm,
        pay_external_accounts ac        
    WHERE
        1 = 1
        and ass.assignment_id      = pm.assignment_id
        AND pm.external_account_id = ac.external_account_id   
        and ass.person_id = 1649
        --AND pm.personal_payment_method_id = 4692
       /* and ass.effective_start_date = (
                                     select max(effective_start_date)
                                     from per_all_assignments_f x
                                     where x.person_id = ass.person_id
                                     )*/
        ;

BEGIN

    --apps.fnd_global.apps_initialize(12447,20536,800);

    --insert into fnd_sessions (session_id,effective_date) values(userenv('SESSIONID'),sysdate);
    --commit;

    FOR r IN c1 LOOP
        BEGIN
            ln_obj_ver_num      := r.object_version_number;
            ln_ext_acc_id       := r.external_account_id;
            ln_method_id        := r.personal_payment_method_id;
            ln_comment_id       := NULL;
            ld_eff_start_date   := r.effective_start_date;            
            ld_eff_end_date     := r.effective_end_date;


            HR_PERSONAL_PAY_METHOD_API.update_personal_pay_method (
                   p_validate                      => false
                  ,p_effective_date                => r.effective_start_date --SYSDATE-1
                  ,p_datetrack_update_mode         => 'CORRECTION'
                  ,p_personal_payment_method_id    => ln_method_id
                  ,p_object_version_number         => ln_obj_ver_num
                  ,p_territory_code                => 'MX'
                  
                  --,p_segment1 => 'Santander'  --Bank
                  --,p_segment2 => ''           --Branch
                  ,p_segment3 => 'XX3333'
                  --,p_segment4 => 'DEB'        --Account Type
                  ,p_segment5 => '39393939393'

                  ,p_comment_id                    => ln_comment_id
                  ,p_external_account_id           => ln_ext_acc_id
                  ,p_effective_start_date          => ld_eff_start_date
                  ,p_effective_end_date            => ld_eff_end_date
                );            

            dbms_output.put_line(ln_method_id || ' puf chido! '|| ln_obj_ver_num);
            ---COMMIT;
            
        EXCEPTION
            WHEN OTHERS THEN
               --- ROLLBACK;
                dbms_output.put_line(ln_method_id || ' Error: ' || sqlerrm);
        END;
    END LOOP;
    
    --commit;
    
END;