
SELECT dq.owner, dq.name queue_name, dq.owner||'.AQ$'||dq.queue_table queue_table_name
     , dq.enqueue_enabled, dq.dequeue_enabled, dq.retention
     , dqt.object_type, dq.retention
FROM dba_queues         dq
    ,dba_queue_tables   dqt
WHERE 1=1
  and dq.queue_table = dqt.queue_table
  and dq.name like upper('XXCMX_INV_TO_CWMS_AQ%')
;

EXEC DBMS_AQADM.STOP_QUEUE (queue_name=>'XXCMX.XXCMX_INV_TO_CWMS_AQ', enqueue=>TRUE, dequeue=>TRUE, wait=>TRUE);
EXEC DBMS_AQADM.Start_Queue (queue_name=>'XXCMX.XXCMX_INV_TO_CWMS_AQ', enqueue=>TRUE, dequeue=>FALSE );
EXEC DBMS_AQADM.Alter_Queue (queue_name=>'XXCMX.XXCMX_INV_TO_CWMS_AQ', retention_time=>600); 

SELECT enq_timestamp, deq_timestamp, user_data, original_queue_name
     , sys.xmltype.createxml(user_data) xml_text
FROM XXCMX.AQ$XXCMX_INV_TO_CWMS_QTAB
WHERE 1=1
--  and msg_state <> 'EXPIRED'
order by enq_time  desc
;