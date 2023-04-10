SET SERVEROUTPUT ON

DECLARE

v_org_id                NUMBER(15) := 265;
v_gl_date               date;
v_rcvbles_trx_id        number(15);
v_payment_schedule_id   number(15);
v_adj_rec               AR_ADJUSTMENTS%rowtype;

v_new_adj_id            number(15);
v_new_adj_num           varchar2(100);
v_return_status         varchar2(10);
v_msg_count             number(15);
v_msg_data              varchar2(500);

BEGIN


    fnd_global.apps_initialize    (
        user_id        => 1671, --CONE-RBORES
        resp_id        => 50834, --GRP_ALL_AR_CONE_GTE
        resp_appl_id    => 222
    );

    mo_global.init ('AR');
    --mo_global.set_policy_context('S', v_org_id);
    --arp_global.functional_currency     := 'MXN';
    --arp_global.set_of_books_id         := 2;
    --CEP_STANDARD.init_security; --The table CE_SECURITY_PROFILES_GT is populated through this call 

    SELECT payment_schedule_id
    INTO v_payment_schedule_id
    FROM ar_payment_schedules_all
    WHERE customer_trx_id = 9066301 --FARFG1848800
    ;
    
    SELECT receivables_trx_id    
    INTO v_rcvbles_trx_id
    FROM ar_receivables_trx_all
    WHERE 1=1
      and status = 'A'       
      and type = 'ADJUST'
      AND NAME LIKE '1GDCE_FALTANTE DE CXC' 
    --
    -- bug del API: Falla si el nombre es superior a 30 caracteres
    --              y no marca ningún error
      --AND NAME LIKE '1GDCE_AJUSTE FACTURA NO OPERATIVOS'
    --- ------------------------------------------------------------
    ;

    v_gl_date := TO_DATE ('2020-04-30', 'YYYY-MM-DD');

    v_adj_rec.TYPE                 := 'LINE';   --LINE, TAX, INVOICE o CHARGES
    v_adj_rec.payment_schedule_id  := v_payment_schedule_id;
    v_adj_rec.receivables_trx_id   := v_rcvbles_trx_id;
    v_adj_rec.apply_date           := SYSDATE;
    v_adj_rec.reason_code          := 'WRITE OFF';    --REFUND, SMALL AMT REMAINING, WRITE OFF
    v_adj_rec.gl_date              := v_gl_date;
    v_adj_rec.created_from         := 'MAR';
    v_adj_rec.amount               := -1; --0.32
    v_adj_rec.comments             := 'Estoy Probando los Ajustes :)';
    v_adj_rec.attribute3           := 'Y';      --Y = timbrar ajuste

    apps.AR_ADJUST_PUB.Create_Adjustment (
                           p_api_name             => 'AR_ADJUST_PUB'
                          ,p_api_version          => 1.0
                          ,p_validation_level     => apps.FND_API.G_Valid_Level_Full
                          ,p_init_msg_list        => apps.FND_API.g_true
                          ,p_commit_flag          => apps.FND_API.g_false
                          ,p_chk_approval_limits  => apps.FND_API.g_false
                          ,p_check_amount         => apps.FND_API.g_false
                          ,p_adj_rec              => v_adj_rec
                          ,p_org_id               => v_org_id
                          ,p_new_adjust_number    => v_new_adj_num
                          ,p_new_adjust_id        => v_new_adj_id 
                          ,p_called_from            => 'MAR'
                          ,p_msg_count            => v_msg_count
                          ,p_msg_data             => v_msg_data
                          ,p_return_status        => v_return_status      
                    );
      
      DBMS_OUTPUT.put_line ('Estatus : '||v_return_status);
      DBMS_OUTPUT.put_line ('Contador: '||v_msg_count);
      DBMS_OUTPUT.put_line ('Data    : '||v_msg_data);
      
      IF v_return_status = 'S' THEN
        --COMMIT;
        DBMS_OUTPUT.put_line ('Chido! ' || v_new_adj_id);        
        DBMS_OUTPUT.put_line ('Monto! ' ||v_adj_rec.amount);        
      ELSE
        DBMS_OUTPUT.put_line ('¡Horror!');
        IF v_msg_count=1 THEN
            DBMS_OUTPUT.put_line (v_msg_count ||': '||v_msg_data);
        ELSE
            --FOR e IN 1..v_msg_count LOOP          
              v_msg_data := apps.FND_MSG_PUB.Get(apps.FND_MSG_PUB.G_NEXT, APPS.FND_API.G_FALSE);
              --IF v_msg_data IS NULL THEN
              --  EXIT;
              --END IF;
                DBMS_OUTPUT.put_line(': '||v_msg_data);
            --END LOOP;        
        END IF;
      END IF;
            
ROLLBACK; 
      --DBMS_OUTPUT.put_line (SQLERRM);      
END;
/



