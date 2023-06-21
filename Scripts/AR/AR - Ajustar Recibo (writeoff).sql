SET SERVEROUTPUT ON

DECLARE

v_org_id                NUMBER(15) := 85;
v_gl_date               date;
v_receivables_trx_id    number(15);
v_cash_receipt_id       number(15);
v_receipt_number        varchar2(50);
v_amount                number(15,4);


v_app_ref_type          varchar2(50);
v_app_ref_id            number(15);
v_app_ref_num           varchar2(50);
v_secondary_app_ref_id  number(15);
v_payment_set_id        number(15);
v_receivable_app_id     number(15);
v_return_status         varchar2(10);
v_msg_count             number(15);
v_msg_data              varchar2(500);

BEGIN


    fnd_global.apps_initialize    (
        user_id        => 1671, --CONE-RBORES
        resp_id        => 50834, --GRP_ALL_AR_CONE_GTE
        resp_appl_id    => 222
    );


    SELECT receivables_trx_id    
    INTO v_receivables_trx_id
    FROM ar_receivables_trx_all
    WHERE 1=1
      and type = 'WRITEOFF'
      --AND name like  'FARF_COMIS AGENCIAS 16%'
       AND NAME LIKE 'FARFG_SOBRANTE RECIBOS DE CXC'     
    ;
 
    SELECT cash_receipt_id, receipt_number, amount, org_id
    INTO v_cash_receipt_id, v_receipt_number, v_amount, v_org_id
    FROM ar_Cash_receipts_all
    WHERE 1=1
    and cash_receipt_id = 8294845
    --and receipt_number = 'FARFG_4117_23DIC19_4602'
    AND status = 'UNAPP'
    ;

    mo_global.init ('AR');
    mo_global.set_policy_context('S', v_org_id);
    arp_global.functional_currency     := 'MXN';
    --arp_global.set_of_books_id         := 2;
    CEP_STANDARD.init_security; --The table CE_SECURITY_PROFILES_GT is populated through this call 


    v_gl_date := TO_DATE ('2020-03-31', 'YYYY-MM-DD');

    DBMS_OUTPUT.put_line ('v_org_id          = '|| v_org_id);
    DBMS_OUTPUT.put_line ('v_cash_receipt_id = '|| v_cash_receipt_id);
    DBMS_OUTPUT.put_line ('v_gl_date         = '|| v_gl_date);
--APPS.arp_process_application.activity_application
      apps.AR_RECEIPT_API_PUB.Activity_Application (
                                p_api_version                       => 1.0
                                ,p_init_msg_list                    => apps.FND_API.g_true
                                ,p_commit                           => apps.FND_API.g_false
                                ,p_validation_level                 => apps.FND_API.g_valid_level_full
                                
                                ,p_org_id                           => v_org_id
                                ,p_cash_receipt_id                  => v_cash_receipt_id
                                --,p_receipt_number                   => v_receipt_number
                                --,p_link_to_customer_trx_id          => 8503923
                                ,p_amount_applied                   => 10
                                ,p_applied_payment_schedule_id      => -3   -- (-2=Short Term Debit -3=Write-off)
                                ,p_receivables_trx_id               => v_receivables_trx_id  
                                --,p_apply_date                       => TO_DATE ('2020-04-06', 'YYYY-MM-DD')
                                ,p_apply_gl_date                    => v_gl_date
                                ,p_val_writeoff_limits_flag         => 'Y'                           
                                ,p_comments                         => 'Aplicado x Modulo MAR'
                                ,p_called_from                      => 'MAR'
                                ,p_payment_set_id                   => v_payment_set_id                                
                                ,p_application_ref_type             => v_app_ref_type
                                ,p_application_ref_id               => v_app_ref_id
                                ,p_application_ref_num              => v_app_ref_num
                                ,p_secondary_application_ref_id     => v_secondary_app_ref_id  
                                --,p_payment_priority                 => 99
                                -- ---------------------------------
                                ,p_receivable_application_id        => v_receivable_app_id                                
                                ,x_return_status                    => v_return_status
                                ,x_msg_count                        => v_msg_count
                                ,x_msg_data                         => v_msg_data
                            );
            
      IF v_return_status = 'S' THEN
        COMMIT;
        DBMS_OUTPUT.put_line ('Chido! ' || v_receivable_app_id);        
      ELSE
        ROLLBACK;
        IF v_msg_count=1 THEN
            DBMS_OUTPUT.put_line (v_msg_count ||': '||v_msg_data);
        ELSE
            FOR e IN 1..v_msg_count LOOP          
              v_msg_data := apps.FND_MSG_PUB.Get(apps.FND_MSG_PUB.G_NEXT,APPS.FND_API.G_FALSE);
              IF v_msg_data IS NULL THEN
                EXIT;
              END IF;
                DBMS_OUTPUT.put_line(e || ': '||v_msg_data);
            END LOOP;        
        END IF;
      END IF;
            
 
      --DBMS_OUTPUT.put_line (SQLERRM);      
END;
/
