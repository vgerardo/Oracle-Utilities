SET SERVEROUTPUT ON
DECLARE
v_uom_conv  NUMBER(15,4);
BEGIN

    v_uom_conv := INV_CONVERT.inv_um_convert(
                                         p_item_id       => 112271
                                        ,p_from_uom_code => 'kg'
                                        ,p_to_uom_code   => 'pz'
                                    );
                            
    IF v_uom_conv = -99999 THEN
        RAISE_APPLICATION_ERROR (-20101, 'NO HAY REGLA DE CONVERSIÓN');
    END IF;
    
    DBMS_OUTPUT.Put_Line ('Conversion = '||v_uom_conv );
    
END;
/

