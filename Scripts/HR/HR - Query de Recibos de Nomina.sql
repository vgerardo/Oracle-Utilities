


--
-- Periodos de Nómina
--
select distinct
     ptp.period_name, ptp.time_period_id, end_date     
from per_time_periods   ptp, 
     fnd_sessions       fs
where ptp.payroll_id = 88--:payroll_id
  and ptp.start_date <= fs.effective_date
  and end_date >= to_date ('01-08-2014', 'DD-MM-YYYY')
ORDER BY 3



  SELECT    ppa.display_run_number
         || ' - '
         || pas.ASSIGNMENT_SET_NAME
         || ' - '
         || pps.element_set_name
            nombre_recibo,
         hoi.org_information1 Empresa,
         hoi.org_information2 Registro_patronal,
         hoi.org_information3 RFC_patronal,
         TO_NUMBER (pp.employee_number) No_empleado,
         pp.full_name Empleado,
         pp.national_identifier Curp,
         UPPER (pp.attribute2) RFC,
         UPPER (pp.attribute1) IMMS,
         TO_CHAR (pp.original_date_of_hire, 'DD') FI_Dia,
         TO_CHAR (pp.original_date_of_hire, 'MM') FI_Mes,
         TO_CHAR (pp.original_date_of_hire, 'RR') FI_Ano,
         DECODE (UPPER (ptp.period_type),  'WEEK', 'S',  'CALENDAR MONTH', 'M')
         || ptp.period_num
            Periodo,
         TO_CHAR (ppa.date_earned, 'DD') FP_Dia,
         TO_CHAR (ppa.date_earned, 'MM') FP_Mes,
         TO_CHAR (ppa.date_earned, 'RR') FP_Ano,
         paa.assignment_action_id,         
         TO_NUMBER (1) secuencia,
         ptp.start_date Inicio_periodo,
         ptp.end_date fin_periodo,
         SUBSTR (hoi.org_information1, 1, 1) Inf_Legal,
         paf.grade_id grado,
         paf.assignment_id asignacion,
         ppp.PROPOSED_SALARY_N salario         
    FROM pay_assignment_actions paa,
         pay_payroll_actions ppa,
         per_time_periods ptp,
         pay_payrolls_f ppf,
         per_all_assignments_f paf,
         hr_soft_coding_keyflex_kfv hkf,
         hr_organization_information hoi,
         hr_all_organization_units houv,
         per_all_people_f pp,
         pay_people_groups ppg,
         PER_PAY_PROPOSALS ppp,
         PAY_ELEMENT_SETS pps,
         HR_ASSIGNMENT_SETS pas
   WHERE     paa.payroll_action_id = ppa.payroll_action_id
         AND ppa.action_status = 'C'
         AND ppa.time_period_id = ptp.time_period_id
         AND TRUNC (NVL (ppa.date_earned, ppa.effective_date)) BETWEEN TRUNC (ptp.start_date)
                                                                   AND TRUNC (ptp.end_date)
         AND ppf.payroll_id = paf.payroll_id
         AND paa.assignment_id = paf.assignment_id
         AND TRUNC (NVL (ppa.date_earned, ppa.effective_date)) BETWEEN TRUNC (paf.effective_start_date)
                                                                   AND TRUNC (paf.effective_end_date)
         AND paf.soft_coding_keyflex_id = hkf.soft_coding_keyflex_id
         AND hkf.segment1 = TO_CHAR (hoi.organization_id)
         AND hoi.org_information_context = 'MX Informacion Legal'
         AND houv.organization_id = hoi.organization_id
         AND paf.person_id = pp.person_id
         AND TRUNC (NVL (ppa.date_earned, ppa.effective_date)) BETWEEN TRUNC (pp.effective_start_date)
                                                                   AND TRUNC (pp.effective_end_date)
         AND paf.people_group_id = ppg.people_group_id         
         --AND ppa.element_set_Id IS NULL
         AND paf.business_group_id = pp.business_group_id
         AND pp.business_group_id = 81
         AND paf.payroll_id       = 88
         --AND ptp.time_period_id > 297528 --:ID_PERIODO
         AND pp.employee_number   = '72000' --:NO_EMPLEADO
         --AND paa.assignment_action_id = 531384446         
         AND paf.ASSIGNMENT_ID = ppp.ASSIGNMENT_ID
         AND pps.ELEMENT_SET_ID(+) = ppa.ELEMENT_SET_ID -- agregada para sacar el nombre del recibo
         AND pas.ASSIGNMENT_SET_ID(+) = ppa.ASSIGNMENT_SET_ID -- agregada para sacar el nombre del recibo
         AND PPP.CHANGE_DATE = (SELECT MAX (SAL.CHANGE_DATE)
                                  FROM PER_PAY_PROPOSALS SAL
                                 WHERE PPP.ASSIGNMENT_ID = SAL.ASSIGNMENT_ID)
GROUP BY    ppa.display_run_number
         || ' - '
         || pas.ASSIGNMENT_SET_NAME
         || ' - '
         || pps.element_set_name,
         hoi.org_information1,
         hoi.org_information2,
         hoi.org_information3,
         pp.employee_number,
         pp.full_name,
         pp.attribute2,
         pp.national_identifier,
         pp.attribute1,
         TO_CHAR (pp.original_date_of_hire, 'DD'),
         TO_CHAR (pp.original_date_of_hire, 'MM'),
         TO_CHAR (pp.original_date_of_hire, 'RR'),
         ptp.period_num,
         TO_CHAR (ppa.date_earned, 'DD'),
         TO_CHAR (ppa.date_earned, 'MM'),
         TO_CHAR (ppa.date_earned, 'RR'),
         paa.assignment_action_id,
         ppp.PROPOSED_SALARY_N,
         TO_NUMBER (1),
         ptp.start_date,
         ptp.end_date,
         SUBSTR (hoi.org_information1, 1, 1),
         paf.grade_id,
         paf.assignment_id,
         ptp.period_type        
ORDER BY TO_NUMBER (pp.employee_number)



--
-- DEDUCCIONES
--
 SELECT  dev.report_name  deduccion, 
           dev.result_value dedvalor       
   FROM    bolinf.csa_pay_element_types_mx_v1 dev
   WHERE   dev.type_class = 'DED' 
     AND   dev.result_value IS NOT NULL 
     AND   dev.result_value <> 0
     AND   dev.assignment_action_id = 615743344 --:ACTION_ID
     --AND dev.report_name IN ('Fondo de Ahorro Empleado', 'Intereses Prestamo Fondo Ahorro', 'Pago Cap F Ahorro')
  
    
--
-- PERCEPCIONES
-- 
   SELECT  per.report_name  percepcion, 
           per.result_value pervalor, 
           per.type_class,                   
           assignment_action_id      
   FROM    bolinf.csa_pay_element_types_mx_v1 per
   WHERE   1=1
     AND   per.type_class = 'PER'     
     AND   per.result_value IS NOT NULL 
     AND   per.result_value <> 0
     AND   per.assignment_action_id = 615743344      
     --AND per.report_name LIKE 'Aguin%'       
   ORDER BY 1
     
