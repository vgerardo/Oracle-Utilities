--
-- http://docs.oracle.com/cd/E18727_01/doc.121/e13662/T358453T358458.htm
--
DECLARE
p_org_contact_rec                                apps.HZ_PARTY_CONTACT_V2PUB.ORG_CONTACT_REC_TYPE;
x_org_contact_id                                 NUMBER;
x_party_rel_id                                   NUMBER;
x_party_id                                       NUMBER;
x_party_number                                   VARCHAR2(2000);
x_return_status                                  VARCHAR2(2000);
x_msg_count                                      NUMBER;
x_msg_data                                       VARCHAR2(2000);
BEGIN
p_org_contact_rec.department_code := 'ACCOUNTING';
p_org_contact_rec.job_title := 'ARTIST';
p_org_contact_rec.job_title_code := 'ARTIST';
p_org_contact_rec.decision_maker_flag := 'Y';
p_org_contact_rec.created_by_module := 'TCA_V2_API';
p_org_contact_rec.party_rel_rec.subject_id := 8444;    -- party_id de la persona
p_org_contact_rec.party_rel_rec.subject_type := 'PERSON';
p_org_contact_rec.party_rel_rec.subject_table_name := 'HZ_PARTIES';
p_org_contact_rec.party_rel_rec.object_id := 8442;      -- party_id de la organizacion
p_org_contact_rec.party_rel_rec.object_type := 'ORGANIZATION';
p_org_contact_rec.party_rel_rec.object_table_name := 'HZ_PARTIES';
p_org_contact_rec.party_rel_rec.relationship_code := 'CONTACT_OF';
p_org_contact_rec.party_rel_rec.relationship_type := 'CONTACT';
p_org_contact_rec.party_rel_rec.start_date := SYSDATE;

apps.hz_party_contact_v2pub.create_org_contact(
'T',
p_org_contact_rec,
x_org_contact_id,
x_party_rel_id,
x_party_id,
x_party_number,
x_return_status,
x_msg_count,
x_msg_data);

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