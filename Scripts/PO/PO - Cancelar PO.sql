set serveroutput on

declare

v_api_status    varchar2(100)    := 'S';
v_dummy         varchar2(4000);
v_segment1      varchar2(20)     :=  'PO310409';

begin

    dbms_application_info.set_client_info(83); 
    fnd_client_info.set_org_context('83');

    fnd_global.apps_initialize (user_id => 37709,  /* SYS ADMIN */ 
                                resp_id => 50202,
                                resp_appl_id => 201
                               );
          
    mo_global.set_policy_context ('S', 83 );        

    mo_global.init ;    
    
    apps.po_document_control_pub.control_document
                              (p_api_version           => 1.0,
                               p_init_msg_list         => 'T',
                               p_commit                => 'T',
                               x_return_status         => v_api_status,
                               p_doc_type              => 'PO',
                               p_doc_subtype           => 'STANDARD',
                               p_doc_id                => NULL,
                               p_doc_num               => v_segment1,
                               p_release_id            => NULL,
                               p_release_num           => NULL,
                               p_doc_line_id           => NULL,
                               p_doc_line_num          => null,
                               p_doc_line_loc_id       => NULL,
                               p_doc_shipment_num      => NULL,
                               p_action                => 'CANCEL',
                               p_action_date           => SYSDATE,
                               p_cancel_reason         => 'Interface con Ariba',
                               p_cancel_reqs_flag      => 'N',
                               p_print_flag            => NULL,
                               p_note_to_vendor        => NULL,
                               p_use_gldate            => 'N'
                              );


    IF (UPPER (v_api_status) <> 'S') THEN
    
   --        ROLLBACK;
           DBMS_OUTPUT.PUT_LINE ('No se pudo cancelar la PO= ' || v_segment1);         
           
            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP
                           
               v_dummy := SUBSTR(fnd_msg_pub.get (p_msg_index   => i
                                                 ,p_encoded     => 'F'
                                                 )
                                 , 0, 4000
                                 )  ;
                             
                dbms_output.put_line (v_dummy);
                                                                                                      
            END LOOP;           
           
    ELSE    
        
     --   COMMIT;
        DBMS_OUTPUT.PUT_LINE ('Se canceló la PO= ' || v_segment1);       

           
    END IF;


    rollback;

end;
/