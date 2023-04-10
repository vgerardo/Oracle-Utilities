SET SERVEROUTPUT ON
SET LINES 5000
SET PAGES 0
set pause off
set wrap off
set feed off
set term off


SPOOL C:\LOG.TXT


DECLARE

V_SEQ NUMBER(15):=0;

CURSOR C_RESPONSABILIDADES 
IS 
    SELECT frtl.responsibility_name
         , fmtl.user_menu_name        menu
         , fm.menu_id
    FROM fnd_responsibility     fr
       , fnd_responsibility_tl  frtl
       , fnd_menus              fm
       , fnd_menus_tl           fmtl
    WHERE 1=1
      and fr.responsibility_id = frtl.responsibility_id
      and fr.menu_id        = fm.menu_id 
      and fm.menu_id        = fmtl.menu_id
      and nvl(fr.END_DATE,sysdate+1) >= sysdate
      and frtl.LANGUAGE     = 'ESA'      
      and fmtl.LANGUAGE     = 'ESA'
	and ( frtl.responsibility_name LIKE 'GPDA_EF_CONSOLIDADOS_SU'
         --or frtl.responsibility_name LIKE 'GPDA%'
         )
    ORDER BY 1   
    ;


PROCEDURE P_MENUS_SUB_MENUS (p_menu_id varchar2, p_nivel number)
IS

v_nivel number(15);

CURSOR C_MENUS (p_menu_id varchar2)
IS
    select                      
            F.ENTRY_SEQUENCE        SEQUENCE,                    
            E.GRANT_FLAG            ASIGNADA,               
            NVL2(E.FUNCTION_ID, 'Funcion', 'Sub-Menu') TIPO,
            F.PROMPT,
            E.SUB_MENU_ID
    from                            
         fnd_menu_entries       E,
         fnd_menu_entries_tl    F     
    WHERE   1=1
    and     f.menu_id  = p_menu_id        
    and     f.language = 'ESA'
    and     e.entry_sequence = f.entry_sequence    
    and     e.menu_id  = p_menu_id
    and     E.GRANT_FLAG = 'Y'
    and     f.prompt is not null
    ORDER BY F.ENTRY_SEQUENCE
    ;

BEGIN


            FOR C_M IN C_MENUS (p_menu_id) LOOP
        
			insert into gvp_datos_01 values ( V_SEQ,
							  rpad('|', 30 + (p_nivel*4))|| lpad( '|',p_nivel,'|') ||
                                            rpad(C_M.sequence,4) ||
                                            rpad(c_m.tipo,9)    ||
                                            c_m.prompt                                            
                                   );     

				V_SEQ := V_SEQ + 1;

--                    DBMS_OUTPUT.PUT_LINE(   rpad('|', 30 + (p_nivel*4))|| lpad( '|',p_nivel,'|') ||
  --                                          rpad(C_M.sequence,4) ||
    --                                        rpad(c_m.tipo,9)    ||
      --                                      c_m.prompt                                            
        --                           );                 

                    IF C_M.TIPO = 'Sub-Menu' THEN
                        P_MENUS_SUB_MENUS (c_m.sub_menu_id, p_nivel+1);
                    end if;
                        
            
            END LOOP;
          
    
END;    


BEGIN

    -- Create table gvp_datos_01 (seq number(15), dato varchar2(800))

    DELETE gvp_datos_01 ;
    COMMIT;

    V_SEQ := 1;

    FOR C_R IN C_RESPONSABILIDADES LOOP

		insert into gvp_datos_01 values ( V_SEQ,
                               rpad(c_r.responsibility_name, 30, ' ') ||'|'||
                               rpad(c_r.menu, 30,' ')
					);
	      V_SEQ := V_SEQ + 1;

            --DBMS_OUTPUT.PUT_LINE(
              --                 rpad(c_r.responsibility_name, 30, ' ') ||'|'||
                --               rpad(c_r.menu, 30,' ')
                  --         );
            
            P_MENUS_SUB_MENUS (c_r.menu_id, 1) ;       
                

            insert into gvp_datos_01 values (V_SEQ, ' ');
            V_SEQ := V_SEQ + 1;

		--DBMS_OUTPUT.PUT_LINE(' ');
                                  
    END LOOP;

    COMMIT;


END;
/
SPOOL C:\MENUS_PIPES.TXT

SELECT DATO
FROM GVP_DATOS_01
ORDER BY SEQ
/

