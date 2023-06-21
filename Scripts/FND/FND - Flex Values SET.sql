SELECT
     ffvs.flex_value_set_name         "Value Set",
     CASE
         WHEN validation_type = 'I'   THEN 'Independent'
         WHEN validation_type = 'F'   THEN 'Table'
         WHEN validation_type = 'D'   THEN 'Dependent'
         WHEN validation_type = 'P'   THEN 'Pair'
         WHEN validation_type = 'U'   THEN 'Special'
         WHEN validation_type = 'N'   THEN 'None'
         ELSE validation_type
     END "Validation Type"
    , fval.flex_value
    , fval.flex_value_meaning
    , fval.description
    , fval.enabled_flag     
    , fval.parent_flex_value_low 
    , fval.parent_flex_value_high
    , ffvs.flex_value_set_id
 FROM
     fnd_flex_value_sets ffvs,
     fnd_flex_values_vl     fval     
 WHERE 1=1     
     and ffvs.flex_value_set_id  = fval.flex_value_set_id
     and ffvs.flex_value_set_name = 'GRP_INV_SUBCATEGORIA'
     and fval.parent_flex_value_low = 'TA'
     ;
     
     