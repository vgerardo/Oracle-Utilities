
DECLARE
v_function_id   number(15):=0;
v_form_id       number(15):=0;
v_app_id        number(15):=0;
v_menu_id       number(15);
v_menu_sq       number(15);
BEGIN

    select m.menu_id, me.entry_sequence
    into v_menu_id, v_menu_sq    
    from fnd_menus m
        ,fnd_menu_entries_tl me
    where 1=1
      and m.menu_id = me.menu_id
      and me.language = 'US'
      and m.menu_name = 'XXCMX_LCM_SETUP'
      and me.prompt = 'XXCMX Setup Factor de Costos MX'
     ;

    select function_id, form_id, application_id
    into v_function_id, v_form_id, v_app_id
    from fnd_form_functions
    where function_name = p_function_name;
    
    FND_MENU_ENTRIES_PKG.Delete_Row (x_menu_id => v_menu_id, x_entry_sequence => v_menu_sq);
    FND_FORM_FUNCTIONS_PKG.Delete_Row (x_function_id => v_function_id);
    FND_FORM_PKG.Delete_Row ( x_application_id => v_app_id, x_form_id => v_form_id);
                            
END;
/
