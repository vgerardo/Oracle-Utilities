SET SERVEROUTPUT ON 
DECLARE
v_file      UTL_FILE.File_Type;
v_line      varchar2 (32767 CHAR);
v_clob      clob;
v_serial    clob;
v_xml       xmltype;
BEGIN

    DBMS_LOB.CreateTemporary (v_clob, TRUE, DBMS_LOB.Session);

    IF UTL_FILE.Is_Open (v_file) THEN
        UTL_FILE.FClose (v_file);
    END IF;
    
    --
    -- El archivo se debe subir a directorio del FTP:
    -- /u01/oracle/DEV/inbound/xxcmxcarga/
    -- /u01/oracle/LANDOEA/inbound/xxcmxcarga/
    --
    v_file := UTL_FILE.FOPEN ( location     => 'XXCMX_IN_FILES'
                             , filename     => 'Shipping Consolidated.xml'
                             , open_mode    => 'r'
                             , max_linesize => 32767
                             );
    
    -- 
    -- Carga el contenido del archivo a una variable CLOB
    --
    LOOP
    begin
        UTL_FILE.Get_Line (v_file, v_line);
        DBMS_LOB.Append (v_clob, v_line);
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN EXIT; 
    end;
    END LOOP;

    UTL_FILE.FClose (v_file);

    DBMS_OUTPUT.Put_Line ( '=========== XML NORMAL ==================' );
    --DBMS_OUTPUT.Put_Line ( v_clob );
/*
    --
    -- XMLSERIALIZE: Para quitarle espacios y saltos de linea.
    --
    v_xml := XMLType (v_clob);
     SELECT 
        XMLSERIALIZE (document v_xml as CLOB NO INDENT) --DOCUMENT, cuando sea XMLType
        --XMLSERIALIZE (content v_clob) --CONTENT, XML no root y tipo VARCHAR2, CLOB, BLOB
    INTO v_serial
    FROM DUAL;


    DBMS_OUTPUT.Put_Line ( '================= XML SERIALIZADO ==================' );
    --DBMS_OUTPUT.Put_Line ( v_serial );

    INSERT INTO my_xml VALUES (
         'cristina'                                          --status
        , xmltype(v_serial)                              --payload
        );
        
    COMMIT;
*/
END;
/

--
--Comprobar la carga
--
select * from my_xml;

DELETE my_xml;