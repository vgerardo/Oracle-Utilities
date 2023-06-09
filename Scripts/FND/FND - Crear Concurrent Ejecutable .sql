/**************************************************
*PURPOSE: To Create an Executable from backend    *
*AUTHOR: Shailender Thallam                       *
***************************************************/

DECLARE
 --
   l_executable            VARCHAR2 (200);
   l_application           VARCHAR2 (200);
   l_short_name            VARCHAR2 (200);
   l_description           VARCHAR2 (200);
   l_execution_method      VARCHAR2 (200);
   l_execution_file_name   VARCHAR2 (200);
   l_subroutine_name       VARCHAR2 (200);
   l_icon_name             VARCHAR2 (200);
   l_language_code         VARCHAR2 (200);
   l_execution_file_path   VARCHAR2 (200);
   l_check                 VARCHAR2 (2);
 --  
BEGIN
 --
   l_executable          := 'GRP_PAY_TMBRDO_ESTATUS';
   l_application         := 'Grupo Posadas Custom Product'; -- Your target application name
   l_short_name          := 'GRP_PAY_TMBRDO_ESTATUS';
   l_description         := 'Reporte de Estatus de Timbardo de N�mina con Next Technologies';
   l_execution_method    := 'PL/SQL Stored Procedure';
   l_execution_file_name := 'bolinf.GRP_PAY_TMBRDO_ESTATUS';
   l_subroutine_name     := NULL;
   l_icon_name           := NULL;
   l_language_code       := 'US';
   l_execution_file_path := NULL;
 --
 --Calling API to create executable
 --
   apps.fnd_program.executable (executable               => l_executable,
                                application              => l_application,
                                short_name               => l_short_name,
                                description              => l_description,
                                execution_method         => l_execution_method,
                                execution_file_name      => l_execution_file_name,
                                subroutine_name          => l_subroutine_name,
                                icon_name                => l_icon_name,
                                language_code            => l_language_code,
                                execution_file_path      => l_execution_file_path
                               );
   COMMIT;
   BEGIN
   --
   --To check whether executable is created or not
   --
      SELECT 'Y'
        INTO l_check
        FROM fnd_executables
       WHERE executable_name = l_executable;
       --
       DBMS_OUTPUT.put_line ('Executable Created Successfully');
       --
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         DBMS_OUTPUT.put_line ('Executable Registration Failed');
   END;
END;