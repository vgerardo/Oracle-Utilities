
DECLARE

l_organization_rec  hz_party_v2pub.organization_rec_type;
x_profile_id        NUMBER;
l_vendor_id         NUMBER;
v_employee_id       number(15);
l_party_id          NUMBER;
l_object_version_number NUMBER;
l_msg_count         NUMBER;
l_msg_data          VARCHAR2(4000);
l_return_status     VARCHAR2(10);

BEGIN


    SELECT aps.party_id, hzp.object_version_number, aps.employee_id
    into l_party_id, l_object_version_number, v_employee_id
    FROM AP_SUPPLIERS aps, 
         HZ_PARTIES hzp
    WHERE 1=1      
      AND aps.party_id = hzp.party_id
      AND vendor_id =     28112
      ;

    l_organization_rec.party_rec.party_id   := l_party_id;
    l_organization_rec.organization_name    := 'Gerardo 3';
    --l_organization_rec.employee_id          := v_employee_id;
    --l_organization_rec.address1             := 'laurel 99'; --calle
    --l_organization_rec.address2             := '99'; --numero
    --l_organization_rec.address3             := 'Roble'; --colonia
    --l_organization_rec.city                 := 'Acapulco';
    --l_organization_rec.segment1             := 'ABCD998877ABC';      

    HZ_PARTY_V2PUB.update_organization (
            p_init_msg_list             => fnd_api.g_true,
            p_organization_rec          => l_organization_rec,
            p_party_object_version_number => l_object_version_number,
            x_profile_id                => x_profile_id,
            x_return_status             => l_return_status,
            x_msg_count                 => l_msg_count,
            x_msg_data                  => l_msg_data    
    );
    
    FOR I IN 1..l_msg_count LOOP
        l_msg_data := l_msg_data||SUBSTR(FND_MSG_PUB.GET(p_encoded=>'T'),1,255);
        dbms_output.put_line(l_msg_data);
    END LOOP ;     
    
END;