DECLARE
lc_user_name                VARCHAR2(100) := 'NEXT-OCESPEDES';
lc_user_password            VARCHAR2(100) := 'Oracle123';
ld_user_start_date          DATE := TO_DATE('28-MAY-2017','DD-MON-YYYY');
ld_user_end_date            VARCHAR2(100) := NULL;
ld_password_date            VARCHAR2(100) := TO_DATE('01-JUN-2019', 'DD-MON-YYYY');
ld_password_lifespan_days   NUMBER:=90;
ln_person_id                NUMBER(15):=NULL;
lc_email_address            VARCHAR2(100) := 'jjcorona@4ce.com.mx';

BEGIN

APPS.fnd_user_pkg.createuser ( x_user_name => lc_user_name,
    x_owner=>NULL,
    x_unencrypted_password=>lc_user_password,
    x_start_date=>ld_user_start_date,
    x_end_date=>ld_user_end_date,
    x_password_date=>ld_password_date,
    x_password_lifespan_days=>ld_password_lifespan_days,
    x_employee_id=>ln_person_id,
    x_email_address=>lc_email_address
 );
 
 COMMIT;

EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
    
END;

/
SHOW ERR; 