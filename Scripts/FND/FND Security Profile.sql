
SELECT 
  frt.responsibility_id
 ,frt.responsibility_name
 ,psp.security_profile_name
 ,fnd_prof_opt.* --USER_PROFILE_OPTION_NAME
,fnd_prof_v.profile_option_value
FROM apps.fnd_profile_option_values fnd_prof_v
    ,apps.per_security_profiles         psp
    ,apps.fnd_responsibility            fr
    ,apps.fnd_responsibility_tl         frt
    ,apps.FND_PROFILE_OPTIONS_VL        fnd_prof_opt
WHERE 1=1
  and TO_CHAR (psp.security_profile_id) = fnd_prof_v.profile_option_value
  AND fnd_prof_v.level_value = fr.responsibility_id
  AND fr.responsibility_id = frt.responsibility_id
  AND fnd_prof_opt.profile_option_id = fnd_prof_v.profile_option_id
  AND frt.responsibility_name LIKE 'GT AC INV GTM Key User'

;


select psp.security_profile_name, pso.*
from per_security_profiles      psp
   , per_security_organizations pso
   , hr_operating_units         hou
where 1=1
  and psp.security_profile_id = pso.security_profile_id
  and pso.organization_id     = hou.organization_id
  and psp.security_profile_name = 'PS_GTM'
;


SELECT 
    FND_PROFILE.Value_Specific ('XLA_MO_SECURITY_PROFILE_LEVEL', 19282, 54267, 602)
from dual;