SET SERVEROUTPUT ON;

DECLARE
    p_init_msg_list           VARCHAR2(200);
    p_acct_rec                apps.ce_bank_pub.bankacct_rec_type;
    p_object_version_number   NUMBER;
    x_return_status           VARCHAR2(200);
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(200);
    p_count                   NUMBER;
    l_msg_index_out             number;

BEGIN

     fnd_global.apps_initialize(5801 -- 
                               , 50796 --GRP_ALL_CE_CONE_GTE
                               , 260); --CE
     mo_global.init('CE'); 


    p_init_msg_list                     := NULL;
    p_acct_rec.bank_account_id          := 10089;
 -- HZ_PARTIES.PARTY_ID BANK BRANCH
    p_acct_rec.branch_id                := 4127;
 -- HZ_PARTIES.PARTY_ID BANK
    p_acct_rec.bank_id                  := 4125;
 -- HZ_PARTIES.PARTY_ID ORGANIZATION
    p_acct_rec.account_owner_org_id     := 23273;
 -- HZ_PARTIES.PARTY_ID Person related to ABOVE ORGANIZATION
    p_acct_rec.account_owner_party_id   := 4041;
    p_acct_rec.account_classification   := 'INTERNAL';
    p_acct_rec.bank_account_name        := 'GPO_CAPT TC_6051633';
    p_acct_rec.bank_account_num         := 99123456789012;
    --p_acct_rec.currency                 := 'USD';
    p_acct_rec.start_date               := SYSDATE;
    p_acct_rec.end_date                 := NULL;
    p_object_version_number             := 8;
    
    CE_BANK_PUB.update_bank_acct(
        p_init_msg_list           => fnd_api.g_true,
        p_acct_rec                => p_acct_rec,
        p_object_version_number   => p_object_version_number,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
    );

    
    if x_return_status <> FND_API.G_RET_STS_SUCCESS then
        dbms_output.put_line ('Error API: ' || x_msg_data);        
    end if;

    dbms_output.put_line('P_OBJECT_VERSION_NUMBER = ' || p_object_version_number);
    dbms_output.put_line('X_RETURN_STATUS         = ' || x_return_status);
    dbms_output.put_line('X_MSG_COUNT             = ' || x_msg_count);    
    
    IF x_msg_count = 1 THEN
        
        dbms_output.put_line('x_msg_data =' || x_msg_data);
        
    ELSIF x_msg_count > 1 THEN
        dbms_output.put_line('x_msgs_data: ' || x_msg_data);
        p_count := 0;
        LOOP
            p_count      := p_count + 1;
            /*x_msg_data   := fnd_msg_pub.get(
                                fnd_msg_pub.g_next,
                                fnd_api.g_false
                             );*/
                             
            apps.fnd_msg_pub.get(
                             p_msg_index    => p_count, 
                             p_encoded      => fnd_api.g_false, 
                             p_data         => x_msg_data
                           , p_msg_index_out=> l_msg_index_out);                             
                             
            dbms_output.put_line('   (' || p_count ||') ' || x_msg_data);                 
                             
            IF p_count >= x_msg_count THEN
                EXIT;
            END IF;
            
        END LOOP;
        
        
        
    END IF;

END;