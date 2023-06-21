SPOOL C:\balance_datos_dic14.txt

SET ARRAYSIZE 1000
SET COLSEP    '|'     
SET RECSEP    OFF    
SET PAGESIZE  0 EMBEDDED ON
SET LINESIZE  500    
SET WRAP      OFF      
SET TRIMOUT   ON       
SET TRIMSPOOL ON       
SET TERMOUT OFF        

SET HEADING   ON

COLUMN segment1        FORMAT A4  HEADING 'CIA'
COLUMN period_name     FORMAT A7  HEADING 'PERIODO'
COLUMN combinacion     FORMAT A34 HEADING 'FLEXFIELD CONTABLE'   
COLUMN desc_segment3   FORMAT A50 HEADING 'DESCRIPCION CUENTA'   
COLUMN balance_inicial FORMAT 99,999,999,990.00
COLUMN movimientos     FORMAT 99,999,999,990.00
COLUMN balance_final   FORMAT 99,999,999,990.00

BREAK ON segment1 skip 1

SELECT  
         glcc.segment1
       , glb.period_name 
       ,fnd_flex_ext.get_segs ('SQLGL','GL#', 50217, glcc.code_combination_id)                   combinacion                         
       ,(glb.begin_balance_dr-glb.begin_balance_cr)                                              balance_inicial
       ,(glb.period_net_dr-glb.period_net_cr)                                                    movimientos
       ,((glb.begin_balance_dr-glb.begin_balance_cr) + (glb.period_net_dr-glb.period_net_cr))    balance_final  
       ,(apps.gl_flexfields_pkg.get_description_sql( glcc.chart_of_accounts_id,3,glcc.segment3)) desc_segment3
FROM gl_balances            glb,
     gl_code_combinations   glcc
WHERE 1=1
  and glb.code_combination_id = glcc.code_combination_id    
  and glb.translated_flag IS NULL   
  and glb.template_id IS NULL       -- omitira las sumarias
  ----------------------------------- parametros --------------------------------------
  --and glcc.segment1     in ('0001','0806')
  and glb.period_name   = 'DIC-14'
  and glb.currency_code = 'MXP'
  and glb.actual_flag   = 'A'
--AND ROWNUM < 1000
  --and glb.last_update_date > TO_DATE ('06-05-2014 15:50:00', 'DD-MM-YYYY HH24:MI:SS')  
  ------------------------------------------------------------------------------------- 
ORDER by glcc.segment1, glcc.segment2
/

exit
/

