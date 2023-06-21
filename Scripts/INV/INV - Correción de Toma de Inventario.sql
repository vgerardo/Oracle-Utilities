

SELECT * FROM hr_all_organization_units
where name like '%WPVAE%'
;

Y borras el registro del inventario que reporten

create table Cmr_Inv_Fis_Conteo_Ajuste_gvp
as

SELECT *
FROM Cmr_Inv_Fis_Conteo_Ajuste_h
where organization_id = 428
and physical_inventory_name = 'WPVAE31-OCT-2010LAH'         --Inventario Reportado
;

DELETE Cmr_Inv_Fis_Conteo_Ajuste_h
where organization_id = 428
and physical_inventory_name = 'WPVAE31-OCT-2010LAH'         --Inventario Reportado
;
