SET SERVEROUTPUT ON 

DECLARE

v_return_status     VARCHAR2(1);
p_count             NUMBER;
v_msg_count         NUMBER;
v_msg_data          VARCHAR2(2000);
v_cash_receipt_id   NUMBER     := 8293869;
v_gl_date           DATE       := to_date ('2020-03-30','yyyy-mm-dd');
v_reversal_date     DATE       := to_date ('2020-03-30','yyyy-mm-dd');
v_context           VARCHAR2(2);
v_org_id            number(15) := 85;

BEGIN

    fnd_global.apps_initialize    (
        user_id        => 1134,     -- ext-gvargas
        resp_id        => 50834,    -- GRP_ALL_AR_CONE_GTE
        resp_appl_id    => 222     -- AR
    );

    mo_global.init ('AR');
    mo_global.set_policy_context('S',v_org_id);
    arp_global.functional_currency     := 'MXN';
    --arp_global.set_of_books_id         := 2;

    AR_RECEIPT_API_PUB.Reverse (
                 p_api_version             => 1.0
                ,p_init_msg_list           => FND_API.G_FALSE
                ,p_commit                  => FND_API.G_FALSE
                ,p_validation_level        => FND_API.G_VALID_LEVEL_FULL
                --,p_cash_receipt_id         => v_cash_receipt_id
                ,p_receipt_number          => 'FARFG_4117_28OCT19_443'
                ,p_reversal_category_code  => 'REV'
                ,p_reversal_category_name  => NULL
                ,p_reversal_gl_date        => v_gl_date
                ,p_reversal_date           => v_reversal_date
                ,p_reversal_reason_code    => 'WRONG INVOICE'
                ,p_reversal_reason_name    => NULL
                ,p_reversal_comments       => 'Revertido por API'
                ,p_called_from             => 'My Script'
                ,p_cancel_claims_flag      => 'Y'
                ,p_org_id                  => v_org_id
                ,x_return_status           => v_return_status
                ,x_msg_count               => v_msg_count
                ,x_msg_data                => v_msg_data
            );

    IF v_return_status = 'S' THEN
       DBMS_OUTPUT.put_line('Receipt Reversal is Sucessful');
    ELSE
       DBMS_OUTPUT.put_line('¡Ops! Carambolas! '||v_msg_data);
       DBMS_OUTPUT.put_line('Message count ' || v_msg_count);
       LOOP
          p_count := p_count+1;
          v_msg_data := FND_MSG_PUB.Get(FND_MSG_PUB.G_NEXT, FND_API.G_FALSE);
          IF v_msg_data IS NULL THEN
            EXIT;
          END IF;
          DBMS_OUTPUT.put_line('Message' || p_count ||': '||v_msg_data);
      END LOOP;
    END IF;

END;
/
