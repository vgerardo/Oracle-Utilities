SELECT DISTINCT 
       frm.form_name       
      ,frmtl.user_form_name       
      ,frmtl.description 
      ,usr.user_name     
      ,rule.*
FROM 
     apps.fnd_form              frm, 
     apps.fnd_form_tl           frmtl,      
     apps.fnd_form_custom_rules rule, 
     fnd_user                   usr
WHERE 1=1   
  AND frm.form_id      = frmtl.form_id 
  AND rule.form_name   = frm.form_name
  and rule.enabled     = 'Y' 
  and rule.created_by  = usr.user_id
  and frmtl.language   = 'ESA'
  and usr.user_name    = 'ACCN-ALOPEZ'  
  --and frm.form_name like 'APXVDMVD'



select * 
from FND_FORM_CUSTOM_RULES#     rule,
     FND_FORM_CUSTOM_ACTIONS#   act
where 1=1
  and rule.id = act.rule_id
 --and rule.form_name like 'APXVDMVD'
-- and rule.function_name like 'POXPOEPO'
  --and id=162
order by rule.sequence

