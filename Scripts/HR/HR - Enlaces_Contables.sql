
SELECT DISTINCT co.segment1 cia_cargo
                        ,co.segment2 cc_cargo
                        ,co.segment3 cta_cargo
                        ,decode(substr(co.segment3,1,1),'6','752',co.segment7) sbcta_cargo
                        ,co.segment6 interco_cargo
                        ,co.segment5 fut2_cargo
                        ,co.segment4 fut1_cargo 
                        ,cb.segment1 cia_abono
                        ,cb.segment2 cc_abono
                        ,cb.segment3 cta_abono
                        ,decode(substr(cb.segment3,1,1),'6','752',cb.segment7) sbcta_abono
                        ,cb.segment6 interco_abono
                        ,cb.segment5 fut2_abono
                        ,cb.segment4 fut1_abono
                        , v.*
                       FROM pay_element_links_f l,
                            pay_cost_allocation_keyflex co,
                            pay_element_types_f ele,
                            pay_cost_allocation_keyflex cb,
                            hr_all_organization_units org
                            ,CSA_CONE_EMPLEADOS_V V
                      WHERE l.cost_allocation_keyflex_id = co.cost_allocation_keyflex_id
                        AND l.balancing_keyflex_id = cb.cost_allocation_keyflex_id
                        AND l.element_type_id = ele.element_type_id
                        and ele.effective_end_date > sysdate
                        AND org.organization_id = NVL (l.organization_id, 0)
                        AND ele.element_name LIKE 'Sueldo Base COS'
                        AND org.NAME LIKE 'CONE.PROYECTOS CONECTUM'
                        AND ORG.NAME LIKE V.CENTRO_COSTOS
                        AND V.CENTRO_COSTOS = 'CONE.PROYECTOS CONECTUM'
                        AND V.NOMBRE_COLABORADOR = 'VARGAS-PEÑAFORT, GERARDO'
                        
  