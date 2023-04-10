declare

v_person_rec        apps.HZ_PARTY_V2PUB.PERSON_REC_TYPE;
v_party_rec         apps.HZ_PARTY_V2PUB.party_rec_type;
x_profile_id        number(15);
x_return_status varchar2(10);
x_msg_count     number(15);
x_msg_data      varchar2(1000);
v_object_version_number number(15):=0;

begin

v_party_rec.party_id                        := 52713;

select object_version_number
into v_object_version_number
from HZ_PARTIES
where party_id =   v_party_rec.party_id;  
    
--v_person_rec.job_title               := 'INGENIERO';
v_person_rec.person_title            := 'ING';  
v_person_rec.party_rec               := v_party_rec;                 
    
apps.HZ_PARTY_V2PUB.update_person (
                                            fnd_api.g_true                  ,
                                            v_person_rec                    ,
                                            v_object_version_number         ,
                                            x_profile_id                    ,
                                            x_return_status ,
                                            x_msg_count     ,
                                            x_msg_data );

dbms_output.put_line ('msg_data: '||x_msg_data);                                            
                                            
end;                                            