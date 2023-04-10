SET SERVEROUTPUT ON

DECLARE
 
 lr_vendor_rec      AP_VENDOR_PUB_PKG.r_vendor_rec_type;
 
 p_object_version_number NUMBER;
 x_return_status        VARCHAR2 ( 2000 ) ;
 x_msg_count            NUMBER;
 x_msg_data             VARCHAR2 ( 2000 ) ;

 l_msg          VARCHAR2(200);
 p_vendor_id    NUMBER;

BEGIN
  
 fnd_global.apps_initialize(1123 -- CONE-LGOMEZ
                           , 50833 --GRP_ALL_AP_CONE_GTE
                           , 200); --AP
 mo_global.init('SQLAP'); 

 --mo_global.set_org_context ( 204, NULL, 'SQLAP' ) ; 
 --mo_global.set_policy_context ( 'S', 204 ) ;
 
 --fnd_global.set_nls_context ( 'AMERICAN' ) ;
 --fnd_client_info.set_org_context(101);
 
 p_vendor_id            := 2093;
 lr_vendor_rec.vendor_id:= p_vendor_id;
 lr_vendor_rec.segment1 := 'XYZW998877ABC';
  
 AP_VENDOR_PUB_PKG.update_vendor(
            p_api_version   => 1.0,
            p_init_msg_list => fnd_api.g_true,
            p_commit        => fnd_api.g_true,
            p_validation_level=> fnd_api.g_valid_level_full,
            x_return_status => x_return_status,
            x_msg_count     => x_msg_count,
            x_msg_data      => x_msg_data,
            p_vendor_rec    => lr_vendor_rec,
            p_vendor_id     => p_vendor_id
            ); 
 
 DBMS_OUTPUT.put_line ('x_return_status= '||x_return_status);
 DBMS_OUTPUT.put_line (x_msg_data);
 
END;
/


