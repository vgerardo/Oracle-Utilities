DECLARE
    l_schema          VARCHAR2(30);
    l_schema_status   VARCHAR2(1);
    l_industry        VARCHAR2(1);
BEGIN

    fnd_stats.load_histogram_cols('DELETE', 401, 'MTL_SYSTEM_ITEMS_INTERFACE', 'PROCESS_FLAG');
    fnd_stats.load_histogram_cols('DELETE', 401, 'MTL_SYSTEM_ITEMS_INTERFACE', 'SET_PROCESS_ID');

    IF ( fnd_installation.get_app_info('EGO', l_schema_status, l_industry, l_schema) ) THEN
        fnd_stats.gather_table_stats(ownname => l_schema, tabname => 'EGO_ITM_USR_ATTR_INTRFC', cascade => true);
    END IF;

    IF ( fnd_installation.get_app_info('INV', l_schema_status, l_industry, l_schema) ) THEN
        fnd_stats.gather_table_stats(ownname => l_schema, tabname => 'MTL_SYSTEM_ITEMS_INTERFACE', cascade => true);

        fnd_stats.gather_table_stats(ownname => l_schema, tabname => 'MTL_ITEM_REVISIONS_INTERFACE', cascade => true);

    END IF;

    dbms_stats.set_column_stats('EGO', 'EGO_ITM_USR_ATTR_INTRFC', 'PROCESS_STATUS', distcnt => 4, density => 0.25);

    dbms_stats.lock_table_stats('EGO', 'EGO_ITM_USR_ATTR_INTRFC');
    dbms_stats.lock_table_stats('INV', 'MTL_SYSTEM_ITEMS_INTERFACE');
    dbms_stats.lock_table_stats('INV', 'MTL_ITEM_REVISIONS_INTERFACE');
    
END;