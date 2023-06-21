--
-- Validación de Cuentas Contables
--

set serveroutput on

declare
    v_combination_id number(15);
    v_status         boolean;
    v_segmentos      FND_FLEX_EXT.SegmentArray;
begin

v_segmentos(1) := '0306';       -- compañia
v_segmentos(2) := '0000';       -- centro costo
v_segmentos(3) := '2182';       -- cuenta
v_segmentos(4) := '201226';     -- subcta
v_segmentos(5) := '000';        -- subsubcta
v_segmentos(6) := '0000';       -- intercompñía
v_segmentos(7) := '0000';       -- identificador
v_segmentos(8) := '0000';       -- Operativo

    v_status :=
                FND_FLEX_EXT.get_combination_id (   
                                        application_short_name  => 'SQLGL'
                                       ,key_flex_code           => 'GL#'
                                       ,structure_number        => 50393
                                       ,validation_date         => SYSDATE
                                       ,n_segments              => 8 --number of segments
                                       ,segments                => v_segmentos
                                       ,combination_id          => v_combination_id
                                       ,data_set                => -1
                                       )
    ;

    if v_status then
        DBMS_OUTPUT.put_line ('Cuenta Valida: ' || v_combination_id);
    else
        DBMS_OUTPUT.put_line ('Cta. Invalida: ' || v_combination_id);
    end if;    

end;
/

