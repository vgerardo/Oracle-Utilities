SET SERVEROUTPUT ON
DECLARE
v_jo        JSON_OBJECT_T;
v_ja        JSON_ARRAY_T;
V_jo_proy   JSON_OBJECT_T;
BEGIN
    v_jo := JSON_OBJECT_T.parse (
                    '{"nombre":"Gerardo",
                     "puesto":"oracle programer",
                     "edad":"50",
                     "proyectos":[{"proyecto":"json"},{"proyecto":"xml"},{"proyecto":"otros"}]
                     }'
                     );

    DBMS_OUTPUT.Put_LIne ('Puesto = ' || v_jo.get_String('puesto') );
    DBMS_OUTPUT.Put_LIne ('Edad = '   || v_jo.get_Number('edad') );

    v_ja := v_jo.get_Array ('proyectos');
    DBMS_OUTPUT.Put_LIne ('Array Size = ' || v_ja.get_Size);
    FOR n IN 0..v_ja.get_Size-1 LOOP
        v_jo_proy := JSON_OBJECT_T (v_ja.get(n));
        DBMS_OUTPUT.Put_LIne (n||'-Proyecto = '|| v_jo_proy.get_String('proyecto'));
    END LOOP;

    FOR js IN (
                SELECT *
                FROM JSON_TABLE (
                    v_jo.get_Clob()
                    ,
                                '$[*]'
                                COLUMNS (
                                    nombre varchar2(50)     PATH '$.nombre'
                                    ,edad      number(15)    PATH '$.edad'
                                    ,NESTED PATH '$.projectos[*]' COLUMNS
                                        (
                                        projecto varchar2(50) path '$.projecto'
                                        )
                                    )
                                ) as t
                )
   LOOP          
        DBMS_OUTPUT.put_line ('Registro = '|| js.nombre ||','||js.edad||','||js.projecto);   
    END LOOP;
END;
/