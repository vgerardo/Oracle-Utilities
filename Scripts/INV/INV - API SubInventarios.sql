--
--NOTE: 286339.1   - HOW to load Items to organization, subinventory and locator using API
--NOTE: 1458355.1  - https://support.oracle.com/knowledge/Oracle%20E-Business%20Suite/1458355_1.html
--

DECLARE

v_dummy                 varchar2(100);
v_inventory_item_id     number(15) := 1;
v_organization_id       number(15) := 492;
v_secondary_inventory   varchar2(50) := 'SUB_BEBIDA';

BEGIN

    SELECT
        1
    INTO v_dummy
    FROM
        mtl_item_sub_inventories
    WHERE
        inventory_item_id = v_inventory_item_id
        AND secondary_inventory = v_secondary_inventory
        AND organization_id = v_organization_id
        ;

EXCEPTION
    WHEN no_data_found THEN
    
        INSERT INTO mtl_item_sub_inventories (
            inventory_item_id
          , organization_id
          , secondary_inventory
          , last_update_date
          , last_updated_by
          , creation_date
          , created_by
          , inventory_planning_code
        ) VALUES (
            v_inventory_item_id
          , v_organization_id
          , v_secondary_inventory
          , SYSDATE
          , fnd_global.user_id
          , SYSDATE
          , fnd_global.user_id
          , 6
        );

END;