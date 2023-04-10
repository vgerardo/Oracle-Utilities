SET SERVEROUTPUT ON

DECLARE

v_xref_table    MTL_CROSS_REFERENCES_PUB.XRef_Tbl_Type;
v_return_status varchar2(100);
v_msg_count     number(15);
v_message_list  Error_Handler.Error_Tbl_Type;

v_inventory_item_id     number(15);
v_cross_reference_id    number(15);
v_items_description    varchar2(250);
p_item                 varchar2(50):= 'AL.0002.06266';
p_org_id               number(15) := 91; --maestra


BEGIN

    -- Obtiene el ID del Item
    --
    SELECT msi.inventory_item_id
    INTO v_inventory_item_id
    FROM mtl_system_items_b msi
    WHERE msi.organization_id   = p_org_id
     AND (msi.segment1||'.'||msi.segment2||'.'||msi.segment3) = p_item
     AND msi.enabled_flag      = 'Y'
     AND TRUNC(SYSDATE) BETWEEN NVL(start_date_active, TRUNC(SYSDATE)) AND NVL(end_date_active, TRUNC(SYSDATE+1)) 
     ;

    v_xref_table (1).transaction_type       := 'CREATE'; --'CREATE/UPDATE/DELETING';

    IF v_xref_table (1).transaction_type <> 'CREATE' THEN
        SELECT cross_reference_id
        INTO v_cross_reference_id
        FROM APPS.Mtl_Cross_References_b
        WHERE cross_reference_type = 'GRP_ITEMS'
        AND inventory_item_id = v_inventory_item_id 
        ;  
        
        v_xref_table (1).cross_reference_id     := v_cross_reference_id;  --Necesario cuando UPDATE or DELETING        
        
    END IF;

    v_xref_table (1).cross_reference_type   := 'GRP_ITEMS';
    v_xref_table (1).org_independent_flag   := 'Y';    
    v_xref_table (1).inventory_item_id      := v_inventory_item_id;
    v_xref_table (1).cross_reference        := p_item; --Nombre de la Referencia.
    v_xref_table (1).description            := 'Creado por API: MTL_CROSS_REFERENCES_PUB';
    v_xref_table (1).attribute1             := 'http://cms.posadas.com/posadas/Catalogs/Media/SUMMAS/LaRanita/RANITA_AR00003.jpgx';
    --v_xref_table (1).attribute2             := 
    v_xref_table (1).attribute3             := sysdate+600; --expiration_date
    v_xref_table (1).attribute4             := to_char(sysdate,'yyyy-mm-dd'); --effective_date
    --v_xref_table (1).attribute5             := fianza
    --v_xref_table (1).attribute6             := item_desc_ext
    --v_xref_table (1).attribute7             := short_name
    --v_xref_table (1).attribute8             := price_unit
    --v_xref_table (1).attribute9             := price_unit_qty
    --v_xref_table (1).attribute10            := 
    --v_xref_table (1).attribute11            := unit_conversion
    v_xref_table (1).attribute12            := 'Y'; --is_partial (Y/N)
    --v_xref_table (1).attribute13            := parametric_name
    --v_xref_table (1).attribute14            := man_url
    
    
    --Public API Item Cross References
    MTL_CROSS_REFERENCES_PUB.process_xref (
                        p_api_version       => 1.0,
                        p_init_msg_list     => 'T',
                        p_commit            => 'F',
                        p_xref_tbl          => v_xref_table,
                        x_return_status     => v_return_status,
                        x_msg_count         => v_msg_count,
                        x_message_list      => v_message_list
                        );

    DBMS_OUTPUT.put_line ('X_return_status = ' || v_return_status);

    IF v_return_status = 'S'  THEN
          -- Means all records are loaded successfully.
        COMMIT;
        DBMS_OUTPUT.put_line ('Todo chido!');
          
    ELSE
    
        DBMS_OUTPUT.put_line ('Chin! Algo salió Mal!');
         -- Means all records are Failed.
        FOR i IN 1 .. v_message_list.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(v_message_list(i).message_text);
        END LOOP;         
         
         ROLLBACK;
    END IF;


END;
/