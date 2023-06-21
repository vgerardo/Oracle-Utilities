/* Formatted on 27/05/2015 06:32:37 p.m. (QP5 v5.240.12305.39446) */
  SELECT          
         p.profile_option_name          SHORT_NAME
        ,n.user_profile_option_name 
        ,DECODE (v.level_id,  10001, 'Site',  
                              10002, 'Application',  
                              10003, 'Responsibility',  
                              10004, 'User',  
                              10005, 'Server',  
                              10006, 'Org',  
                              10007, DECODE (TO_CHAR (v.level_value2), '-1', 'Responsibility', 
                                                                       DECODE (TO_CHAR (v.level_value), '-1', 'Server', 
                                                                                                        'Server+Resp')),  'UnDef') LEVEL_SET
        ,DECODE (
             TO_CHAR (v.level_id)
            ,'10001', ''
            ,'10002', app.application_short_name
            ,'10003', rsp.responsibility_key
            ,'10004', usr.user_name
            ,'10005', svr.node_name
            ,'10006', org.name
            ,'10007', DECODE (
                          TO_CHAR (v.level_value2)
                         ,'-1', rsp.responsibility_key
                         ,DECODE (
                              TO_CHAR (v.level_value)
                             ,'-1', (SELECT node_name FROM fnd_nodes WHERE node_id = v.level_value2)
                             ,   (SELECT node_name FROM fnd_nodes WHERE node_id = v.level_value2)
                              || '-'
                              || rsp.responsibility_key
                          )
                      )
            ,'UnDef'
         ) "CONTEXT"
        ,v.profile_option_value VALUE        
        ,p.sql_validation
        
    FROM fnd_profile_options        p
        ,fnd_profile_options_tl     n    
        ,fnd_profile_option_values  v
        
        ,fnd_user                   usr
        ,fnd_application            app
        ,fnd_responsibility         rsp
        ,fnd_nodes                  svr
        ,hr_operating_units         org
        
   WHERE p.profile_option_id = v.profile_option_id(+)
     AND p.profile_option_name = n.profile_option_name
     AND usr.user_id(+) = v.level_value
     AND rsp.application_id(+) = v.level_value_application_id
     AND rsp.responsibility_id(+) = v.level_value
     AND app.application_id(+) = v.level_value
     AND svr.node_id(+) = v.level_value
     AND org.organization_id(+) = v.level_value
     and n.language = 'ESA'
     -------------------------------------
    --and n.user_profile_option_name    like 'MO: Perfil de Seguridad'
    and rsp.responsibility_key LIKE 'GRP_POS_AP%_FARFG_CONSULTA' 
    --and rsp.responsibility_key = 'GRP_POS_AP_CONE_ANALISTA'
    -------------------------------------
    
ORDER BY short_name
        ,user_profile_option_name
        ,level_id
        ,level_set
;


/*
Toma los valores configurados para la "Responsabilidad o usuario"
*/
SELECT fnd_profile.value('PROFILEOPTION')
      ,fnd_profile.value('MFG_ORGANIZATION_ID')
      ,fnd_profile.value('ORG_ID')
      ,fnd_profile.value('LOGIN_ID')
      ,fnd_profile.value('USER_ID')
      ,fnd_profile.value('USERNAME')
      ,fnd_profile.value('CONCURRENT_REQUEST_ID')
      ,fnd_profile.value('GL_SET_OF_BKS_ID')
      ,fnd_profile.value('SO_ORGANIZATION_ID')
      ,fnd_profile.value('APPL_SHRT_NAME')
      ,fnd_profile.value('RESP_NAME')
      ,fnd_profile.value('RESP_ID')
      ,fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL')
      ,FND_PROFILE.value ('GL_SET_OF_BKS_ID')
FROM DUAL;


select *
from  bolinf.GRP_GL_BOOK_VS_CIAS_V;

/*
Estas tablas se alimentan en:
Recursos Humanos -> Seguridad -> Perfil
*/

SELECT *     
FROM PER_SECURITY_PROFILES S 
where security_profile_id = 2063
;


SELECT organization_id, substr(organization_name, 8) cia, organization_name
FROM PER_SECURITY_ORGANIZATIONS_V
WHERE 1=1        
    --and entry_type = 'I'  -- Incluir, Excluir
    AND security_profile_id = 2063    
    
    ;

SELECT *
FROM gl_ledger_norm_seg_vals;

select *
from bolinf.GRP_GL_BOOK_VS_CIAS_V
WHERE CIA_SIGLAS = 'FARFG';

select profile_option_value
from  fnd_profile_options po,
      fnd_profile_option_values  v
where po.profile_option_id = v.profile_option_id
 and profile_option_name like 'GL_SET_OF_BKS_ID'
 and level_value = 50901
;

select *
from 
where profile_option_name like 'GL_SET_OF_BKS_ID'
;