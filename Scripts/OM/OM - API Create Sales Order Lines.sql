SET SERVEROUTPUT ON 
DECLARE

l_org_id               number(15)   := 82;
p_header_id            NUMBER(15)   := 1212902;
p_shipping_method_code VARCHAR2(50) := '000001_TONIATO SP_P_1111100';
p_unit_list_price      NUMBER       := 41.67; 
p_line_type_id         NUMBER(15)   := 1002;
p_ordered_quantity     NUMBER       := 1;
p_ship_from_org_id     NUMBER(15)   := 92;
p_return_reason_code   VARCHAR2(50);
p_line_id              NUMBER(15);
x_return_status        VARCHAR2(50);
x_message              VARCHAR2(500);
--
i               NUMBER := 0;
l_count         NUMBER;
l_msg_index_out NUMBER;
l_msg_data      VARCHAR2(4000);
l_msg_return    VARCHAR2(4000);
v_error         VARCHAR2(4000);
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;

--IN Variables API oe_order_pub.process_order --
l_header_rec                oe_order_pub.header_rec_type;
l_line_tbl                  oe_order_pub.line_tbl_type;
l_action_request_tbl        oe_order_pub.request_tbl_type;

-- OUT Variables API        oe_order_pub.process_order --
l_header_rec_out             oe_order_pub.header_rec_type;
l_header_val_rec_out         oe_order_pub.header_val_rec_type;
l_header_adj_tbl_out         oe_order_pub.header_adj_tbl_type;
l_header_adj_val_tbl_out     oe_order_pub.header_adj_val_tbl_type;
l_header_price_att_tbl_out   oe_order_pub.header_price_att_tbl_type;
l_header_adj_att_tbl_out     oe_order_pub.header_adj_att_tbl_type;
l_header_adj_assoc_tbl_out   oe_order_pub.header_adj_assoc_tbl_type;
l_header_scredit_tbl_out     oe_order_pub.header_scredit_tbl_type;
l_header_scredit_val_tbl_out oe_order_pub.header_scredit_val_tbl_type;

l_line_tbl_out               oe_order_pub.line_tbl_type;
l_line_val_tbl_out           oe_order_pub.line_val_tbl_type;
l_line_adj_tbl_out           oe_order_pub.line_adj_tbl_type;
l_line_adj_val_tbl_out       oe_order_pub.line_adj_val_tbl_type;
l_line_price_att_tbl_out     oe_order_pub.line_price_att_tbl_type;
l_line_adj_att_tbl_out       oe_order_pub.line_adj_att_tbl_type;
l_line_adj_assoc_tbl_out     oe_order_pub.line_adj_assoc_tbl_type;
l_line_scredit_tbl_out       oe_order_pub.line_scredit_tbl_type;
l_line_scredit_val_tbl_out   oe_order_pub.line_scredit_val_tbl_type;
l_lot_serial_tbl_out         oe_order_pub.lot_serial_tbl_type;
l_lot_serial_val_tbl_out     oe_order_pub.lot_serial_val_tbl_type;
l_action_request_tbl_out     oe_order_pub.request_tbl_type;
--
BEGIN
    --
    x_return_status := 'S';
    x_message       := NULL;
    --

    mo_global.init('ONT');
    
    -- INITIALIZE ENVIRONMENT
    fnd_global.apps_initialize (
            user_id         => 10865,   --H808091 (MX)=16776 (BR)=10865
            resp_id         => 51202,   --Order Management Super User (mx)=21623
            resp_appl_id    => 660      --
        );
    
    mo_global.set_policy_context ('S', l_org_id);
    oe_msg_pub.delete_msg;

    
    l_count := 0;
    l_header_rec := oe_order_pub.G_MISS_HEADER_REC;
    
    l_action_request_tbl(1) := oe_order_pub.G_MISS_REQUEST_REC;
    l_count := l_count + 1;
    l_line_tbl(l_count) := oe_order_pub.G_MISS_LINE_REC;
    
    -- Line Record --
    --REGISTROS DE LINHA
    l_line_tbl(l_count).operation           := oe_globals.G_OPR_CREATE;
    l_line_tbl(l_count).header_id           := 1051430;
    l_line_tbl(l_count).inventory_item_id   := 13525;
    l_line_tbl(l_count).ordered_quantity    := 2;
    l_line_tbl(l_count).unit_selling_price  := 56.89;
    --l_line_tbl(l_count).unit_list_price     := 56.89;
    l_line_tbl(l_count).ship_from_org_id    := 86;
    l_line_tbl(l_count).shipping_method_code:= '000001_ROLOFF_P_1111100' ;
    l_line_tbl(l_count).line_type_id        := 1081;
    l_line_tbl(l_count).return_reason_code  := 'RETURN';
    --
    
    OE_ORDER_PUB.process_order(p_api_version_number => 1.0
                              ,p_init_msg_list      => fnd_api.g_false
                              ,p_return_values      => fnd_api.g_false
                              ,p_action_commit      => fnd_api.g_false
                              ,x_return_status      => l_return_status
                              ,x_msg_count          => l_msg_count
                              ,x_msg_data           => l_msg_data
                              ,p_header_rec         => l_header_rec
                              ,p_line_tbl           => l_line_tbl
                              ,p_action_request_tbl => l_action_request_tbl
                               -- OUT PARAMETERS ,
                              ,x_header_rec             => l_header_rec_out
                              ,x_header_val_rec         => l_header_val_rec_out
                              ,x_header_adj_tbl         => l_header_adj_tbl_out
                              ,x_header_adj_val_tbl     => l_header_adj_val_tbl_out
                              ,x_header_price_att_tbl   => l_header_price_att_tbl_out
                              ,x_header_adj_att_tbl     => l_header_adj_att_tbl_out
                              ,x_header_adj_assoc_tbl   => l_header_adj_assoc_tbl_out
                              ,x_header_scredit_tbl     => l_header_scredit_tbl_out
                              ,x_header_scredit_val_tbl => l_header_scredit_val_tbl_out
                              ,x_line_tbl               => l_line_tbl_out
                              ,x_line_val_tbl           => l_line_val_tbl_out
                              ,x_line_adj_tbl           => l_line_adj_tbl_out
                              ,x_line_adj_val_tbl       => l_line_adj_val_tbl_out
                              ,x_line_price_att_tbl     => l_line_price_att_tbl_out
                              ,x_line_adj_att_tbl       => l_line_adj_att_tbl_out
                              ,x_line_adj_assoc_tbl     => l_line_adj_assoc_tbl_out
                              ,x_line_scredit_tbl       => l_line_scredit_tbl_out
                              ,x_line_scredit_val_tbl   => l_line_scredit_val_tbl_out
                              ,x_lot_serial_tbl         => l_lot_serial_tbl_out
                              ,x_lot_serial_val_tbl     => l_lot_serial_val_tbl_out
                              ,x_action_request_tbl     => l_action_request_tbl_out);
    
    
    FOR i IN 1 .. l_msg_count LOOP
      --
      oe_msg_pub.get(p_msg_index     => i
                    ,p_encoded       => fnd_api.g_false
                    ,p_data          => l_msg_data
                    ,p_msg_index_out => l_msg_index_out);
    END LOOP;
    
    -- Check the return status
    IF l_return_status = fnd_api.g_ret_sts_success THEN
      --
      x_return_status := 'S';
      x_message       := l_line_tbl_out(1).line_id;
      COMMIT;
    ELSE
      --
      IF l_msg_count > 0 THEN
        l_msg_return := 'OE_ORDER_PUB.PROCESS_ORDER ';
        FOR l_index IN 1 .. l_msg_count LOOP
          --
          l_msg_return := l_msg_return || ' - ' ||oe_msg_pub.get(p_msg_index => l_index,p_encoded   => 'F');
        END LOOP;
        --
      ELSE
        l_msg_return := l_msg_data;
      END IF;
      --
      x_message       := l_msg_return;
      x_return_status := 'E';
      --
    END IF;
    --
    
    DBMS_OUTPUT.put_line ('x_message = ' || x_message);
    
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'E';
      DBMS_OUTPUT.put_line ('   Erro ao criar o pedido para a Ordem: ' ||p_header_id || ' | ' || l_msg_return || '-' ||SQLERRM );
  END p_add_lines;
