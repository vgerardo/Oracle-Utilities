begin
fnd_global.APPS_INITIALIZE (user_id=>1134
                          , resp_id=>50834
                          , resp_appl_id=>222);
--dbms_session.SET_CONTEXT('multi_org','access_mode','A'); -- S=Single, M=Multiple, A=All, X=None
mo_global.INIT('AR');
mo_global.SET_POLICY_CONTEXT('S',644);
end;
/


--
-- busco los ID que usará el API
--
SELECT class, customer_trx_id, payment_schedule_id, trx_number
FROM ar_payment_schedules_all
WHERE 1=1
  and status  = 'OP'                    -- solo las transacciones Abiertas (Open)
  and invoice_currency_code = 'MXN'
  and class in ('CM', 'DM', 'INV')      --CM=Credit Memos  DM=Debit Memos  INV=Invoices 
  and org_id = 644
  AND trx_number in ('400160328093217120', '400160706153100001', '400160706153100002', '400160706153100003')  
  ;

  
DECLARE
    p_cm_customer_trx_id  NUMBER        := 1126603;  -- Notas de Credito
    p_inv_customer_trx_id NUMBER        := 1139763;  -- Notas de Debito, y Facturas
    p_org_id              NUMBER        := 644;
    
    p_mensaje             VARCHAR2 (1000);
    x_return_status       VARCHAR2 (50) ;
    x_msg_count           NUMBER (15) ;
    x_msg_data            VARCHAR2 (500) ;
    x_out_rec_application_id NUMBER (15) ;
    x_count               NUMBER (15) ;
    
    l_cm_app_rec         apps.ar_cm_api_pub.CM_APP_REC_TYPE;    
    x_acctd_amount_applied_from ar_receivable_applications.acctd_amount_applied_from%TYPE;
    x_acctd_amount_applied_to ar_receivable_applications.acctd_amount_applied_to%TYPE;    
    
BEGIN

    DBMS_OUTPUT.PUT_LINE ('Inicia API');

    l_cm_app_rec.cm_customer_trx_id     := p_cm_customer_trx_id;    
    l_cm_app_rec.inv_customer_trx_id    := p_inv_customer_trx_id;
    l_cm_app_rec.amount_applied         := -1;
    l_cm_app_rec.installment            := 1;
    l_cm_app_rec.apply_date             := sysdate;
    l_cm_app_rec.gl_date                := sysdate;
    l_cm_app_rec.comments               := 'Procedure: GRP_AR_APPLY_CM_PRC';
    
    apps.ar_cm_api_pub.APPLY_ON_ACCOUNT ( p_api_version => 1.0, 
                                          p_init_msg_list => FND_API.G_TRUE, 
                                          p_commit      => FND_API.G_FALSE, 
                                          p_cm_app_rec  => l_cm_app_rec, 
                                          p_org_id      => p_org_id, 
                                          x_return_status => x_return_status, 
                                          x_msg_count   => x_msg_count, 
                                          x_msg_data    => x_msg_data, 
                                          x_out_rec_application_id      => x_out_rec_application_id, 
                                          x_acctd_amount_applied_from   => x_acctd_amount_applied_from, 
                                          x_acctd_amount_applied_to     => x_acctd_amount_applied_to
                                          ) ;

    IF x_return_status = 'S' THEN
        p_mensaje := 'Aplicado Correctamente';
    ELSE            
        --
        -- por si hubo errores
        --
        IF x_msg_count = 1 THEN
             p_mensaje := SUBSTR (x_msg_data, 1, 300) ;

        ELSIF x_msg_count > 1 THEN
             x_count := 0;
            LOOP
                x_count := x_count + 1;
                x_msg_data := APPS.FND_MSG_PUB.Get (APPS.FND_MSG_PUB.G_NEXT, APPS.FND_API.G_FALSE) ;

                IF x_msg_data IS NULL THEN
                        EXIT;
                END IF;
                    
                p_mensaje := '('||x_count||')'||SUBSTR (x_msg_data, 1, 200) ||' '|| NVL (p_mensaje, ' ') ||chr(13);

             END LOOP;
        END IF;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE (p_mensaje);    

END ;
/
