--
-- http://docs.oracle.com/cd/E18727_01/doc.121/e13662/T358453T358458.htm
--
DECLARE

p_location_rec       apps.HZ_LOCATION_V2PUB.location_rec_type;
x_location_id        NUMBER;
x_return_status      VARCHAR2(2000);
x_msg_count          NUMBER;
x_msg_data           VARCHAR2(2000);

BEGIN

p_location_rec.country      := 'MX';
p_location_rec.address1     := 'LAUREL 17';
p_location_rec.address2     := 'El Roble';
p_location_rec.city         := 'Acapulco';
p_location_rec.postal_code  := '94065';
p_location_rec.state        := 'CA';
p_location_rec.created_by_module := 'TCA_V2_API'; -- lookup type HZ_CREATED_BY_MODULES

apps.HZ_LOCATION_V2PUB.create_location(
                                          'T',
                                          p_location_rec,
                                          x_location_id,
                                          x_return_status,
                                          x_msg_count,
                                          x_msg_data
                                       );



dbms_output.put_line('x_return_status = '||SubStr(x_return_status,1,255));
dbms_output.put_line('x_msg_count = '||TO_CHAR(x_msg_count));
dbms_output.put_line('x_msg_data = '||SubStr(x_msg_data,1,255));
dbms_output.put_line('x_location_id=' || x_location_id);

IF x_msg_count >1 THEN
FOR I IN 1..x_msg_count
LOOP
dbms_output.put_line(I||'. '||SubStr(APPS.FND_MSG_PUB.Get(p_encoded => APPS.FND_API.G_FALSE ), 1, 255));
END LOOP;
END IF;

END;