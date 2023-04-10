SET SERVEROUTPUT ON 

DECLARE

l_item_table    EGO_Item_PUB.Item_Tbl_Type;
x_item_table    EGO_Item_PUB.Item_Tbl_Type;
x_return_status VARCHAR2(1);
x_msg_count     NUMBER(10);
x_msg_data      VARCHAR2(1000);
x_message_list  Error_Handler.Error_Tbl_Type;

BEGIN

    --Apps Initialize
    FND_GLOBAL.apps_initialize (
						 user_id     => 1118,  --CONE-JFLORES
						 resp_id     => 50750, --GRP_ALL_INV_CONE_GTE
						 resp_appl_id=> 401    --401=Inventory
                     );
    
      -- Item definition
    l_item_table(1).Transaction_Type        := 'CREATE'; --'UPDATE';
    l_item_table(1).Segment1                := 'TA';    -- GRP_INV_CATEGORIA
    l_item_table(1).Segment2                := '0003';  -- GRP_INV_SUBCATEGORIA
    l_item_table(1).Segment3                := '12344';
    l_item_table(1).Organization_id         := 91;
    l_item_table(1).description             := 'My Primer Item x API';
    l_item_table(1).start_date_active       := sysdate;
    l_item_table(1).inventory_item_status_code:= 'Active';
    --l_item_table(1).purchasing_item_flag    := 'Y'
    --l_item_table(1).inventory_item_flag     := 
    --l_item_table(1).purchasing_enabled_flag :=
    --l_item_table(1).attribute_category      := 2990;

    -- Calling procedure EGO_ITEM_PUB.Process_Items 
    apps.EGO_ITEM_PUB.Process_Items(
                        --Input Parameters
                        p_api_version 	=> 1.0,
                        p_init_msg_list => FND_API.G_TRUE,
                        p_commit 		=> FND_API.G_FALSE,
                        p_Item_Tbl 		=> l_item_table,

                        --Output Parameters
                        x_Item_Tbl		=> x_item_table,
                        x_return_status	=> x_return_status,
                        x_msg_count		=> x_msg_count
                    );

    DBMS_OUTPUT.put_line ('Items updated Status ==>'||x_return_status);

    IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        COMMIT;
        
        FOR i IN 1 .. x_item_table.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE ('Inventory Item Id :' || to_char(x_item_table(i).Inventory_Item_Id));
            DBMS_OUTPUT.PUT_LINE ('Organization Id :'||to_char(x_item_table(i).Organization_Id));
        END LOOP;
        
    ELSE
    
		DBMS_OUTPUT.PUT_LINE('Error Messages :');
		Error_Handler.GET_MESSAGE_LIST(x_message_list => x_message_list);
        FOR i IN 1 .. x_message_list.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('Error= ' ||x_message_list(i).message_text);
        END LOOP;
        
        ROLLBACK;
    END IF;

END;
