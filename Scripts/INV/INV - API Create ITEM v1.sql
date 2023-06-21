SET SERVEROUTPUT ON

DECLARE

l_inventory_item_id number;
l_organization_id   number;
l_return_status     varchar2(3000);
l_msg_data          varchar2(3000);
l_msg_count         number (15);
l_msg_index         number (15);

API_ERROR EXCEPTION;

BEGIN

 FND_GLOBAL.apps_initialize (USER_ID    => 1118, --CONE-JFLORES
                             RESP_ID    => 50750, --GRP_ALL_INV_CONE_GTE
                             RESP_APPL_ID=>401 --401=Inventory
  );

 --execute immediate 'truncate table inv.mtl_system_items_interface';
 --execute immediate 'truncate table inv.mtl_interface_errors';

 apps.EGO_ITEM_PUB.process_item (
              p_api_version         => 1.0
              ,p_init_msg_list      => FND_API.G_TRUE
              ,p_commit             => FND_API.G_FALSE
              ,p_transaction_type   => 'DELETE' --CREATE, UPDATE
              ,p_segment1           => 'AL'     -- Categoria
              ,p_segment2           => '0017'   -- SubCategoria
              ,p_segment3           => '00018'
              ,p_description        => 'My Item Test'
              --,p_long_description   => 'Long pero very long long description'
              ,p_organization_id    => 1340
              --,p_template_id        => 19              
              --,p_approval_status    => 'A'
              --,p_inventory_item_status_code => 'Active'              
              ,p_attribute1         => '123456'
              ,x_inventory_item_id  => l_inventory_item_id
              ,x_organization_id    => l_organization_id
              ,x_return_status      => l_return_status
              ,x_msg_count          => l_msg_count
              ,x_msg_data           => l_msg_data
             );

 IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    DBMS_OUTPUT.PUT_LINE('Item is created successfully, Inventory Item Id : '||l_inventory_item_id);
    COMMIT;
 ELSE
 
    DBMS_OUTPUT.PUT_LINE('Error: '||l_msg_data);    

    FOR I IN 1 .. NVL(l_msg_count,1)
    loop
        l_msg_data := SUBSTR (FND_MSG_PUB.Get(p_encoded=> apps.FND_API.G_FALSE),1,255);
        DBMS_OUTPUT.put_line (i ||'. '|| l_msg_data);
    end loop;

    FOR e IN (      
            SELECT msii.segment1
                  ,msii.description
                  ,msii.process_flag
                  ,msii.transaction_id
                  ,mie.error_message
            FROM mtl_system_items_interface msii,
                 mtl_interface_errors mie
            WHERE msii.transaction_id = mie.transaction_id
              AND msii.process_flag = 3
              and msii.organization_id = 93
              AND msii.segment1 = 'AL'
            )
    LOOP
        DBMS_OUTPUT.put_line (e.error_message);
    END LOOP;    
       
    ROLLBACK;   
       
 END IF;

--
--EXCEPTION                  
--    WHEN OTHERS THEN 
--        DBMS_OUTPUT.PUT_LINE('Exception Occured :'); 
--        DBMS_OUTPUT.PUT_LINE(SQLCODE ||':'||SQLERRM); 
--        DBMS_OUTPUT.PUT_LINE('===');               
                  
END;
/

SELECT *
FROM MTL_SYSTEM_ITEMS_B
WHERE (SEGMENT1||'.'||SEGMENT2||'.'||SEGMENT3) = 'AL.0017.00018'
AND ORGANIZATION_ID = 1340
;