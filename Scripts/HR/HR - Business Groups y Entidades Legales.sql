
/*
Business Group
     | 
     +--> Ledgers(r12) (Set of Books in 11i)
        |
        +--> Legal Entity 
           |
           +--> Operting Units 
              |
              +--> Inventory Organization.

*/


--
-- Business Groups
--

SELECT * FROM per_business_groups
;

select ou.organization_id, ou.business_group_id, ou.name, ou.type,
       oi.*
from HR_ALL_ORGANIZATION_UNITS      ou,
     HR_ORGANIZATION_INFORMATION    oi
where 1=1
  and ou.organization_id = oi.organization_id     
  --and oi.org_information_context ='Business Group Information'
  and ou.organization_id in ( 279, 649,86)
;

select *
from HR_ORGANIZATION_INFORMATION
where organization_id  in ( 279, 649,86)
;

--
-- Entidades Legales
--
select * 
from  xle_entity_profiles     ent, 
      XLE_LEGAL_CONTACTS_V    cont
 WHERE 1 = 1   
   AND ent.legal_entity_id = cont.entity_id(+)
order by ent.legal_entity_id


select *
from hr_legal_entities
;


--
-- Unidad Operativa
--
SELECT *
FROM hr_operating_units             opr
where organization_id  in ( 279, 649,86)

