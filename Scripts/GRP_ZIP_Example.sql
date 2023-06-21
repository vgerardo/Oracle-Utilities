--
-- Ejemplo de USO de GRP_ZIP
--

set serveroutput on 

declare

v_lista     bolinf.GRP_ZIP.file_list;
v_lob       blob;
v_zip_lob   blob;
v_texto     varchar2(4000);

v_file_clob clob;
v_file_size integer := dbms_lob.lobmaxsize;
v_dest_offset integer := 1;
v_src_offset integer := 1;
v_blob_csid number := dbms_lob.default_csid;
v_lang_context number := dbms_lob.default_lang_ctx;
v_warning integer;
v_length number;
begin

    select file_data
    into v_lob
    from fnd_lobs
    where file_id = 966332
    ;
    
    v_lista := bolinf.GRP_ZIP.file_list();
    v_lista := bolinf.GRP_ZIP.get_file_list (v_lob, '');
        
    dbms_output.put_line  ('registro(s): '||v_lista.count);
    
    for x IN 1..v_lista.count loop
        v_texto := DBMS_LOB.substr(v_lista(x), 260, 1);        
        dbms_output.put_line ('linea :'||x||' ' || v_texto);
    end loop;

    v_zip_lob := bolinf.GRP_ZIP.get_file    ( v_lob, 'FACTURAS VISITA 1XPAT/TRASLADOS/taxi  Corpo a Polanco 05 Agos.xml', null);  
    dbms_lob.createtemporary(v_file_clob, true);
    dbms_lob.converttoclob(v_file_clob,
                            v_zip_lob,
                            v_file_size,
                            v_dest_offset,
                            v_src_offset,
                            v_blob_csid,
                            v_lang_context,
                            v_warning);
    v_texto := DBMS_LOB.substr(v_file_clob, 200, 1);
    
    dbms_output.put_line (' ');
    dbms_output.put_line ('Contenido : ' || v_texto);


end;
/



declare
  zip_files GRP_ZIP.file_list;
  v_lob       blob;
begin


    select file_data
    into v_lob
    from fnd_lobs
    where file_id = 966332
    ;

  --zip_files  := GRP_zip.get_file_list( 'GRP_OUTGOING', 'fc_VCI0004041R0.zip' );
  zip_files  := GRP_zip.get_file_list( v_lob, '');
  
  for i in zip_files.first() .. zip_files.last  loop
    dbms_output.put_line( zip_files( i ) );
--    dbms_output.put_line( utl_raw.cast_to_varchar2( 
--                                          GRP_ZIP.get_file ('GRP_OUTGOING', 'fc_VCI0004041R0.zip', zip_files(i) )                     
--                        ));
--                    
    if lower(zip_files( i )) like '%.xml' then
    dbms_output.put_line( utl_raw.cast_to_varchar2( 
                                            GRP_ZIP.get_file (v_lob, zip_files(i))
                        ));
    end if;
                    
  end loop;
end;
/