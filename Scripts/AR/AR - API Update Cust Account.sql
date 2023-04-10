
DECLARE

CURSOR c_cust_accounts
IS
    SELECT  hca.cust_account_id
            ,object_version_number
           --,party_id
           --,account_name           
    FROM    hz_cust_accounts        hca
    WHERE account_number LIKE 'GPO'
    ;
   
--p_location_rec          apps.HZ_LOCATION_V2PUB.location_rec_type;
--p_cust_acct_site_rec    apps.HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE;
v_cust_accnt_rg         apps.HZ_CUST_ACCOUNT_V2PUB.CUST_ACCOUNT_REC_TYPE;
v_object_version_number number;
v_return_status         varchar2(5);
v_msg_count             number(15);
v_msg_data              varchar2(1000);

BEGIN

       
    MO_GLOBAL.INIT('AR');
    --MO_GLOBAL.SET_POLICY_CONTEXT('S', v_org_id);         

    OPEN c_cust_accounts;
    FETCH c_cust_accounts INTO v_cust_accnt_rg.cust_account_id, v_object_version_number ;
    CLOSE c_cust_accounts;    
    
    -- ---------------------------------------------------------
    --                 Campos a MODIFICAR
    --                  
    v_cust_accnt_rg.account_name := 'PRUEBA DE MI PARA MI';
    -- ---------------------------------------------------------

     HZ_CUST_ACCOUNT_V2PUB.update_cust_account (
            p_init_msg_list         => FND_API.G_TRUE,
            p_cust_account_rec      => v_cust_accnt_rg,
            p_object_version_number => v_object_version_number,
            x_return_status         => v_return_status,
            x_msg_count             => v_msg_count,
            x_msg_data              => v_msg_data
        );

    DBMS_OUTPUT.put_line ('v_return_status = '||v_return_status);
    DBMS_OUTPUT.put_line ('v_msg_data      = '||v_msg_data);
                                                 
COMMIT;
                                                
END;                                                