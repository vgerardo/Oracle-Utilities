
SET SERVEROUTPUT ON


DECLARE

v_return_status     varchar2(50);
v_msg_count         number(15);
v_msg_data          varchar2(1000);
v_application_id    number(15) := 222; --101=SQLGL
v_ledger_id         number(15) := 2022; --POS_LD_POSADAS
v_ae_header_id      number(15);
v_event_id          number(15);
v_period_name       varchar2(20);
v_ae_line_num       integer;
v_completion_retcode    VARCHAR2(10);

BEGIN

    -- ------------------------------------------------------
    -- Inicializa Entorno
    /*FND_GLOBAL.apps_initialize ( 
                             user_id      => 1561   -- CONE-RCABALLEROS
                            ,resp_id      => 50747  -- GRP_ALL_GL_CONE_GTE
                            ,resp_appl_id => 101    -- SQLGL
                           );        
    fnd_msg_pub.initialize;*/


    mo_global.init('AR');
    mo_global.set_policy_context('S',85); -- S for single Operating Unit and M for multiple Operating Unit

    fnd_global.apps_initialize( user_id => 1134,
                                        resp_id => 50834,
                                        resp_appl_id  => 222
                                        ); 
                         

--    MO_GLOBAL.set_policy_context('S', v_org_id); 
--    MO_GLOBAL.init('SQLAP'); -- product short name: AR, SQLAP
--    CEP_STANDARD.init_security; --The table CE_SECURITY_PROFILES_GT is populated through this call 
    -- ------------------------------------------------------


XLA_JOURNAL_ENTRIES_PUB_PKG.create_journal_entry_header (
                                p_api_version       => 1.0,
                                p_init_msg_list     => fnd_api.g_true,
                                p_application_id    => v_application_id,
                                p_ledger_id         => v_ledger_id,
                                p_legal_entity_id   => 26278,
                                P_Gl_Date           => sysdate,
                                p_description       => 'prueba de gvp',
                                p_je_category_name  => '17',
                                p_balance_type_code => 'A', --A=actual B=budged
                                p_budget_version_id => NULL
                                ,p_reference_date         => NULL
                                ,p_budgetary_control_flag => null
                                ,p_attribute_category     => NULL
                                ,p_attribute1             => NULL
                                ,p_attribute2             => NULL
                                ,p_attribute3             => NULL
                                ,p_attribute4             => NULL
                                ,p_attribute5             => NULL
                                ,p_attribute6             => NULL
                                ,p_attribute7             => NULL
                                ,p_attribute8             => NULL
                                ,p_attribute9             => NULL
                                ,p_attribute10            => NULL
                                ,p_attribute11            => NULL
                                ,p_attribute12            => NULL
                                ,p_attribute13            => NULL
                                ,p_attribute14            => NULL
                                ,p_attribute15            => NULL
                              ,x_return_status          => v_return_status
                              ,x_msg_count              => v_msg_count
                              ,x_msg_data               => v_msg_data
                              ,x_ae_header_id           => v_ae_header_id
                              ,x_event_id               => v_event_id

    );


if v_return_status != FND_API.G_RET_STS_SUCCESS then
    DBMS_OUTPUT.put_line ('HORROR!!!!' );
    DBMS_OUTPUT.put_line (v_msg_data);
    FOR i IN 1 .. fnd_msg_pub.count_msg
    LOOP                   
       v_msg_data := SUBSTR(fnd_msg_pub.get (p_msg_index   => i
                                         ,p_encoded     => 'F'
                                         )
                         , 0, 4000
                         )  ;              
        dbms_output.put_line ( to_char(i) || ': '||v_msg_data);
    END LOOP; 
end if;

DBMS_OUTPUT.put_line ('Return Status Header= ' || v_return_status );
DBMS_OUTPUT.put_line ('Header ID = ' || v_ae_header_id );

if v_ae_header_id is not null then
        
        XLA_JOURNAL_ENTRIES_PUB_PKG.create_journal_entry_line  (
                                       p_api_version                => 1.0
                                      ,p_init_msg_list              => fnd_api.g_true
                                      ,p_application_id		        => v_application_id
                                      ,p_ae_header_id               => v_ae_header_id
                                      ,p_displayed_line_number	    => 1
                                      ,p_code_combination_id        => 4143591
                                      ,p_gl_transfer_mode          	=> 'S' --Detail, Summary
                                      ,p_accounting_class_code	    => 'ACCRUAL'
                                      ,p_currency_code          	=> 'MXN'
                                      ,p_entered_dr          	    => 1001
                                      ,p_entered_cr	       		    => 0
                                      ,p_accounted_dr		        => 1001
                                      ,p_accounted_cr		        => 0
                                      ,p_conversion_type		    => 'User' -- Corporate, User
                                      ,p_conversion_date   		    => sysdate
                                      ,p_conversion_rate   		    => 1
                                      ,p_party_type_code          	=> NULL
                                      ,p_party_id          		    => NULL
                                      ,p_party_site_id          	=> NULL
                                      ,p_description          	    => 'Prueba de linea de GVP'
                                      ,p_statistical_amount         => NULL
                                      ,p_jgzz_recon_ref          	=> NULL
                                      ,p_attribute_category		    => NULL
                                      ,p_encumbrance_type_id        => NULL
                                      ,p_attribute1			        => NULL
                                      ,p_attribute2			        => NULL
                                      ,p_attribute3			        => NULL
                                      ,p_attribute4			        => NULL
                                      ,p_attribute5			        => NULL
                                      ,p_attribute6			        => NULL
                                      ,p_attribute7			        => NULL
                                      ,p_attribute8			        => NULL
                                      ,p_attribute9			        => NULL
                                      ,p_attribute10		        => NULL
                                      ,p_attribute11		        => NULL
                                      ,p_attribute12		        => NULL
                                      ,p_attribute13		        => NULL
                                      ,p_attribute14		        => NULL
                                      ,p_attribute15		        => NULL
                                      ,x_return_status              => v_return_status
                                      ,x_msg_count                  => v_msg_count
                                      ,x_msg_data                   => v_msg_data
                                      ,x_ae_line_num             	=> v_ae_line_num
                  );

        if v_return_status != FND_API.G_RET_STS_SUCCESS then
            DBMS_OUTPUT.put_line ('HORROR en LINEAS!!!!' );
            DBMS_OUTPUT.put_line (v_msg_data);
            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP                   
               v_msg_data := SUBSTR(fnd_msg_pub.get (p_msg_index   => i
                                                 ,p_encoded     => 'F'
                                                 )
                                 , 0, 4000
                                 )  ;              
                dbms_output.put_line ( to_char(i) || ': '||v_msg_data);
            END LOOP; 
        end if;

        DBMS_OUTPUT.put_line ('Return Status Lines 1= ' || v_return_status );
        DBMS_OUTPUT.put_line ('Line ID 1= ' || v_ae_line_num );

        XLA_JOURNAL_ENTRIES_PUB_PKG.create_journal_entry_line  (
                                       p_api_version                => 1.0
                                      ,p_init_msg_list              => fnd_api.g_true
                                      ,p_application_id		        => v_application_id
                                      ,p_ae_header_id               => v_ae_header_id
                                      ,p_displayed_line_number	    => 2
                                      ,p_code_combination_id        => 4143591
                                      ,p_gl_transfer_mode          	=> 'S' --Detail, Summary
                                      ,p_accounting_class_code	    => 'ACCRUAL'
                                      ,p_currency_code          	=> 'MXN'
                                      ,p_entered_dr          	    => 0
                                      ,p_entered_cr	       		    => 1001
                                      ,p_accounted_dr		        => 0
                                      ,p_accounted_cr		        => 1001
                                      ,p_conversion_type		    => 'User' -- Corporate, User
                                      ,p_conversion_date   		    => sysdate
                                      ,p_conversion_rate   		    => 1
                                      ,p_party_type_code          	=> NULL
                                      ,p_party_id          		    => NULL
                                      ,p_party_site_id          	=> NULL
                                      ,p_description          	    => 'Prueba de linea de GVP'
                                      ,p_statistical_amount         => NULL
                                      ,p_jgzz_recon_ref          	=> NULL
                                      ,p_attribute_category		    => NULL
                                      ,p_encumbrance_type_id        => NULL
                                      ,p_attribute1			        => NULL
                                      ,p_attribute2			        => NULL
                                      ,p_attribute3			        => NULL
                                      ,p_attribute4			        => NULL
                                      ,p_attribute5			        => NULL
                                      ,p_attribute6			        => NULL
                                      ,p_attribute7			        => NULL
                                      ,p_attribute8			        => NULL
                                      ,p_attribute9			        => NULL
                                      ,p_attribute10		        => NULL
                                      ,p_attribute11		        => NULL
                                      ,p_attribute12		        => NULL
                                      ,p_attribute13		        => NULL
                                      ,p_attribute14		        => NULL
                                      ,p_attribute15		        => NULL
                                      ,x_return_status              => v_return_status
                                      ,x_msg_count                  => v_msg_count
                                      ,x_msg_data                   => v_msg_data
                                      ,x_ae_line_num             	=> v_ae_line_num
                  );

        if v_return_status != FND_API.G_RET_STS_SUCCESS then
            DBMS_OUTPUT.put_line ('HORROR en LINEAS!!!!' );
            DBMS_OUTPUT.put_line (v_msg_data);
            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP                   
               v_msg_data := SUBSTR(fnd_msg_pub.get (p_msg_index   => i
                                                 ,p_encoded     => 'F'
                                                 )
                                 , 0, 4000
                                 )  ;              
                dbms_output.put_line ( to_char(i) || ': '||v_msg_data);
            END LOOP; 
        end if;

        
        DBMS_OUTPUT.put_line ('Return Status Lines 2= ' || v_return_status );
        DBMS_OUTPUT.put_line ('Line ID 2= ' || v_ae_line_num );

end if;


if v_ae_header_id is not null AND 
   v_ae_line_num IS NOT NULL AND 
   v_return_status=FND_API.G_RET_STS_SUCCESS 
then

    COMMIT;
    
    v_return_status := null;
    xla_datafixes_pub.g_msg_mode := 'X';        

    XLA_JOURNAL_ENTRIES_PUB_PKG.complete_journal_entry (
           p_api_version                => 1.0
          ,p_init_msg_list              => fnd_api.g_true
          ,p_application_id             => v_application_id
          ,p_ae_header_id               => v_ae_header_id
          ,p_completion_option          => 'P' -- P=complete, transfer, and post final accounting
          ,x_return_status              => v_return_status
          ,x_msg_count                  => v_msg_count
          ,x_msg_data                   => v_msg_data
          ,x_completion_retcode         => v_completion_retcode
        );
        
        if v_return_status != FND_API.G_RET_STS_SUCCESS then
            DBMS_OUTPUT.put_line ('HORROR en COMPLETE JOURNAL!!!!' );
            DBMS_OUTPUT.put_line ('v_msg_data: '||v_msg_data);
            FOR i IN 1 .. fnd_msg_pub.count_msg
            LOOP                   
               v_msg_data := SUBSTR(fnd_msg_pub.get (p_msg_index   => i
                                                 ,p_encoded     => 'F'
                                                 )
                                 , 0, 4000
                                 )  ;              
                dbms_output.put_line ( to_char(i) || ': '||v_msg_data);
            END LOOP; 
        end if;
--
--        if v_completion_retcode = 'X' then
--            for x in ( select encoded_msg
--                        from XLA_ACCOUNTING_ERRORS 
--                        where ae_header_id  =  v_ae_header_id
--                          and ae_line_num = v_ae_line_num)
--            loop
--                DBMS_OUTPUT.put_line (x.encoded_msg);
--            end loop;
--            
--        /*FOR i IN 1..v_msg_count LOOP
--            dbms_output.put_line(fnd_msg_pub.get(i, p_encoded => fnd_api.g_false));
--        END LOOP;            
--          */  
--        end if;
        
        DBMS_OUTPUT.put_line ('Return Status Complete= ' || v_return_status );
        DBMS_OUTPUT.put_line ('Completion RetCode = ' || v_completion_retcode );
END IF;

END;