    
DECLARE
v_note_rec AR_NOTES%ROWTYPE;
BEGIN

    MO_GLOBAL.Init ('AR');
   -- MO_GLOBAL.set_policy_context ('S', 204);
    
    --
    v_note_rec.customer_trx_id := 1721768;
    --
    
    v_note_rec.note_type    := 'MAINTAIN';
    v_note_rec.text         := 'GVP My Test 3';
    --v_note_rec.customer_call_topic_id := null;
    --v_note_rec.call_action_id := null;
    
    ARP_NOTES_PKG.Insert_P (v_note_rec);
    
    COMMIT;
    
END;
/

    
SELECT *
FROM AR_NOTES
WHERE customer_trx_id = 1721768
ORDER BY creation_date 
;