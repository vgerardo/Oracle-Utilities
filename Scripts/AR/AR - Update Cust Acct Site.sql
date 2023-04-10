
DECLARE

v_account_number    varchar2(20) := 'GVP023';
v_org_name          varchar2(15) := 'POS_OU_HVP' ;
v_location          varchar2(15) := 'PERLA';
v_org_id            number(15) := 0 ;
c_cust_account_id   number(15) := 0;

c_cust_acct_site_id number(15) := 0;
c_site_use_id       number(15) := 0;

c_party_site_id     number(15) := 0;

v_location_id           number;
v_object_version_number number;
x_return_status         varchar2(5);
x_msg_count             number(15);
x_msg_data              varchar2(1000);
    
p_location_rec           apps.HZ_LOCATION_V2PUB.location_rec_type;
p_cust_acct_site_rec     apps.HZ_CUST_ACCOUNT_SITE_V2PUB.CUST_ACCT_SITE_REC_TYPE;


BEGIN

       
  SELECT organization_id
  Into    v_org_id
  FROM HR_OPERATING_UNITS
  WHERE NAME LIKE v_org_name
    ;
                            

MO_GLOBAL.INIT('AR');
MO_GLOBAL.SET_POLICY_CONTEXT('S', v_org_id);         


SELECT  hca.cust_account_id
       ,cas.cust_acct_site_id
       ,csu.site_use_id
INTO   c_cust_account_id 
       ,c_cust_acct_site_id
       ,c_site_use_id
FROM    hz_cust_accounts        hca
       ,hz_parties              hzp
       ,hz_cust_acct_sites_all  cas
       ,hz_cust_site_uses_all   csu
       ,hz_party_sites          hzps
       ,hz_locations            hzl
WHERE   1 = 1
  AND hca.party_id          = hzp.party_id
  and hca.cust_account_id   = cas.cust_account_id (+)
  and cas.cust_acct_site_id = csu.cust_acct_site_id(+) 
  AND cas.party_site_id     = hzps.party_site_id(+) 
  AND hzps.location_id      = hzl.location_id(+)
  --And hca.status = 'A'
  and csu.site_use_code  = 'BILL_TO'
  and csu.org_id         = v_org_id
  And hca.account_number = v_account_number
  and csu.location       = v_location
  ;


select object_version_number
into v_object_version_number
from hz_cust_acct_sites
where cust_acct_site_id = c_cust_acct_site_id;


dbms_output.put_line ('c_org_id='||v_org_id ||'  '||
                      'c_cust_account_id='||c_cust_account_id||'  '||
                      'c_cust_acct_site_id='||c_cust_acct_site_id||'  '||
                      'c_party_site_id='||c_party_site_id||'  '||
                      'c_site_use_id='||c_site_use_id 
                      );       
                          
p_cust_acct_site_rec.cust_acct_site_id := c_cust_acct_site_id;
p_cust_acct_site_rec.cust_account_id   := c_cust_account_id;
--p_cust_acct_site_rec.party_site_id   := 66625; 
p_cust_acct_site_rec.org_id            := v_org_id;

-- ---------------------------------------------------------
--                 Campos a MODIFICAR
--                  
p_cust_acct_site_rec.status            := 'I';  -- Activo  Inactivo
-- ---------------------------------------------------------

apps.hz_cust_account_site_v2pub.update_cust_acct_site ('T',
                                                     p_cust_acct_site_rec,
                                                     v_object_version_number,
                                                     x_return_status,
                                                     x_msg_count,
                                                     x_msg_data);
                                                
 dbms_output.put_line (x_msg_count ||'.'||x_msg_data);
                                                 
COMMIT;
                                                
END;                                                