--
-- http://docs.oracle.com/cd/E18727_01/doc.121/e13662/T358453T358458.htm
--
DECLARE

p_person_rec           apps.HZ_PARTY_V2PUB.PERSON_REC_TYPE;
x_return_status        VARCHAR2(2000);
x_msg_count            NUMBER;
x_msg_data             VARCHAR2(2000);
x_party_id             NUMBER;
x_party_number         VARCHAR2(2000);
x_profile_id           NUMBER;

BEGIN
p_person_rec.person_first_name := 'Gerardo';
p_person_rec.person_last_name  := 'Vargas1';
p_person_rec.created_by_module := 'TCA_V2_API';

apps.HZ_PARTY_V2PUB.create_person (    
    'T',
    p_person_rec,
    x_party_id,    
    x_party_number,
    x_profile_id,    
    x_return_status,
    x_msg_count,
    x_msg_data  
  );

dbms_output.put_line(SubStr('x_return_status = '||x_return_status,1,255));
dbms_output.put_line('x_msg_count = '||TO_CHAR(x_msg_count));
dbms_output.put_line(SubStr('x_msg_data = '||x_msg_data,1,255));
dbms_output.put_line('x_party_id=' || x_party_id);

IF x_msg_count >1 THEN

FOR I IN 1..x_msg_count

LOOP
dbms_output.put_line(I||'. '||SubStr(apps.FND_MSG_PUB.Get(p_encoded => apps.FND_API.G_FALSE ), 1, 255));

END LOOP;
END IF;
END;