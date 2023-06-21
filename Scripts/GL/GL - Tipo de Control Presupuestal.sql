

--
-- Consulta de CUENTAS por tipo de Control Presupuestal
--
  SELECT decode (glst.amount_type, 'PTD', 'Acumulado de Periodo'   
                                 , 'YTD', 'Acumulado Anual'
                                 , 'QTD', 'Acumulado Trimestral'
                                 , glst.amount_type
                )
    FROM  FND_FLEX_VALUE_NORM_HIERARCHY  fnh ,
          fnd_flex_values fv,
          FND_FLEX_HIERARCHIES_VL        fhv,
          GL_SUMMARY_TEMPLATES           glst
  WHERE FV.flex_value = fnh.parent_flex_value     
    and fv.structured_hierarchy_level = fhv.hierarchy_id
    and fhv.hierarchy_code = glst.segment3_type               
    and glst.set_of_books_id = 1002
         and fhv.FLEX_VALUE_SET_ID=1010519 
         and fnh.FLEX_VALUE_SET_ID=fhv.FLEX_VALUE_SET_ID
         and sysdate between nvl(fnh.start_date_active,sysdate-1) and nvl(fnh.end_date_active,sysdate+1)
         and :p_cuenta between fnh.child_flex_value_low and fnh.child_flex_value_high                
ORDER BY glst.template_name
