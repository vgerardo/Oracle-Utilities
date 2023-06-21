DECLARE

 l_init_msg_list                VARCHAR2(200);
 l_organization_rec             apps.hz_party_v2pub.organization_rec_type;
 l_party_rec                    apps.hz_party_v2pub.party_rec_type;
 l_party_object_version_number  NUMBER;
 x_profile_id                   NUMBER;
 l_error_message                VARCHAR2(2000) := null;
 l_msg_index_out                NUMBER;
 x_return_status                VARCHAR2(200);
 x_msg_count                    NUMBER;
 x_msg_data                     VARCHAR2(200);
 
BEGIN

 l_init_msg_list                := 1.0;
 l_party_rec.party_id           := 6195;
 l_party_rec.attribute4         := 'Valid';
 l_organization_rec.party_rec   := l_party_rec;
 x_profile_id                   := NULL;
 x_return_status                := NULL;
 x_msg_count                    := NULL;
 x_msg_data                     := NULL;
 
 SELECT object_version_number
  INTO l_party_object_version_number
  FROM hz_parties
  WHERE party_id = l_party_rec.party_id   
   ;
   
 l_organization_rec.organization_name := 'High Technology Corporation 2';
 l_organization_rec.jgzz_fiscal_code  := 'XXXX1234YYY';
   
 apps.HZ_PARTY_V2PUB.update_organization(
                      p_init_msg_list               => apps.fnd_api.g_true
                    , p_organization_rec            => l_organization_rec
                    , p_party_object_version_number => l_party_object_version_number
                    , x_profile_id                  => x_profile_id
                    , x_return_status               => x_return_status
                    , x_msg_count                   => x_msg_count
                    , x_msg_data                    => x_msg_data
                );

DBMS_OUTPUT.put_line('x_return_status :' || x_return_status);
DBMS_OUTPUT.put_line('x_msg_count     :' || x_msg_count);
DBMS_OUTPUT.put_line('x_msg_data      :' || x_msg_data);

 IF x_return_status <> fnd_api.g_ret_sts_success THEN
   FOR i IN 1 .. x_msg_count   LOOP
        apps.fnd_msg_pub.get(
                             p_msg_index    => i, 
                             p_encoded      => fnd_api.g_false, 
                             p_data         => l_error_message
                           , p_msg_index_out=> l_msg_index_out);

        IF l_error_message IS NULL    THEN
          l_error_message                := SUBSTR(l_error_message, 1, 250);
        ELSE
          l_error_message                := l_error_message || '/' || SUBSTR(l_error_message, 1, 250);
        END IF;
   END LOOP;

   DBMS_OUTPUT.put_line('*****************************************');
   DBMS_OUTPUT.put_line('API Error :' || l_error_message);
   DBMS_OUTPUT.put_line('*****************************************');
   ROLLBACK;

 ELSE
 
   DBMS_OUTPUT.put_line('*****************************************');
   DBMS_OUTPUT.put_line('Attribute4 for Party : ' || l_party_rec.party_id || ' Updated Successfully ');
   DBMS_OUTPUT.put_line('*****************************************');
   COMMIT;
 END IF;
 
EXCEPTION
 WHEN OTHERS THEN
   DBMS_OUTPUT.put_line('Unexpected Error ' || SUBSTR(SQLERRM, 1, 250));
END;
