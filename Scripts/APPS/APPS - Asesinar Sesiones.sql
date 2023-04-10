SET SERVEROUTPUT ON

DECLARE

v_osuser    varchar2(50);
v_dbuser    varchar2(50);
v_asesinar  varchar2(150);

BEGIN
   
    FOR VS IN (   
            SELECT vs.username, vs.osuser, 
                   ('ALTER SYSTEM KILL SESSION ''' || vs.SID||','|| vs.SERIAL# || ''' IMMEDIATE') asesinar
            --into v_dbuser, v_osuser, v_asesinar
            FROM v$session vs
            WHERE 1=1 
             and vs.osuser NOT IN ('applebsd','oraebsd', 'alberto.lopez', 'jair.nolasco','wendolyne.avila')
            )
    LOOP       
    
        IF vs.username in ('BOLINF', 'APPS') and vs.osuser IN ('vale', 'armin.luna', 'facto') THEN
            EXECUTE IMMEDIATE vs.asesinar;
            dbms_output.Put_Line (vs.osuser ||' '||vs.asesinar);
        ELSE
            null;
        END IF;

    END LOOP;
          
END;
