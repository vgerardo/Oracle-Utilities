
SET SERVEROUTPUT ON

DECLARE 
   l_resp_key            VARCHAR2 (100) := 'GRP_POS_AP_AQCU_APLICACION';
   l_resp_name           VARCHAR2 (100) := 'GRP_POS_AP_AQCU_APLICACION';
   l_rowid               VARCHAR2 (500) := NULL;
   l_responsibility_id   NUMBER := NULL;
   l_application_id      NUMBER := NULL;
   l_data_group_id       NUMBER := NULL;
   l_menu_id             NUMBER := NULL;
   l_start_date          DATE := SYSDATE-1;
   l_version             NUMBER := 4;           --    Oracle Applications Type
   v_request_group_id   number(15);
BEGIN
   SELECT fnd_responsibility_s.NEXTVAL INTO l_responsibility_id FROM DUAL;

   SELECT application_id
     INTO l_application_id
     FROM fnd_application_vl
    WHERE application_short_name = 'SQLAP';


   SELECT data_group_id
     INTO l_data_group_id
     FROM fnd_data_groups
    WHERE data_group_name = 'Standard';


   SELECT menu_id
     INTO l_menu_id
     FROM fnd_menus_vl
    WHERE menu_name = 'GRP_AP_APP_USER'
    ;            

    SELECT request_group_id
     INTO v_request_group_id
     FROM FND_REQUEST_GROUPS
    WHERE request_group_name = 'GRP_AP_APP_USER'
    ;


   fnd_responsibility_pkg.insert_row (
              x_rowid                       => l_rowid,
              x_responsibility_id           => l_responsibility_id,
              x_application_id              => l_application_id,
              x_web_host_name               => 'PROFESSIONAL',
              x_web_agent_name              => NULL,
              x_data_group_application_id   => l_application_id,
              x_data_group_id               => l_data_group_id,
              x_menu_id                     => l_menu_id,
              x_start_date                  => l_start_date,
              x_end_date                    => NULL,
              x_group_application_id        => l_application_id,
              x_request_group_id            => v_request_group_id,
              x_version                     => l_version,
              x_responsibility_key          => l_resp_key,
              x_responsibility_name         => l_resp_name,
              x_description                 => 'Resp. de usuario del Módulo "Aplicación de Pagos Parciales"',
              x_creation_date               => SYSDATE,
              x_created_by                  => 1,
              x_last_update_date            => SYSDATE,
              x_last_updated_by             => 1,
              x_last_update_login           => 1
      );

   DBMS_OUTPUT.put_line (l_resp_name || ' has been created Successfully!!!');
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Exception: ' || SQLERRM);
END;