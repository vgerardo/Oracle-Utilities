
SET SERVEROUTPUT ON


DECLARE

v_group_id          number(15);
v_request_id        number(15);
v_je_batch_id       number(15);
v_run_id            number(15) := 0;

v_return_status     varchar2(50);
v_ledger_id         number(15) := 2022; --2022=POS_LD_POSADAS
v_period_name       varchar2(20);

v_wait_stts         BOOLEAN;
v_wait_dummy		varchar2(500);
          
PROCEDURE INSERT_GL_INTERFACE (
            p_STATUS                        GL_INTERFACE.STATUS%TYPE
            ,p_DATE_CREATED                 GL_INTERFACE.DATE_CREATED%TYPE
            ,p_CREATED_BY                   GL_INTERFACE.CREATED_BY%TYPE
            ,p_LEDGER_ID                    GL_INTERFACE.LEDGER_ID%TYPE
            ,p_ACCOUNTING_DATE              GL_INTERFACE.ACCOUNTING_DATE%TYPE
            ,p_CURRENCY_CODE                GL_INTERFACE.CURRENCY_CODE%TYPE
            ,p_ACTUAL_FLAG                  GL_INTERFACE.ACTUAL_FLAG%TYPE
            ,p_CURRENCY_CONVERSION_DATE     GL_INTERFACE.CURRENCY_CONVERSION_DATE%TYPE
            ,p_CURRENCY_CONVERSION_TYPE     GL_INTERFACE.USER_CURRENCY_CONVERSION_TYPE%TYPE
            ,p_CURRENCY_CONVERSION_RATE     GL_INTERFACE.CURRENCY_CONVERSION_RATE%TYPE
            ,p_ENTERED_DR                   GL_INTERFACE.ENTERED_DR%TYPE
            ,p_ENTERED_CR                   GL_INTERFACE.ENTERED_CR%TYPE
            --,p_ACCOUNTED_DR
            --,p_ACCOUNTED_CR
            ,p_PERIOD_NAME                  GL_INTERFACE.PERIOD_NAME%TYPE
            ,p_CODE_COMBINATION_ID          GL_INTERFACE.CODE_COMBINATION_ID%TYPE
            ,p_USER_JE_CATEGORY_NAME        GL_INTERFACE.USER_JE_CATEGORY_NAME%TYPE
            ,p_USER_JE_SOURCE_NAME          GL_INTERFACE.USER_JE_SOURCE_NAME%TYPE
            ,p_GROUP_ID                     GL_INTERFACE.GROUP_ID%TYPE
            ,p_REFERENCE1                   GL_INTERFACE.REFERENCE1%TYPE
            ,p_REFERENCE4                   GL_INTERFACE.REFERENCE4%TYPE
            ,p_REFERENCE5                   GL_INTERFACE.REFERENCE5%TYPE
            --,p_reference10                GL_INTERFACE.REFERENCE10%TYPE --Line Description
        )
IS       
BEGIN    

--REFERENCE1 Batch name. Its structure is: <Reference1><Source><Request ID><Balance Type ><Group ID>
--REFERENCE2 Batch description; if one is not defined, it will look like: Journal Import <Source><Request ID>
--REFERENCE4 Journal entry name; with the format: <Category><Currency>< Conversion Type >< Conversion Rate>< Conversion Date ><Encumbrance Type ID><Budget Version>. Some of this information depends on the journal type.
--REFERENCE5 Journal entry description; if one is not given, it will follow this format: Journal Import - Request ID
--REFERENCE6 Reference or journal number. If it is not defined, it is automatically defined as Journal Import Created.
--REFERENCE7 Reverse Journal Flag
--REFERENCE8 Reverse Journal Period
--REFERENCE10 Journal line description
--REFERENCE21...30
--    The values and meanings for these fields depend on the Journal Source and Release. 
--    They store information used to identify and match the journal with the source document. 
--    The values for these fields map to REFERENCE_1 through REFERENCE_10 in the GL_JE_LINES table and the GL_IMPORT_REFERENCES table.

    INSERT INTO GL_INTERFACE (
            STATUS
            ,DATE_CREATED
            ,CREATED_BY
            ,LEDGER_ID
            ,ACCOUNTING_DATE
            ,CURRENCY_CODE
            ,ACTUAL_FLAG
            ,CURRENCY_CONVERSION_DATE
            ,USER_CURRENCY_CONVERSION_TYPE
            ,CURRENCY_CONVERSION_RATE
            ,ENTERED_DR
            ,ENTERED_CR
            --,ACCOUNTED_DR
            --,ACCOUNTED_CR
            ,PERIOD_NAME
            ,CODE_COMBINATION_ID
            ,USER_JE_CATEGORY_NAME
            ,USER_JE_SOURCE_NAME
            ,GROUP_ID
            ,REFERENCE1
            ,REFERENCE4  
            ,REFERENCE5
            --,reference10 --Line Description
    ) VALUES (
            P_STATUS
            ,P_DATE_CREATED
            ,P_CREATED_BY
            ,P_LEDGER_ID
            ,P_ACCOUNTING_DATE
            ,P_CURRENCY_CODE
            ,P_ACTUAL_FLAG
            ,P_CURRENCY_CONVERSION_DATE
            ,P_CURRENCY_CONVERSION_TYPE
            ,P_CURRENCY_CONVERSION_RATE
            ,P_ENTERED_DR
            ,P_ENTERED_CR
            --,ACCOUNTED_DR
            --,ACCOUNTED_CR
            ,P_PERIOD_NAME
            ,P_CODE_COMBINATION_ID
            ,P_USER_JE_CATEGORY_NAME
            ,P_USER_JE_SOURCE_NAME
            ,P_GROUP_ID
            ,P_REFERENCE1 --Batch Name
            ,P_REFERENCE4 --Journal Name
            ,P_REFERENCE5 --Description
            --,p_reference10 --Line Description
    );
END ;




BEGIN

    -- ------------------------------------------------------
    -- Inicializa Entorno
    FND_GLOBAL.apps_initialize ( 
                         user_id      => 5801--1561   -- CONE-RCABALLEROS
                        ,resp_id      => 50747  -- GRP_ALL_GL_CONE_GTE
                        ,resp_appl_id => 101    -- SQLGL
                 );        
    FND_MSG_PUB.initialize;
     

    SELECT gl_journal_import_s.NEXTVAL 
    INTO v_group_id 
    FROM DUAL;

--    select access_set_id
--     from gl_access_sets
--     where name like 'POS_LD_POSADAS'
--     ;
--     

    INSERT_GL_INTERFACE (
            'NEW'
            ,SYSDATE
            ,1561
            ,2022
            ,SYSDATE
            ,'MXN'
            ,'A'
            ,SYSDATE
            ,'User'
            ,1
            ,1010   --p_entered_dr
            ,0      --p_entered_cr
            --,1010
            --,0
            ,'JUL-19'
            ,4143591
            ,'CONE Contabilizacion'
            ,'Manual'
            ,v_group_id        
            ,'Mi Poliza Provac'
            ,'0041 Revierte PIF KIVAC MCLUBG_CAPT LOC_439674452 JUL-19' --Journal Name
            ,'Mi Descripcion'
    );



    INSERT_GL_INTERFACE (
            'NEW'
            ,SYSDATE
            ,1561
            ,2022
            ,SYSDATE
            ,'MXN'
            ,'A'
            ,SYSDATE
            ,'User'
            ,1
            ,0
            ,1010
            --,1010
            --,0
            ,'JUL-19'
            ,4143591
            ,'CONE Contabilizacion'
            ,'Manual'
            ,v_group_id
            ,'Mi Poliza Provac' --batch name
            ,'0041 Revierte PIF KIVAC MCLUBG_CAPT LOC_439674452 JUL-19' --Journal Name
            ,'Mi Descripcion'
    );

    /*
    apps.gl_journal_import_pkg.populate_interface_control (
        user_je_source_name => 'Manual',
        GROUP_ID            => v_group_id,
        set_of_books_id     => 2022,
        interface_run_id    => v_run_id,
        table_name          => 'GL_INTERFACE',
        processed_data_action=>'S' --S=save data into interface
    );
    COMMIT; */   
    
    --
    --  Program - Import Journals (Programa - Importar Asientos)
    --
    
    v_request_id := FND_REQUEST.submit_request (
                            'SQLGL',
                            'GLLEZLSRS', -- Short Name of program
                            NULL,
                            NULL,
                            FALSE,
                            1000, --Data Access Set ID
                            'Manual',      --Source 'Freight'
                            2022,           --Ledger
                            v_group_id,     --Group ID
                             'N',         --Post Errors to Suspense
                             'N',         --Create Summary Journals
                             'O'          --Import DFF
                    );

        /*
        v_request_id := fnd_request.submit_request (
                            application => 'SQLGL', -- application short name
                             program => 'GLLEZL', -- program short name
                             description => NULL, -- program name
                             start_time => NULL, -- start date
                             sub_request => FALSE, -- sub-request
                              argument1 => v_run_id, -- interface run id
                              argument2 => 1000, -- set of books id
                              argument3 => 'Y', -- error to suspense flag
                              argument4 => NULL, -- from accounting date
                              argument5 => NULL, -- to accounting date
                              argument6 => 'N', -- create summary flag
                              argument7 => 'O', -- import desc flex flag
                              argument8 => 'Y' 
                                    );*/

    DBMS_OUTPUT.put_line ('Se envio la solicitud: ' || v_request_id);

    IF v_request_id = 0 THEN        
        ROLLBACK;
    ELSE
        COMMIT;
        
        v_wait_stts  := fnd_concurrent.WAIT_FOR_REQUEST (
                                     request_id      => v_request_id
                                    ,INTERVAL        => 30   --interval Number of seconds to wait between checks
                                    ,max_wait        => 5*60 --Maximum number of seconds to wait for the request completion
                                     -- out arguments
                                    ,phase           => v_wait_dummy
                                    ,STATUS          => v_wait_dummy
                                    ,dev_phase       => v_wait_dummy
                                    ,dev_status      => v_wait_dummy
                                    ,message         => v_wait_dummy
                            );
        
        -- Revisa la Interface
        FOR x in (                    
                    SELECT status
                    into v_return_status
                    FROM GL_INTERFACE
                    WHERE request_id IN (
                                        select request_id
                                        from fnd_concurrent_requests
                                        where parent_request_id = v_request_id
                                    )
                )
        LOOP
            DBMS_OUTPUT.put_line ('Status = ' || x.status );
        END LOOP;

/*
        SELECT  gl_je_posting_s.nextval
        into v_run_id
        FROM DUAL;        
    
        update gl_je_batches set
        posting_run_id = v_run_id
        ,status = 'S'   --Selected for posting
        WHERE 1=1
           and default_period_name = 'JUL-19'
           AND chart_of_accounts_id = 50393
           AND name like 'Mi Poliza Provac%'
           and group_id = v_group_id
        ;
        COMMIT;
 
    --
    --  Posting: Single Ledger (Programa - Importar Asientos)
    --
    v_request_id := FND_REQUEST.submit_request (
                            'SQLGL',
                            'GLPPOSS', -- Posting: Single Ledger
                            NULL,
                            NULL,
                            FALSE,
                            2022,           --Ledger
                            1002,
                            50393,          --char_of_accounts_id
                            v_run_id
                    );
        commit;                    
*/
    END IF;
    
    DBMS_OUTPUT.put_line ('v_run_id: ' || v_run_id);
    DBMS_OUTPUT.put_line ('v_group_id: ' || v_group_id);
        
    -- verificar
--    SELECT DISTINCT JE_BATCH_ID
--    INTO v_je_batch_id
--    FROM GL_JE_BATCHES
--    WHERE GROUP_ID = v_group_id
--    ;
     
    --
    -- Journal Post program
    --
END;
