SET SERVEROUTPUT ON 

DECLARE
l_api_version_number  NUMBER := 1;
l_return_status       VARCHAR2 (2000);
l_msg_count           NUMBER;
l_msg_data            VARCHAR2 (2000);

l_debug_level       NUMBER(15)  := 5;
l_org               number      := 82; --OPERATING UNIT
l_no_orders         number      := 1; -- NO OF ORDERS

-- INPUT VARIABLES FOR PROCESS_ORDER API
l_header_rec            oe_order_pub.header_rec_type;
l_line_tbl              oe_order_pub.line_tbl_type;
l_action_request_tbl    oe_order_pub.Request_Tbl_Type;

-- OUT VARIABLES FOR PROCESS_ORDER API
l_header_rec_out            oe_order_pub.header_rec_type;
l_header_val_rec_out        oe_order_pub.header_val_rec_type;
l_header_adj_tbl_out        oe_order_pub.header_adj_tbl_type;
l_header_adj_val_tbl_out    oe_order_pub.header_adj_val_tbl_type;
l_header_price_att_tbl_out  oe_order_pub.header_price_att_tbl_type;
l_header_adj_att_tbl_out    oe_order_pub.header_adj_att_tbl_type;
l_header_adj_assoc_tbl_out  oe_order_pub.header_adj_assoc_tbl_type;
l_header_scredit_tbl_out    oe_order_pub.header_scredit_tbl_type;
l_header_scredit_val_tbl_out oe_order_pub.header_scredit_val_tbl_type;
l_line_tbl_out              oe_order_pub.line_tbl_type;
l_line_val_tbl_out          oe_order_pub.line_val_tbl_type;
l_line_adj_tbl_out          oe_order_pub.line_adj_tbl_type;
l_line_adj_val_tbl_out      oe_order_pub.line_adj_val_tbl_type;
l_line_price_att_tbl_out    oe_order_pub.line_price_att_tbl_type;
l_line_adj_att_tbl_out      oe_order_pub.line_adj_att_tbl_type;
l_line_adj_assoc_tbl_out    oe_order_pub.line_adj_assoc_tbl_type;
l_line_scredit_tbl_out      oe_order_pub.line_scredit_tbl_type;
l_line_scredit_val_tbl_out  oe_order_pub.line_scredit_val_tbl_type;
l_lot_serial_tbl_out        oe_order_pub.lot_serial_tbl_type;
l_lot_serial_val_tbl_out    oe_order_pub.lot_serial_val_tbl_type;
l_action_request_tbl_out    oe_order_pub.request_tbl_type;
l_msg_index     NUMBER;
l_data          VARCHAR2(2000);
l_loop_count    NUMBER;
l_debug_file    VARCHAR2(200);

BEGIN

    mo_global.init('ONT');
    
    -- INITIALIZE ENVIRONMENT
    fnd_global.apps_initialize (
            user_id         => 10865,   --H808091 (MX)=16776 (BR)=10865
            resp_id         => 51202,   --Order Management Super User (mx)=21623
            resp_appl_id    => 660      --
        );
    
    mo_global.set_policy_context ('S', l_org);
    oe_msg_pub.delete_msg;

    -- INITIALIZE DEBUG INFO
    IF (l_debug_level > 0) THEN
        l_debug_file := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
        oe_debug_pub.initialize;
        oe_debug_pub.setdebuglevel(l_debug_level);
        Oe_Msg_Pub.initialize;
    END IF;

    -- INITIALIZE ACTION REQUEST RECORD
    l_action_request_tbl(1) := OE_ORDER_PUB.G_MISS_REQUEST_REC;


    -- INITIALIZE LINE RECORD
    l_line_tbl(1) := OE_ORDER_PUB.G_MISS_LINE_REC;

    l_line_tbl(1).operation             := OE_GLOBALS.G_OPR_UPDATE; -- Mandatory Operation to Pass
   -- l_line_tbl(1).header_id             := 4849193;
    l_line_tbl(1).line_id               := 6742138;
    l_line_tbl(1).ordered_quantity      := 0;
    l_line_tbl(1).cancelled_flag        := 'Y';
    l_line_tbl(1).change_reason         := 1;   --1=Administrative Reason
    l_line_tbl(1).change_comments       := 'API - Prueba GVP';

    -- REQUIRED LINE DFF INFORMATIONS
    --l_line_tbl(1).attribute2        := '20.99998'; -- Gross Margin
    --l_line_tbl(1).attribute3        := '2.493288'; -- Business Cost
    --l_line_tbl(1).attribute10       := '1000'; -- Original Cust Requested Qty
    --l_line_tbl(1).attribute11       := '662.772'; -- Baseline Margin
    --l_line_tbl(1).attribute16       := 'DBP'; -- Buy Price Basis

    for i in 1..l_no_orders loop 
        -- CALLTO PROCESS ORDER API
        OE_ORDER_PUB.process_order(
                p_org_id                => l_org,
                p_operating_unit        => NULL,
                p_api_version_number    => l_api_version_number,
                p_header_rec            => l_header_rec,
                p_line_tbl              => l_line_tbl,
                p_action_request_tbl    => l_action_request_tbl,
                -- OUT variables
                x_header_rec            => l_header_rec_out,
                x_header_val_rec        => l_header_val_rec_out,
                x_header_adj_tbl        => l_header_adj_tbl_out,
                x_header_adj_val_tbl    => l_header_adj_val_tbl_out,
                x_header_price_att_tbl  => l_header_price_att_tbl_out,
                x_header_adj_att_tbl    => l_header_adj_att_tbl_out,
                x_header_adj_assoc_tbl  => l_header_adj_assoc_tbl_out,
                x_header_scredit_tbl    => l_header_scredit_tbl_out,
                x_header_scredit_val_tbl=> l_header_scredit_val_tbl_out,
                x_line_tbl              => l_line_tbl_out,
                x_line_val_tbl          => l_line_val_tbl_out,
                x_line_adj_tbl          => l_line_adj_tbl_out,
                x_line_adj_val_tbl      => l_line_adj_val_tbl_out,
                x_line_price_att_tbl    => l_line_price_att_tbl_out,
                x_line_adj_att_tbl      => l_line_adj_att_tbl_out,
                x_line_adj_assoc_tbl    => l_line_adj_assoc_tbl_out,
                x_line_scredit_tbl      => l_line_scredit_tbl_out,
                x_line_scredit_val_tbl  => l_line_scredit_val_tbl_out,
                x_lot_serial_tbl        => l_lot_serial_tbl_out,
                x_lot_serial_val_tbl    => l_lot_serial_val_tbl_out,
                x_action_request_tbl    => l_action_request_tbl_out,
                x_return_status         => l_return_status,
                x_msg_count             => l_msg_count,
                x_msg_data              => l_msg_data
            );
        
    -- CHECK RETURN STATUS
    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF (l_debug_level > 0) THEN
            DBMS_OUTPUT.PUT_LINE('Sales Order Line SUCCESSFULLY CANCELED');
        END IF;
        COMMIT;
    ELSE
        IF (l_debug_level > 0) THEN
            DBMS_OUTPUT.PUT_LINE('FAILED to CANCEL Sales Order Line');
        END IF;
        ROLLBACK;
    END IF;
END LOOP;

-- DISPLAY RETURN STATUS FLAGS
if (l_debug_level > 0) then
    DBMS_OUTPUT.PUT_LINE('Process Order Return Status is: ======> ' || l_return_status);
    DBMS_OUTPUT.PUT_LINE('Process Order msg data is: ===========> ' || l_msg_data);
    DBMS_OUTPUT.PUT_LINE('Process Order Message Count is:=======> ' || l_msg_count);
    DBMS_OUTPUT.PUT_LINE('Sales Order Canceled is:==============> ' || to_char(l_header_rec_out.order_number));
    DBMS_OUTPUT.PUT_LINE('Booked Flag for the Sales Order is:===> ' || l_header_rec_out.booked_flag);
    DBMS_OUTPUT.PUT_LINE('Header_id for the Sales Order is:=====> ' || l_header_rec_out.header_id);
    DBMS_OUTPUT.PUT_LINE('Flow_Status For the Sales Order is:==>: ' || l_header_rec_out.flow_status_code);
END IF;

-- DISPLAY ERROR MSGS
IF (l_debug_level > 0) THEN
    FOR i IN 1 .. l_msg_count LOOP
        oe_msg_pub.get(
            p_msg_index => i
            ,p_encoded => Fnd_Api.G_FALSE
            ,p_data => l_data
            ,p_msg_index_out => l_msg_index);
            DBMS_OUTPUT.PUT_LINE('('||l_msg_index||') message is: ' || l_data);           
    END LOOP;
END IF;

IF (l_debug_level > 0) THEN
    DBMS_OUTPUT.PUT_LINE( 'Debug = ' ||OE_DEBUG_PUB.G_DEBUG);
    DBMS_OUTPUT.PUT_LINE( 'Debug Level = ' ||to_char(OE_DEBUG_PUB.G_DEBUG_LEVEL));
    DBMS_OUTPUT.PUT_LINE( 'Debug File = ' || oe_debug_pub.g_dir ||' / ' ||oe_debug_pub.g_file);
    OE_DEBUG_PUB.debug_off;
END IF;

END;

