--
-- PARA CREAR UN LOOKUP_TYPE
--
DECLARE
  
  v_LOOKUP_TYPE         VARCHAR2(100) := 'GRP_AR_MAR_MATRIZ_SUCURSALES';
  v_MEANING             VARCHAR2(100) := 'GRP_AR_MAR_MATRIZ_SUCURSALES';  
  v_SECURITY_GROUP_ID   NUMBER(15)    := 0;   
  v_VIEW_APPLICATION_ID NUMBER(15)    := 222;      --222=AR
  v_APPLICATION_ID      NUMBER(15)    := 50201;   --50201=Grupo Posadas
  v_DESCRIPTION         VARCHAR2(100) := 'Matrices y Sucursales para el Módulo de Aplicación de Recibos';
  
  v_CREATION_DATE       DATE          := SYSDATE;
  v_CREATED_BY          NUMBER(15)    := 0;
  v_LAST_UPDATE_DATE    DATE          := SYSDATE;
  v_LAST_UPDATED_BY     NUMBER(15)    := 0;
  v_LAST_UPDATE_LOGIN   NUMBER(15)    := 0;
  v_ROWID               VARCHAR2(100);

begin

    FND_LOOKUP_TYPES_PKG.Insert_Row (
                      X_ROWID               => v_rowid,
                      X_LOOKUP_TYPE         => v_lookup_type,
                      X_SECURITY_GROUP_ID   => v_security_group_id ,
                      X_VIEW_APPLICATION_ID => v_view_application_id,
                      X_APPLICATION_ID      => v_application_id,
                      X_CUSTOMIZATION_LEVEL => 'U', --U=usuario S=system
                      X_MEANING             => v_meaning,
                      X_DESCRIPTION         => v_description,
                      X_CREATION_DATE       => SYSDATE,
                      X_CREATED_BY          => v_created_by,
                      X_LAST_UPDATE_DATE    => SYSDATE,
                      X_LAST_UPDATED_BY     => v_last_updated_by,
                      X_LAST_UPDATE_LOGIN   => v_last_update_login
                );

COMMIT;
end;