
-- Cabecera de Gastos de Viaje
--
SELECT  
                pap.full_name
              , erh.invoice_num  
              , decode(erh.payment_currency_code, 'MXP', erh.total, 0) mxp
              , decode(erh.payment_currency_code, 'USD', erh.total, 0) usd
              , erh.default_exchange_rate tc
              , decode (erh.payment_currency_code, 'USD', erh.total * erh.default_exchange_rate, erh.total) TOTAL_PESOS
              , api.invoice_amount, api.amount_paid, api.amt_due_employee
              , erh.creation_date
              , erh.attribute_category
              , erh.expense_status_code
              , pap2.full_name                  current_approver
              , erh.description                            
              , erh.report_header_id, erh.employee_id              
              , erh.default_currency_code
              , erh.payment_currency_code
              , erh.flex_concatenated
              , erh.override_approver_name
              , expense_last_status_date 
              , erh.report_submitted_date                                                                         
FROM ap_expense_report_headers_all erh
   , AP_INVOICES_ALL  api
   , per_all_people_f pap
   , per_all_people_f pap2
WHERE erh.employee_id = pap.person_id
      AND erh.invoice_num = api.invoice_num (+)      
      --and erh.payment_currency_code > 10000 
      --and invoice_num  in (:p_oie)
      --and pap.employee_number = 17984
      and erh.expense_current_approver_id = pap2.person_id (+)
      and (pap2.person_id is null or pap2.effective_end_date > sysdate)
      and pap.effective_end_date > sysdate
      -------------------------------------------------
      -- PROYECTOS
      --
      and pap.full_name in (
                    --'LOPEZ-NUÑEZ, ALBERTO',
                    --'NOLASCO-SUAREZ, JAIR',
                    --'CORNEJO-MENDOZA, RIGOBERTO',
                    --'VALENCIA-ESTRADA, ELIZABETH MARICELA',
                    --'RENTERIA-PINEDA, YANET',
                    --'FIGUEROA-AMBRIZ, XAVIER',
                    --'VARGAS-PEÑAFORT, GERARDO',
                    --'AVILA-AMEZCUA, WENDOLYNE',
                    'SANCHEZ-DE LA ROSA, JONATHAN'
                    )      
       -- -----------------------------------------
    AND TO_CHAR (erh.report_submitted_date, 'YYYYMM') >= '201209'                    
    --AND erh.flex_concatenated like '1722%'                 
ORDER BY erh.creation_date      

--
--
-- Lineas de Gastos de Viaje
-- 
SELECT erh.expense_status_code
     , pap.full_name 
     , pap.employee_number     
     , erh.flex_concatenated    cntr_csto 
     , erh.report_submitted_date         
     , erh.invoice_num          oie_number
     , erh.TOTAL                oie_header_amount
     , erl.item_description     
     , erl.amount               oie_line_amount
     , erl.justification        
     , (gcc.segment1 ||'.'|| gcc.segment2 ||'.'|| gcc.segment3 ||'.'|| gcc.segment4 ||'.'|| gcc.segment5) cnta
     , erl.code_combination_id        
FROM ap_expense_report_headers_all  erh
   , ap_expense_report_lines_all    erl
   , gl_code_combinations           gcc
   , per_all_people_f               pap
WHERE erh.report_header_id = erl.report_header_id
  and erl.code_combination_id = gcc.code_combination_id
  and erh.employee_id = pap.person_id
  --and erh.expense_status_code <> 'INVOICED' 
  and (:p_oie is null OR erh.invoice_num = :p_oie)  
  and TO_CHAR (erh.report_submitted_date, 'YYYYMM') >= '201209'
--  and TO_CHAR (erh.report_submitted_date, 'YYYYMM') <= '201210'
  and pap.full_name like 'SANCHEZ-DE LA ROSA%'
  and pap.effective_end_date in (
            select max (x.effective_end_date)
            from per_all_people_f x  
            where x.person_id = pap.person_id
      )





