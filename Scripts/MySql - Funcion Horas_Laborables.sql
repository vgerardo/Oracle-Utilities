DROP FUNCTION IF EXISTS TCT2.CSA_Calcula_Horas;
CREATE FUNCTION TCT2.`CSA_Calcula_Horas`(p_inicio datetime, p_fin datetime ) RETURNS decimal(10,2)
BEGIN

DECLARE v_tiempo_1   TIME DEFAULT '00:00:00';
DECLARE v_tiempo_2   TIME DEFAULT '00:00:00';
DECLARE v_horas      TIME DEFAULT '00:00:00';
DECLARE v_fecha_loop DATE;
DECLARE v_horario_tmp1 DATETIME;
DECLARE v_horario_tmp2 DATETIME;
DECLARE v_dia int default 0;
DECLARE v_festivo date;
DECLARE v_done int default 0;
DECLARE v_horarios SET (
                       'Monday|08:30:00|13:30:00', 
                       'Monday|15:30:00|19:00:00',
                       'Tuesday|08:30:00|13:30:00', 
                       'Tuesday|15:30:00|19:00:00',
                       'Wednesday|08:30:00|13:30:00',
                       'Wednesday|15:30:00|19:00:00',
                       'Thursday|08:30:00|13:30:00',
                       'Thursday|15:30:00|19:00:00',
                       'Friday|08:30:00|14:30:00'                                              
                       );

DECLARE c_laborables CURSOR FOR SELECT inicio, fin FROM t_Laborables WHERE dianum = v_dia;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

DROP TEMPORARY TABLE IF EXISTS t_Laborables;
CREATE TEMPORARY TABLE IF NOT EXISTS t_Laborables (dianum int, diastr varchar(20), inicio time, fin time) ENGINE=MEMORY;
INSERT INTO t_Laborables (dianum, diastr, inicio, fin) VALUES (2, 'Monday',    '08:30:00', '13:30:00');
INSERT INTO t_Laborables (dianum, diastr, inicio, fin) VALUES (2, 'Monday',    '15:30:00', '19:00:00');
INSERT INTO t_Laborables (dianum, diastr, inicio, fin) VALUES (3, 'Tuesday',   '08:30:00', '13:30:00');
INSERT INTO t_Laborables (dianum, diastr, inicio, fin) VALUES (3, 'Tuesday',   '15:30:00', '19:00:00');
INSERT INTO t_Laborables (dianum, diastr, inicio, fin) VALUES (4, 'Wednesday', '08:30:00', '13:30:00');
INSERT INTO t_Laborables (dianum, diastr, inicio, fin) VALUES (4, 'Wednesday', '15:30:00', '19:00:00');
INSERT INTO t_Laborables (dianum, diastr, inicio, fin) VALUES (5, 'Thursday',  '08:30:00', '13:30:00');
INSERT INTO t_Laborables (dianum, diastr, inicio, fin) VALUES (5, 'Thursday',  '15:30:00', '19:00:00');
INSERT INTO t_Laborables (dianum, diastr, inicio, fin) VALUES (6, 'Friday',    '08:30:00', '14:30:00');

DROP TEMPORARY TABLE IF EXISTS t_Festivos;
CREATE TEMPORARY TABLE IF NOT EXISTS t_Festivos (fecha date, celebracion varchar(50)) ENGINE=MEMORY;
INSERT INTO t_Festivos (fecha, celebracion) VALUES ('2011-09-16', 'Revoluci?n');
INSERT INTO t_Festivos (fecha, celebracion) VALUES ('2011-11-21', 'x');
INSERT INTO t_Festivos (fecha, celebracion) VALUES ('2012-02-06', 'x');
INSERT INTO t_Festivos (fecha, celebracion) VALUES ('2012-03-19', 'x');
INSERT INTO t_Festivos (fecha, celebracion) VALUES ('2012-05-01', 'x');
INSERT INTO t_Festivos (fecha, celebracion) VALUES ('2012-09-17', 'Revolucion');
INSERT INTO t_Festivos (fecha, celebracion) VALUES ('2012-11-19', 'x');

  SET v_fecha_loop = Date(p_inicio); # fecha inicial, SIN Horas:Minutos:Segundos

  WHILE v_fecha_loop <= p_fin DO
      
      SET v_festivo = '1900-01-01';
      
      SELECT fecha INTO v_festivo
      FROM t_Festivos
      WHERE fecha = v_fecha_loop;
      
      # Si la variable no cambia, entonces NO encontro un dia festivo
      IF v_festivo = '1900-01-01' THEN
            
          SET v_done = 0;                          #variable que controla el LOOP
          
          SET v_dia = dayofweek(v_fecha_loop);     #parametro para el cursor 
          OPEN c_laborables;      
                         
          busca: LOOP 
               
              # obtiene el rango de Horario del dia en proceso.        
              FETCH c_laborables INTO v_tiempo_1, v_tiempo_2 ;
                 
              IF v_done = 1 THEN
                LEAVE busca;
              END IF;          
              
              # Agrega a la fecha el horario laboral: 
              # Ej. 8:30 a 13:30 -> '2011-10-20 08:30' a 2011-10-20 13:30
              #
              SET v_horario_tmp1 = ADDTIME (date_format(v_fecha_loop,'%Y-%m-%d %H:%i:%s'), v_tiempo_1);
              SET v_horario_tmp2 = ADDTIME (date_format(v_fecha_loop,'%Y-%m-%d %H:%i:%s'), v_tiempo_2);                                              
              
              # si el "rango de horario" esto dentro del "rango de los parametros"
              # si el "rango de parametros" esto dentro del "rango de horario"
              # entonces suma las horas del rango que corresponda.
              #
              IF  
                    v_horario_tmp1 BETWEEN p_inicio       AND p_fin
                 OR v_horario_tmp2 BETWEEN p_inicio       AND p_fin
                 OR p_inicio       BETWEEN v_horario_tmp1 AND v_horario_tmp2
                 OR p_fin          BETWEEN v_horario_tmp1 AND v_horario_tmp2
              THEN 
                SET v_horario_tmp1 = IF (v_horario_tmp1 >= p_inicio and v_horario_tmp1 <= p_fin, v_horario_tmp1, p_inicio );
                SET v_horario_tmp2 = IF (v_horario_tmp2 >= p_inicio and v_horario_tmp2 <= p_fin, v_horario_tmp2, p_fin );
                       
                SET v_horas = ADDTIME(v_horas, TIMEDIFF (v_horario_tmp2, v_horario_tmp1) );
              END IF;          
          
          END LOOP busca;  # termina busqueda de horarios del dia
          
          CLOSE c_laborables;
    
      END IF; # No es Festivo    
          
      SET v_fecha_loop = DATE_ADD(v_fecha_loop,INTERVAL 1 DAY);    
    
  END WHILE; # termina de recorrer las fechas del rango
  
  # Convierte el Tiempo(HH:MI:SS) en Segundos y luego lo transforma en Horas (999.99)
  RETURN (TIME_TO_SEC(v_horas) / 60 / 60);
  
END;
