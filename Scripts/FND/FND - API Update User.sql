
SET SERVEROUTPUT ON

DECLARE
v_user_name varchar2(30) := 'H808091';
v_user_pwd  varchar2(30) := 'Comex#2023';
v_status boolean;
BEGIN

    v_status := FND_USER_PKG.ChangePassword (username => v_user_name, newpassword => v_user_pwd);
    
  /*FND_USER_PKG.UpdateUser
           (  x_user_name               => v_user_name,
              x_owner                   => NULL,
              x_unencrypted_password    => v_user_pwd,
              x_start_date              => TO_DATE ('2021-02-15', 'YYYY-MM-DD'),
              x_end_date                => null,
              x_password_date           => sysdate,
              x_password_lifespan_days  => 180,
              x_employee_id             => 17910,
              x_email_address           => 'gvargas@ppg.com'
           );
*/

  
    
    if v_status then
        dbms_output.put_line ('Chido!');
         COMMIT;  
    else
        dbms_output.put_line ('¡ERROR! = ' || sqlerrm);
        rollback;
    end if;
    
    
END;
/
