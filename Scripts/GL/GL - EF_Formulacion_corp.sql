
--plus80 bolinf/welcome12@di_production @EF_Formulacion_corp.sql

SPOOL C:\EF_Consolidado.txt

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


COLUMN rep_grupo        FORMAT A4  HEADING 'GRPO'
COLUMN rep_tipo     	FORMAT A4  HEADING 'TIPO'
COLUMN cta_oprdor	FORMAT A3  HEADING 'OPR'
COLUMN ref_rep      	FORMAT A5  HEADING 'R.REP'
COLUMN ref_cnc          FORMAT A5  HEADING 'R.CNC'

REM COLUMN rep_grupo NEW_VALUE GRUPO NOPRINT

REM TTITLE LEFT 'Grupo: ' GRUPO SKIP 1

REM BREAK ON grupo skip 1 

SELECT 
       rep.grupo rep_grupo, rep.tipo rep_tipo, rep.id_rep, rep.nombre rep_nombre, rep.visible rep_visible,
       cnc.id_cnc, cnc.nombre cnc_nombre, cnc.tipo, cnc.visible cnc_visible,
       cta.oprdor cta_oprdor, cta.cia, cta.cc, cta.cuenta, cta.subcta, cta.intrco,
       rfr.oprdor rfr_oprdor, rfr.ref_rep, rfr.ref_cnc
FROM CSA_EF_CNSL_REPS  rep,
     CSA_EF_CNSL_CNCPT cnc,
     CSA_EF_CNSL_CNTAS cta,
     CSA_EF_CNSL_RFRNC rfr
WHERE 1=1
  and rep.id_rep = cnc.id_rep
  and cnc.id_rep = cta.id_rep (+)
  and cnc.id_cnc = cta.id_cnc (+)
  and cnc.id_rep = rfr.id_rep (+)
  and cnc.id_cnc = rfr.id_cnc (+)
--  AND rep.grupo ='ALL'  
ORDER BY rep.grupo, rep.id_rep, rep.ORDEN,
         cnc.orden, cnc.id_cnc,
         cta.cia, cta.cc, cta.cuenta, cta.subcta, cta.intrco


/
SPOOL OFF
/
EXIT
/
 