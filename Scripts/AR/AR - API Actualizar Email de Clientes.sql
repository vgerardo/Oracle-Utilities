SET SERVEROUTPUT ON

DECLARE

 v_object_version_number    NUMBER(15);
 x_profile_id               NUMBER(15);
 l_error_message            VARCHAR2(2000) := null;
 l_msg_index_out            NUMBER(15);
 x_return_status            VARCHAR2(200);
 x_msg_count                NUMBER(15);
 x_msg_data                 VARCHAR2(200);

 l_contact_point_rec   hz_contact_point_v2pub.contact_point_rec_type;
 l_email_rec           hz_contact_point_v2pub.email_rec_type;
 l_contact_point_id    NUMBER;

BEGIN
 
            l_contact_point_rec.contact_point_type  := 'EMAIL';
            l_contact_point_rec.owner_table_name    := 'HZ_PARTIES';                        
            l_contact_point_rec.contact_point_id    := 242019;            
            l_contact_point_rec.owner_table_id      := 358661;
            l_contact_point_rec.created_by_module   := 'HZ_CPUI'; --'TCA_V2_API';
            l_email_rec.email_address               := DBMS_RANDOM.string('l',10)||'@dummy.com.mx';
            v_object_version_number                 := 1;
     
            HZ_CONTACT_POINT_V2PUB.update_email_contact_point(
                        p_init_msg_list         => 'T', --fnd_api.g_false
                        p_contact_point_rec     => l_contact_point_rec,
                        p_email_rec             => l_email_rec,
                        p_object_version_number => v_object_version_number,                        
                        x_return_status         => x_return_status,
                        x_msg_count             => x_msg_count,
                        x_msg_data              => x_msg_data
                     );     

            dbms_output.put_line('X_Return_Status = '|| x_return_status);
            dbms_output.put_line('X_Msg_Data:     = ' || x_msg_data);

END;
/