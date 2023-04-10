--
--SUB-INVENTORY TRANSFER
--
SET SERVEROUTPUT ON 
DECLARE
v_dummy                     varchar2(500);
v_lot_control               NUMBER(15);
v_serial_control            NUMBER(15);
v_transaction_interface_id  NUMBER(15);
v_transaction_type_id       number(15);
v_location_from_id          number(15);
v_location_to_id            number(15);
v_reason_id                 number(15);

v_return_status             varchar2(50);
v_msg_count                 number(15);
v_msg_data                  varchar2(500);
v_trans_count               number(15);
v_header_id                 number(15);

-- Parametros
p_inv_org_id            number(15)  := 422;
p_item_id               NUMBER(15)  := 111180;
p_uom                   varchar2(10):= 'pz'; 
p_quantity              number(15,4):= 1.0;
p_subinventory_from     varchar2(50):= 'DISPONIBLE';
p_location_from         varchar2(50):= '.V.1.1';
p_subinventory_to       varchar2(50):= 'DESTRUIR';
p_location_to           varchar2(50):= '.X.1.1';
p_reason                varchar2(10):= 'AUC';
p_reference             varchar2(250):='prueba gvp';

BEGIN

  --  fnd_global.apps_initialize (l_user_id, l_resp_id, l_appl_id);


    -- Check if item is "Lot/Serial" Controlled
    BEGIN
        SELECT lot_control_code, serial_number_control_code
          INTO v_lot_control, v_serial_control
          FROM mtl_system_items_b
         WHERE organization_id  = p_inv_org_id
           AND inventory_item_id= p_item_id              
           ;
         dbms_output.put_line (' v_lot_control='||v_lot_control || '  v_serial_control='||v_serial_control); 
    EXCEPTION WHEN others THEN
        dbms_output.put_line ('Excepción analizando si el artículo tiene Control por Lotes/Serie: '||SQLERRM);
    END;


    SELECT mtl_material_transactions_s.NEXTVAL
    INTO v_transaction_interface_id
    FROM DUAL;

    BEGIN
        SELECT transaction_type_id
          INTO v_transaction_type_id
          FROM mtl_transaction_types
         WHERE transaction_type_name = 'Subinventory Transfer'
         ;
     EXCEPTION WHEN others THEN
        dbms_output.put_line ( 'Excepción buscando Transaction Type ID de Inter-Org Transfer: '  ||  SQLERRM);
     END;



    select inventory_location_id
    into v_location_from_id
    from mtl_item_locations_kfv
    WHERE 1=1
     AND organization_id = p_inv_org_id
     and concatenated_segments = p_location_from --'.V.1.1'
    ;


    select inventory_location_id
    into v_location_to_id
    from mtl_item_locations_kfv
    WHERE 1=1
     AND organization_id = p_inv_org_id
     and concatenated_segments = p_location_to --'.X.1.1'
    ;


    SELECT reason_id
    INTO v_reason_id
    FROM apps.mtl_transaction_reasons
    WHERE reason_name = p_reason --'AUC'
    ;


    INSERT INTO mtl_transactions_interface (
                    transaction_header_id
                   ,transaction_interface_id
                   ,transaction_type_id
                   ,transaction_uom
                   ,transaction_date
                   ,organization_id
                   ,transaction_quantity
                   ,last_update_date
                   ,last_updated_by
                   ,creation_date
                   ,created_by
                   ,transaction_mode
                   ,process_flag
                   ,lock_flag                                               
                   ,source_header_id
                   ,source_line_id
                   ,source_code
                   ,transaction_source_id
                   ,transaction_source_name
                   --,flow_schedule
                   ,inventory_item_id
                   ,subinventory_code
                   ,distribution_account_id
                   --,cost_type_id
                   ,locator_id
                   ,transfer_subinventory
                   ,transfer_locator
                   ,reason_id
                   /*,dst_segment1
                   ,dst_segment2
                   ,dst_segment3
                   ,dst_segment4
                   ,dst_segment5
                   ,dst_segment6
                   ,dst_segment7
                   */
                   ,transaction_reference
                   
        ) VALUES (
                v_transaction_interface_id          -- transaction_header_id
               ,v_transaction_interface_id          -- transaction_interface_id
               ,v_transaction_type_id               -- transaction_type_id
               ,p_uom                               -- transaction_uom
               ,SYSDATE                             -- transaction_date
               ,p_inv_org_id                        -- organization_id (inventario)
               ,p_quantity                          -- transaction_quantity 
               ,SYSDATE                             -- last_update_date
               ,1                           -- last_updated_by
               ,SYSDATE                             -- creation_date
               ,1                           -- created_by
               ,3                                   -- transaction_mode = BACKGROUND PROCESSING
               ,1                                   -- process_flag
               ,2                                   -- Lock_flag               
               ,v_transaction_interface_id          -- source_header_id
               ,v_transaction_interface_id          -- source_line_id
               ,'Subinventory Transfer'             -- source_code
               ,''                                  -- transaction_source_id
               ,''                                  -- transaction_source_name
               --,'Y'                               -- flow_schedule
               ,p_item_id                           -- inventory_item_id
               ,p_subinventory_from                 -- subinventory_code
               ,''                                  -- distribution_account_id
               --,1                                   -- cost_type_id // For Standard Costs. Check cst_cost_types for your cost you want
               ,v_location_from_id                  -- locator_id // Get the inventory_location_id from mtl_item_locations_kfv where concatenated_segements = << Your Specific Locator>>
               ,p_subinventory_to
               ,v_location_to_id
               ,v_reason_id
               --,l_segment1
               --,l_segment2
               --,l_segment3
               --,l_segment4
               --,l_segment5
               --,l_segment6
               --,l_segment7
               ,p_reference
               );

              /*
                    IF l_lot_control_code = 2 THEN

                        --Insert lot on mtl_transactions_interface
                        BEGIN

                            SELECT mms.status_id
                              INTO l_lot_status_id
                              FROM mtl_material_statuses_tl mms
                             WHERE 1=1
                               AND mms.language    = USERENV('LANG')
                               AND mms.status_code = 'APQC'; -- Definir status del lote

                            INSERT INTO mtl_transaction_lots_interface (transaction_interface_id,
                                                                        last_update_date,
                                                                        last_updated_by,
                                                                        creation_date,
                                                                        created_by,
                                                                        lot_number,
                                                                        lot_expiration_date,
                                                                        transaction_quantity,
                                                                        status_id)
                                 VALUES (l_transaction_interface_id,
                                         SYSDATE,
                                         FND_GLOBAL.USER_ID,
                                         SYSDATE,
                                         FND_GLOBAL.USER_ID,
                                         r_items.lot_number,
                                         SYSDATE + 100, --Definir regla
                                         r_items.quantity,
                                         l_lot_status_id
                                        );

*/

        COMMIT;
        
        v_dummy := INV_TXN_MANAGER_PUB.Process_Transactions (
                                                 p_api_version      => '1.0'
                                                ,p_init_msg_list    => 'T'
                                                ,p_commit           => 'T'
                                                ,p_validation_level => 100
                                                ,x_return_status    => v_return_status
                                                ,x_msg_count        => v_msg_count
                                                ,x_msg_data         => v_msg_data
                                                ,x_trans_count      => v_trans_count
                                                ,p_table            => 1
                                                ,p_header_id        => v_transaction_interface_id
                                            );


    DBMS_OUTPUT.Put_Line ('v_return_status  ='|| v_return_status);
    DBMS_OUTPUT.Put_Line ('v_msg_data       ='|| v_msg_data);

    IF v_return_status = 'E' THEN
    
        FND_MSG_PUB.Count_and_Get (
                                     p_count     => v_msg_count
                                    ,p_data      => v_msg_data
                                    ,p_encoded   => FND_API.G_False
                                );
    END IF;

END;
/


SELECT transaction_set_id, subinventory_code, transfer_subinventory, organization_id,
transaction_date, transaction_id, transaction_quantity, transaction_uom, transaction_reference
, source_code, transfer_transaction_id, inventory_item_id
;
SELECT *
FROM MTL_MATERIAL_TRANSACTIONS  mt
   , mtl_transaction_types      mtt
WHERE 1=1
  and mt.transaction_type_id = mtt.transaction_type_id
  and mtt.transaction_type_id = 2           --2=Subinventory Transfer
  AND mt.parent_transaction_id IS NULL 
  AND mt.transaction_action_id != 24
  and mt.subinventory_code is not null
  and mt.transfer_subinventory is not null
  and mt.transaction_id = (
                        --La transferencia de subinventario genera 2 registros
                        --El 1ro corresponde al movimiento origen, y el 2do es generado por EBS en automático.
                        --este query devuelve la 1ra transacción.
                        SELECT  min(transaction_id)
                        FROM mtl_material_transactions
                        WHERE transaction_set_id = mt.transaction_set_id
                        )
  AND mt.organization_id = 422 
  AND mt.inventory_item_id = 111180
  AND ( mt.transaction_date BETWEEN TO_DATE('29-07-2022 00:00:00', 'DD-MM-YYYY HH24:MI:SS') 
                                AND TO_DATE('29-07-2022 23:59:59', 'DD-MM-YYYY HH24:MI:SS') )
;

select *
from mtl_transaction_details_v
where transaction_id = 703207809
;

select *
from mtl_transaction_types
where transaction_type_id= 2;

SELECT *
FROM MTL_SYSTEM_ITEMS_B
;