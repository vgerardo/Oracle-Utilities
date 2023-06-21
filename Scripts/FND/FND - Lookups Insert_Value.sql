
--
-- INSERTAR VALORES A UN LOOKUP_TYPE
--
DECLARE

  v_ROWID VARCHAR2 (100);
  
  v_LOOKUP_TYPE   VARCHAR2(30) := 'GRP_AR_MAR_MATRIZ_SUCURSALES';  
  --
  v_LOOKUP_CODE   VARCHAR2(30) := null;
  v_MEANING       VARCHAR2(30) := null;
  v_DESCRIPTION   VARCHAR2 (100) := null;

BEGIN

    FOR v IN (select * from bolinf.grp_borrame_03) LOOP
      
      --v_lookup_code := v.code;
      --v_meaning     := v.meaning;
      --v_description := v.description;
      
      fnd_lookup_values_pkg.INSERT_ROW (
                        X_ROWID               => v_rowid,
                        X_LOOKUP_TYPE         => v_lookup_type,
                        X_SECURITY_GROUP_ID   => 0,
                        X_VIEW_APPLICATION_ID => 222,      --222=AR
                        X_LOOKUP_CODE         => v.lookup_code,
                        X_MEANING             => v.meaning,
                        X_DESCRIPTION         => v.description,                        
                        X_TAG                 => v.tag,                        
                        X_START_DATE_ACTIVE   => SYSDATE,
                        X_ENABLED_FLAG        => 'Y',
                        
                        X_ATTRIBUTE_CATEGORY  => null,
                        X_ATTRIBUTE1          => null,
                        X_ATTRIBUTE2          => null,
                        X_ATTRIBUTE3          => null,
                        X_ATTRIBUTE4          => null,
                        X_END_DATE_ACTIVE     => null,
                        X_TERRITORY_CODE      => null,
                        X_ATTRIBUTE5          => null,
                        X_ATTRIBUTE6          => null,
                        X_ATTRIBUTE7          => null,
                        X_ATTRIBUTE8          => null,
                        X_ATTRIBUTE9          => null,
                        X_ATTRIBUTE10         => null,
                        X_ATTRIBUTE11         => null,
                        X_ATTRIBUTE12         => null,
                        X_ATTRIBUTE13         => null,
                        X_ATTRIBUTE14         => null,
                        X_ATTRIBUTE15         => null,
                        X_CREATION_DATE       => SYSDATE,
                        X_CREATED_BY          => 0,
                        X_LAST_UPDATE_DATE    => SYSDATE,
                        X_LAST_UPDATED_BY     => 0,
                        X_LAST_UPDATE_LOGIN   => 0
        );
    
    END LOOP;

END;