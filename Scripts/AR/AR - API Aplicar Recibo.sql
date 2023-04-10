SET SERVEROUTPUT ON

DECLARE

v_org_id              number(15) := 85;

x_return_status       VARCHAR2(500);
x_msg_count           NUMBER(15);
x_msg_data            VARCHAR2(500);       
x_count               number(15):=0;

BEGIN

    fnd_global.apps_initialize    (
        user_id        => 1671, --cone-rbores
        resp_id        => 50834,
        resp_appl_id    => 222
    );

    mo_global.init ('CE');
    mo_global.set_policy_context('S', v_org_id);
    arp_global.functional_currency     := 'MXN';
    --arp_global.set_of_books_id         := 2;


    --AR_RECEIPT_API_PUB.Create_And_Apply
    --AR_RECEIPT_API_PUB.Apply

        apps.AR_RECEIPT_API_PUB.Apply (
          p_api_version             => 1.0,
          p_init_msg_list           => FND_API.G_TRUE,
          p_commit                  => FND_API.G_TRUE,
          p_validation_level        => FND_API.G_Valid_Level_Full,
          p_cash_receipt_id         => 8294845,        -- ID del recibo
          p_customer_Trx_id         => 8503923,      -- ID de la Factura
          p_amount_applied          => 2.32,
          --, p_amount_applied_from          => p_monto_usd
          --, p_trans_to_receipt_rate        => p_v_trans
          --, p_apply_date                   => v_gl_date --p_fecha
          p_org_id             => v_org_id, 
          x_return_status      => x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
        );
          
         DBMS_OUTPUT.PUT_LINE ('x_return_status= ' || x_return_status );
         DBMS_OUTPUT.PUT_LINE ('x_msg_data     = ' || x_msg_data);
     
      IF x_msg_count = 1 THEN
        DBMS_OUTPUT.PUT_LINE('1.   Error en crea recibo '|| x_msg_count || ': ' || x_msg_data);
        
      ELSIF x_msg_count > 1 THEN
        DBMS_OUTPUT.PUT_LINE('2.   Error en crea recibo ');
        LOOP          
          x_count := x_count+1;
          x_msg_data := APPS.FND_MSG_PUB.Get(APPS.FND_MSG_PUB.G_NEXT,APPS.FND_API.G_FALSE);
          IF x_msg_data IS NULL THEN
            EXIT;
          END IF;
          DBMS_OUTPUT.PUT_LINE('3.    ' || x_count ||': '||x_msg_data);
        END LOOP;
      END IF;
     
END;
/

