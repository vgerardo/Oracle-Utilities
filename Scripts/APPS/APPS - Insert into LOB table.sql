
declare
v_bfile BFILE;
v_lob   BLOB;
begin

-- 
-- El archivo hay que subirlo al FTP de Oracle
--
v_bfile:= bfilename ('GRP_INCOMING','layout_altas_ejemplo.xlsx' );

Insert into FND_LOBS (FILE_ID,FILE_NAME,FILE_CONTENT_TYPE,FILE_DATA,UPLOAD_DATE,EXPIRATION_DATE,PROGRAM_NAME,PROGRAM_TAG,LANGUAGE,ORACLE_CHARSET,FILE_FORMAT) 
    values (
    2985128,
    'layout_altas_ejemplo.xlsx','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', EMPTY_BLOB(),
    to_date('01-JAN-20','DD-MON-RR'),to_date('31-JAN-30','DD-MON-RR'),
    'GRP_INV_MAC','Altas','US','WE8MSWIN1252','binary'
    ) RETURNING FILE_DATA INTO v_lob;


DBMS_LOB.open (v_bfile, DBMS_LOB.LOB_READONLY);
DBMS_LOB.LOADFROMFILE (v_lob, v_bfile, DBMS_LOB.GETLENGTH (v_bfile));
DBMS_LOB.CLOSE (v_bfile);
COMMIT;

end;
/
