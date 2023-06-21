
declare

v_org_contact_rec apps.hz_party_contact_v2pub.ORG_CONTACT_REC_TYPE;

v_cont_object_version_number    NUMBER(15);
v_rel_object_version_number     NUMBER(15);
v_party_object_version_number   NUMBER(15);
x_return_status                 VARCHAR2(10);
x_msg_count                     NUMBER(15);
x_msg_data                      VARCHAR2(1000);


begin


v_org_contact_rec.org_contact_id    := 15024;

v_org_contact_rec.contact_number    := 'PRVC-2015-08-00002' ;       
v_org_contact_rec.job_title         := 'LICENCIADO';
--    job_title_code                  VARCHAR2(30),
--    party_site_id                   NUMBER,
--    orig_system_reference           VARCHAR2(240),
--    party_rel_rec HZ_RELATIONSHIP_V2PUB.relationship_rec_type:= HZ_RELATIONSHIP_V2PUB.G_MISS_REL_REC


SELECT object_version_number
INTO v_cont_object_version_number 
FROM hz_org_contacts
WHERE org_contact_id         = v_org_contact_rec.org_contact_id;


--
-- This API update a record in the HZ_ORG_CONTACTS table.
--                          
apps.hz_party_contact_v2pub.update_org_contact (
                                p_init_msg_list                 => FND_API.G_FALSE,
                                p_org_contact_rec               => v_org_contact_rec,
                                p_cont_object_version_number    => v_cont_object_version_number,
                                p_rel_object_version_number     => v_rel_object_version_number,
                                p_party_object_version_number   => v_party_object_version_number,
                                x_return_status                 => x_return_status,
                                x_msg_count                     => x_msg_count,
                                x_msg_data                      => x_msg_data
                          ) ;

IF x_msg_count > 1 THEN
    FOR I IN 1..x_msg_count        
    LOOP
        dbms_output.put_line (I||'. '||SUBSTR ( FND_MSG_PUB.Get ( p_encoded=> FND_API.G_FALSE ), 1, 255 ) ) ;
    END LOOP;
END IF;    
        

COMMIT;

end;
