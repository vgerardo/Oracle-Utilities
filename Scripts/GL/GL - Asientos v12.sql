--
--
--  Asientos y SLA (SubLedger Accounting)
-- 
--
--
SELECT jeb.name                 Nombre_Lote
     , jeh.name                 Jornal_Name
     , jeh.je_category
     , jeh.je_source
     , jeh.period_name
     , jeh.name      
     , decode (xl.gl_transfer_mode_code, 'S', 'Summary',
                                           'D', 'Detail',
                                            xl.gl_transfer_mode_code
               ) Nivel_Detalle     
     , jel.entered_dr
     , jel.entered_cr
     , jel.je_line_num
     , jel.je_header_id          
     , xh.application_id
     , xt.entity_code
     , xm.transaction_id_col_name_1
     , xm.source_id_col_name_1
     , xt.source_id_int_1 
     , xt.security_id_int_1     
FROM gl_je_batches          jeb 
   , gl_je_headers          jeh
   , gl_je_lines            jel
   , GL_IMPORT_REFERENCES   ref
   , xla.xla_ae_lines               xl
   , xla.xla_ae_headers             xh
   , xla.xla_events                 xe
   , xla.xla_transaction_entities   xt
   , xla.xla_entity_id_mappings#    xm  -- para conocer los mapeos con los modulos
where 1=1
  and jeb.je_batch_id   = jeh.je_batch_id 
  and jeh.je_header_id  = jel.je_header_id
  and jel.je_header_id  = ref.je_header_id
  and jel.je_line_num   = ref.je_line_num
  and ref.gl_sl_link_table = xl.gl_sl_link_table  (+)
  and ref.gl_sl_link_id    = xl.gl_sl_link_id (+)
  and xl.application_id  = xh.application_id (+)
  and xl.ae_header_id    = xh.ae_header_id (+)
  and xh.application_id  = xe.application_id (+)
  and xh.event_id        = xe.event_id (+)
  and xe.application_id  = xt.application_id (+)
  and xe.entity_id       = xt.entity_id (+)
  and xt.application_id  = xm.application_id (+)
  and xt.entity_code     = xm.entity_code (+)
  --
  and jeh.je_source like 'Manual'
  --and jeh.je_header_id = 3277
  --and jeh.name like '17668 Recibos USD'
  --and xl.gl_transfer_mode_code = 'D'
  --
ORDER BY jeh.je_category, jeh.name                 
 
 