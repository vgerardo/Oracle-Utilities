/*********************************************************

    Responsabilidad:    GRP_SYS_AD_CONE_DESARROLLO
    Request Group:      Application Developer Reports
    Concurrent Padre:   GRP Concurrente Padre con Hijos
    Concurrent Hijo:    GRP Hijito
    
    Descripción:        Este procedure es un ejemplo de llamada a un Sub-Request.

===============================================
NOTA IMPORTANTE DE ORACLE:
===============================================
How To Set The Parent Request Status Based On The Sub Request Result (Doc ID 1922152.1) 
https://support.oracle.com/knowledge/Oracle%20E-Business%20Suite/1922152_1.html

APPLIES TO: Oracle Concurrent Processing - Version 12.1.3 to 12.2 [Release 12.1 to 12.2]

GOAL 
 How to set parent request status based On sub request result ?   
 You are unable to set Parent Request Status based on Child Request completion status 
 when fnd_request.submit_request is used with sub_request  set to "TRUE".
 
SOLUTION 
 Please ensure the parent request must EXIT after setting its status to "Paused".   
 You can not check the child request status until the parent program is woken and runs the SECOND TIME. 
 So when we use sub_request as true , You can not check the status of child request

*********************************************************/
 CREATE OR REPLACE PROCEDURE bolinf.GRP_PADRE (
                                                    errbuf    OUT VARCHAR2,
                                                    retcode   OUT NUMBER
                                                ) authid current_user
IS    

-- Arreglo solo para almacenar los REQUEST_ID de los Hijos
TYPE t_sub_requests IS VARRAY(10) OF NUMBER(15); 
v_sub_request  t_sub_requests ;

v_data      VARCHAR2 (500);
v_req       NUMBER (15);
v_hijito    NUMBER (15);
v_status    VARCHAR2(15);
v_fase      varchar2(15);

BEGIN

    --
    -- verifica algún "hijo" anterior   
    -- esto es necesario, porque cuando se pone como "PAUSE" y después "DESPIERTA"
    -- el programa es llamado por 2da Vez.
    --
    v_data := fnd_conc_global.REQUEST_DATA;        
    IF v_data IS NOT NULL THEN
        -- Segunda Llamada (el Padre ha despertado)
        fnd_file.Put_Line (fnd_file.LOG, 'He despertado ¿quienes son mis hijos? = ' || v_data);  
        
        FOR hijo IN (
                    SELECT 
                        request_id,
                        DECODE (cr.status_code, 'A', 'Waiting', 'B', 'Resuming', 'C', 'Normal', 'D', 'Cancelled', 'E', 'Errored', 'F', 'Scheduled', 'G', 'Warning', 'H', 'On Hold', 'I', 'Normal', 'M', 'No Manager', 'Q', 'Standby', 'R', 'Normal', 'S', 'Suspended', 'T', 'Terminating', 'U', 'Disabled', 'W', 'Paused', 'X', 'Terminated', 'Z', 'Waiting', 'no se') status,
                        DECODE (cr.phase_code, 'R', 'Running', 'P', 'Pending', 'C', 'Complete', 'I', 'Inactive', cr.phase_code) fase
                    --INTO v_req, v_status, v_fase
                    FROM fnd_concurrent_requests cr
                    WHERE request_id IN (
                                        SELECT regexp_substr( '16015948,16015949,','[^,]+', 1, LEVEL) req_id
                                        FROM dual
                                        CONNECT BY regexp_substr( '16015948,16015949,', '[^,]+', 1, LEVEL) IS NOT NULL
                                        )
                    )
         LOOP
            fnd_file.Put_Line (fnd_file.LOG, 'Estatus de mi hijito ('||hijo.request_id||') = ' || hijo.status || ' ' || hijo.fase);  
            IF hijo.fase <> 'Normal' THEN
                retcode := -1;
            end if;
         END LOOP
        ;
        
        
        RETURN;
    end if;

    -- inicializa variables
    v_sub_request   := t_sub_requests() ;
    v_data          := '';
    v_hijito        := 0;

   loop       
       
        -- lleva el conteo de hijos procreados
        -- (como un buen padre :) )        
        v_hijito := v_hijito + 1;
                             
        -- este ejemplo, solo crea DOS hijitos 
        -- (hay que cuidar la planificación familiar!)
        IF v_hijito > 2  THEN           
           errbuf := 'Termina Ejecución del Padre';           
           EXIT;
        end if;
      
        v_req   := fnd_request.submit_request (
                            APPLICATION 	=> 'XBOL',
                            PROGRAM   		=> 'GRP_HIJITO', -- GRP Hijito
                            DESCRIPTION    	=> 'Hijito ' || TO_CHAR (v_hijito),
                            start_time      => NULL,  -- null = inmediato
                            sub_request     => TRUE     -- Indica que este será ¡su Hijo!
                            ,argument1       => v_hijito
                            --,argument2       => NULL
                            --,argument3       => NULL
                            -- etc hasta 100
                        );
    
        IF  v_req = 0    THEN         
            errbuf    := fnd_message.get;
            retcode   := 2;            
        ELSE 
            -- guarda el ID del Hijito
            v_sub_request.extend;
            v_sub_request(v_sub_request.LAST) := v_req;        
            v_data := v_data || v_req ||',';
        END IF;

    END LOOP;                  
            
    -- Indica que el Padre Esperará la finalización de "Cada" Hijo
    fnd_file.Put_Line (fnd_file.LOG, 'Dormiré hasta que mis hijos acaben su chamba: ' || v_hijito);    
    fnd_conc_global.SET_REQ_GLOBALS (
                conc_status    => 'PAUSED',
                request_data   =>  v_data  
        );              

            
    -- Simple Reporte de los Sub-Request (hijitos)    
    v_hijito := to_number(nvl(v_sub_request.LAST,0));
    fnd_file.Put_Line (fnd_file.LOG, 'Sub-Request Ejecutados = ' || v_hijito);    
    IF v_hijito > 0 THEN 
        FOR x IN 1 .. v_hijito LOOP         
            fnd_file.Put_Line (fnd_file.LOG, 'Sub-Request ID = ' || v_sub_request (x));            
        END LOOP;
    END IF;
        

END;
/

 CREATE OR REPLACE PROCEDURE bolinf.GRP_HIJITO (
                                                errbuf      OUT VARCHAR2,
                                                retcode     OUT NUMBER,
                                                p_hijito    in number
                                                ) 
IS  
v_data      VARCHAR2 (10);
BEGIN    
    fnd_file.Put_Line (fnd_file.OUTPUT, ' Ejemplo de un Hijito, ejecutado desde un concurrente Padre: '|| p_hijito);
    dbms_lock.sleep(3); -- solo para simular que está chambeando en algo
    
    IF p_hijito = 2 THEN        
        retcode := 1;
    END IF;    
    
END;
/

GRANT EXECUTE ON  bolinf.GRP_PADRE TO APPS;
GRANT EXECUTE ON bolinf.GRP_HIJITO TO APPS;


