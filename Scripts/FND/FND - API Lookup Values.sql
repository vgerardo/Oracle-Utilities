DECLARE
--CREATE OR REPLACE PROCEDURE XXCMX_API_Lookup_Value (p_lookup_type varchar2, p_lookup_value varchar2, p_meaning varchar2, p_description varchar2, p_tag varchar2)
--IS
p_lookup_type   varchar2(50);
p_lookup_value  varchar2(50);
p_meaning       varchar2(50);
p_description   varchar2(150);
p_tag           varchar2(80);

v_rowid varchar2(1000);
BEGIN

    for x in (
                SELECT  lookup_code, meaning, lv.description, lv.tag
                FROM fnd_lookup_values      lv
                WHERE 1=1
                  AND lv.view_application_id = 3
                  AND lv.security_group_id   = 0    
                  and lv.enabled_flag = 'Y'
                  and nvl(lv.end_date_active,sysdate) >= sysdate
                  and language = userenv('LANG')
                  and lv.lookup_type = 'XXCMX_WSH_CCP_CP_ALTERNO'
              )
    LOOP
    p_lookup_type   := 'XXCMX_WSH_CCP_CP_SUSTITUTO' ;
    p_lookup_value  := x.lookup_code ;
    p_meaning       := x.meaning ;
    p_description   := x.description ;
    p_tag           := x.tag ;
    
    
    FND_LOOKUP_VALUES_PKG.Insert_Row (
            x_rowid                 => v_rowid
            ,x_lookup_type          => P_LOOKUP_TYPE -- 
            ,x_lookup_code          => P_LOOKUP_VALUE --'1B1'
            ,x_meaning              => P_Meaning --'1A1'
            ,x_description          => P_DESCRIPTION --'Bidones (Tambores) de Aluminio de tapa no desmontable'
            ,x_tag                  => P_TAG
            ,x_security_group_id    => 0
            ,x_view_application_id  => 3
            ,x_attribute_category   => NULL
            ,x_attribute1=> null
            ,x_attribute2=> null
            ,x_attribute3=> null
            ,x_attribute4=> null
            ,x_attribute5=> null
            ,x_attribute6=> null
            ,x_attribute7=> null
            ,x_attribute8=> null
            ,x_attribute9=> null
            ,x_attribute10=> null
            ,x_attribute11=> null
            ,x_attribute12=> null
            ,x_attribute13=> null
            ,x_attribute14=> null
            ,x_attribute15=> null
            ,x_enabled_flag         => 'Y'
            ,x_start_date_active    => SYSDATE
            ,x_end_date_active      => NULL
            ,x_territory_code       => NULL
            ,x_creation_date        => SYSDATE
            ,x_created_by           => FND_GLOBAL.user_id    
            ,x_last_update_date     => SYSDATE
            ,x_last_updated_by      => FND_GLOBAL.user_id
            ,x_last_update_login    => -1
        );
    
    END LOOP;
    
END ;
/