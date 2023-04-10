--
-- Uso de UNDO
--
SELECT 
    --SYSDATE AS fecha,
    to_char(unexpired.unexpired, 'FM999,999,990.00') unexpired_mb
    ,to_char(expired.expired, 'FM999,999,990.00') expired_mb
    ,to_char(active.active, 'FM999,999,990.00') active_mb
FROM 
    (    
    --significa que estos segmentos de UNDO no contienen ninguna transacción activa, 
    --pero estos contienen transacciones que todavía son requeridos para FLASHBACK
    SELECT SUM(BYTES/1024/1024) AS unexpired
    FROM dba_undo_extents
    WHERE status='UNEXPIRED'    
    ) unexpired,
    (
    --significa que estos segmentos no son requeridos después del periodo de 
    -- retención definido en undo_retention
    SELECT SUM(BYTES/1024/104) AS expired
    FROM dba_undo_extents tr
    WHERE status='EXPIRED') expired,    
    (
    --significa que estos segmentos de UNDO contienen transacciones activas, o sea, no se ha realizado commit.
    SELECT CASE
    WHEN COUNT(status)=0
    THEN 0
    ELSE SUM(BYTES/1024/1024)
    END AS active
    FROM dba_undo_extents
    WHERE status='ACTIVE'
    ) active
;