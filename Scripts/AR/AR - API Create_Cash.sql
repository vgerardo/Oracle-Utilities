SET SERVEROUTPUT ON

DECLARE

x_return_status       VARCHAR2(500);
x_msg_count           NUMBER(15);
x_msg_data            VARCHAR2(500);       
x_P_CR_ID             NUMBER(15);
x_count               number(15):=0;

BEGIN

    fnd_global.apps_initialize
    (
        user_id        => 1134,
        resp_id        => 51382,
        resp_appl_id    => 222
    );

    mo_global.init ('AR');
    mo_global.set_policy_context('S',85);

    arp_global.functional_currency     := 'MXN';
    --arp_global.set_of_books_id         := 2;

--    SELECT receipt_method_id
--    INTO v_receipt_method_id
--    FROM ar_receipt_methods
--     WHERE UPPER(name) = NVL(p_rct_rec.receipt_method_name,'CREDIT CARD')
--       AND rownum = 1
--       ;

    --AR_RECEIPT_API_PUB.Apply

    apps.AR_RECEIPT_API_PUB.Create_Cash(
            p_api_version                 => 1.0
          , p_init_msg_list               => APPS.Fnd_Api.g_true
          , p_commit                      => APPS.Fnd_Api.g_false
          , p_receipt_number              => 'GVP004'
          , p_receipt_date                => sysdate
          , p_gl_date                     => to_date('31-03-2020','dd-mm-yyyy')
          , p_amount                      => 4
          --, p_receipt_method_id           => 47383
          ,p_receipt_method_name          => 'FARFG_CAPT TC_4524117'
          , p_customer_id                 => 3806   --VIAJES EL CORTE INGLES SA DE CV
          ,p_doc_sequence_value           => null
          --,p_customer_bank_account_id
          --,p_customer_site_use_id
          --,p_remittance_bank_account_id  => p_remmitance          
          --p_deposit_date 
          , p_currency_code               => 'MXN'
          , p_exchange_rate_type          => NULL
          , p_exchange_rate               => NULL
          , p_exchange_rate_date          => NULL
          , p_comments                    => 'Mi Prueba 004'
          --, p_postmark_date               => to_date('31-03-2020','dd-mm-yyyy')
          , p_customer_receipt_reference  => 'FARFG_4117_04NOV19_5628'
          , p_org_id                      => 85         
          ,p_called_from                  => 'Mi Script'          
          , x_return_status               => X_return_status
          , x_msg_count                   => X_msg_count
          , x_msg_data                    => X_msg_data 
          , p_cr_id                       => X_P_CR_ID
          );
      
     DBMS_OUTPUT.PUT_LINE ('x_return_status= ' || x_return_status );
     DBMS_OUTPUT.PUT_LINE ('Recibo ID      = ' || x_p_cr_id);
     
      IF x_msg_count = 1 THEN
        DBMS_OUTPUT.PUT_LINE('6.   Error en crea recibo '|| x_msg_count || ': ' || x_msg_data);
      ELSIF x_msg_count > 1 THEN
        DBMS_OUTPUT.PUT_LINE('7.   Error en crea recibo ');
        LOOP          
          x_count := x_count+1;
          x_msg_data := APPS.FND_MSG_PUB.Get(APPS.FND_MSG_PUB.G_NEXT,APPS.FND_API.G_FALSE);
          IF x_msg_data IS NULL THEN
            EXIT;
          END IF;
          DBMS_OUTPUT.PUT_LINE('8.    ' || x_count ||': '||x_msg_data);
        END LOOP;
      END IF;
     
END;
/

