--
-- Security Rules
--
-- General Ledger >> Configuración >> Financiera >> Flexfields >>Clave >>Seguridad >>Definir
--
select 
       rsp.responsibility_name,       
       vset.parent_value_set_name,       
       rule.flex_value_rule_name,
       lines.flex_value_low,
       lines.flex_value_high,
       decode(lines.include_exclude_indicator,'I','Incluir','E','Excluir') tipo
       ;
       SELECT RULE.*
FROM 
     apps.fnd_responsibility_tl rsp,
     fnd_flex_value_rule_usages use,
     fnd_flex_value_rules_vl    rule,
     fnd_flex_value_rule_lines  lines,
     fnd_flex_vset_v            vset
WHERE 1=1
    and rsp.responsibility_id  = use.responsibility_id 
    and rsp.language           = 'ESA'
    and use.flex_value_rule_id = rule.flex_value_rule_id
    and rule.flex_value_rule_id= lines.flex_value_rule_id
    and rule.flex_value_set_id = lines.flex_value_set_id
    and use.flex_value_set_id  = vset.flex_value_set_id (+)
    --AND vset.parent_value_set_name NOT IN ( 'GRP_CIA')
    -- 
    and rsp.responsibility_name LIKE 'GRP_POS_GL_FACCG_CONSULTA'
ORDER BY lines.include_exclude_indicator DESC,
         lines.flex_value_low
;


SELECT distinct segment1
FROM gl_code_combinations
where 1=1
  and segment1 NOT between '0000' and '0000'
  and segment1 NOT between '0002' and '0040'
  and segment1 NOT between '0042' and 'ZZZZ'
  and segment1 between '0000' and 'ZZZZ'
; 

