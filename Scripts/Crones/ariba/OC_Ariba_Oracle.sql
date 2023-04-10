set feed off
set verify off
set pagesize 0
set linesize 1000


spool /conectum/Areas/TI/crones/Ariba/d_tiempo.txt
--
-- Dimensión de TIEMPO
--
SELECT  '#'
      || '"'||TO_CHAR(SYSDATE- rownum,'YYYYMMDD')||'"!' --ID_TIEMPO
      || '"'||TO_CHAR(SYSDATE-rownum,'YYYY-MM-DD')||'"!'              --FECHA
      || '"'||TO_CHAR(SYSDATE-rownum, 'DD')||'"!' --DIA
      || '"'||TO_CHAR(SYSDATE-rownum, 'MM')||'"!' --MES
      || '"'||TO_CHAR(SYSDATE-rownum, 'YYYY')||'"!' --ANIO
      || '"'||trim(TO_CHAR(SYSDATE-rownum, 'DAY', 'NLS_DATE_LANGUAGE= SPANISH'))||'"!' --DIA_SEMANA
FROM po_headers_all
WHERE ROWNUM < 90
ORDER BY 1
/

spool off
/



spool /conectum/Areas/TI/crones/Ariba/h_ordenes_compra.txt

--
-- TABLA DE HECHOS
--
 SELECT '#'
       || '"' ||(
          SELECT t.flex_value_meaning      
          FROM fnd_flex_values_tl   t
             , fnd_flex_values      b
             , fnd_flex_value_sets ffvs
         WHERE 1=1
           and t.flex_value_id = b.flex_value_id
           and b.flex_value_set_id = ffvs.flex_value_set_id
           and ffvs.flex_value_set_name = 'GPDA_CIA'
           and t.LANGUAGE = 'ESA'          
           AND b.summary_flag = 'N'
           and trim(substr(t.description, 1,instr(t.description,'-')-1)) = decode(loc.location_code,'APTPZ','FIAPT', loc.location_code)
         GROUP BY t.flex_value_meaning  
          ) || '"!'
       ||'"'||TO_CHAR(poh.creation_date,'YYYYMMDD') ||'"!'               
       ||'"'||count(poh.segment1) ||'"!'  
FROM   po_headers_all poh,
       hr_locations_all_tl loc
WHERE  poh.ship_to_location_id = loc.location_id
AND    poh.segment1 LIKE 'PO%'
AND    loc.LANGUAGE = userenv('lang')
AND    poh.authorization_status = 'APPROVED'
AND    poh.cancel_flag = 'N'
AND    trunc(poh.creation_date) BETWEEN  sysdate-60 AND sysdate-1
GROUP BY TO_CHAR(poh.creation_date,'YYYYMMDD'), loc.location_code
/
spool off
/


spool /conectum/Areas/TI/crones/Ariba/d_hotel.txt

--
--Dimensión de HOTELES
--
SELECT '#'
     || '"'|| b.flex_value ||'"!'    -- ID_HOTEL
     || '"'|| trim(substr(t.description, 1,instr(t.description,'-')-1))||'"!' --SIGLAS
     || '"'|| trim(substr(t.description,instr(t.description,'-')+1))||'"!'    --DESCRIPCION
     ||'"'|| 
     CASE 
        WHEN   -- Hoteles FIESTA AMERICANA            
              (  t.description LIKE 'FA%'
              OR t.description LIKE 'OFACA%'
              OR t.description LIKE 'OFACU%'
              OR t.description LIKE 'OFAKO%'
              ) 
              AND NOT (
                   t.description LIKE 'FACC%'
                OR t.description LIKE 'FACR%'
                OR t.description LIKE 'FALC%'
              )                                
        THEN 'FA'
        WHEN   -- Hoteles Fiesta Inn             
               (t.description LIKE 'FI%'
               OR t.description LIKE 'APTPZ%' )
        THEN 'FI'        
        WHEN -- Hoteles ONE
                t.description LIKE '1%'               
        THEN 'ONE'        
        WHEN -- Hoteles ALL INCLUSIVE            
              t.description LIKE 'AQCU%'
               OR t.description LIKE 'FACC%'
               OR t.description LIKE 'FACR%'
        THEN  'ALLI'
        WHEN -- Hoteles GRAND            
                t.description LIKE 'FALC%'
        THEN  'GRAND'                
        ELSE 'OTRO'
    END  ||'"!'                            MARCA           
  FROM fnd_flex_values_tl t
     , fnd_flex_values b
     , FND_FLEX_VALUE_SETS ffvs
 WHERE b.flex_value_id = t.flex_value_id
   and ffvs.flex_value_set_id = b.flex_value_set_id
   and ffvs.flex_value_set_name = 'GPDA_CIA'   
   and t.LANGUAGE = 'ESA'          
   AND b.ENABLED_FLAG = 'Y'
   and b.summary_flag = 'N'
   and nvl(b.end_date_active,sysdate+1) > sysdate
   and b.flex_value not like 'E%'
   and  instr(t.description,'-') > 0    
/

spool off
/
