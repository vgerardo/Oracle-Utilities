

SELECT ('grant ' || rpad(privilege,10) || ' on  ' || rpad(lower(owner)||'.'||table_name,35) ||' to  '|| GRANTEE) ||
       decode(grantable,'YES',' with GRANT OPTION', ' ') || 
       decode(hierarchy,'YES',' with HIERARCHY OPTION;', '; ') Instruccion_Para_Permisos
FROM DBA_TAB_PRIVS
WHERE 1=1
  and grantee ='BOLINF'   
  and grantor ='APPS'
  --and lower(table_name) = 'po_lines_all'
ORDER BY table_name  
;
