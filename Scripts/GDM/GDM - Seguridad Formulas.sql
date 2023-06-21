--
--Esta configuración se realiza en la responsabilidad: MX AC GMD Admin Perfiles Seguridad
--En la pantalla: "Security Profiles" -> Consultar Todo (F11 y Cntl+F11)
--

--
-- Organizaciones con Seguridad en formulas
--
SELECT
    gsc.user_ind,
    gsc.responsibility_ind,
    gsc.organization_id
    ,ou.name
FROM  gmd_security_control          gsc
    , hr_all_organization_units_tl  ou
WHERE 1 = 1
    AND gsc.organization_id = ou.organization_id 
    and ou.language = 'ESA'
;
      
      
--
--Organizaciones Asignadas a Usuario
--
SELECT
    gsc.organization_id
    ,ou.NAME
    ,decode(gsp.access_type_ind,'U', 'Update', 'V', 'View') Access_Level
FROM  gmd_security_control          gsc
    , hr_all_organization_units_tl  ou
    , gmd_security_profiles        gsp
    , fnd_user                     usr
WHERE 1 = 1
    AND gsc.organization_id = ou.organization_id 
    and ou.language = 'ESA'
    and gsc.organization_id = gsp.organization_id
    and gsp.user_id = usr.user_id  
    AND usr.user_name = 'S000043'
    ;
    
 