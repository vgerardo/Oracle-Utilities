
SELECT dq.owner, dq.name queue_name, dq.owner||'.AQ$'||dq.queue_table queue_table_name
     , dq.enqueue_enabled, dq.dequeue_enabled, dq.retention
     , dqt.object_type
FROM dba_queues         dq
    ,dba_queue_tables   dqt
WHERE 1=1
  and dq.queue_table = dqt.queue_table
  and dq.name like upper('xxcmx_inv_conf_surtido_q%')
;


SELECT enq_timestamp, deq_timestamp, user_data, original_queue_name
     , sys.xmltype.createxml(user_data) xml_text
FROM xxcmx.AQ$XXCMX_INV_MO_ISSUE_T
WHERE 1=1
--  and msg_state <> 'EXPIRED'
order by enq_time  desc
;