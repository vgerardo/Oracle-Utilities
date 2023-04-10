-- permisos para poder ejecutar comandos 
-- del sistema operativo a traves de Java.
BEGIN
  DBMS_JAVA.grant_permission ('APPS', 'java.io.FilePermission',
                             '<>', 'read ,write, execute, delete');

  DBMS_JAVA.grant_permission ('APPS', 'SYS:java.lang.RuntimePermission',
                             'writeFileDescriptor', '');
 
  DBMS_JAVA.grant_permission ('APPS', 'SYS:java.lang.RuntimePermission',
                             'readFileDescriptor', '');
END;
/




CREATE OR REPLACE AND RESOLVE JAVA SOURCE NAMED "HOST" AS
 import java.lang.*;
 import java.io.*;

 public class Host {
 
 public static void executeCommand (String command , String etype) throws IOException, InterruptedException
 {                  
    String[] wFullCommand = {"C:\\winnt\\system32\\cmd.exe", "/y", "/c", command};
    String[] uFullCommand = {"/bin/sh", "-c", command};     
    
    
    if (etype.toUpperCase().equals("W"))    
        uFullCommand = new String[] {"C:\\winnt\\system32\\cmd.exe", "/y", "/c", command};
        
    else if(etype.toUpperCase().equals("U+"))
        //Runtime.getRuntime().exec(uFullCommand);
        uFullCommand = new String[] {"/bin/sh", "-c", command};  
    
    else if (etype.toUpperCase().equals("U"))
        //No pude hacer que funcione, con esta opcion
        uFullCommand  = new String[] {command};
  
    Process p = Runtime.getRuntime().exec (uFullCommand);   
      
    int returnCode = p.waitFor();
     
    if (returnCode >= 2)  {
        System.out.println("CMD:Error");        
        System.out.println (p.exitValue());
    } else                 
        System.out.println("CMD:Correcto");    
    
    BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream()));
    
    while (br.ready()) {
         String str = br.readLine();
         System.out.println(str);
         //if (str.startsWith("line")) System.out.println(str);         
    }    

 } 
 };
 /

--
-- Envoltura, para poder ser llamado desde un PLSQL
--
 CREATE OR REPLACE PROCEDURE apps.Host_Command (p_command IN VARCHAR2, p_etype IN VARCHAR2) authid current_user
 AS LANGUAGE JAVA 
 NAME 'Host.executeCommand (java.lang.String, java.lang.String)';
 /



--
--  PROBANDO PROBANDO
--
DECLARE

l_output        DBMS_OUTPUT.chararr;
l_lines         INTEGER := 100;
v_comando_str   varchar2(200);
v_in_dir        varchar2(50) := '/interface/GRPEBSD/outgoing/';
v_out_dir       varchar2(50) := '/interface/GRPEBSD/outgoing/';

BEGIN    
    DBMS_OUTPUT.enable (1000000);
    DBMS_JAVA.set_output (1000000);                  

    ---jm
      v_comando_str := '/usr/bin/zip '
                 || v_out_dir 
                 || 'gvp07.zip'
                 || ' '
                 || v_in_dir
                 || 'GRPEBSD.dbc'
                 ;
        
    Host_Command ( v_comando_str, 'U+');  
  
    DBMS_OUTPUT.Get_Lines (l_output, l_lines);

    FOR i IN 1 .. l_lines
    LOOP
        DBMS_OUTPUT.put_line (l_output (i));            
    END LOOP;  

END;
/