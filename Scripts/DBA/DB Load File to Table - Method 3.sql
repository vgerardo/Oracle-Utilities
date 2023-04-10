SET SERVEROUTPUT ON 
DECLARE
v_bfile     BFILE;
v_amount    number(15) := 4086; -- Siempre multiplos de 1024
v_offset    number(15) := 1;
v_buffer    raw (4086);

v_chunk     varchar2(4086);
v_clob      clob;
v_xml       xmltype;
v_serveroutput number(15) := 0;

BEGIN

    --
    -- El archivo se debe subir a directorio del FTP:
    -- /u01/oracle/DEV/inbound/xxcmxcarga/
    -- /u01/oracle/LANDOEA/inbound/xxcmxcarga/
      
    v_bfile := BFILENAME ( 'XXCMX_IN_FILES', 'Shipping Consolidated.xml');
  
    DBMS_LOB.FileOpen ( file_loc  => v_bfile );
  
    --DBMS_LOB.LOADFROMFILE 

    DBMS_LOB.CreateTemporary (v_clob, TRUE, DBMS_LOB.Session);
  
    -- 
    -- Carga el contenido del archivo a una variable CLOB
    --
    LOOP
    begin    
        DBMS_LOB.Read ( 
                        file_loc  => v_bfile
                       ,amount    => v_amount
                       ,offset    => v_offset
                       ,buffer    => v_buffer
                       );
        
        v_offset := v_offset + v_amount;
        
        v_chunk := UTL_RAW.Cast_To_Varchar2 (v_buffer);
        
        v_serveroutput := v_serveroutput + length (v_chunk);
        IF v_serveroutput < 1000000 THEN
            DBMS_OUTPUT.Put_Line (v_chunk);
        END IF;
        
        DBMS_LOB.Append (v_clob, v_chunk);
        EXCEPTION 
            WHEN NO_DATA_FOUND THEN EXIT; 
    end;
    END LOOP;

    DBMS_LOB.FileClose (v_bfile);
    --LOADFROMFILE 

    DBMS_OUTPUT.Put_Line ( 'FIN=========== DATOS DEL ARCHIVO ==================FIN' );
    

/*
    --
    -- XMLSERIALIZE: Para quitarle espacios y saltos de linea.
    --
    v_xml := XMLType (v_clob);
     SELECT 
        XMLSERIALIZE (document v_xml as CLOB NO INDENT) --DOCUMENT, cuando sea XMLType
        --XMLSERIALIZE (content v_clob) --CONTENT, XML no root y tipo VARCHAR2, CLOB, BLOB
    INTO v_clob
    FROM DUAL;


    DBMS_OUTPUT.Put_Line ( '================= XML SERIALIZADO ==================' );
    --DBMS_OUTPUT.Put_Line ( v_clob );
*/
    INSERT INTO my_xml VALUES (
         to_char(sysdate, 'yyyy-mm-dd hh24:mi:ss')     --fecha
        , xmltype(v_clob)                              --payload
        );
        
    COMMIT;

END;
/

--
--Comprobar la carga
--
select * from my_xml;
--create table my_xml (fecha varchar2(50), payload xmltype);

DELETE my_xml;