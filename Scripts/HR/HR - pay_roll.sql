SELECT   rpad ( substr ( ppf.payroll_name, 1, 22 ), 22, ' ' ) payroll_name
        , rpad ( substr ( depto.NAME, 1, 35 ), 35, ' ' ) || ',' departamento
        ,lpad ( paf.person_id, 5, '0' ) person_id_infor
        ,substr ( rpad ( substr ( petf.element_name, 1, 20 ), 20, ' ' ), 1, 20 )
                                                                               concepto_informativo
        ,SUM ( to_number (   nvl ( prrv.result_value, 0 )
                           * decode ( substr ( pcac.segment3, 1, 1 )
                                     ,6, 1
                                     ,-1 )
                          ,'9999999.99' )) informativo
FROM     pay_assignment_actions paa
        ,pay_payroll_actions ppa
        ,per_time_periods ptp
        ,per_assignments_f paf
        ,pay_payrolls_f ppf
        ,hr_locations_all hrl
        ,pay_run_results prr
        ,pay_element_types_f petf
        ,pay_element_links_f pel
        ,pay_cost_allocation_keyflex pcab
        ,pay_cost_allocation_keyflex pcac
        ,pay_element_classifications pec
        ,pay_run_result_values prrv
        ,pay_input_values_f pivf
        ,hr_soft_coding_keyflex_kfv hkf
        ,hr_organization_information hoi
        ,hr_all_organization_units houv
        ,hr_all_organization_units depto
WHERE    paa.payroll_action_id = ppa.payroll_action_id
and      ppa.action_status = 'C'
and      ppa.action_type IN ( 'R', 'Q' )
and      ppa.time_period_id = ptp.time_period_id
and      paf.organization_id = depto.organization_id
and      petf.element_type_id = pel.element_type_id
and      paf.organization_id = pel.organization_id
and      pel.cost_allocation_keyflex_id = pcac.cost_allocation_keyflex_id
and      pel.balancing_keyflex_id = pcab.cost_allocation_keyflex_id
--  and (substr(pcab.segment3,1,1)='6' or substr(pcac.segment3,1,1)='6')
and      petf.element_name LIKE '%COS'
and      trunc ( pel.effective_end_date ) >= trunc ( ptp.end_date )
and      trunc ( pel.effective_start_date ) < trunc ( ptp.end_date )
and      trunc ( nvl ( ppa.date_earned, ppa.effective_date )) BETWEEN trunc ( ptp.start_date )
                                                                  and trunc ( ptp.end_date )
and      paf.assignment_id = paa.assignment_id
and      trunc ( nvl ( ppa.date_earned, ppa.effective_date )) BETWEEN trunc
                                                                           ( paf.effective_start_date )
                                                                  and trunc ( paf.effective_end_date )
and      trunc ( nvl ( ppa.date_earned, ppa.effective_date ))
               BETWEEN trunc ( petf.effective_start_date )
                   and trunc ( petf.effective_end_date )
and      ppf.payroll_id = paf.payroll_id
and      paf.location_id = hrl.location_id
and      paf.assignment_id = paa.assignment_id
and      paa.payroll_action_id = ppa.payroll_action_id
and      ppa.time_period_id = ptp.time_period_id
and      paa.assignment_action_id = prr.assignment_action_id
and      prr.element_type_id = petf.element_type_id
and      petf.classification_id = pec.classification_id
and      prr.run_result_id = prrv.run_result_id
and      prrv.input_value_id = pivf.input_value_id
--and        paf.location_id = houv.location_id
and      paf.soft_coding_keyflex_id = hkf.soft_coding_keyflex_id
and      hkf.segment1 = to_char ( hoi.organization_id )
and      hoi.org_information_context = 'MX Informacion Legal'
and      houv.organization_id = hoi.organization_id
and      pivf.NAME = 'Pay Value'
and      paa.action_status = 'C'
and      ppa.action_status = 'C'
and      pec.classification_name IN
                         ( 'Percepciones Informativas', 'Deducciones Informativas', 'Provisiones' )
and      ppa.action_type IN ( 'R', 'Q' )
and      paf.business_group_id = :bg
--and     ptp.time_period_id = 14493
and      EXISTS (
               SELECT 1
               FROM   per_time_periods ptp2
               WHERE  ptp.time_period_id = ptp2.time_period_id
               and    trunc ( ptp2.start_date ) >= trunc ( :fecha_ini )
               and    trunc ( ptp2.end_date ) <= trunc ( :fecha_fin ))
--and     paf.person_id in (1002,1022,1041,1049)
--and       houv.organization_id = :pn_location_id
and      ppf.payroll_id = :payroll_id_v
and      paf.organization_id = nvl ( :organization_id_v, paf.organization_id )
GROUP BY ppf.payroll_name
        ,depto.NAME
        ,paf.person_id
        ,petf.element_name
HAVING   SUM ( nvl ( prrv.result_value, 0 )) != 0
ORDER BY depto.NAME
        ,petf.element_name