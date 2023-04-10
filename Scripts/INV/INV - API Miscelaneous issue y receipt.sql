set SERVEROUTPUT ON

declare

v_trx_hdr_id    number(15);
v_trx_det_id    number(15);
v_row_hdr       inv.mtl_transactions_interface%rowtype;

v_return_status varchar2(1);
v_msg_count     number(15);
v_msg_data      varchar2(2000);
v_trans_count   number(15);
v_ret_value     NUMBER(15);

begin

    FND_GLOBAL.Apps_Initialize (user_id=>19282, resp_id =>20634, resp_appl_id=>401);


        -- obtiene ID para insertar en la Interface
        v_trx_hdr_id := mtl_material_transactions_s.NEXTVAL;
        
        v_trx_det_id := mtl_material_transactions_s.NEXTVAL;
        
        v_row_hdr.transaction_header_id     := v_trx_hdr_id;
        v_row_hdr.transaction_interface_id  := v_trx_det_id;    
        v_row_hdr.organization_id           := 422;    
        v_row_hdr.transaction_type_id       := 32;              --32=issue  42=receipt
        v_row_hdr.transaction_date          := to_date ('2022-09-08 00:00:41', 'YYYY-MM-DD HH24:MI:SS');
        v_row_hdr.inventory_item_id         := 111385;
        v_row_hdr.transaction_quantity      := -1;              --Negativo para Issue, Positivo para Receipt.
        v_row_hdr.transaction_uom           := 'pz';
        v_row_hdr.subinventory_code         := 'DISPONIBLE';
        v_row_hdr.reason_id                 := 479;
        v_row_hdr.transaction_mode          := 1;               -- 1=Online 2=Concurrent 3=Background
        v_row_hdr.process_flag              := 1;               -- 1=Pending 2=Running 3=Error
        v_row_hdr.lock_flag                 := 1;               -- 1=Locked 2=NOT Locked
        v_row_hdr.source_header_id          := 1234567;
        v_row_hdr.source_line_id            := 1234567;
        v_row_hdr.source_code               := 'Miscellaneous issue'; --'Miscellaneous Issue/Receipt'
        v_row_hdr.distribution_account_id   := 508250;
        v_row_hdr.locator_id                := 1138;            -- .V.1.1
        v_row_hdr.transaction_reference     := 'prueba gvp '||to_char(sysdate,'HH24:MI:SS');
        
        --v_row_hdr.transaction_source_id     := ; --mtl_generic_dispositions.disposition_id
        --v_row_hdr.transaction_source_name   := 'DEFAULT';
        --v_row_hdr.flow_schedule             := 'Y';    
        --v_row_hdr.cost_type_id              := 1; --1=Standard Cost
        
        v_row_hdr.last_update_date          := SYSDATE;
        v_row_hdr.last_updated_by           := FND_GLOBAL.user_id;
        v_row_hdr.creation_date             := SYSDATE;
        v_row_hdr.created_by                := FND_GLOBAL.user_id;
           

        INSERT INTO inv.mtl_transactions_interface VALUES v_row_hdr;


        v_trx_det_id := mtl_material_transactions_s.NEXTVAL;
        
        v_row_hdr.transaction_header_id     := v_trx_hdr_id;
        v_row_hdr.transaction_interface_id  := v_trx_det_id;    
        v_row_hdr.organization_id           := 422;    
        v_row_hdr.transaction_type_id       := 32;              --32=issue  42=receipt
        v_row_hdr.transaction_date          := to_date ('2022-09-08 00:00:42', 'YYYY-MM-DD HH24:MI:SS');
        v_row_hdr.inventory_item_id         := 130943;
        v_row_hdr.transaction_quantity      := -1;              --Negativo para Issue, Positivo para Receipt.
        v_row_hdr.transaction_uom           := 'pzx';
        v_row_hdr.subinventory_code         := 'DISPONIBLE';
        v_row_hdr.reason_id                 := 479;
        v_row_hdr.transaction_mode          := 1;               -- 1=Online 2=Concurrent 3=Background
        v_row_hdr.process_flag              := 1;               -- 1=Pending 2=Running 3=Error
        v_row_hdr.lock_flag                 := 1;               -- 1=Locked 2=NOT Locked
        v_row_hdr.source_header_id          := 1234567;
        v_row_hdr.source_line_id            := 1234567;
        v_row_hdr.source_code               := 'Miscellaneous issue'; --'Miscellaneous Issue/Receipt'
        v_row_hdr.distribution_account_id   := 508250;
        v_row_hdr.locator_id                := 1138;            -- .V.1.1
        v_row_hdr.transaction_reference     := 'prueba gvp '||to_char(sysdate,'HH24:MI:SS');
        
        --v_row_hdr.transaction_source_id     := ; --mtl_generic_dispositions.disposition_id
        --v_row_hdr.transaction_source_name   := 'DEFAULT';
        --v_row_hdr.flow_schedule             := 'Y';    
        --v_row_hdr.cost_type_id              := 1; --1=Standard Cost
        
        v_row_hdr.last_update_date          := SYSDATE;
        v_row_hdr.last_updated_by           := FND_GLOBAL.user_id;
        v_row_hdr.creation_date             := SYSDATE;
        v_row_hdr.created_by                := FND_GLOBAL.user_id;
           

        INSERT INTO inv.mtl_transactions_interface VALUES v_row_hdr;



   -- COMMIT;
    
    v_ret_value := INV_TXN_MANAGER_PUB.Process_Transactions (
                                     p_api_version      => '1.0'
                                    ,p_init_msg_list    => 'T'
                                    ,p_commit           => 'F'
                                    ,p_validation_level => 100
                                    ,x_return_status    => v_return_status
                                    ,x_msg_count        => v_msg_count
                                    ,x_msg_data         => v_msg_data
                                    ,x_trans_count      => v_trans_count
                                    ,p_table            => 1
                                    ,p_header_id        => v_trx_hdr_id 
                                );
  
  DBMS_OUTPUT.Put_Line ('v_return_status=' || v_return_status);
  DBMS_OUTPUT.Put_Line ('v_msg_count=' || v_msg_count);
  DBMS_OUTPUT.Put_Line ('v_msg_data=' || v_msg_data);     
  DBMS_OUTPUT.Put_Line ('v_trans_count=' || v_trans_count);
 
    FOR e IN (                               
            SELECT transaction_header_id, source_code, error_code, (error_explanation ||'. ') error_msg
            FROM MTL_TRANSACTIONS_INTERFACE
            WHERE 1=1
              and transaction_header_id = v_trx_hdr_id
            --and process_flag = 3
            )
    LOOP
        DBMS_OUTPUT.Put_Line ('ERRORES =' || E.error_code);
    END LOOP;

end;
/

SELECT transaction_interface_id, source_code, error_code, (error_explanation ||'. ') error_msg
FROM MTL_TRANSACTIONS_INTERFACE
WHERE 1=1
--and transaction_interface_id = 703302835
--and process_flag = 3
;