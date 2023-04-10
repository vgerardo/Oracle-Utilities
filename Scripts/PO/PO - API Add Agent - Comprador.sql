
DECLARE
v_agent_id      number(15);
v_buyer_rowid   varchar2(200);
BEGIN
    SELECT DISTINCT person_id
    INTO v_agent_id
    FROM per_all_people_f
    WHERE FULL_NAME LIKE 'VARGAS PEÑAFORT, GERARDO'
    ;

    apps.PO_AGENTS_PKG.insert_row (
                         x_rowid                => v_buyer_rowid
                        ,x_agent_id             => v_agent_id
                        ,x_last_update_date     => sysdate
                        ,x_last_updated_by      => 1
                        ,x_last_update_login    => 1
                        ,x_creation_date        => sysdate
                        ,x_created_by           => 1
                        ,x_location_id          => null
                        ,x_category_id          => null
                        ,x_authorization_limit  => null
                        ,x_start_date_active    => null
                        ,x_end_date_active      => null
                        ,x_attribute_category   => null
                        ,x_attribute1           => null
                        ,x_attribute2           => null
                        ,x_attribute3           => null
                        ,x_attribute4           => null
                        ,x_attribute5           => null
                        ,x_attribute6           => null
                        ,x_attribute7           => null
                        ,x_attribute8           => null
                        ,x_attribute9           => null
                        ,x_attribute10          => null
                        ,x_attribute11          => null
                        ,x_attribute12          => null
                        ,x_attribute13          => null
                        ,x_attribute14          => null
                        ,x_attribute15          => null
                    );
    COMMIT;
END;
/