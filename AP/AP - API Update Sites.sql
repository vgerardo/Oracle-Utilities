
SET SERVEROUTPUT ON

DECLARE
 
 l_site_rec             AP_VENDOR_PUB_PKG.r_vendor_site_rec_type;
 
 p_object_version_number NUMBER;
 x_return_status        VARCHAR2 ( 2000 ) ;
 x_msg_count            NUMBER;
 x_msg_data             VARCHAR2 ( 2000 ) ;

 l_msg                  VARCHAR2(200);
 p_vendor_id            NUMBER(15);
 x_site_id              number(15);

BEGIN
  
 fnd_global.apps_initialize(1123 -- CONE-LGOMEZ
                           , 50833 --GRP_ALL_AP_CONE_GTE
                           , 200); --AP
 mo_global.init('SQLAP'); 

 --mo_global.set_org_context ( 204, NULL, 'SQLAP' ) ; 
 --mo_global.set_policy_context ( 'S', 204 ) ;
 
 --fnd_global.set_nls_context ( 'AMERICAN' ) ;
 --fnd_client_info.set_org_context(101);
 
 p_vendor_id                := 2093;
 x_site_id                  := 26470;
 l_site_rec.vendor_id       := p_vendor_id;
 l_site_rec.vendor_site_id  := x_site_id;
 l_site_rec.location_id     := 8352;
 l_site_rec.org_id          := 86;
 l_site_rec.address_line1   := 'Laurel 97';
 l_site_rec.address_line2   := 'Roble';
 l_site_rec.address_line3   := 'Acapulco';
 
 AP_VENDOR_PUB_PKG.Update_Vendor_Site_Public(
    p_api_version       => 1,
    p_init_msg_list     => FND_API.G_TRUE,
    p_commit            => FND_API.G_TRUE,
    p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
    x_return_status     => x_return_status, 
    x_msg_count         => x_msg_count, 
    x_msg_data          => x_msg_data, 
    p_vendor_site_rec   => l_site_rec, 
    p_vendor_site_id    => x_site_id
    );
  
  
commit;
 DBMS_OUTPUT.put_line ('x_return_status= '||x_return_status);
 DBMS_OUTPUT.put_line ('x_msg_data     = ' ||x_msg_data);
 
END;
/


