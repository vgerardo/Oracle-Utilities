--
-- Query para saber el tamaño y fagmentación de las Tablas
--
SELECT OWNER, SEGMENT_NAME, SEGMENT_TYPE, extents, to_char((BYTES)/1024/1024,'FM999,999,990') Megas, TABLESPACE_NAME
FROM DBA_SEGMENTS 
WHERE 1=1
  --and OWNER='ICX'
  and TABLESPACE_NAME = 'CTXD'
  --AND SEGMENT_NAME LIKE 'ICX_CAT_DATASTORE_HDRS'
--GROUP BY SEGMENT_NAME, SEGMENT_TYPE, TABLESPACE_NAME
ORDER BY 4 DESC, segment_name
;


--
-- Tamaño de TABLESPACES
--
SELECT b.tablespace_name, 
       to_char(tbs_size,'FM9,999,999.00') Size_Mb, 
       to_char(a.free_space,'FM9,999,999.00') Free_Mb, 
       round(a.free_space/tbs_size,2)*100 "% Free"
  FROM (  SELECT tablespace_name, ROUND (SUM (bytes) / 1024 / 1024, 2) AS free_space
            FROM dba_free_space
          GROUP BY tablespace_name) a
      ,(  SELECT tablespace_name, SUM (bytes) / 1024 / 1024 AS tbs_size
            FROM dba_data_files
        GROUP BY tablespace_name) b
 WHERE A.tablespace_name(+) = b.tablespace_name
 --  and b.tablespace_name in ('APPS_TS_TX_DATA', 'APPS_TS_TX_IDX', 'APPS_UNDOTS1', 'APPS_TS_NOLOGGING')
 ORDER BY 4 ;

--
-- TAMAÑO DE TABLAS
--
SELECT SEGMENT_NAME, SEGMENT_TYPE, TABLESPACE_NAME, extents, ROUND(SUM(BYTES)/1024/1024) SIZE_MB
FROM DBA_SEGMENTS A
WHERE 1=1
--AND OWNER= 'INV'
AND SEGMENT_NAME in ( 'EGO_ITEM_TEXT_TL', 'ICX_CAT_ITEMS_CTX_DTLS_TLP', 'ICX_CAT_ITEMS_CTX_HDRS_TLP')
GROUP BY SEGMENT_NAME, SEGMENT_TYPE, TABLESPACE_NAME, extents
ORDER BY 4 DESC, 1;

-- Tamaño de la Base de Datos
select sum(BYTES)/1024/1024 MB 
FROM DBA_EXTENTS  
;

SELECT *
FROM DBA_Tablespaces
ORDER BY tablespace_name;

--
-- BLOQUEOS
--
select a.SID "Blocking Session", b.SID "Blocked Session"
  from v$lock a, v$lock b
  where a.SID != b.SID
  and a.ID1 = b.ID1
  and a.ID2 = b.ID2
  and b.request > 0
  and a.block = 1; 
  
  
--WHICH LOCK MODES ARE REQUIRED FOR WHICH TABLE ACTION?
--The following table describes what lock modes on DML enqueues 
-- are actually gotten for which table operations in a standard Oracle installation.

--Operation         Lock Mode    LMODE    Lock    Description
--===========       ===========  =======  ======  ================
--Select            NULL        1       null    
--Select for update SS          2        sub    share
--Insert            SX          3       sub    exclusive
--Update            SX          3       sub    exclusive
--Delete            SX          3       sub    exclusive
--Lock For Update   SS          2       sub    share
--Lock Share        S           4       share    
--Lock Exclusive    X           6       exclusive    
--Lock Row Share    SS          2       sub    share
--Lock Row Exclusive    SX      3       sub    exclusive
--Lock Share Row Exclusive    SSX    5    share/sub    exclusive
--Alter table       X           6       exclusive    
--Drop table        X           6       exclusive    
--Create Index      S           4       share    
--Drop Index        X           6       exclusive    
--Truncate table    X           6       exclusive
      
      
pct_increase
freelists
freelist_groups