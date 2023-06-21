--
--
-- Forma -> Funcion -> MenuEntry -> Menu -> Responsabilidad
--
--
select frm.form_name
      ,frmtl.user_form_name
      ,frmtl.description        form_description
      ,(select user_name from fnd_user where user_id=frmtl.created_by) Creado_Por      
      ,fnc.function_name            
      ,fnc.function_id
      ,fnc.parameters
      ,fnc.type
      ,fnctl.user_function_name
      ,fnctl.description        fuction_description
      ,opctl.prompt
      ,mnu.user_menu_name
      ,rsp.responsibility_key
from fnd_form                   frm
    ,fnd_form_tl                frmtl
    ,fnd_form_functions         fnc
    ,fnd_form_functions_tl      fnctl
    ,fnd_menu_entries           opc
    ,fnd_menu_entries_tl        opctl
    ,fnd_menus_vl               mnu
    ,fnd_responsibility         rsp
where 1=1
  and frm.form_id       = frmtl.form_id
  and frmtl.language    = 'ESA'
  and frm.form_id       = fnc.form_id
  and fnc.function_id   = fnctl.function_id
  and fnctl.language    = 'ESA'
  and fnc.function_id   = opc.function_id (+)
  and opc.menu_id       = opctl.menu_id (+)
  and opc.entry_sequence = opctl.entry_sequence (+)
  and opctl.language    (+)= 'ESA'
  and opc.menu_id       = mnu.menu_id(+)
  and mnu.menu_id       = rsp.menu_id(+)
  --
  and UPPER(frmtl.user_form_name) like UPPER('GRP_AR_%')
  
 