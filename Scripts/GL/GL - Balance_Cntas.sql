
SPOOL C:\x.txt

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

COLUMN period_name     HEADING 'PERIODO'
COLUMN combinacion     FORMAT A34 HEADING 'FLEXFIELD CONTABLE'   
COLUMN desc_segment1   FORMAT A80 HEADING 'DESCRIPCION COMPANIA' 
COLUMN desc_segment2   FORMAT A40 HEADING 'DESCRIPCION CENTRO COSTOS'
COLUMN desc_segment3   FORMAT A50 HEADING 'DESCRIPCION CUENTA'   
COLUMN desc_segment4   FORMAT A40 HEADING 'DESCRIPCION SUB-CTA'
COLUMN desc_segment5   FORMAT A70 HEADING 'DESCRIPCION INTERCO'
COLUMN balance_inicial FORMAT 99,999,999,990.00


SELECT         
         glb.period_name 
       , glb.period_year
       , glb.period_num       
       , decode(glb.actual_flag, 'A','Actual', 'B','Budget', 'E','Encumbrance', glb.actual_flag) Actual 
       , glb.currency_code
        -- -------------------------------------------------------
        -- A=Asset           - then Balance Sheet (BS)
        -- E=Expense         - Then Profit and Loss (PL)
        -- L=Liability       - then BS
        -- O=Owners Equity   - then BS
        -- R=Revenue         - Then PL
        --
       , Decode(glcc.account_type, 'A', 'Asset',
                                   'E', 'Expense',
                                   'L', 'Liability',
                                   'O', 'Owners Equity',
                                   'R', 'Revenue',
                                   glcc.account_type
                ) Account_Type       
        --
        -- --------------------------------------------------------
       , fnd_flex_ext.get_segs ('SQLGL','GL#', 50217, glcc.code_combination_id)                   combinacion           
       , (glb.begin_balance_dr-glb.begin_balance_cr)                                              balance_inicial
       , (glb.period_net_dr-glb.period_net_cr)                                                    movimientos
       , (glb.begin_balance_dr-glb.begin_balance_cr) + (glb.period_net_dr-glb.period_net_cr)      balance_final           
       , (apps.gl_flexfields_pkg.get_description_sql( glcc.chart_of_accounts_id,1,glcc.segment1)) desc_segment1
       , (apps.gl_flexfields_pkg.get_description_sql( glcc.chart_of_accounts_id,2,glcc.segment2)) desc_segment2
       , (apps.gl_flexfields_pkg.get_description_sql( glcc.chart_of_accounts_id,3,glcc.segment3)) desc_segment3
       , (apps.gl_flexfields_pkg.get_description_sql( glcc.chart_of_accounts_id,4,glcc.segment4)) desc_segment4
       , (apps.gl_flexfields_pkg.get_description_sql( glcc.chart_of_accounts_id,5,glcc.segment5)) desc_segment5
       , glb.last_update_date 
FROM gl_balances            glb,
     gl_code_combinations   glcc
WHERE 1=1
  and glb.code_combination_id = glcc.code_combination_id    
  and glb.translated_flag IS NULL   
  and glb.template_id IS NULL       -- omitira las sumarias
  ----------------------------------- parametros --------------------------------------
--  and glcc.segment1     = '0001'
  and glb.period_name   = 'DIC-14'
  and glb.currency_code = 'MXP'
  and glb.actual_flag   = 'A'
and rownum < 50002
  --and glb.last_update_date > TO_DATE ('06-05-2014 15:50:00', 'DD-MM-YYYY HH24:MI:SS')  
  ------------------------------------------------------------------------------------- 
ORDER by glcc.segment1, glb.period_year, glb.period_num
/

exit
/
