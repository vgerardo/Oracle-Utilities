
DECLARE

c_account_number    varchar2(20) := 'GVP023';
c_location          varchar2(15) := 'PERLA';
c_org_name          varchar2(15) := 'POS_OU_HVP' ;

v_cust_account_id   number(15) := 0;
v_org_id            number(15) := 0;
v_cust_acct_site_id number(15) := 0;
v_site_use_id       number(15) := 0;
    
v_cust_site_use_rec         apps.HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_SITE_USE_REC_TYPE;
v_object_version_number     number;

x_return_status             varchar2(5);
x_msg_count                 number(15);
x_msg_data                  varchar2(1000);

BEGIN    

    SELECT organization_id
    into v_org_id
      FROM HR_OPERATING_UNITS
      WHERE NAME LIKE c_org_name;

    MO_GLOBAL.INIT('AR');
    MO_GLOBAL.SET_POLICY_CONTEXT('S', v_org_id);         


    Select   hca.cust_account_id, csu.cust_acct_site_id, csu.site_use_id, csu.object_version_number
    Into     v_cust_account_id,
             v_cust_acct_site_id,
             v_site_use_id, 
             v_object_version_number
    From     hz_cust_accounts       hca,
             hz_cust_acct_sites_all cas,             
             hz_cust_site_uses_all  csu
    Where    1 = 1
     and csu.cust_acct_site_id = cas.cust_acct_site_id
     --and      csu.status = 'A'             
     and csu.site_use_code    = 'BILL_TO'
     --and addr.cust_account_id = c_cust_account_id
     and hca.cust_account_id  = cas.cust_account_id
     And hca.account_number   = c_account_number
     and csu.org_id           = v_org_id
     ;    
   

    select 
    apps.FND_FLEX_EXT.get_ccid
                             ('SQLGL'
                             , 'GL#'
                             , 50393
                             , TO_CHAR(SYSDATE,'DD-MON-YYYY')
                             , '0262.0000.1123.101376.000.0000.0000.0316'                         
                             ) 
    into v_cust_site_use_rec.gl_id_rec                             
    from dual    ;    
    

    dbms_output.put_line ('v_cust_acct_site_id='||v_cust_acct_site_id ||'  '|| 
                          'v_site_use_id='||v_site_use_id ||'  '||
                          'gl_id_rec='|| v_cust_site_use_rec.gl_id_rec ||'  '||
                          'v_org_id='|| v_org_id
                          );

    v_cust_site_use_rec.site_use_id         := v_site_use_id ;
    v_cust_site_use_rec.cust_acct_site_id   := v_cust_acct_site_id;         
    v_cust_site_use_rec.status              := 'A';


    apps.hz_cust_account_site_v2pub.update_cust_site_use (
                                    FND_API.G_TRUE,
                                    v_cust_site_use_rec,
                                    v_object_version_number,
                                    x_return_status , 
                                    x_msg_count , 
                                    x_msg_data 
                                  );
                                                
    dbms_output.put_line (x_msg_count ||'. '||x_msg_data);
                                                 
    COMMIT;
                                                
END;                                                