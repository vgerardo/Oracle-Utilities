SET SERVEROUTPUT ON

DECLARE
l_return_status     varchar2(1);
l_msg_count         number (15);
l_msg_data          varchar2(2000);
l_batch_id          number (15);  
l_cnt               number(15):= 0;
l_customer_trx_id   number(15);

l_batch_source_rec      ar_invoice_api_pub.batch_source_rec_type;
l_trx_header_tbl        ar_invoice_api_pub.trx_header_tbl_type;
l_trx_lines_tbl         ar_invoice_api_pub.trx_line_tbl_type;
l_trx_dist_tbl          ar_invoice_api_pub.trx_dist_tbl_type;
l_trx_salescredits_tbl  ar_invoice_api_pub.trx_salescredits_tbl_type;
v_errores_tbl            arp_trx_validate.Message_Tbl_Type;

BEGIN

--dbms_application_info.set_client_info() 
--ARP_GLOBAL.INIT_GLOBAL
--ARP_STANDARD.INIT_STANDARD

    fnd_global.apps_initialize (  
                            user_id     => 1671,    -- CONE-RBORES 
                            resp_id     => 50834,   -- GRP_ALL_AR_CONE_GTE 
                            resp_appl_id => 222     -- AR
                        );

    MO_GLOBAL.set_policy_context('S',85);

    --
    -- HEADER information
    --
    SELECT RA_CUSTOMER_TRX_S.NEXTVAL
    into l_trx_header_tbl(1).trx_header_id 
    FROM DUAL;
  
    -- El TRX_NUMBER se pobla cuando el ORIGEN está configurado como NO Automático.
    -- Cuano es Automático, el API creará un número consecutivo, así que NO debe poblarse.
    --l_trx_header_tbl(1).trx_number := 'GVP-201704-001';
    l_trx_header_tbl(1).bill_to_customer_id := 130293;
    l_trx_header_tbl(1).cust_trx_type_id    := 4000;   -- RA_CUST_TRX_TYPES_ALL  GPO_0501_FAC                
                        
    -- Batch information                        
    l_batch_source_rec.batch_source_id      := 1010;  -- depende de la organización RA_BATCH_SOURCES_ALL

    --
    -- First line
    --
    l_trx_lines_tbl(1).trx_header_id := l_trx_header_tbl(1).trx_header_id ;
     
    SELECT RA_CUSTOMER_TRX_LINES_S.NEXTVAL
    INTO l_trx_lines_tbl(1).trx_line_id
    FROM DUAL;
    
    l_trx_lines_tbl(1).line_number          := 1;
    l_trx_lines_tbl(1).memo_line_id         := 2755;     -- tabla AR_MEMO_LINES_ALL_TL
    l_trx_lines_tbl(1).quantity_invoiced    := 10;
    l_trx_lines_tbl(1).unit_selling_price   := 12;
    l_trx_lines_tbl(1).line_type            := 'LINE';
  
    -- second line--l_trx_lines_tbl(2).trx_header_id := l_trx_header_tbl(1).trx_header_id ;

--    SELECT RA_CUSTOMER_TRX_LINES_S.NEXTVAL
--    INTO l_trx_lines_tbl(2).trx_line_id
--    FROM DUAL;
--    
--    l_trx_lines_tbl(2).line_number := 2;
--    l_trx_lines_tbl(2).description := 'Test sin memoline';
--    l_trx_lines_tbl(2).quantity_invoiced := 12;
--    l_trx_lines_tbl(2).unit_selling_price := 12;
--    l_trx_lines_tbl(2).line_type := 'LINE';
  
  
    AR_INVOICE_API_PUB.create_single_invoice(
            p_api_version           => 1.0,
            p_batch_source_rec      => l_batch_source_rec,
            p_trx_header_tbl        => l_trx_header_tbl,
            p_trx_lines_tbl         => l_trx_lines_tbl,
            p_trx_dist_tbl          => l_trx_dist_tbl,
            p_trx_salescredits_tbl  => l_trx_salescredits_tbl,
            x_customer_trx_id       => l_customer_trx_id,
            x_return_status         => l_return_status,
            x_msg_count             => l_msg_count,
            x_msg_data              => l_msg_data
        ); 
        
        /*
 AR_INVOICE_API_PUB.Delete_Transaction(
     p_api_name           => 'AR_INVOICE_API_PUB',
     p_api_version        => 1.0,
     p_init_msg_list      => FND_API.G_FALSE,
     p_commit             => FND_API.G_TRUE,
     --p_validation_level          IN  varchar2 := FND_API.G_VALID_LEVEL_FULL,
     p_customer_trx_id    => 3563315,
     p_return_status      => l_return_status,
     p_msg_count          =>   l_msg_count,
     p_msg_data           => l_msg_data,
     p_errors             => v_errores_tbl
     );        */

    dbms_output.put_line('x_return_status = '||SubStr(l_return_status,1,255));
    dbms_output.put_line('x_msg_count = '||TO_CHAR(l_msg_count));
    dbms_output.put_line('x_customer_trx_id=' || l_customer_trx_id);

    IF l_msg_count >1 THEN
        FOR I IN 1..l_msg_count
        LOOP
            dbms_output.put_line(I||'. '||SubStr(apps.FND_MSG_PUB.Get(p_encoded => apps.FND_API.G_FALSE ), 1, 255));
        END LOOP;
    END IF;

    
    
    
    SELECT count(*)
    Into      l_cnt
    From ar_trx_errors_gt
    WHERE trx_header_id = l_trx_header_tbl(1).trx_header_id
    ;
    
    IF l_cnt = 0
    THEN
        dbms_output.put_line ( 'Perfectirijillo! :)');     
    ELSE
        dbms_output.put_line ( 'Transaction not Created, Please check ar_trx_errors_gt table');     
        FOR i in (SELECT * FROM ar_trx_errors_gt 
                  WHERE trx_header_id = l_trx_header_tbl(1).trx_header_id
                  )
        LOOP          
            dbms_output.put_line (i.invalid_value || ': '||i.error_message);                  
        END LOOP;          
    END IF;
      
  commit;
END;
/

