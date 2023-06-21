
select segment1, sum(decode (substr(segment3,'1'), '1', period_net_cr - period_net_dr, 0)) activo
               , sum(decode (substr(segment3,'2'), '2', period_net_cr - period_net_dr, 0)) pasivo
               , sum(decode (substr(segment3,'3'), '3', period_net_cr - period_net_dr, 0)) capital
               , sum(decode (substr(segment3,'4'), '4', period_net_cr - period_net_dr, 0)) ingreso
               , sum(decode (substr(segment3,'5'), '5', period_net_cr - period_net_dr, 0)) costo
               , sum(decode (substr(segment3,'6'), '6', period_net_cr - period_net_dr, 0)) gasto
from 
       gl_code_combinations gcc
      , gl_balances gb
where gcc.code_combination_id = gb.code_combination_id
--and   gb.period_name between :g_periodo1 and :g_periodo2
and gb.period_year = 2010
--and gb.period_num = 1
and gcc.segment1 = '0001'
and      gb.actual_flag <> 'E'
and      gb.translated_flag IS NULL
group by segment1
order by 1
          