set serveroutput ON

DECLARE
l_rowid                 ROWID;
l_attached_document_id  NUMBER;
l_document_id           NUMBER;
l_media_id              NUMBER;
l_category_id           NUMBER;
l_seq_num               NUMBER;
l_blob_data             BLOB;
l_blob                  BLOB;
l_bfile                 BFILE;
l_byte                  NUMBER;
l_fnd_user_id           NUMBER(15)  := 1134;
l_short_datatype_id     NUMBER;
x_blob                  BLOB;
fils                    BFILE;
blob_length             integer;
l_entity_name           varchar2(100) := 'AR_CASH_RECEIPTS'; --Must be defined before or use existing ones. Table: FND_DOCUMENT_ENTITIES
l_category_name         VARCHAR2(100) := 'Miscellaneous'; --Must be defined before or use existing ones.

l_pk1_value             fnd_attached_documents.pk1_value%TYPE := 8292982;  --primary key, identifies the information
l_description           fnd_documents_tl.description%type:= 'Factura Comision';
l_filename              VARCHAR2(240) := 'factura_comision_test1.xml';

BEGIN

    --Enter USER_ID,RESP_ID,RESP_APPL_ID
    fnd_global.apps_initialize    (
                    user_id        => l_fnd_user_id,     -- ext-gvargas
                    resp_id        => 50834,    -- GRP_ALL_AR_CONE_GTE
                    resp_appl_id    => 222     -- AR
    );
    mo_global.init ('AR');

    SELECT fnd_documents_s.NEXTVAL
    INTO l_document_id
    FROM DUAL;
    
    SELECT fnd_attached_documents_s.NEXTVAL
    INTO l_attached_document_id
    FROM DUAL;

    SELECT NVL (MAX (seq_num), 0) + 10
    INTO l_seq_num
    FROM fnd_attached_documents
    WHERE pk1_value = l_pk1_value AND entity_name = l_entity_name;

    
    --Get Data type id for Short Text types of attachments
    SELECT datatype_id
    INTO l_short_datatype_id
    FROM apps.fnd_document_datatypes
    WHERE LANGUAGE = 'ESA'
      AND NAME = 'FILE';

    --Select Category id for Attachments
    SELECT category_id
    INTO l_category_id
    FROM apps.fnd_document_categories_vl
    WHERE USER_NAME = l_category_name;
    
    --Select nexvalues of document id, attached document id and
    SELECT apps.fnd_documents_s.NEXTVAL,
    apps.fnd_attached_documents_s.NEXTVAL
    into l_document_id,l_attached_document_id
    FROM DUAL;

    SELECT fnd_lobs_s.nextval
    INTO l_media_id
    FROM dual;
        

    --This package allows user to share file across multiple orgs or restrict to single org
    FND_DOCUMENTS_PKG.Insert_Row (
                        x_rowid             => l_rowid,
                        x_document_id       => l_document_id,
                        x_datatype_id       => l_short_datatype_id,
                        x_publish_flag      => 'Y', --This flag allow the file to share across multiple organization
                        x_category_id       => l_category_id,
                        x_security_type     => 2,
                        X_security_id       => 2022, --Security ID defined in your Attchments, Usaully SOB ID/ORG_ID                        
                        x_usage_type        => 'S',
                        x_language          => 'ESA',
                        x_description       => l_description,
                        x_file_name         => l_filename,
                        x_media_id          => l_media_id,
                        x_created_by        => l_fnd_user_id,
                        x_creation_date     => SYSDATE,
                        x_last_updated_by   => l_fnd_user_id,                        
                        x_last_update_date  => SYSDATE,
                        x_last_update_login => fnd_profile.VALUE('LOGIN_ID')
                    );


    -- Description informations will be stored in below table based on languages.
    FND_DOCUMENTS_PKG.Insert_tl_Row (
                        x_document_id       => l_document_id,
                        x_language          => 'ESA',
                        x_description       => l_description,
                        x_creation_date     => SYSDATE,
                        x_created_by        => l_fnd_user_id,
                        x_last_update_date  => SYSDATE,
                        x_last_updated_by   => l_fnd_user_id,
                        x_last_update_login => fnd_profile.VALUE('LOGIN_ID')
                    );


    FND_ATTACHED_DOCUMENTS_PKG.Insert_Row (
                            x_rowid                 => l_rowid,
                            x_attached_document_id  => l_attached_document_id,
                            x_document_id           => l_document_id,
                            x_seq_num               => l_seq_num,
                            x_entity_name           => l_entity_name,
                            x_column1               => NULL,
                            x_pk1_value             => l_pk1_value,
                            x_pk2_value             => NULL,
                            x_pk3_value             => NULL,
                            x_pk4_value             => NULL,
                            x_pk5_value             => NULL,
                            x_automatically_added_flag => 'N',
                            x_datatype_id           => 6,
                            x_category_id           => l_category_id,
                            x_security_type         => 2,
                            X_security_id           => 2022, --Security ID defined in your Attchments, Usaully SOB ID/ORG_ID 
                            x_publish_flag          => 'Y', x_language => 'US', 
                            x_description           => l_description,
                            x_file_name             => l_filename, 
                            x_media_id              => l_media_id,
                            x_creation_date         => SYSDATE,
                            x_created_by            => l_fnd_user_id,
                            x_last_update_date      => SYSDATE,
                            x_last_updated_by       => l_fnd_user_id,
                            x_last_update_login     => fnd_profile.VALUE('LOGIN_ID')
                            
                        );
                        
    --COMMIT;
    
    dbms_output.put_line('MEDIA ID created IS ' || l_media_id);

END;
/