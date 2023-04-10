SET SERVEROUTPUT ON

DECLARE
v_resp_id   number(15);
v_app_id    number(15);
v_modulo    varchar2(100) := 'GRP_AR_MAR%'
BEGIN

    BEGIN
        SELECT application_id, responsibility_id
        INTO v_app_id, v_resp_id
        FROM FND_RESPONSIBILITY
        WHERE responsibility_key like 'GRP_ALL_AR_APLICATIVO_COBRANZA'
        ;        
        --
        -- Borra una responsabilidad
        --
        FND_RESPONSIBILITY_PKG.Delete_Row (
                                      X_RESPONSIBILITY_ID 	=> v_resp_id,
                                      X_APPLICATION_ID 		=> v_app_id
                                      );            
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.put_line ('No se encontró la responsabilidad');
    END;                              
                                  
                                  
    --
    -- Borra REQUEST GROUP
    --
    FND_PROGRAM.delete_group(
                        request_group  => 'GRP_AR_MAR_RG_USR',
                        application    => 'AR'
                        );


    --
    -- Borra los MENUS y sus ENTRADAS
    --
    FOR m IN (SELECT menu_id
                FROM FND_MENUS
                WHERE MENU_NAME LIKE 'GRP_AR_MAR%')
    LOOP
    
        FOR e IN (SELECT entry_sequence
                    FROM FND_MENU_ENTRIES_VL 
                    WHERE menu_id= m.menu_id ) 
        LOOP            
            FND_MENU_ENTRIES_PKG.delete_row (
                                x_menu_id           => m.menu_id,                                       
                                x_entry_sequence    => e.entry_sequence 
                                );    
        END LOOP;
    
        FND_MENUS_PKG.delete_row (x_menu_id => m.menu_id);

    END LOOP;

    --
    -- Borra FUNCIONES
    --
    FOR f in (SELECT function_id
            FROM FND_FORM_FUNCTIONS_VL
            WHERE function_name like 'GRP_AR_MAR%')
    LOOP    
        FND_FORM_FUNCTIONS_PKG.delete_row (x_function_id => f.function_id);
    END LOOP;
    
    --
    -- Borra FORMAS
    --
    FOR P IN (select application_id, form_id
            from FND_FORM_VL
            where form_name like 'GRP_AR_MAR%')
    LOOP
        FND_FORM_PKG.delete_row (p.application_id, p.form_id);
    END LOOP;
        
    --
    -- Borra CONCURRENTES
    --
    FOR c IN (SELECT app.application_short_name, concurrent_program_name, user_concurrent_program_name
            FROM FND_CONCURRENT_PROGRAMS_VL cp,
                 FND_APPLICATION            app
            WHERE cp.application_id = app.application_id
              and concurrent_program_name like 'GRP_AR_MAR%')
    LOOP
        FND_PROGRAM.delete_program (c.concurrent_program_name, c.application_short_name);
    END LOOP;

    --
    -- Borra EXECUTABLES
    --
    -- OJO FALTA!!!
    -- FND_PROGRAM.delete_executable (executable_short_name =>, application => );
    --
    
    --
    -- Borra XML TEMPLATES
    --
   for r in (select t1.application_short_name template_app_name,
                    t1.data_source_code,
                    t1.application_short_name def_app_name,
                    t1.template_code
               from xdo_templates_b t1
              where t1.template_code LIKE 'GRP_AR_MAR%')
   loop
     
      XDO_TEMPLATES_PKG.delete_row (r.template_app_name, R.template_code);
 
      delete from xdo_lobs
            where lob_code = R.template_code
                  and application_short_name = r.template_app_name
                  and lob_type in ('TEMPLATE_SOURCE', 'TEMPLATE');
 
      delete from xdo_config_values
            where application_short_name = r.template_app_name
                  and template_code = R.template_code
                  and data_source_code = r.data_source_code
                  and config_level = 50;
 
  end loop;    
    

    --
    -- Borra DATA DEFINITIONS
    --
    FOR d IN (SELECT dd.application_short_name, dd.data_source_code
                FROM xdo_ds_definitions_vl  dd
                     ,xdo_lobs              files
                WHERE 1=1
                 and dd.data_source_code = files.lob_code (+)
                 and dd.data_source_code LIKE 'GRP_AR_MAR%'
                )
    LOOP
        XDO_DS_DEFINITIONS_PKG.delete_row (D.application_short_name, D.data_source_code);
    END LOOP;


    --
    -- Borra VALUE SET y sus VALORES
    --
    FOR v IN (select flex_value_set_name, flex_value_set_id
             from FND_FLEX_VALUE_SETS fvs
             WHERE flex_value_set_name like 'GRP_FND_USER_VS_PERSON')
    LOOP         
        FOR s IN (SELECT flex_value_id
                  FROM fnd_flex_values     fv
                  WHERE fv.flex_value_set_id = v.flex_value_set_id)
        loop
            FND_FLEX_VALUES_PKG.delete_row (s.flex_value_id);
        end loop;
        
        FND_FLEX_VAL_API.DELETE_VALUESET(v.flex_value_set_name);
    END LOOP;    
    
    
    
    --
    -- Borrar LOOKUP and VALUES
    --
    FOR x IN (
                select lookup_type, security_group_id, view_application_id
                from fnd_lookup_types
                where lookup_type LIKE 'GRP_AR_MAR%')
    LOOP                
    
        FOR v IN (
                select security_group_id, view_application_id, lookup_code
                from fnd_lookup_values_vl
                where lookup_type LIKE x.lookup_type )
        LOOP
        
            FND_LOOKUP_VALUES_PKG.delete_row (
                                    x_lookup_type           => x.lookup_type,
                                    x_security_group_id     => v.security_group_id,
                                    x_view_application_id   => v.view_application_id,
                                    x_lookup_code           => v.lookup_code
                                  );
        END LOOP;
        
        FND_LOOKUP_TYPES_PKG.delete_row (
                              x_lookup_type         => X.lookup_type,
                              x_security_group_id   => X.security_group_id,
                              x_view_application_id => X.view_application_id
                            );
    END LOOP;    
    
    
END;
/


--