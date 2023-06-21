SET SERVEROUTPUT ON 

DECLARE

v_return_status      VARCHAR2(1) := NULL;
v_msg_count          NUMBER      := 0;
v_msg_data           VARCHAR2(2000);
v_errorcode          VARCHAR2(1000);
v_category_id        NUMBER;  
v_category_set_id    NUMBER;  
v_inventory_item_id  NUMBER;  
v_organization_id    NUMBER;
v_context            VARCHAR2(2);


BEGIN

    --Apps Initialize
    FND_GLOBAL.apps_initialize (
						 user_id     => 1118,  --CONE-JFLORES
						 resp_id     => 50750, --GRP_ALL_INV_CONE_GTE
						 resp_appl_id=> 401    --401=Inventory
                     );


        v_category_id        := 1143;
        v_category_set_id    := 1100000041;
        v_inventory_item_id  := 199588;
        v_organization_id    := 91;
        
        /*INV_ITEM_CATEGORY_PUB.Create_Category_Assignment (
                                   p_api_version        => 1.0,  
                                   p_init_msg_list      => FND_API.G_TRUE,  
                                   p_commit             => FND_API.G_FALSE,  
                                   p_category_id        => v_category_id,  
                                   p_category_set_id    => v_category_set_id,  
                                   p_inventory_item_id  => v_inventory_item_id,  
                                   p_organization_id    => v_organization_id,
                                   
                                   x_return_status      => v_return_status,  
                                   x_errorcode          => v_errorcode,  
                                   x_msg_count          => v_msg_count,  
                                   x_msg_data           => v_msg_data  
                                );        
        */
        
        INV_ITEM_CATEGORY_PUB.Update_Category_Assignment (
                                   p_api_version        => 1.0,  
                                   p_init_msg_list      => FND_API.G_TRUE,  
                                   p_commit             => FND_API.G_FALSE,  
                                   p_category_id        => v_category_id,  
                                   p_category_set_id    => v_category_set_id,  
                                   p_inventory_item_id  => v_inventory_item_id,  
                                   p_organization_id    => v_organization_id,
                                   
                                   p_old_category_id    => 1328,
                                   
                                   x_return_status      => v_return_status,  
                                   x_errorcode          => v_errorcode,  
                                   x_msg_count          => v_msg_count,  
                                   x_msg_data           => v_msg_data  
                                );
        
        IF v_return_status = fnd_api.G_RET_STS_SUCCESS THEN
            
            COMMIT;
            DBMS_OUTPUT.put_line ('The Item assignment to category is Successful : '||v_category_id);
            
        ELSE
            DBMS_OUTPUT.put_line ('Assignment to category failed: ('||v_errorcode || ') ' ||v_msg_data);            
            FOR i IN 1 .. v_msg_count
            LOOP
              --v_msg_data := OE_MSG_PUB.get( p_msg_index => i, p_encoded => 'F');
              v_msg_data := SUBSTR (FND_MSG_PUB.get(p_encoded=> apps.FND_API.G_FALSE),1,255);
              DBMS_OUTPUT.put_line( i|| ') '|| v_msg_data);
            END LOOP;
            
            ROLLBACK;
            
        END IF;

END;
/
