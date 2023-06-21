    SELECT hou.organization_id   org_id
         , hou.name              org_name
         , hou.date_from         org_date_from
         , loc.location_id       loc_id
         , loc.location_code     loc_code
         , loc.description       loc_desc
         , (initcap(loc.description)  ||' ('|| hou.name||')')  descripcion
      FROM hr_organization_units        hou
          ,hr_organization_information  hoi1
          ,hr_locations_all             loc
     WHERE hou.organization_id = hoi1.organization_id 
       AND hoi1.org_information1 = 'INV' 
       AND hoi1.org_information2 = 'Y' 
       and hou.organization_id = loc.inventory_organization_id
