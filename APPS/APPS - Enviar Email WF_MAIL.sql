DECLARE

v_message       clob := 'prueba wf_mail en clob';
v_recipients    WF_MAIL.wf_recipient_list_t; 

begin

    v_recipients(1).name := 'Gerardo Vargas';
    v_recipients(1).address := 'vgerardo@gmail.com';
    v_recipients(1).recipient_type := 'TO'; 


    v_recipients(2).name := 'Agustin Fernandez';
    v_recipients(2).address := 'agustin.fernandez@posadas.com';
    v_recipients(2).recipient_type := 'CC'; 

    WF_MAIL.send (
           p_subject            => 'PRUEBA DE WF_MAIL 3',
           p_message            => v_message,
           p_recipient_list     => v_recipients,
           p_module             => 'XBOL',
           p_idstring           => null,
           p_from               => 'gerardo.vargas@posadas.com',
           p_replyto            => null,
           p_language           => 'AMERICAN',
           p_territory          => 'AMERICA',
           p_codeset            => 'UTF8',
           p_content_type       => 'text/plain',
           p_callback_event     => null,
           p_event_key          => null,
           p_fyi_flag           => null
           );
   
END;   
/

SHOW ERRORS
