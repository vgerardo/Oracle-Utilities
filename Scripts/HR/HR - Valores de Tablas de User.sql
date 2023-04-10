
SELECT put.user_table_name, 
       puc.user_column_name, 
       pur.row_low_range_or_name, pur.row_high_range, pur.display_sequence,
       pci.value
FROM   apps.pay_user_tables_fv      put
      ,apps.pay_user_columns_fv     puc
      ,apps.pay_user_rows_f         pur 
      ,pay_user_column_instances_f  pci
WHERE 1=1
 AND put.user_table_id = puc.user_table_id
 and put.user_table_id = pur.user_table_id
 and puc.user_column_id= pci.user_column_id
 and pci.user_row_id = pur.user_row_id 
 and pci.effective_end_date > sysdate
 AND upper(put.user_table_name) LIKE upper('Dias Fin Mes')
 and upper(puc.user_column_name) like upper('Dias Fin Mes')
order by  pur.display_sequence
 
            
 