
SELECT *
FROM FND_RESPONSIBILITY_VL
WHERE 1=1
  AND nvl(end_date,sysdate+1) > sysdate
  --AND language = 'ESA'
  AND responsibility_name like 'GRP_%\_AP\_%\_CONSULTA' ESCAPE '\'
  AND responsibility_name <> responsibility_key
;


SELECT *
from fnd_profile_options   
where 1=1 
  AND profile_option_name in  ('GL_ACCESS_SET_ID', 
                                'PER_BUSINESS_GROUP_ID', 
                                'GL_SET_OF_BKS_ID',
                                'XLA_MO_SECURITY_PROFILE_LEVEL',
                                'ORG_ID',
                                'GL_SET_OF_BKS_NAME'
    )
  ;
  




set serveroutput on

declare

CURSOR c_perfiles 
is
    SELECT
        r.responsibility_name,        
        po.profile_option_id,
        po.profile_option_name,
        po.user_profile_option_name,
        pov.profile_option_value,    
        po.sql_validation
    FROM FND_PROFILE_OPTIONS_VL     po,
         FND_PROFILE_OPTION_VALUES  pov,
         FND_RESPONSIBILITY_VL      r     
    WHERE 1=1
      AND po.profile_option_id = pov.profile_option_id
      AND pov.level_value_application_id = 200        
      --AND v.level_id = 10003
      AND pov.level_value = r.responsibility_id
      and r.responsibility_id =  50990 --61095 --      
    ;

    v_result    boolean;
begin

    FOR c IN c_perfiles LOOP
        
            v_result := FND_PROFILE.SAVE(
                            X_NAME              => c.profile_option_name,   -- Ej. GL_SET_OF_BKS_ID
                            X_VALUE             => c.profile_option_value,  -- Ej. '2022', 
                            X_LEVEL_NAME        => 'RESP',  --Level that you're setting at: 'SITE','APPL','RESP','USER', ETC.
                            X_LEVEL_VALUE       => 61095,    --Level value that you are setting at, e.g. user id for 'USER' level. is not used at site level.
                            X_LEVEL_VALUE_APP_ID=> 200,   --Used for 'RESP' and 'SERVRESP' level; Resp Application_Id.       
                            X_LEVEL_VALUE2      => NULL     --2nd Level value that you are setting at. This is for the 'SERVRESP' hierarchy.
                        );
    
            if v_result then
                dbms_output.put_line ('Chido!');
            else
                dbms_output.put_line ('ups! Error');
            end if;   

    END LOOP;                    
 
end;
/

                              
