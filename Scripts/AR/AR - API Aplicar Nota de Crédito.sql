SET SERVEROUTPUT ON

DECLARE

p_customer_trx_id   NUMBER(15) := 3570475;
p_org_id            number(15) := 85;

cursor c_invoice (p_trx_id number)
is
   SELECT ct.trx_number
       , ct.customer_trx_id
       , ct.attribute1
       , ct.attribute3
       , ct.attribute7
       , ct.attribute10
       , ct.attribute11
       , ct.attribute12   
       , bs.NAME                    source_name       
       , bs.auto_trx_numbering_flag trx_num_flag
       , bs.accounting_rule_rule    accnt_rule
       , ctl.customer_trx_line_id
       , ctl.quantity_invoiced
       , ctl.unit_selling_price   
      FROM  ra_customer_trx_all         ct,
            ra_customer_trx_lines_all   ctl,
            ra_batch_sources_all         bs
      WHERE ct.customer_trx_id = ctl.customer_trx_id
        and ct.batch_source_id = bs.batch_source_id
      --AND    ct.trx_number = p_trx_number
        AND ctl.line_type = 'LINE'
        and ct.customer_trx_id = p_trx_id
      ;


v_msg_count     NUMBER(15);
v_msg_data      VARCHAR2 (2000);
v_return_status VARCHAR2 (1);
v_request_id    NUMBER(15);
v_attr          arw_cmreq_cover.pq_attribute_rec_type;
v_lines         arw_cmreq_cover.Cm_Line_Tbl_Type_Cover;

v_source_name   varchar2(100):= 'x';
v_trx_num_flag  varchar2(1)  := 'x';
v_trx_number    VARCHAR2(100):= 'x';
v_method_rule   varchar2(20) := 'x';

v_nc_monto      number(15,4) := 0;
v_reg           number(15)   := 0;
v_req_id        number(15);

BEGIN

    mo_global.init('AR');
    mo_global.set_policy_context('S',p_org_id); -- S for single Operating Unit and M for multiple Operating Unit

    fnd_global.apps_initialize( user_id => 1134,
                                        resp_id => 50834,
                                        resp_appl_id  => 222
                                        ); 
                                        
    dbms_application_info.set_client_info(p_org_id); 

    v_nc_monto  := 0;
    v_reg       := 0;
    
    for inv in c_invoice (p_customer_trx_id) loop
    
        v_reg := v_reg + 1;
        
        -- Datos de las Lineas
        v_lines(v_reg).customer_trx_line_id := inv.customer_trx_line_id;
        v_lines(v_reg).quantity_credited    := inv.quantity_invoiced * -1;
        v_lines(v_reg).price                := inv.unit_selling_price;
        v_lines(v_reg).extended_amount      := inv.quantity_invoiced * inv.unit_selling_price * -1;
        
        v_nc_monto := v_nc_monto + inv.quantity_invoiced * inv.unit_selling_price * -1;

        -- Datos de la Cabecera
        v_attr.attribute1  := inv.attribute1;   -- UUID de la Factura
        v_attr.attribute3  := inv.attribute3;   -- Orden Facturacion
        v_attr.attribute7  := inv.attribute7;   -- Forma de Pago
        v_attr.attribute10 := inv.attribute10;  -- Metodo Pago
        v_attr.attribute11 := inv.attribute11;  -- Uso CFDI
        v_attr.attribute12 := 'Cancelar';    
        
        v_trx_num_flag     := inv.trx_num_flag;
        v_source_name      := inv.source_name;
        
        if v_trx_num_flag = 'N' then
            v_trx_number := inv.trx_number;
        else -- Y
            -- El source está configurado como Autonumérico.
            v_trx_number := null; 
        end if;        
        
        -- si el SOURCE está configurado como AutoAccounting
        IF inv.accnt_rule IS NOT NULL THEN
            v_method_rule := 'PRORATE';
        ELSE
            v_method_rule := null;
        end if;
        
    end loop;
    
    --bolinf.GRP_DBMS_PIPE.SET_Message ('DEBUG', 'API 01- '|| v_trx_num_flag ||' '||v_trx_number );
    
    
    ar_credit_memo_api_pub.CREATE_REQUEST (
                             -- standard api parameters
                           p_api_version                     => 1.0,
                           p_init_msg_list                   => fnd_api.g_true,
                           p_commit                          => fnd_api.g_false,
                           x_return_status                   => v_return_status,
                           x_msg_count                       => v_msg_count,
                           x_msg_data                        => v_msg_data,
                            -- credit memo request parameters
                           p_customer_trx_id                 => p_customer_trx_id,
                           p_line_credit_flag                => 'N',
                           p_line_amount                     => v_nc_monto,
                           p_tax_amount                      => 0,
                           p_cm_reason_code                  => 'CANCELLATION', --'RETURN',
                           p_skip_workflow_flag              => 'Y',
                           p_batch_source_name               => v_source_name,
                           p_trx_number                      => v_trx_number,
                           p_attribute_rec                   => v_attr,                           
                          -- p_cm_line_tbl                     => v_lines,
                           p_org_id                          => p_org_id,
                           p_credit_method_installments      => NULL,
                           p_credit_method_rules             => v_method_rule, --VALUE, PRORATE, NULL
                           x_request_id                      => v_req_id, 
                           p_comments                        => 'Cancela el UUID',
                           p_internal_comment                => 'Creado por API'
                          );
                                      
                                  

    IF v_return_status <> 'S' THEN
        FOR I IN 1..nvl(v_msg_count,1) LOOP
          v_msg_data := v_msg_data || ' (' || to_char(I) ||')'||
                           substr(fnd_msg_pub.get (fnd_msg_pub.g_next, fnd_api.g_false),1,300 );
         END LOOP;         
    end if;
    
    --bolinf.GRP_DBMS_PIPE.SET_Message ('DEBUG', 'API 02- '|| v_msg_data );
    
    IF    v_return_status = fnd_api.g_ret_sts_unexp_error
       OR v_return_status = fnd_api.g_ret_sts_error
    THEN
        DBMS_OUTPUT.put_line ('error: ' || v_return_status);
        DBMS_OUTPUT.put_line ('error: ' ||v_msg_data);
        rollback;
    ELSE        
        DBMS_OUTPUT.put_line ('bien!');
    END IF;    


END;