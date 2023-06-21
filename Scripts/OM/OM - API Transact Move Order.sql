SET SERVEROUTPUT ON

-- Transact Move Order
--DOC ID 861453.1
--

DECLARE
vMoveOrderLineId      NUMBER(10) := 732509;      
p_pick_conf_qty       NUMBER(3) := 1;
pStatus               VARCHAR2 (100);
pMsgData              VARCHAR2 (4000);
v_movehdr_rec         INV_MOVE_ORDER_PUB.TROHDR_REC_TYPE;
v_movehdr_val_rec     INV_MOVE_ORDER_PUB.TROHDR_VAL_REC_TYPE;
v_moveln_tbl          INV_MOVE_ORDER_PUB.TROLIN_TBL_TYPE;
v_moveln_tbl_p        INV_MOVE_ORDER_PUB.TROLIN_TBL_TYPE;
v_moveln_zero_tbl     INV_MOVE_ORDER_PUB.TROLIN_TBL_TYPE;
v_moveln_zero_tbl_p   INV_MOVE_ORDER_PUB.TROLIN_TBL_TYPE;
v_moveln_tbl_d        INV_MOVE_ORDER_PUB.TROLIN_TBL_TYPE;
v_moveln_tbl_o        INV_MOVE_ORDER_PUB.TROLIN_TBL_TYPE;
v_moveln_val_tbl      INV_MOVE_ORDER_PUB.TROLIN_VAL_TBL_TYPE;
v_mold_tbl            INV_MO_LINE_DETAIL_UTIL.G_MMTT_TBL_TYPE;
v_mold_tbl_p          INV_MO_LINE_DETAIL_UTIL.G_MMTT_TBL_TYPE;
l_mold_tbl            INV_MO_LINE_DETAIL_UTIL.G_MMTT_TBL_TYPE;
l_moveln_tbl          INV_MOVE_ORDER_PUB.TROLIN_TBL_TYPE;
l_trolin_rec          INV_MOVE_ORDER_PUB.TROLIN_REC_TYPE;
l_trolin_tbl          INV_MOVE_ORDER_PUB.TROLIN_TBL_TYPE;
l_return_status       VARCHAR2 (240);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2 (2000);
l_move_hdr_id         NUMBER;
l_move_order_no       NUMBER := 0;
v_return_values       VARCHAR2 (2000) := FND_API.G_TRUE;
v_move_hdr_rec        INV_MOVE_ORDER_PUB.TROHDR_REC_TYPE;
v_move_hdr_val_rec    INV_MOVE_ORDER_PUB.TROHDR_VAL_REC_TYPE;
v_api_pick_confirm    NUMBER;
cv_fail               VARCHAR2 (100) := 'Fail';
cv_success            VARCHAR2 (100) := 'Success';

CURSOR c_mmtt_recs (vMoveOrderLineId NUMBER)
   IS
    SELECT *
    FROM MTL_MATERIAL_TRANSACTIONS_TEMP
    WHERE move_order_line_id = vMoveOrderLineId
    ;

REC                   C_MMTT_RECS%ROWTYPE;

l_moveln_fidx         NUMBER;
l_moveln_lidx         NUMBER;
n_mvln_cntr           NUMBER;
l_Index               NUMBER := 1;
v_records_in_mmtt     NUMBER := 0;
l_user_id             NUMBER;
l_resp_id             NUMBER;
l_appl_id             NUMBER;
i                     NUMBER(5) :=0 ;

BEGIN

 
   SELECT user_id
     INTO l_user_id
     FROM fnd_user
    WHERE user_name = 'H808091';

   SELECT responsibility_id, application_id
     INTO l_resp_id, l_appl_id
     FROM fnd_responsibility_vl
    WHERE responsibility_name = 'Inventory';


   DBMS_OUTPUT.put_line ('l_resp_id - ' || l_resp_id);
   DBMS_OUTPUT.put_line ('l_appl_id - ' || l_appl_id);
   DBMS_OUTPUT.put_line ('l_user_id - ' || l_user_id);
 
   fnd_global.apps_initialize (l_user_id, l_resp_id, l_appl_id);


   SELECT COUNT (move_order_line_id)
     INTO v_records_in_mmtt
     FROM MTL_MATERIAL_TRANSACTIONS_TEMP
    WHERE move_order_line_id = vMoveOrderLineId;

DBMS_OUTPUT.PUT_LINE (
            'Records in MMTT for move_order_line_id = '
         || v_records_in_mmtt);

    SELECT mtrh.header_id, mtrh.request_number
     INTO l_move_hdr_id, l_move_order_no
     FROM mtl_txn_request_headers mtrh
        , mtl_txn_request_lines mtrl
    WHERE mtrh.header_id = mtrl.header_id 
      AND mtrl.line_id = vMoveOrderLineId;

   DBMS_OUTPUT.PUT_LINE (
         'Obtained MTRH.HEADER_ID = '
      || l_move_hdr_id
      || ' MTRH.REQUEST_NUMBER = '
      || l_move_order_no
      || ' for move_order_line_id = '
      || vMoveOrderLineId);

   i := 1;

   OPEN c_mmtt_recs (vMoveOrderLineId);

   LOOP
      FETCH c_mmtt_recs INTO rec;

      EXIT WHEN c_mmtt_recs%NOTFOUND;

      v_mold_tbl (1).transaction_header_id  := rec.transaction_header_id;
      v_mold_tbl (1).transaction_temp_id    := rec.transaction_temp_id;
      v_mold_tbl (1).source_code            := rec.source_code;
      v_mold_tbl (1).source_line_id         := rec.source_line_id;
      v_mold_tbl (1).transaction_mode       := rec.transaction_mode;
      v_mold_tbl (1).lock_flag              := rec.lock_flag;
      v_mold_tbl (1).last_update_date       := rec.last_update_date;
      v_mold_tbl (1).last_updated_by        := rec.last_updated_by;
      v_mold_tbl (1).creation_date          := rec.creation_date;
      v_mold_tbl (1).created_by             := rec.created_by;
      v_mold_tbl (1).last_update_login      := rec.last_update_login;
      v_mold_tbl (1).request_id             := rec.request_id;
      v_mold_tbl (1).program_application_id := rec.program_application_id;
      v_mold_tbl (1).program_id             := rec.program_id;
      v_mold_tbl (1).program_update_date    := rec.program_update_date;
      v_mold_tbl (1).inventory_item_id      := rec.inventory_item_id;
      v_mold_tbl (1).revision               := rec.revision;
      v_mold_tbl (1).organization_id        := rec.organization_id;
      v_mold_tbl (1).subinventory_code      := rec.subinventory_code;
      v_mold_tbl (1).locator_id             := rec.locator_id;
      v_mold_tbl (1).transaction_quantity   := rec.transaction_quantity;
      v_mold_tbl (1).primary_quantity       := rec.primary_quantity;
      v_mold_tbl (1).transaction_uom        := rec.transaction_uom;
      v_mold_tbl (1).transaction_cost       := rec.transaction_cost;
      v_mold_tbl (1).transaction_type_id    := rec.transaction_type_id;
      v_mold_tbl (1).transaction_action_id      := rec.transaction_action_id;
      v_mold_tbl (1).transaction_source_type_id := rec.transaction_source_type_id;
      v_mold_tbl (1).transaction_source_id      := rec.transaction_source_id;
      v_mold_tbl (1).transaction_source_name    := rec.transaction_source_name;
      v_mold_tbl (1).transaction_date           := rec.transaction_date;
      v_mold_tbl (1).acct_period_id             := rec.acct_period_id;
      v_mold_tbl (1).distribution_account_id    := rec.distribution_account_id;
      v_mold_tbl (1).transaction_reference      := rec.transaction_reference;
      v_mold_tbl (1).requisition_line_id        := rec.requisition_line_id;
      v_mold_tbl (1).requisition_distribution_id:= rec.requisition_distribution_id;
      v_mold_tbl (1).reason_id                  := rec.reason_id;
      v_mold_tbl (1).lot_number                 := rec.lot_number;
      v_mold_tbl (1).lot_expiration_date        := rec.lot_expiration_date;
      v_mold_tbl (1).serial_number := rec.serial_number;
      v_mold_tbl (1).receiving_document := rec.receiving_document;
      v_mold_tbl (1).demand_id := rec.demand_id;
      v_mold_tbl (1).rcv_transaction_id := rec.rcv_transaction_id;
      v_mold_tbl (1).move_transaction_id := rec.move_transaction_id;
      v_mold_tbl (1).completion_transaction_id := rec.completion_transaction_id;
      v_mold_tbl (1).wip_entity_type := rec.wip_entity_type;
      v_mold_tbl (1).schedule_id := rec.schedule_id;
      v_mold_tbl (1).repetitive_line_id := rec.repetitive_line_id;
      v_mold_tbl (1).employee_code := rec.employee_code;
      v_mold_tbl (1).primary_switch := rec.primary_switch;
      v_mold_tbl (1).schedule_update_code := rec.schedule_update_code;
      v_mold_tbl (1).setup_teardown_code := rec.setup_teardown_code;
      v_mold_tbl (1).item_ordering := rec.item_ordering;
      v_mold_tbl (1).negative_req_flag := rec.negative_req_flag;
      v_mold_tbl (1).operation_seq_num := rec.operation_seq_num;
      v_mold_tbl (1).picking_line_id := rec.picking_line_id;
      v_mold_tbl (1).trx_source_line_id := rec.trx_source_line_id;
      v_mold_tbl (1).trx_source_delivery_id := rec.trx_source_delivery_id;
      v_mold_tbl (1).physical_adjustment_id := rec.physical_adjustment_id;
      v_mold_tbl (1).cycle_count_id := rec.cycle_count_id;
      v_mold_tbl (1).rma_line_id := rec.rma_line_id;
      v_mold_tbl (1).customer_ship_id := rec.customer_ship_id;
      v_mold_tbl (1).currency_code := rec.currency_code;
      v_mold_tbl (1).currency_conversion_rate := rec.currency_conversion_rate;
      v_mold_tbl (1).currency_conversion_type := rec.currency_conversion_type;
      v_mold_tbl (1).currency_conversion_date := rec.currency_conversion_date;
      v_mold_tbl (1).ussgl_transaction_code := rec.ussgl_transaction_code;
      v_mold_tbl (1).vendor_lot_number := rec.vendor_lot_number;
      v_mold_tbl (1).encumbrance_account := rec.encumbrance_account;
      v_mold_tbl (1).encumbrance_amount := rec.encumbrance_amount;
      v_mold_tbl (1).ship_to_location := rec.ship_to_location;
      v_mold_tbl (1).shipment_number := rec.shipment_number;
      v_mold_tbl (1).transfer_cost := rec.transfer_cost;
      v_mold_tbl (1).transportation_cost := rec.transportation_cost;
      v_mold_tbl (1).transportation_account := rec.transportation_account;
      v_mold_tbl (1).freight_code := rec.freight_code;
      v_mold_tbl (1).containers := rec.containers;
      v_mold_tbl (1).waybill_airbill := rec.waybill_airbill;
      v_mold_tbl (1).expected_arrival_date := rec.expected_arrival_date;
      v_mold_tbl (1).transfer_subinventory := rec.transfer_subinventory;
      v_mold_tbl (1).transfer_organization := rec.transfer_organization;
      v_mold_tbl (1).transfer_to_location := rec.transfer_to_location;
      v_mold_tbl (1).new_average_cost := rec.new_average_cost;
      v_mold_tbl (1).value_change := rec.value_change;
      v_mold_tbl (1).percentage_change := rec.percentage_change;
      v_mold_tbl (1).material_allocation_temp_id := rec.material_allocation_temp_id;
      v_mold_tbl (1).demand_source_header_id := rec.demand_source_header_id;
      v_mold_tbl (1).demand_source_line := rec.demand_source_line;
      v_mold_tbl (1).demand_source_delivery := rec.demand_source_delivery;
      v_mold_tbl (1).item_segments := rec.item_segments;
      v_mold_tbl (1).item_description := rec.item_description;
      v_mold_tbl (1).item_trx_enabled_flag := rec.item_trx_enabled_flag;
      v_mold_tbl (1).item_location_control_code :=     rec.item_location_control_code;
      v_mold_tbl (1).item_restrict_subinv_code :=      rec.item_restrict_subinv_code;
      v_mold_tbl (1).item_restrict_locators_code :=    rec.item_restrict_locators_code;
      v_mold_tbl (1).item_revision_qty_control_code := rec.item_revision_qty_control_code;
      v_mold_tbl (1).item_primary_uom_code := rec.item_primary_uom_code;
      v_mold_tbl (1).item_uom_class := rec.item_uom_class;
      v_mold_tbl (1).item_shelf_life_code := rec.item_shelf_life_code;
      v_mold_tbl (1).item_shelf_life_days := rec.item_shelf_life_days;
      v_mold_tbl (1).item_lot_control_code := rec.item_lot_control_code;
      v_mold_tbl (1).item_serial_control_code := rec.item_serial_control_code;
      v_mold_tbl (1).item_inventory_asset_flag :=      rec.item_inventory_asset_flag;
      v_mold_tbl (1).allowed_units_lookup_code :=      rec.allowed_units_lookup_code;
      v_mold_tbl (1).department_id := rec.department_id;
      v_mold_tbl (1).department_code := rec.department_code;
      v_mold_tbl (1).wip_supply_type := rec.wip_supply_type;
      v_mold_tbl (1).supply_subinventory := rec.supply_subinventory;
      v_mold_tbl (1).supply_locator_id := rec.supply_locator_id;
      v_mold_tbl (1).valid_subinventory_flag := rec.valid_subinventory_flag;
      v_mold_tbl (1).valid_locator_flag := rec.valid_locator_flag;
      v_mold_tbl (1).locator_segments := rec.locator_segments;
      v_mold_tbl (1).current_locator_control_code :=         rec.current_locator_control_code;
      v_mold_tbl (1).number_of_lots_entered := rec.number_of_lots_entered;
      v_mold_tbl (1).wip_commit_flag := rec.wip_commit_flag;
      v_mold_tbl (1).next_lot_number := rec.next_lot_number;
      v_mold_tbl (1).lot_alpha_prefix := rec.lot_alpha_prefix;
      v_mold_tbl (1).next_serial_number := rec.next_serial_number;
      v_mold_tbl (1).serial_alpha_prefix := rec.serial_alpha_prefix;
      v_mold_tbl (1).shippable_flag := rec.shippable_flag;
      v_mold_tbl (1).posting_flag := rec.posting_flag;
      v_mold_tbl (1).required_flag := rec.required_flag;
      v_mold_tbl (1).process_flag := rec.process_flag;
      v_mold_tbl (1).ERROR_CODE := rec.ERROR_CODE;
      v_mold_tbl (1).error_explanation := rec.error_explanation;
      v_mold_tbl (1).attribute_category := rec.attribute_category;
      v_mold_tbl (1).attribute1 := rec.attribute1;
      v_mold_tbl (1).attribute2 := rec.attribute2;
      v_mold_tbl (1).attribute3 := rec.attribute3;
      v_mold_tbl (1).attribute4 := rec.attribute4;
      v_mold_tbl (1).attribute5 := rec.attribute5;
      v_mold_tbl (1).attribute6 := rec.attribute6;
      v_mold_tbl (1).attribute7 := rec.attribute7;
      v_mold_tbl (1).attribute8 := rec.attribute8;
      v_mold_tbl (1).attribute9 := rec.attribute9;
      v_mold_tbl (1).attribute10 := rec.attribute10;
      v_mold_tbl (1).attribute11 := rec.attribute11;
      v_mold_tbl (1).attribute12 := rec.attribute12;
      v_mold_tbl (1).attribute13 := rec.attribute13;
      v_mold_tbl (1).attribute14 := rec.attribute14;
      v_mold_tbl (1).attribute15 := rec.attribute15;
      v_mold_tbl (1).movement_id := rec.movement_id;
      v_mold_tbl (1).reservation_quantity := rec.reservation_quantity;
      v_mold_tbl (1).shipped_quantity := rec.shipped_quantity;
      v_mold_tbl (1).transaction_line_number := rec.transaction_line_number;
      v_mold_tbl (1).task_id := rec.task_id;
      v_mold_tbl (1).to_task_id := rec.to_task_id;
      v_mold_tbl (1).source_task_id := rec.source_task_id;
      v_mold_tbl (1).project_id := rec.project_id;
      v_mold_tbl (1).source_project_id := rec.source_project_id;
      v_mold_tbl (1).pa_expenditure_org_id := rec.pa_expenditure_org_id;
      v_mold_tbl (1).to_project_id := rec.to_project_id;
      v_mold_tbl (1).expenditure_type := rec.expenditure_type;
      v_mold_tbl (1).final_completion_flag := rec.final_completion_flag;
      v_mold_tbl (1).transfer_percentage := rec.transfer_percentage;
      v_mold_tbl (1).transaction_sequence_id := rec.transaction_sequence_id;
      v_mold_tbl (1).material_account := rec.material_account;
      v_mold_tbl (1).material_overhead_account :=         rec.material_overhead_account;
      v_mold_tbl (1).resource_account := rec.resource_account;
      v_mold_tbl (1).outside_processing_account :=         rec.outside_processing_account;
      v_mold_tbl (1).overhead_account := rec.overhead_account;
      v_mold_tbl (1).flow_schedule := rec.flow_schedule;
      v_mold_tbl (1).cost_group_id := rec.cost_group_id;
      v_mold_tbl (1).demand_class := rec.demand_class;
      v_mold_tbl (1).qa_collection_id := rec.qa_collection_id;
      v_mold_tbl (1).kanban_card_id := rec.kanban_card_id;
      v_mold_tbl (1).overcompletion_transaction_id :=         rec.overcompletion_transaction_id;
      v_mold_tbl (1).overcompletion_primary_qty :=         rec.overcompletion_primary_qty;
      v_mold_tbl (1).overcompletion_transaction_qty :=         rec.overcompletion_transaction_qty;
      v_mold_tbl (1).end_item_unit_number := rec.end_item_unit_number;
      v_mold_tbl (1).scheduled_payback_date := rec.scheduled_payback_date;
      v_mold_tbl (1).line_type_code := rec.line_type_code;
      v_mold_tbl (1).parent_transaction_temp_id :=         rec.parent_transaction_temp_id;
      v_mold_tbl (1).put_away_strategy_id := rec.put_away_strategy_id;
      v_mold_tbl (1).put_away_rule_id := rec.put_away_rule_id;
      v_mold_tbl (1).pick_strategy_id := rec.pick_strategy_id;
      v_mold_tbl (1).pick_rule_id := rec.pick_rule_id;
      v_mold_tbl (1).common_bom_seq_id := rec.common_bom_seq_id;
      v_mold_tbl (1).common_routing_seq_id := rec.common_routing_seq_id;
      v_mold_tbl (1).cost_type_id := rec.cost_type_id;
      v_mold_tbl (1).org_cost_group_id := rec.org_cost_group_id;
      v_mold_tbl (1).move_order_line_id := rec.move_order_line_id;
      v_mold_tbl (1).task_group_id := rec.task_group_id;
      v_mold_tbl (1).pick_slip_number := rec.pick_slip_number;
      v_mold_tbl (1).reservation_id := rec.reservation_id;
      v_mold_tbl (1).transaction_status := rec.transaction_status;
      v_mold_tbl (1).transfer_cost_group_id := rec.transfer_cost_group_id;
      v_mold_tbl (1).lpn_id := rec.lpn_id;
      v_mold_tbl (1).transfer_lpn_id := rec.lpn_id; --381411;--rec.transfer_lpn_id               ;
      v_mold_tbl (1).pick_slip_date := rec.pick_slip_date;
      v_mold_tbl (1).content_lpn_id := rec.content_lpn_id;

 

      DBMS_OUTPUT.PUT_LINE ( i||')'||rec.transaction_temp_id);

 

      INV_PICK_WAVE_PICK_CONFIRM_PUB.Pick_Confirm    (
                  p_api_version_number => 1.0
                  , p_init_msg_list      => FND_API.G_FALSE
                  , p_commit             => FND_API.G_FALSE
                  , x_return_status      => l_return_status
                  , x_msg_count          => l_msg_count
                  , x_msg_data           => l_msg_data
                  , p_move_order_type    => 3               -- PickWave - Order
                  , p_transaction_mode   => 1               -- 1:On-Line, 2:Concurrent, 3:Background
                  , p_trolin_tbl         => v_moveln_tbl_d
                  , p_mold_tbl           => v_mold_tbl
                  , x_mmtt_tbl           => v_mold_tbl
                  , x_trolin_tbl         => v_moveln_tbl_o
                  , p_transaction_date   => SYSDATE
                );

   DBMS_OUTPUT.PUT_LINE (
         'Return status of INV_PICK_WAVE_PICK_CONFIRM_PUB.PICK_CONFIRM  = '
      || l_return_status);

   IF l_return_status != FND_API.G_RET_STS_SUCCESS
   THEN
      pStatus := cv_fail;
      pMsgData :=
            'Failed to pick confirm move order inv_pick_wave_pick_confirm_pub.pick_confirm for MOVE_ORDER_LINE_ID : '
         || vMoveOrderLineId;
   END IF;
 
 
   DBMS_OUTPUT.put_line (
      '=======================================================');
   DBMS_OUTPUT.put_line (l_return_status);
   DBMS_OUTPUT.put_line (l_msg_data);
   DBMS_OUTPUT.put_line (l_msg_count);


   IF (l_return_status <> fnd_api.g_ret_sts_success)
   THEN
      DBMS_OUTPUT.put_line (l_msg_data);
   END IF;

   v_api_pick_confirm := 1;
 
   DBMS_OUTPUT.put_line (
      'Status of the Pick Confirm is : ' || l_return_status);

    i := i + 1;
   END LOOP;

   CLOSE c_mmtt_recs;

EXCEPTION
WHEN OTHERS
THEN
   DBMS_OUTPUT.put_line ('Exception - '||SQLERRM||SQLCODE);
END;
/
