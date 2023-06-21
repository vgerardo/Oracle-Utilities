
SELECT *
FROM BOLINF.GRP_AP_APP_CIA_VS_CNCNTRDRA_V
;

CREATE OR REPLACE VIEW bolinf.GRP_AP_APP_CIA_VS_CNCNTRDRA_V
AS
SELECT cncntrdra.llave, cncntrdra.bank_account_name, cias.cia_num, cias.cia_siglas
FROM (
    SELECT application_id,vls.description bank_account_name, vls.tag llave
    FROM FND_LOOKUP_TYPES  typ,
         FND_LOOKUP_VALUES vls
    WHERE typ.lookup_type = vls.lookup_type  
       and vls.enabled_flag = 'Y'
       and nvl(vls.end_date_active,sysdate+1) > sysdate
       and vls.language = 'ESA'
       and vls.enabled_flag = 'Y'            
       and typ.lookup_type like 'GRP_AP_CTAS_CONCENTRADORAS_LP'        
    ) cncntrdra,
    (
    SELECT application_id, vls.lookup_code cia_num, vls.meaning cia_siglas, vls.tag llave
    FROM FND_LOOKUP_TYPES  typ,
         FND_LOOKUP_VALUES vls
    WHERE typ.lookup_type = vls.lookup_type  
       and vls.enabled_flag = 'Y'
       and nvl(vls.end_date_active,sysdate+1) > sysdate
       and vls.language = 'ESA'
       and vls.enabled_flag = 'Y'                   
       and typ.lookup_type like 'GRP_AP_LST_CIAS_CNCTRDR_LP'         
    )  cias 
WHERE cncntrdra.llave = cias.llave    
  --AND cias.cia_siglas  = 'FACCG'
;

              
