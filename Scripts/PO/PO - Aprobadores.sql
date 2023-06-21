
SELECT ppc.control_group_id, ppc.start_date, ppc.end_date, ppc.control_function_id
     , pcg.control_group_name
     , pap.name posicion
     , ou_b.name matriz
     , ou_a.name sucursal
FROM PO_POSITION_CONTROLS_ALL       ppc
    ,hr_all_organization_units      ou_a
    ,hr_all_organization_units      ou_b
    ,hr_all_positions_f             pap
    ,po_control_groups_all          pcg      
WHERE ppc.organization_id = ou_a.organization_id
  and ppc.org_id = ou_b.organization_id
  and ppc.position_id = pap.position_id
  and ppc.control_group_id = pcg.control_group_id  
  and pap.name = '90019.SUBDIRECTOR DE SUBDIRECCION CONTROL PRESUPUESTAL.HCMR'
  --and ou_b.name like 'CCRM%'
ORDER BY pcg.control_group_name  


