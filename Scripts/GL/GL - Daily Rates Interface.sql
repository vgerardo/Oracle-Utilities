
TRUNCATE TABLE GL.gl_daily_rates_interface;

SELECT *
FROM GL_DAILY_RATES
WHERE from_currency = 'GTQ'
  AND to_currency = 'MXN'
  AND conversion_date < '01-OCT-22'
ORDER BY conversion_date desc
;

INSERT INTO gl_daily_rates_interface (
from_currency
,to_currency
,from_conversion_date
,to_conversion_date
,user_conversion_type
,conversion_rate
,mode_flag
,inverse_conversion_rate
,batch_number
)VALUES (
    'GTQ' --from_currency
    ,'MXN' --to_currency
    ,to_date ('2022-09-30', 'YYYY-MM-DD') --from_conversion_date
    ,to_date ('2022-09-30', 'YYYY-MM-DD') --to_conversion_date
    ,'Corporate' --user_conversion_type
    ,3 --conversion_rate
    ,'I' --mode_flag
    ,1/3 --inverse_conversion_rate
    ,123456789
)
;

SET SERVEROUTPUT ON
DECLARE
v_request_id    NUMBER(15);
BEGIN

    --PPGLA CRP GL Administracion Catalogo
    FND_GLOBAL.Apps_Initialize (19282, 51446, 101);
    
    --
    -- Ejecuta el concurrente "Program - Daily Rates Import and Calculation"
    --
    v_request_id := FND_REQUEST.Submit_Request (
                                            application => 'SQLGL'
                                            ,program    => 'GLDRICCP'
                                            ,description=> null
                                            ,start_time => null
                                            ,sub_request=> null
                                            ,argument1  => 123456789
                                        );
    COMMIT;
    
    IF v_request_id = 0 THEN
        DBMS_OUTPUT.put_line ('No se lanzó el concurrente: '|| fnd_message.get );
    END IF;
    
END;
/
