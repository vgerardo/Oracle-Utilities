
SET SERVEROUTPUT ON

BEGIN
    FND_USER_PKG.CreateUser (
          x_user_name                  => 'H808091'
          ,x_owner                      => 'Vargas, Gerardo'
          ,x_unencrypted_password       => 'ChangeMe#99'
          --x_session_number             in number default 0,
          ,x_start_date                 => to_Date ('2020-12-01', 'YYYY-MM-DD')
          --x_end_date                   in date default null,
          --x_last_logon_date            in date default null,
          ,x_description                => 'Vargas, Gerardo (Oracle Developer)'
          --x_password_date              in date default null,
          --x_password_accesses_left     in number default null,
          --x_password_lifespan_accesses in number default null,
          ,x_password_lifespan_days     => 90
          --x_employee_id                 in number default null,
          ,x_email_address              => 'gvargas@ppg.com'
          --x_fax                         in varchar2 default null,
          --x_customer_id                 in number default null,
          --x_supplier_id                 in number default null
      );
      
      COMMIT;
      
--EXCEPTION      
      
END;
/


select * from fnd_user where user_name like 'H808091';

