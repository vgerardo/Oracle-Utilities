select organization_code inv_code, ou.attribute1 ou_code, od.organization_name org_inv_name
from org_organization_definitions   od
    ,hr_organization_units          ou
WHERE 1=1
  and od.operating_unit = ou.organization_id
  and inventory_enabled_flag = 'Y'
  --AND organization_code in ('KMX', 'TFC')
;

select m.organization_id, m.organization_code, ou.name
from MTL_PARAMETERS M, 
     HR_ORGANIZATION_UNITS ou
where 1=1
  and m.organization_id = ou.organization_id
  and m.master_organization_id = 403
  --
 -- AND m.organization_code IN ('CCR', 'CLC', 'MSC')
  --
;

select *
from org_organization_definitions
WHERE operating_unit = 107  --FND_PROFILE.Value ('ORG_ID');
;

SELECT org_name.organization_code, org_name.organization_name, org_name.disable_date
     , org_info.operating_unit
     , prmter.master_organization_id
FROM INV_ORGANIZATION_NAME_V    org_name
   , INV_ORGANIZATION_INFO_V    org_info
   , MTL_PARAMETERS             prmter
WHERE org_name.organization_id = org_info.organization_id
  and org_name.organization_id = prmter.organization_id
  and org_info.operating_unit = 162
  ;


--
-- Organización(es) asignadas a una Responsabilidad
--
SELECT 
     MP.ORGANIZATION_CODE,
     OA.ORGANIZATION_ID
FROM 
     FND_RESPONSIBILITY_VL FR
     ,ORG_ACCESS OA
     ,MTL_PARAMETERS MP
     ,HR_ORGANIZATION_UNITS HOU
 WHERE hou.organization_id = oa.organization_id
 AND mp.organization_id = hou.organization_id
 AND fr.responsibility_id = oa.responsibility_id
 AND fr.application_id = oa.resp_application_id
 --and mp.lcm_enabled_flag = 'Y'
 and oa.responsibility_id = 53255 -- To_number(fnd_profile.value('RESP_ID'))
 ;