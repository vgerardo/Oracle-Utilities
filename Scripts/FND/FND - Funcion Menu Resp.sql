

SELECT function_id, function_name, parameters
FROM  fnd_form_functions         fnc
WHERE parameters like '%XXCMX_INV_RECEPCION_RMA%'
;

--57862	XXCMX_INV_RECEPCION_RMA

select fm.menu_id, fm.menu_name, fm.user_menu_name
     , frt.responsibility_name
from fnd_menus_vl       fm
    ,fnd_menu_entries   fme
    ,fnd_responsibility fr
    ,fnd_responsibility_tl frt
where 1=1
  and fm.menu_id  = fme.menu_id
  and fm.menu_id  = fr.menu_id
  and fr.responsibility_id = frt.responsibility_id
  and nvl(fr.end_date,sysdate+1) > sysdate
  and frt.language = 'US'
  and fme.function_id = 57862
;


