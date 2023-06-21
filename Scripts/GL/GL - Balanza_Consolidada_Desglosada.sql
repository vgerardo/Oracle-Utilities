
SELECT  
        glcc.segment1 cia, glcc.segment2 cc, glcc.segment3 cnta, glcc.segment4 sbcta, glcc.segment5 interco, glcc.segment6 fut1, glcc.segment7 fut2
       ,( nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0) )Begin_Balance
       ,( nvl(period_net_dr,0) - nvl(period_net_cr,0) )Actividad_Periodo
       ,( nvl(period_net_dr,0) - nvl(period_net_cr,0) +  nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0) )End_Balance            
FROM   
    gl_balances                    glb, 
    gl_code_combinations         glcc
WHERE    
       glb.actual_flag = 'A'
and    glb.set_of_books_id  = 1
and    glb.currency_code = 'MXP'
and    glb.code_combination_id = glcc.code_combination_id
and    glcc.chart_of_accounts_id = '50217'  
and    glb.period_name like 'AGO-08'
--and    glcc.segment3= '1110001'
and    ( 
        glcc.template_id is not null and glcc.segment1 = '9910' and 'N'=:p_desglose
        OR
        glcc.template_id is null and glcc.segment1 in  (               
                                    select flex_value
                                    from fnd_flex_value_children_v
                                    where flex_value_set_id = 1007054
                                      and parent_flex_value = '9910'
                                      and 'Y'               = :p_desglose
                                )
        )
and ( ( nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0) ) != 0
    or  ( nvl(period_net_dr,0) - nvl(period_net_cr,0) ) != 0
    or  ( nvl(period_net_dr,0) - nvl(period_net_cr,0) +  nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0) ) != 0
)           
ORDER BY glcc.segment3, glcc.segment1, glcc.segment2, glcc.segment4, glcc.segment5, glcc.segment6, glcc.segment7        
        