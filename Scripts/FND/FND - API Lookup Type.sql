DECLARE

--PROCEDURE API_Lookup_Type (p_lookup_type varchar2, p_meaning varchar2, p_description varchar2)
--IS 

p_lookup_type   varchar2(50)    := 'XXCMX_WSH_CCP_CP_SUSTITUTO';
p_meaning       varchar2(50)    := 'XXCMX_WSH_CCP_CP_SUSTITUTO';
p_description   varchar2(150)   := 'Cóigo Postal Sustituto para CCP';

  v_security_group_id   NUMBER(15)    := 0;   
  v_view_application_id NUMBER(15)    := 3;
  v_application_id      NUMBER(15)    := 50301;   --50301=PPG Comex Custom
  v_rowid               VARCHAR2(100);

begin

--XXCMX_SAT_TIPO_EMBALAJE
--XXCMX_WSH_CCP_ITEMS_VS_EMBLJE
--XXCMX_WSH_CCP_ACCESORIOS_OTM

    FND_LOOKUP_TYPES_PKG.Insert_Row (
                      X_ROWID               => v_rowid,
                      X_LOOKUP_TYPE         => p_lookup_type,
                      X_MEANING             => p_meaning,
                      X_DESCRIPTION         => p_description,
                      
                      X_SECURITY_GROUP_ID   => v_security_group_id ,
                      X_VIEW_APPLICATION_ID => v_view_application_id,
                      X_APPLICATION_ID      => v_application_id,
                      X_CUSTOMIZATION_LEVEL => 'U', --U=usuario S=system
                      X_CREATION_DATE       => SYSDATE,
                      X_CREATED_BY          => FND_GLOBAL.user_id,
                      X_LAST_UPDATE_DATE    => SYSDATE,
                      X_LAST_UPDATED_BY     => FND_GLOBAL.user_id,
                      X_LAST_UPDATE_LOGIN   => -1
                );

COMMIT;

END ;
