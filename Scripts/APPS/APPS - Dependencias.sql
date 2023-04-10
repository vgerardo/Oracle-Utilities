
SET SERVEROUTPUT ON SIZE 1000000

DECLARE

TYPE dep_campos_type IS VARRAY (2) OF VARCHAR2(30);
TYPE dep_table_type IS TABLE OF dep_campos_type;-- INDEX BY BINARY_INTEGER;

v_dependiente dep_table_type := dep_table_type (dep_campos_type('x', 'x') );

v_cont number(15) := 0;

PROCEDURE dependencias (p_usr varchar2, p_obj varchar2, p_to_usr varchar2) --return varchar2
IS
v_own varchar2(30);
v_obj varchar2(30);
v_typ varchar2(30);
v_existe number(15) := 0;
BEGIN

    IF v_cont > 600 THEN
        return;
    end if;
    v_cont := v_cont + 1;
          
    FOR c IN (
             SELECT referenced_owner usr, referenced_name obj, referenced_type type
              FROM DBA_dependencies  
             WHERE 1=1            
               --AND (owner||'.'||name) <> (referenced_owner||'.'||referenced_name)
               AND referenced_name not in ('DUAL')
               AND referenced_owner <> 'PUBLIC'
--               AND NOT EXISTS ( SELECT 1
--                                FROM DBA_SYNONYMS
--                                WHERE 1=1
--                                 AND OWNER = 'PUBLIC'
--                                 AND TABLE_OWNER = referenced_owner
--                                 AND SYNONYM_NAME LIKE referenced_name
--                            )
               AND NOT EXISTS (
                            -- objetos con GRANT to PUBLIC, no es necesario darle más permisos                        
                            select 1
                            from  sys.all_tab_privs_recd
                            where grantee = 'PUBLIC'
                             AND owner = referenced_owner
                             AND TABLE_NAME LIKE referenced_name
                        )               
               and owner = p_usr
               and name = p_obj
            GROUP BY referenced_owner, referenced_name, referenced_type
            ORDER BY referenced_name
            )
    LOOP
    
        -- antes de buscar sus Sub-Dependencias, valida que el objeto 
        -- no se haya procesado previamente.
        v_existe := 0;            
        --v_cont := v_dependiente.FIRST;
        FOR x IN v_dependiente.FIRST .. v_dependiente.LAST LOOP
            IF c.usr = v_dependiente(x)(1) AND
               c.obj = v_dependiente(x)(2)
            THEN
                v_existe := 1;
                exit;
            END IF;            
            --v_cont := v_dependiente.NEXT (v_cont);
        END LOOP;
        
        if v_existe = 1 then
            CONTINUE; -- El objeto ya se había proceado, así que continua con el sig. ciclo.
        end if;
        
        -- Almacena el objeto en la lista de Dependientes
        v_dependiente.extend;
        v_dependiente( v_dependiente.last ):= dep_campos_type (c.usr, c.obj);   

        -- busca las dependencias del objeto (recursivo)
        dependencias (C.usr, C.obj, p_to_usr);        
        
        IF c.type in ('TABLE', 'VIEW') THEN
            DBMS_OUTPUT.PUT_LINE ('GRANT SELECT ON ' || c.usr ||'.'|| c.obj || ' TO ' || p_to_usr ||';');
            DBMS_OUTPUT.PUT_LINE ('CREATE OR REPLACE SYNONYM ' || p_to_usr ||'.'||c.obj || ' FOR ' || c.usr||'.'|| c.obj ||';');
        
        ELSIF c.type in ('SYNONYM') THEN        
        
            /*SELECT table_owner , table_name
            INTO v_own, v_obj
            FROM ALL_SYNONYMS
            WHERE 1=1
             and owner = c.propietario            
             AND synonym_name = c.objeto
            ;            
            */
            
            /*select OWNER, OBJECT_NAME, OBJECT_TYPE
            INTO v_own, v_obj, v_typ
            from all_objects
            where 1=1
            AND owner = v_own
             AND object_name = v_obj
             AND object_type not in ('PACKAGE BODY') -- para evitar que salgan 2 rows
            ; */           
            
            /*
            IF v_typ IN ('VIEW', 'TABLE') THEN
                DBMS_OUTPUT.PUT_LINE   ('GRANT SELECT ON ' || v_own ||'.'|| v_obj || ' TO ' || p_to_usr ||';');
            
            ELSIF v_typ IN ('PROCEDURE', 'PAQUETE', 'FUNCTION') THEN
                DBMS_OUTPUT.PUT_LINE  ('GRANT EXECUTE ON ' || v_own ||'.'|| v_obj || ' TO ' || p_to_usr ||';');                
            ELSE
                DBMS_OUTPUT.PUT_LINE (V_TYP ||' - '||  v_own ||'.'|| v_obj ||';');
            END IF;
            */
            DBMS_OUTPUT.PUT_LINE   ('CREATE OR REPLACE SYNONYM ' || p_to_usr||'.'||c.obj || ' FOR ' || c.usr ||'.'|| c.obj ||';');
            
        ELSIF c.type in ('PROCEDURE', 'PACKAGE', 'FUNCTION') THEN
            DBMS_OUTPUT.PUT_LINE  ('GRANT EXECUTE ON ' || c.usr ||'.'|| c.obj || ' TO '||p_to_usr ||';');
            DBMS_OUTPUT.PUT_LINE  ('CREATE OR REPLACE SYNONYM ' || p_to_usr||'.'||c.obj || ' FOR ' || c.usr ||'.'|| c.obj ||';');            
        ELSE
            DBMS_OUTPUT.PUT_LINE  (c.Type ||': ' || 'GRANT XXX ' ||c.usr ||'.'|| c.obj || ' TO ' ||p_to_usr ||';');
        END IF;
    
    END LOOP;
            
END dependencias;


BEGIN        
    
    --DBMS_OUTPUT.put_line ('Dependencias de: FND_DESCRIPTIVE_FLEXS');   
    
    dependencias ('APPS', 'GL_FLEXFIELDS_PKG', 'NEXT_ACCNT'); -- Ponerlos en MAYUSCULAS
    
    DBMS_OUTPUT.put_line (v_cont || ' Se crearon permisos para:');   

    IF (v_dependiente.EXISTS(1)) THEN
        v_cont := v_dependiente.FIRST;
        WHILE v_cont IS NOT NULL LOOP
            DBMS_OUTPUT.put_line (v_dependiente(v_cont)(1) ||'.'|| v_dependiente(v_cont)(2));
            v_cont := v_dependiente.NEXT(v_cont);  -- get index of next element
        end loop;
    END IF;
            
END;
/
