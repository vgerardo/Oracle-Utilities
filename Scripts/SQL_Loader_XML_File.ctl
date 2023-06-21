--
--sqlldr apps/dEv6apP5@landoeadb.grupocomex.com.mx:1526/LANDODB "load_xml.ctl"
--
LOAD DATA
INFILE *
TRUNCATE
INTO TABLE my_xml
FIELDS TERMINATED BY "," OPTIONALLY ENCLOSED BY '"' TRAILING NULLCOLS
(
fecha    char(50) "to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS')" 
,filename filler char(120)
,payload  LOBFILE(filename) TERMINATED BY EOF
)
BEGINDATA 
"SYSDATE","C:\Users\H808091\Downloads\ShippingUpload.xml"