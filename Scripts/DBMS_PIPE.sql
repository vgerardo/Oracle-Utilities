--
-- typically only GRANT EXECUTE on DBMS_STOCK_SERVICE to the stock service application server, 
-- and would only GRANT EXECUTE on stock_request to those users allowed to use the service.
-- also: GRANT execute ON DBMS_PIPE TO myuser;
--
-- http://dbspecialists.com/a-quick-introduction-to-dbms_pipe/
-- https://docs.oracle.com/database/121/ARPLS/d_pipe.htm#ARPLS67413
--
set serveroutput on

declare

v_pipename   varchar2(30); 
random_val  varchar2(10) := DBMS_RANDOM.string('x',10); 

function Enviar_PIPE (p_msg varchar2) return varchar2
IS
status      number(15);
l_pipename  varchar2(30);

BEGIN
    dbms_pipe.RESET_BUFFER;
    l_pipename := 'CNC_TRX'; --'gvp_mi_pipe'||random_val;
    --l_pipename := dbms_pipe.UNIQUE_SESSION_NAME;
    dbms_output.put_line ('Se creará el pipe: '|| l_pipename);
    --status := DBMS_PIPE.CREATE_PIPE (pipename     => l_pipename);

    IF status <> 0 THEN
         dbms_output.put_line ('error al crear el pipe privado');
         raise_application_error(-20099, 'error al crear el pipe privado');    
    else
        dbms_output.put_line ('Created pipe: '|| l_pipename);
    END IF;
    
    --dbms_pipe.PACK_MESSAGE (pipe_name);

    dbms_pipe.pack_message (length(p_msg));
    dbms_pipe.pack_message (p_msg);
    --status := dbms_pipe.send_message('GVP_PIPE');        
    status := dbms_pipe.SEND_MESSAGE (l_pipename);

    IF status != 0 THEN
        dbms_output.put_line ('error en SEND Message');
        raise_application_error(-20099, 'error en SEND Message');
    else
        dbms_output.put_line ('SEND Message: '|| p_msg);
    END IF;
    
    return l_pipename;
    
END Enviar_PIPE;

Function Recibir_PIPE (p_pipe_name varchar2)return Varchar2
IS
status      number(15);
v_length    number(15);
v_message   varchar2(500);
errormsg    varchar2(512);
begin

    --status := dbms_pipe.RECEIVE_MESSAGE (dbms_pipe.unique_session_name);
    
    --If there are no messages, it will just sit there and wait until there is one.
    status := dbms_pipe.RECEIVE_MESSAGE(p_pipe_name, 15 /*seconds*/);
    
    IF status <> 0 THEN
        raise_application_error(-20000, 'Error:'||to_char(status)|| ' receiving on pipe');
        v_message :=  'Error:'||to_char(status)|| ' receiving on pipe';
    ELSE
        dbms_pipe.UNPACK_MESSAGE (v_length);
        dbms_pipe.UNPACK_MESSAGE (v_message);       
    END IF;
    
    /*dbms_pipe.UNPACK_MESSAGE (errormsg);    
    IF errormsg <> 'SUCCESS' THEN
        raise_application_error(-20000, errormsg);
        v_message :=   'Error:'||to_char(status)|| ' receiving on pipe';
    END IF;
    */
      
    dbms_pipe.REMOVE_PIPE  (p_pipe_name);
      
    return v_message;
    
end Recibir_PIPE;


BEGIN

    --v_pipename := Enviar_PIPE ('prueba de mi para mi: ' || to_char(sysdate,'hh24:mi:ss'));
    v_pipename :='CNC_TRX';
    dbms_output.PUT_LINE ( 'RECEIVED message: ' ||Recibir_PIPE (v_pipename));
    
END;


