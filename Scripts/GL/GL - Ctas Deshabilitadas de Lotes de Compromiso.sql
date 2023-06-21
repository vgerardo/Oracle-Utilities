SELECT DISTINCT 1 x
      -- GLB.je_batch_id, 
       --, GLB.NAME lote
       --, glh.NAME asiento
       --, glh.PERIOD_NAME periodo
       --, gcc.SEGMENT1 compañia
       ,(      gcc.segment1
       ||'.'|| gcc.segment2
       ||'.'|| gcc.segment3
       ||'.'|| gcc.segment4
       ||'.'|| gcc.segment5
       ||'.'|| gcc.segment6
       ||'.'|| gcc.segment7 ) "Cuenta Contable"
       --, gcc.ENABLED_FLAG cta_activa
       --, glh.je_source origen
       --, glh.JE_CATEGORY categoria
       --, glh.currency_code divisa 
       --gll.je_line_num linea,
       --TO_CHAR (gll.entered_dr, '$999,999,999.00') debito,
       --TO_CHAR (gll.entered_cr, '$999,999,999.00') credito
  FROM gl_je_batches            GLB,
       gl_je_headers            glh,
       gl_je_lines              gll,
       gl_code_combinations     gcc
 WHERE GLB.je_batch_id  = glh.je_batch_id
   AND glh.je_header_id = gll.je_header_id
   AND substr(glh.period_name,4,3) in (  '-09')
   AND glh.je_source in ('Purchasing', 'Payables')
   AND gll.code_combination_id = gcc.code_combination_id
   AND glh.ACTUAL_FLAG ='E'
   and glb.STATUS      <>'P'    --P=Posted   
   and (   glb.name like 'CAD:%'
        OR glb.name like 'CJE:%'
        )
   and gcc.ENABLED_FLAG='N'
   --order by 6;
   
   