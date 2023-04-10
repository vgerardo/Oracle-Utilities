SET SERVEROUTPUT ON 

DECLARE
    
    l_appl_id         fnd_application.application_id%TYPE;
    l_resp_id         fnd_responsibility_tl.responsibility_id%TYPE;
    v_return_status   VARCHAR2(2);
    v_msg_count       NUMBER := 0;
    v_message_list    error_handler.error_tbl_type;
    
    v_org_code          varchar2(5);
    
BEGIN

     FND_GLOBAL.apps_initialize (USER_ID        => 11260, --ANA GODINEZ
                                 RESP_ID        => 50750, --50709=GRP_HER_INV_CONE_GTE  50750=GRP_ALL_INV_CONE_GTE
                                 RESP_APPL_ID   => 401 --401=Inventory
      );
            
    
    SELECT organization_code 
    INTO v_org_code 
    FROM mtl_parameters
    WHERE ORGANIZATION_ID = 501
    ;
    
    --DBMS_APPLICATION_INFO.set_client_info('ORG_ID', '91');
    FND_PROFILE.PUT('MFG_ORGANIZATION_ID', 501) ;
    
    EGO_ITEM_PUB.Assign_Item_to_Org (
                        p_api_version         => 1.0
                      , p_init_msg_list       => 'T'
                      , p_commit              => 'F'
                      , p_inventory_item_id   => 1003
                      --, p_item_number         => 000000000001035
                      , p_organization_id     => 109
                      --, p_organization_code   => v_org_code
                      --, p_primary_uom_code    => 'EA'
                      , x_return_status       => v_return_status
                      , x_msg_count           => v_msg_count
                    );

    dbms_output.put_line('Status: ' || v_return_status);

    IF ( v_return_status <> 'S' ) THEN
    
            DBMS_LOCK.sleep (1);
            dbms_output.put_line('Error Messages :' || v_msg_count);
            ERROR_HANDLER.get_message_list (x_message_list   => v_message_list);
            FOR j IN 1..v_message_list.count LOOP
                dbms_output.put_line(v_message_list(j).message_text);
            END LOOP;

    END IF;

    DBMS_LOCK.sleep(1);

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Exception Occured :');
        dbms_output.put_line(sqlcode ||
        ':' || sqlerrm); 
END;