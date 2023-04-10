/* Formatted on 29/03/2010 01:08:34 p.m. (QP5 v5.139.911.3011) */
SELECT DISTINCT
       SUBSTR(org.NAME, instr(org.name,'.')+1) CC,
       DECODE (ele.processing_type,
               'N', 'No Recurrente',
               'R', 'Recurrente',
               'Estandarizado')
          tipo,       
       replace (ele.element_name, :nom_cia1) elemento
  FROM pay_element_links_f l,
       pay_cost_allocation_keyflex co,
       pay_element_types_f ele,
       pay_cost_allocation_keyflex cb,
       hr_all_organization_units org
 WHERE     l.cost_allocation_keyflex_id = co.cost_allocation_keyflex_id
       AND l.balancing_keyflex_id = cb.cost_allocation_keyflex_id
       AND l.element_type_id = ele.element_type_id
       AND org.organization_id = NVL (l.organization_id, 0)
       AND org.NAME LIKE UPPER (:nom_cia1) || '%'
       ---AND ele.element_name like  'Impuesto Estatal%'
       
MINUS
       

SELECT DISTINCT
       SUBSTR(org.NAME, instr(org.name,'.')+1) CC,
       DECODE (ele.processing_type,
               'N', 'No Recurrente',
               'R', 'Recurrente',
               'Estandarizado')
          tipo--                                ,rownum+1 idcncpt
       ,
       replace (ele.element_name, :nom_cia2) elemento
  FROM pay_element_links_f l,
       pay_cost_allocation_keyflex co,
       pay_element_types_f ele,
       pay_cost_allocation_keyflex cb,
       hr_all_organization_units org
 WHERE     l.cost_allocation_keyflex_id = co.cost_allocation_keyflex_id
       AND l.balancing_keyflex_id = cb.cost_allocation_keyflex_id
       AND l.element_type_id = ele.element_type_id
       AND org.organization_id = NVL (l.organization_id, 0)
       AND org.NAME LIKE UPPER (:nom_cia2) || '%'       
  --     AND ele.element_name  like  'Impuesto Estatal%'
--       AND SUBSTR(org.NAME, instr(org.name,'.')+1) LIKE 'DIVISION CUARTOS'