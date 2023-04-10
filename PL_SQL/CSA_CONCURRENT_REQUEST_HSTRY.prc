CREATE OR REPLACE PROCEDURE BOLINF.CSA_CONCURRENT_REQUEST_HSTRY ( 
                                      p_errbuf            OUT   VARCHAR2,
                                      p_retcode           OUT   VARCHAR2
                                      )
IS
--
-- Created by   GERARDO'S ADVANCED TECHNOLOGY CORPORATION
-- Fecha: 03-Jul-2013 
--
-- Guarda la última ejecución de los concurrentes
--
-- EJECUTABLE                   CONCURRENTE
-- =======================      ==============================================
-- CSA_x     CSA_x


--
-- Concurrentes configurados en el EBSO, y activos
--
CURSOR c_concurrentes
IS
  SELECT  cptl.user_concurrent_program_name
         ,cp.concurrent_program_id
         ,exe.executable_id
         ,exe.execution_file_name
  FROM 
       fnd_concurrent_programs      cp,
       fnd_concurrent_programs_tl   cptl,
       apps.fnd_executables_vl      exe
  WHERE 1=1
    and cp.application_id         = cptl.application_id
    and cp.concurrent_program_id  = cptl.concurrent_program_id
    and cp.executable_id          = exe.executable_id  
    and cptl.language             IN ('ESA')
    and cp.enabled_flag           = 'Y'
    --and cp.concurrent_program_id = 54986                
    ;
  

--
-- Datos de la última ejecución del concurrente
-- Nota: puede a ver varios registros que corresopndan al MAX(request_date)
--      sin embargo solo intersa cualquiera de dichos registros
--
CURSOR c_ultima_ejecucion (p_concurrent_id number)
IS
    select 
           cr.request_id,
           cr.request_date,            
           cr.responsibility_id,
           cr.requested_by,     
           usr.user_name            
    from fnd_concurrent_requests cr,
         fnd_user                usr
    where 1=1
      and cr.requested_by          = usr.user_id (+)
      and cr.concurrent_program_id = p_concurrent_id
      and cr.hold_flag <> 'Y'   -- retenido
      and cr.request_date = (
                        select max(request_date)
                        from fnd_concurrent_requests        icr
                        where icr.concurrent_program_id = p_concurrent_id
                        )      
      and rownum < 2
    ;


--
-- número de veces que el concurrente ha sido ejecutado en un rango de fechas
-- Nota. a la fecha inicial se le suma 1 segundo
--
CURSOR c_conteo (p_concurrent_id number, p_fecha1 date, p_fecha2 date)
IS
    SELECT count(*) ejecuciones
    FROM fnd_concurrent_requests
    WHERE 1=1
    and concurrent_program_id = p_concurrent_id
    AND request_date between p_fecha1 + 0.00001 and p_fecha2
    ;

v_request_id        number(15);
v_old_executions    number(15);
v_new_executions    number(15);
v_last_date         date;
v_procesados        number(15) := 0;
v_insertados        number(15) := 0;
v_actualizados      number(15) := 0;
v_ignorados         number(15) := 0;
r_ultimo            c_ultima_ejecucion%rowtype;


BEGIN

    --
    -- Recorre todos los concurrentes configurados en el ERP
    --
    FOR c_conc IN c_concurrentes LOOP
        
        v_procesados := v_procesados + 1;
    
        --
        -- Busca la última ejecución del concurrente
        --
        r_ultimo := null;
        OPEN c_ultima_ejecucion (c_conc.concurrent_program_id);
        FETCH c_ultima_ejecucion INTO r_ultimo;
        CLOSE c_ultima_ejecucion ;

        --        
        -- si el concurrente fue ejecutado, lo inserta o actualiza el historial.
        -- de lo contrario no hace nada.
        --
        IF r_ultimo.request_date IS NOT NULL THEN
            
            BEGIN
                v_old_executions := 0;
                --
                -- Revisa el historial del concurrente
                --
                SELECT request_id, executions, last_execution_date
                INTO v_request_id, v_old_executions, v_last_date
                FROM BOLINF.CSA_EXECUTION_HSTRY
                WHERE concurrent_program_id = c_conc.concurrent_program_id
                ;
                
                -- 
                -- Si ambos IDs son iguales, significa que se trata de la misma ejecución
                -- Por lo tanto no realiza ni INSERT ni UPDATE
                -- 
                IF v_request_id = r_ultimo.request_id THEN
                    v_new_executions := -1;                    
                ELSE
                    -- cuenta cuantas ejecuciones hubo desde la ultima vez
                    open c_conteo (c_conc.concurrent_program_id, v_last_date, r_ultimo.request_date);
                    fetch c_conteo into v_new_executions;
                    close c_conteo;
                    v_new_executions := v_old_executions + v_new_executions;
                END IF;    
                
            EXCEPTION
                --
                -- Si el concurrente no existe en el historial, signfica que es su Primera ejecución.
                --
                WHEN NO_DATA_FOUND THEN                                                
                    v_new_executions := 1;
                    v_last_date  := null;
            END;
            
            
            --
            -- Si es 1 entonces concurrente ejecutado por primera vez
            -- Si es mayor a 1 entonces concurrente ejecutado por 2da, 3ra... N vez
            --
            IF v_new_executions = 1 THEN
                
                v_insertados := v_insertados +1;
                
                BEGIN
                INSERT INTO BOLINF.CSA_EXECUTION_HSTRY (
                                request_id,
                                user_concurrent_program_name,
                                concurrent_program_id,
                                executable_id,
                                execution_file_name,
                                responsibility_id,
                                last_execution_by,
                                last_execution_date,
                                executions ,
                                creation_date,
                                last_update_date
                ) VALUES (
                             r_ultimo.request_id,
                             c_conc.user_concurrent_program_name,
                             c_conc.concurrent_program_id,
                             c_conc.executable_id,
                             c_conc.execution_file_name,
                             r_ultimo.responsibility_id,
                             r_ultimo.requested_by,
                             r_ultimo.request_date,
                             v_new_executions,
                             sysdate,
                             sysdate
                );
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN
                        apps.fnd_file.put_line  (apps.fnd_file.output, 'REGISTRO DUPLICADO: ' || r_ultimo.request_id || '-'||c_conc.user_concurrent_program_name) ;                        
                END; 
            
            ELSIF v_new_executions > 1  THEN
                
                v_actualizados := v_actualizados + 1;
            
                UPDATE bolinf.CSA_EXECUTION_HSTRY SET
                    request_id                   = r_ultimo.request_id,
                    user_concurrent_program_name = c_conc.user_concurrent_program_name,
                    executable_id                = c_conc.executable_id,
                    execution_file_name          = c_conc.execution_file_name,        
                    responsibility_id            = r_ultimo.responsibility_id,
                    last_execution_by            = r_ultimo.requested_by,
                    last_execution_date          = r_ultimo.request_date,
                    executions                   = v_new_executions,                    
                    last_update_date             = sysdate
                WHERE concurrent_program_id = c_conc.concurrent_program_id
                ;   
            
            ELSE
                -- no es nuevo ni actualización
                v_ignorados := v_ignorados + 1;
            END IF;
        
        ELSE
            -- no han sido ejecutados
            v_ignorados := v_ignorados + 1;
            
        END IF; -- ultima ejecución
        
    END LOOP;


    COMMIT;


apps.fnd_file.put_line  (apps.fnd_file.output, 'Procesados:  ' || v_procesados)        ;
apps.fnd_file.put_line  (apps.fnd_file.output, 'Insertados:  ' || v_insertados)        ;
apps.fnd_file.put_line  (apps.fnd_file.output, 'Actualizados:' ||v_actualizados)      ;
apps.fnd_file.put_line  (apps.fnd_file.output, 'Ignorados:   ' ||v_ignorados)         ;


END;
/