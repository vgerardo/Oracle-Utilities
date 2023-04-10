



--
-- Importes de NOMINA 
--
SELECT   SUBSTR (pet.element_name, 1, 40) Elemento
       , nvl (pet.reporting_name, pet.element_name) report_name
       , SUBSTR (piv.NAME, 1, 20) Balance
       , to_char(prrv.result_value,'9,999,999,990.00') result_value       
       , piv.input_value_id
       , pec.classification_name
       , pec.costing_debit_or_credit      
    FROM pay_run_result_values prrv,
         pay_run_results prr,
         pay_assignment_actions paa,
         pay_element_types_f pet,
         pay_input_values_f piv ,
         pay_element_classifications pec                                                                                        
   WHERE prrv.run_result_id = prr.run_result_id                                                                                  
     AND prr.assignment_action_id = paa.assignment_action_id
     AND prr.element_type_id = pet.element_type_id
     AND prrv.input_value_id = piv.input_value_id
     AND prrv.result_value IS NOT NULL     
     AND PIV.NAME = 'Pay Value'
     AND PRR.STATUS IN ('P', 'PA')
     AND PIV.UOM = 'M'
     AND SYSDATE BETWEEN PET.effective_start_date and PET.effective_end_date 
     --AND pec.costing_debit_or_credit = 'C'
     and pet.element_name like 'Sueldo Base COS'
     --AND pet.reporting_name LIKE 'Comp Anual Res Corp'
     --AND pec.classification_name != 'Deducciones Voluntarias' 
     AND PET.CLASSIFICATION_ID = PEC.CLASSIFICATION_ID       
     AND paa.assignment_action_id in (         
                    SELECT PAA.assignment_action_id
                    FROM per_all_people_f       ppf
                    , per_all_assignments_f     paf
                    , pay_assignment_actions    paa
                    , pay_payroll_actions       ppa
                    , per_time_periods          ptp
                    WHERE 1=1
                     --AND ppf.employee_number like '1027'
                     AND ppf.full_name like 'VARGAS-PE%AFORT, GERARDO'
                     and ppf.person_id = paf.person_id
                     and paf.assignment_id = paa.assignment_id
                     and paf.payroll_id = ppa.payroll_id
                     and ppa.payroll_action_id = paa.payroll_action_id  
                     and paa.action_status = 'C'
                     and ppa.action_status = 'C'
                     and paf.effective_end_date > sysdate
                     and ppa.date_earned between to_date ('15-02-2011', 'DD-MM-YYYY') and to_date ('15-02-2011', 'DD-MM-YYYY')
                     and ppa.time_period_id = ptp.time_period_id
                     and TRUNC (ppa.date_earned) BETWEEN TRUNC(ptp.start_date) AND TRUNC(ptp.end_date)                     
       )
--ORDER BY pet.element_name;



