DECLARE

p_from      VARCHAR2(100) := 'proyectos@posadas.com';
p_to        varchar2(100) := 'gvargas@exatec.tec.mx';
p_cc        varchar2(100) := null; --'vgerardo@gmail.com';
p_subject   varchar2(100) := 'Email de Prueba. Instancia PRODUCCION. ';
p_message   varchar2(500) := 'Este correo es solo para probar, hacer caso omiso, gracias';

v_smtp_host     varchar2(200);
v_smtp_port     number(15);
v_mail_conn   UTL_SMTP.connection;
BEGIN

    p_subject := p_subject || to_char(sysdate, 'YYYY-MM-DD HH24:MI_SS');

    v_smtp_host := fnd_profile.value('FND_SMTP_HOST');
    v_smtp_port := fnd_profile.value('FND_SMTP_PORT');

    v_mail_conn := UTL_SMTP.open_connection (v_smtp_host, v_smtp_port);
    UTL_SMTP.helo(v_mail_conn, v_smtp_port);
    UTL_SMTP.mail(v_mail_conn, p_from);
    UTL_SMTP.rcpt(v_mail_conn, p_to);
    
    IF p_cc IS NOT NULL THEN    
        UTL_SMTP.rcpt(v_mail_conn, p_cc);  
    END IF;
    
    UTL_SMTP.open_data(v_mail_conn);
    UTL_SMTP.write_data(v_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
    UTL_SMTP.write_data(v_mail_conn, 'From: ' || p_from || UTL_TCP.crlf);
    UTL_SMTP.write_data(v_mail_conn, 'To: '   || p_to || UTL_TCP.crlf); 
    
    IF p_cc IS NOT NULL THEN
        UTL_SMTP.write_data(v_mail_conn, 'Cc: '   || p_cc || UTL_TCP.crlf); 
    END IF;
    
    UTL_SMTP.write_data(v_mail_conn, 'Subject: ' || p_subject || UTL_TCP.crlf);
    UTL_SMTP.write_data(v_mail_conn, 'Reply-To: ' || p_from || UTL_TCP.crlf || UTL_TCP.crlf);    
    UTL_SMTP.write_data(v_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);  
    --UTL_SMTP.write_data(v_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);  
    --UTL_SMTP.write_data(v_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);      
    UTL_SMTP.close_data(v_mail_conn);
    
    UTL_SMTP.quit(v_mail_conn);
END;
/