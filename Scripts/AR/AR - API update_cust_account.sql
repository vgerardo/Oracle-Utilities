DECLARE

 CURSOR c_customers
 IS
    select ca.cust_account_id, 
           ca.party_id, 
           ca.account_number, 
           ca.account_name,
           ca.object_version_number,
           cas.org_id
    from hz_cust_accounts_all   ca,
         hz_cust_acct_sites_all cas
    where 1=1
      and ca.cust_account_id = cas.cust_account_id
      --and ca.account_name = 'SUPER PRECISION INTEGRAL SA DE CV'--'OPERADORA DE SITES MEXICANOS SA DE CV'
      and ca.cust_account_id = 2053
      and cas.org_id = 85
    ;

 p_cust_account_rec        hz_cust_account_v2pub.cust_account_rec_type;
 p_object_version_number   NUMBER;
 x_return_status           VARCHAR2(2000);
 x_msg_count               NUMBER;
 x_msg_data                VARCHAR2(2000);


BEGIN

    --MO_GLOBAL.init ('AR');
    
    FOR c_ca IN c_customers LOOP
    
       -- MO_GLOBAL.set_org_context (c_ca.org_id,NULL,'AR');
        --FND_GLOBAL.set_nls_context('AMERICAN');
       -- MO_GLOBAL.set_policy_context('S', c_ca.org_id);
    
        p_cust_account_rec.cust_account_id  := c_ca.cust_account_id;
        --p_cust_account_rec.customer_type    := 'R';
        p_cust_account_rec.account_name     := 'Hight Technology Corporation 2'; 
        p_object_version_number             := c_ca.object_version_number;

        HZ_CUST_ACCOUNT_V2PUB.update_cust_account(
                                 'T',
                                 p_cust_account_rec,
                                 p_object_version_number,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data
                                 );
    
        dbms_output.put_line('x_return_status = '
                               || substr(x_return_status,1,255) );
        dbms_output.put_line('x_msg_count = ' || TO_CHAR(x_msg_count) );
        dbms_output.put_line('Object Version Number =' || TO_CHAR(p_object_version_number) );
        dbms_output.put_line('x_msg_data = '
                               || substr(x_msg_data,1,255) );
        IF
            x_msg_count > 1
        THEN
            FOR i IN 1..x_msg_count LOOP
                dbms_output.put_line(i
                                       || '.'
                                       || substr(fnd_msg_pub.get(p_encoded => fnd_api.g_false),1,255) );
            END LOOP;
        END IF;
        
    END LOOP;
    
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Error: ' || sqlerrm);
END;
