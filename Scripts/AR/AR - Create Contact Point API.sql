SET SERVEROUTPUT ON 
--
-- http://docs.oracle.com/cd/E18727_01/doc.121/e13662/T358453T358458.htm
--
DECLARE

p_contact_point_rec    apps.HZ_CONTACT_POINT_V2PUB.CONTACT_POINT_REC_TYPE;
p_email_rec            apps.HZ_CONTACT_POINT_V2PUB.EMAIL_REC_TYPE;
p_phone_rec            apps.HZ_CONTACT_POINT_V2PUB.PHONE_REC_TYPE;
--p_telex_rec            apps.HZ_CONTACT_POINT_V2PUB.TELEX_REC_TYPE;
--p_web_rec              apps.HZ_CONTACT_POINT_V2PUB.WEB_REC_TYPE;
--p_edi_rec              apps.HZ_CONTACT_POINT_V2PUB.EDI_REC_TYPE;
x_return_status        VARCHAR2(2000);
x_msg_count            NUMBER;
x_msg_data             VARCHAR2(2000);
x_contact_point_id     NUMBER;

BEGIN


p_contact_point_rec.created_by_module   := 'HZ_CPUI';
p_contact_point_rec.primary_flag        := 'Y';

p_contact_point_rec.owner_table_name        := 'HZ_PARTY_SITES';    --HZ_PARTIES or HZ_PARTY_SITES
p_contact_point_rec.owner_table_id          := '382114';            -- party_id  or party_site_id

p_contact_point_rec.contact_point_type      := 'EMAIL'; 
p_contact_point_rec.contact_point_purpose   := 'MAIL FE';

p_email_rec.email_address                   := 'abc@dummy.com.xx';

apps.HZ_CONTACT_POINT_V2PUB.create_email_contact_point(
    'T',
    p_contact_point_rec,
    p_email_rec,
    x_contact_point_id   ,
    x_return_status      ,
    x_msg_count          ,
    x_msg_data           
) ;

/*
p_contact_point_rec.contact_point_type := 'PHONE';
p_phone_rec.phone_area_code := '443';
p_phone_rec.phone_country_code := '52';
p_phone_rec.phone_number := '1234234';
p_phone_rec.phone_line_type := 'GEN';

apps.HZ_CONTACT_POINT_V2PUB.create_phone_contact_point(
    'T',
    p_contact_point_rec,
    p_phone_rec,
    x_contact_point_id   ,
    x_return_status      ,
    x_msg_count          ,
    x_msg_data           
) ;
*/

/*
apps.HZ_CONTACT_POINT_V2PUB.create_contact_point(
    'T',
    p_contact_point_rec,
    p_edi_rec,
    p_email_rec,
    p_phone_rec,
    p_telex_rec,
    p_web_rec,
    x_contact_point_id,
    x_return_status,
    x_msg_count,
    x_msg_data
);
*/

dbms_output.put_line(SubStr('x_return_status = '||x_return_status,1,255));
dbms_output.put_line('x_msg_count = '||TO_CHAR(x_msg_count));
dbms_output.put_line(SubStr('x_msg_data = '||x_msg_data,1,255));

IF x_msg_count >1 THEN
    FOR I IN 1..x_msg_count LOOP
        dbms_output.put_line(I||'. '||SubStr(apps.FND_MSG_PUB.Get(p_encoded => apps.FND_API.G_FALSE ), 1, 255));
    END LOOP;
END IF;

COMMIT;


END;
