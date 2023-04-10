DECLARE
   l_prog_short_name   VARCHAR2 (240);
   l_exec_short_name   VARCHAR2 (240);
   l_appl_full_name    VARCHAR2 (240);
   l_appl_short_name   VARCHAR2 (240);
   l_del_prog_flag     VARCHAR2 (1) := 'Y'; 
   l_del_exec_flag     VARCHAR2 (1) := 'Y'; 
BEGIN


   l_prog_short_name := 'XXCMX_WMS_MS_MIGRATE_DLVRYS';  --Concurrent program short name
   l_exec_short_name := 'XXCMX_WMS_MS_MIGRATE_DLVRYS';  --Executable short name
   l_appl_full_name := 'PPG Comex Custom';   -- Application full name
   l_appl_short_name := 'XXCMX';                 -- Application Short name

   IF     FND_PROGRAM.program_exists (l_prog_short_name, l_appl_short_name)  
      --AND FND_PROGRAM.executable_exists (l_exec_short_name, l_appl_short_name)
   THEN
 
         FND_PROGRAM.delete_program (l_prog_short_name, l_appl_full_name);
         --FND_PROGRAM.delete_executable (l_exec_short_name, l_appl_full_name);
      
      COMMIT;
      
      DBMS_OUTPUT.put_line ('Concurrent Program '||l_prog_short_name || ' deleted successfully');
      DBMS_OUTPUT.put_line ('Executable '||l_exec_short_name || ' deleted successfully');

   ELSE
      DBMS_OUTPUT.put_line (l_prog_short_name ||' or '||l_exec_short_name|| ' not found');
   END IF;
   
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Error while deleting: ' || SQLERRM);
END;