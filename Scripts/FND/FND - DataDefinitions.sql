
SELECT files.lob_type, files.file_name
FROM xdo_ds_definitions_vl  dd
     ,xdo_lobs              files
WHERE 1=1
 and dd.data_source_code = files.lob_code (+)
 --and 'BURSTING_FILE'     = files.lob_type (+)
 and dd.data_source_code = 'GRP_AR_MAR_RCBOS_UNAPP'
;


SELECT dd.data_source_code, files.lob_type, files.file_name
FROM xdo_ds_definitions_vl  dd
     ,xdo_lobs              files
WHERE 1=1
 and dd.data_source_code = files.lob_code (+)
 and 'BURSTING_FILE'     = files.lob_type 
 --and dd.data_source_code like 'GRP%'
;