
declare
--
-- Profiles:
-- FND: SMTP Host
-- FND: SMTP Port
--
p_smtp_host     varchar2(200);
p_smtp_port     number(15);

p_subject       VARCHAR2(50) := 'Estoy Probando SMTP';
p_to            varchar2(100) := 'vgerardo@gmail.com';
p_cc            varchar2(100) := 'ghalcon@yahoo.com';
p_from          varchar2(100) := 'gerardo.vargas@posadas.com';
p_message   varchar2(500) := 'probando email del ebs 4'; 

l_mail_conn   UTL_SMTP.connection;


BEGIN

    
    p_smtp_host := fnd_profile.value('FND_SMTP_HOST');
    p_smtp_port := fnd_profile.value('FND_SMTP_PORT');

    l_mail_conn := UTL_SMTP.open_connection(p_smtp_host, p_smtp_port);
  
    UTL_SMTP.helo(l_mail_conn, p_smtp_host);
    UTL_SMTP.mail(l_mail_conn, p_from);
    UTL_SMTP.rcpt(l_mail_conn, p_to);
    UTL_SMTP.rcpt(l_mail_conn, p_cc);
  
  -- send simple EMAIL (32Kb limit)
  --UTL_SMTP.data (l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);
  
  -- send large EMAIL
  UTL_SMTP.open_data(l_mail_conn);
  UTL_SMTP.write_data(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'From: ' || p_from || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'To: '   || p_to || UTL_TCP.crlf); 
  UTL_SMTP.write_data(l_mail_conn, 'Cc: '   || p_cc || UTL_TCP.crlf); 
  UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || p_subject || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || p_from || UTL_TCP.crlf || UTL_TCP.crlf);
  
  UTL_SMTP.write_data(l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);  
  UTL_SMTP.write_data(l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);  
  UTL_SMTP.write_data(l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);  
  UTL_SMTP.close_data(l_mail_conn);
    
  UTL_SMTP.quit(l_mail_conn);

END;


