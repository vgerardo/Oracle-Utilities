
SELECT *
FROM FND_USER
WHERE USER_NAME LIKE '%BROBLES%'
;

BEGIN
FND_USER_PKG.updateuser(
                            x_user_name            => 'EXT-GVARGAS'
                           ,x_owner                => 'CUST' --SEED
                           ,x_unencrypted_password => 'posadas2020'
                           ,x_password_date        => SYSDATE + 360
                           ,x_password_lifespan_days => 360
                           ,x_end_date             => SYSDATE + 360
                           --,x_email_address     => 'gerardo@dummy.com.mx'
                        );  
                        
commit;
END;
