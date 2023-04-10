--
-- method for creating paymanets on Oracle EBS Account Payables
--
SET SERVEROUTPUT ON

DECLARE

v_invoice_num               VARCHAR2(50) := 'FACCG8586411';  --api=FFISLOD10024, FFIMEXA248, FFISLOD10025 pantalla=FFISLOD9961
v_bank_account_name         VARCHAR2(50) := 'INHTL_PAG_CONCE_4524036'; --'FFISLO_PAG_197082703';
v_check_date                date         := to_date('2017-11-24 08:30:01', 'YYYY-MM-DD HH24:MI:SS');

v_return_status             VARCHAR2(100);
v_msg_count                 NUMBER(15);
v_msg_data                  VARCHAR2(500);
v_errorIDs                  IBY_DISBURSE_SINGLE_PMT_PKG.trxnErrorIdsTab;
v_dummy                     VARCHAR2(1000);

v_org_id                    number(15);
v_invoice_id                NUMBER(15);
v_check_id                  number(15);
v_payment_method_code       varchar2(10);
v_internal_bank_account_id  NUMBER(15);
v_bank_acct_use_id          number(15);
v_payment_document_id       NUMBER(15);
v_payment_profile_id        NUMBER(15);
v_currency                  VARCHAR2(3);
v_exchange_rate_type        VARCHAR2(10) := NULL;
v_exchange_rate             NUMBER(15,4) := NULL;
v_exchange_date             DATE := NULL;

BEGIN

    SELECT api.invoice_id, api.payment_method_code, api.org_id, api.invoice_currency_code
    INTO v_invoice_id, v_payment_method_code, v_org_id, v_currency
    FROM ap_invoices_all api
         --ap_invoices_ready_to_pay_v
    WHERE 1=1
      AND api.payment_status_flag = 'N'  -- N = Aún no ha sido pagada
      --AND org_id = 241
      --AND invoice_id  = 1694354
      AND NOT exists (SELECT 1
                    FROM ap_selected_invoices_all
                    WHERE invoice_id = api.invoice_id
                   )
      and api.invoice_num LIKE v_invoice_num 
    ;

    dbms_output.put_line ('v_invoice_id= '||v_invoice_id || ' v_org_id= ' || v_org_id || ' v_payment_method_code= ' || v_payment_method_code);

    -- ------------------------------------------------------
    -- Inicializa Entorno
    FND_GLOBAL.apps_initialize ( 
                             user_id      => 1123   -- CONE-LGOMEZ
                            ,resp_id      => 50833  -- GRP_ALL_AP_CONE_GTE
                            ,resp_appl_id => 200    -- SQLAP
                           );        
    MO_GLOBAL.set_policy_context('S', v_org_id); 
    MO_GLOBAL.init('SQLAP'); -- product short name: AR, SQLAP
    CEP_STANDARD.init_security; --The table CE_SECURITY_PROFILES_GT is populated through this call 
    -- ------------------------------------------------------
    
    --
    -- Para habilitar el LOG del API, los resultados se guardan en FND_LOG_MESSAGES
    --
    --fnd_profile.put('AFLOG_ENABLED', 'Y');
    --fnd_profile.put('AFLOG_MODULE', '%');
    --fnd_profile.put('AFLOG_LEVEL','1'); -- Level 1 is Statement Level
    --fnd_log_repository.init;
    --DBMS_OUTPUT.put_line ('G_CURRENT_RUNTIME_LEVEL = ' || FND_LOG.G_CURRENT_RUNTIME_LEVEL);
    --DBMS_OUTPUT.put_line ('LEVEL_STATEMENT         = ' || FND_LOG.LEVEL_STATEMENT);

    IF v_currency <> 'MXN' THEN
         v_exchange_rate_type  := 'Corporate';
         v_exchange_date       := TO_DATE('2017-10-13 00:00:01', 'YYYY-MM-DD HH24:MI:SS');
         --v_exchange_rate       := 17.5;         
--        ap_utilities_pkg.get_exchange_rate(
--                                    l_inv_rec.pmt_currency_code,
--                                    l_asp_rec.base_currency_code,
--                                    l_check_rec.xrate_type,
--                                    l_check_rec.xrate_date,
--                                    'APAYFULB');         
    END IF;

    SELECT ba.bank_account_id, bau.bank_acct_use_id
    INTO v_internal_bank_account_id, v_bank_acct_use_id
    FROM ce_bank_accounts BA
         ,CE_BANK_ACCT_USES_ALL BAU
    WHERE 1=1
      AND ba.bank_account_id = bau.bank_account_id
      AND nvl(ba.end_date,sysdate+1) > sysdate 
      and bau.org_id           = v_org_id      
      and ba.bank_account_name = v_bank_account_name
    ;

    dbms_output.put_line ('v_internal_bank_account_id = ' || v_internal_bank_account_id);

    SELECT payment_document_id
    into v_payment_document_id
    FROM ce_payment_documents 
    WHERE 1=1      
      and replace(payment_document_name,'  ',' ') = DECODE(v_payment_method_code, 'CHECK', 'CHEQUE MANUAL', 'TRANSFERENCIA ELECTRONICA')
      AND internal_bank_account_id = v_internal_bank_account_id
      ;
      
    dbms_output.put_line ('v_payment_document_id = ' || v_payment_document_id);

    SELECT payment_profile_id
    INTO v_payment_profile_id
    FROM iby_payment_profiles 
    WHERE system_profile_name = decode(v_payment_method_code, 'CHECK', 'GRP_AP_CHEQUES', 'GRP_AP_ELECTRONICO')
    ;  

    dbms_output.put_line ('v_payment_profile_id = '|| v_payment_profile_id);


    AP_PAY_SINGLE_INVOICE_PKG.ap_pay_invoice_in_full (
             p_api_version               => 1.0,
             p_init_msg_list             => fnd_api.g_true,
             p_invoice_id                => v_invoice_id,
             p_payment_method_code       => v_payment_method_code, -- CHECK, EFT, ¿CLEARING?
             p_internal_bank_acct_id     => v_internal_bank_account_id,             
             p_payment_document_id       => v_payment_document_id, 
             p_payment_profile_id        => v_payment_profile_id,  
             p_payment_type_flag         => 'A', --'M=Manual, Q=Quick, A=Payment Process Request'             
             p_take_discount             => 'N',
             p_check_date                => v_check_date,
             p_doc_category_code         => NULL,
             p_exchange_rate_type        => v_exchange_rate_type,
             p_exchange_rate             => v_exchange_rate,
             p_exchange_date             => v_exchange_date,
             x_return_status             => v_return_status,
             x_msg_count                 => v_msg_count,
             x_msg_data                  => v_msg_data,
             x_errorIds                  => v_errorIDs
         );
     
     DBMS_OUTPUT.put_line ('v_return_status: '||v_return_status);
     DBMS_OUTPUT.put_line ('v_msg_count    : '|| nvl(v_msg_count,0) );
     DBMS_OUTPUT.put_line ('v_msg_data     : '|| nvl(v_msg_data, 'null'));
     
    FOR i IN 1 .. fnd_msg_pub.count_msg
    LOOP                   
       v_dummy := SUBSTR(fnd_msg_pub.get (p_msg_index   => i
                                         ,p_encoded     => 'F'
                                         )
                         , 0, 4000
                         )  ;
                     
        dbms_output.put_line ( to_char(i) || ': '||v_dummy);
    END LOOP;       
     
    IF v_return_status = FND_API.G_RET_STS_SUCCESS THEN
        COMMIT;
        
        SELECT check_id 
        INTO v_check_id
        FROM ap_invoice_payments_all x 
        WHERE x.invoice_id = v_invoice_id
        ;
        
        DBMS_OUTPUT.put_line ('Check_ID     : '|| nvl(to_char(v_check_id), 'null'));
        
        --
        -- Algunas Actualizaciones, para finalizar chido!
        --
        
        -- Se actualiza para reflejar correctamente la Cuenta Bancaria en la Pantalla de Facturas
        UPDATE ap_checks_all SET
        ce_bank_acct_use_id = v_bank_acct_use_id
        WHERE check_id = v_check_id
        ;                   
        
        -- Este no sé para que se use, pero cuando se crea el pago desde la Pantalla Estandar
        -- el campo sí contiene un número. Pero con el API el campo queda Nulo.
        UPDATE ap_invoice_payments_all SET
        accounting_event_id = (SELECT accounting_event_id 
                               FROM ap_payment_history_all x
                               WHERE transaction_type = 'PAYMENT CREATED'
                                 and check_id = v_check_id)
        --gain_code_combination_id = 
        --loss_code_combination_id =                              
        WHERE check_id = v_check_id
        ;
        
        COMMIT;
        
    ELSE
        ROLLBACK;
    END IF;
     
END;                                 
/

--SELECT module, message_text, callstack, errorstack
--FROM FND_LOG_MESSAGES
--WHERE 1=1
-- and TIMESTAMP > SYSDATE-.5
-- AND user_id = 1123 
--ORDER BY log_sequence
--;

