--
-- http://docs.oracle.com/cd/E18727_01/doc.121/e13662/T358453T358458.htm
--
DECLARE
 p_party_site_rec HZ_PARTY_SITE_V2PUB.PARTY_SITE_REC_TYPE;
 x_party_site_id NUMBER;
 x_party_site_number VARCHAR2(2000);
 x_return_status VARCHAR2(2000);
 x_msg_count NUMBER;
 x_msg_data VARCHAR2(2000);
BEGIN
 p_party_site_rec.party_id := 8442; --value for party_id 
 p_party_site_rec.location_id := 576; --value for location_id 
 p_party_site_rec.identifying_address_flag := 'Y';
 p_party_site_rec.created_by_module := 'TCA_V2_API';

 apps.HZ_PARTY_SITE_V2PUB.create_party_site(
     'T',
     p_party_site_rec,
     x_party_site_id,
     x_party_site_number,
     x_return_status,
     x_msg_count,
     x_msg_data);
 
 dbms_output.put_line('***************************');
 dbms_output.put_line('Output information ....');
 dbms_output.put_line('x_party_site_id: '||x_party_site_id);
 dbms_output.put_line('x_party_site_number: '||x_party_site_number);
 dbms_output.put_line('x_return_status: '||x_return_status);
 dbms_output.put_line('x_msg_count: '||x_msg_count);
 dbms_output.put_line('x_msg_data: '||x_msg_data);
 dbms_output.put_line('***************************');
 
END;
 
 