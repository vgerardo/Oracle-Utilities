--
-- Tablas Estandares de XML_PUBLISHER
--

select xdd.application_short_name, xdd.data_source_code, xdd.data_source_status, xdd.start_date, xdd.end_date, xdd.created_by, xdd.zd_edition_name
from xdo_ds_definitions_b  xdd    
    ,xdo_ds_definitions_tl xtl
where 1=1
  and xdd.data_source_code = xtl.data_source_code
  and xtl.language = 'ESA'
  and xtl.application_short_name = 'XBOL'   

select xtb.template_id, xtb.template_code, xtb.data_source_code, xtb.template_type_code, xtb.created_by,
       xtl.template_name, xtl.zd_edition_name, 
       xlob.file_name, xlob.xdo_file_type, xlob.file_data, xlob.lob_type, xlob.lob_code 
from xdo_templates_b xtb,
     xdo_templates_tl xtl,
     xdo_lobs         xlob
where xtb.template_code = xtl.template_code
  and xtb.template_code = xlob.lob_code (+)  
  and xtb.application_short_name = 'XBOL'   
  and xtl.language = 'ESA'


