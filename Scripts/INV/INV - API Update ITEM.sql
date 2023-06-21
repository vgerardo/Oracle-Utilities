declare
l_item_table        ego_item_pub.item_tbl_type;
x_item_table        ego_item_pub.item_tbl_type;
x_return_status     VARCHAR2 (1);
x_msg_count         NUMBER (10);
x_msg_data          VARCHAR2 (1000);
x_message_list      error_handler.error_tbl_type;
BEGIN
        l_item_table(1).transaction_type := 'UPDATE';
        l_item_table(1).inventory_item_id :=242008;
        l_item_table(1).organization_id :=127; -- I.ORGANIZATION_ID;
        l_item_table(1).template_id :=19;-- I.NEW_TEMPLATE_ID;

        ego_item_pub.process_items (
                    p_api_version       => 1.0,
                    p_init_msg_list     => fnd_api.g_true,
                    p_commit            => fnd_api.g_true,
                    p_item_tbl          => l_item_table,
                    x_item_tbl          => x_item_table,
                    x_return_status     => x_return_status,
                    x_msg_count         => x_msg_count
                );

        DBMS_OUTPUT.PUT_LINE ('Return Status ==>' || x_return_status);
        DBMS_OUTPUT.PUT_LINE ('Error Messages :');

        error_handler.get_message_list (x_message_list => x_message_list);
        
        FOR i IN 1 .. x_message_list.COUNT
        LOOP
            DBMS_OUTPUT.PUT_LINE (x_message_list (i).MESSAGE_TEXT);
        END LOOP;
        
END;

