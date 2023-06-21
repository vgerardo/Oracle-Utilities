------------------------------------------------- ---------------------------------------------------
-->--                            Copyright © 2008 Craig J. Butts                                --<--
-->--                                    Plain City, Utah                                       --<--
-->--                                  All Rights Reserved                                      --<--
-- ----------------------------------------------------------------------------------------------- --
--  File Description:  
--    This Package is based on the DEMO_MAIL package downloadable from the Oracle Technology Network.
--    This package provide an easy interface to create and send email with or without attachments
--    to any valid email address.  The package allows you to specify multiple Recipients, CC, and BCC
--    recipients.  It also allows you to send file attachments of any file size (I have only tested
--    file attachements with a maximum of 15BM, but there is no built in restriction on the size). 
--
--  Additional Information: 
--  *** THIS PACKAGE WILL NOT SEND MAIL UNLESS YOU CHANGE THE "REQUIRED" ITEMS Listed in the package 
--  *** specification.  This is a GENERIC package and it must be configured to your Mail Server.
--  *** Search for "REQUIRED" in the package body.  Each of items marked "REQUIRED" must be confifured
--      to your environment.
--
--  Oracle 8i Note:
--  If you are required to use an Encrypted User ID and Password to connect to your email server
--  such as Microsoft Exchange, the Java Stored Procedure DEMO_BASE64 to be compiled in the DATABASE
--  Oracle 9i or Higher:
--  You can use the UTL_ENCODE package to perform the UUEncoding.
--
--     This package uses Oracle Directories for the source location of the file attachments. You must
--     create the following DIRECTORY at a minimum and you must ensure the file exists in the location
--     defined by this Oracle DIRECTORY.
--
--     CREATE OR REPLACE DIRECTORY UPLOAD_DIR as '/tmp/'; (or as dictated by DBA).
-- ----------------------------------------------------------------------------------------------- --
--    Revision History  :
--    NAME     DATE           DESCRIPTION
--    CJB      06/30/2006     Created.
--    CJB      04/21/2007     Added SET methods for the Recipient, From, CC, BCC addresses
--    CJB      05/15/2007     Modified the SETter methods to write to a COLLECTION rather than write 
--                            to a Package VARCHAR2 variable. This simplified the process and enabled
--                            the ability to LOOP through a list of email addresses stored in a table.
--    CJB      06/18/2007     Altered SEND to accept a parameter to Disable sending email to addresses
--                            outside of the company domain.  You may not need this, but we found this 
--                            handy in testing situations where we only wanted to send TEST emails to
--                            company addresses.
-- ----------------------------------------------------------------------------------------------- --

-- Start Package specification
-- ----------------------------------------------------------------------------------------------- --
CREATE OR REPLACE PACKAGE EMAIL_PKG IS
   -- 
   -- Define package Global Variables
   -- -------------------------------
   HTML_MIME_TYPE          CONSTANT VARCHAR2(10) := 'text/html';
   TEXT_MIME_TYPE          CONSTANT VARCHAR2(12) := 'text/plain';
   PDF_MIME_TYPE           CONSTANT VARCHAR2(17) := 'application/pdf';
   XLS_MIME_TYPE           CONSTANT VARCHAR2(20) := 'application/xls';
  
   --
   -- Program unit declaration
   -- ------------------------
   PROCEDURE set_recipient (p_to VARCHAR2);
   PROCEDURE set_from (p_from VARCHAR2);
   PROCEDURE set_cc (p_copy VARCHAR2);
   PROCEDURE set_bcc (p_bcopy VARCHAR2);
   PROCEDURE set_subject (p_subj VARCHAR2);
   PROCEDURE set_message ( p_msg VARCHAR2, p_mtype VARCHAR2 DEFAULT TEXT_MIME_TYPE);
   PROCEDURE set_attachment (p_request_id NUMBER, p_display_name VARCHAR2, p_mtype VARCHAR2 DEFAULT PDF_MIME_TYPE);
   PROCEDURE set_attachment (p_filename VARCHAR2, p_display_name VARCHAR2, p_mtype VARCHAR2 DEFAULT TEXT_MIME_TYPE);
   PROCEDURE send ( p_send_outside VARCHAR2 DEFAULT 'YES' );
   PROCEDURE set_message_body ( p_msg VARCHAR2, p_mime_type VARCHAR2 DEFAULT 'TEXT');
   
END;  
/
-- End of the Package specification
-- ----------------------------------------------------------------------------------------------- --


--
-- Start Package Body
-- ----------------------------------------------------------------------------------------------- --
CREATE OR REPLACE PACKAGE BODY EMAIL_PKG IS
   -- 
   -- Program EXCEPTIONS
   -- ------------------
   invalid_mime_type    EXCEPTION;
   invalid_recipient    EXCEPTION;
   invalid_message      EXCEPTION;
   invalid_subject      EXCEPTION;

   TYPE FILES_REC IS RECORD ( request_id VARCHAR2(30), file_name VARCHAR2(150), display_name VARCHAR2(150), mime_type VARCHAR2(30));
   TYPE FILES_TABLE IS TABLE OF files_rec INDEX BY BINARY_INTEGER;
   
   -- 
   -- Private package variables
   -- -------------------------
   f_files_rec             FILES_REC;
   tbl_files               FILES_TABLE;
   null_files_tbl          FILES_TABLE;
   tbl_rownum              PLS_INTEGER := 1;

   -- REQUIRED:  Change SMTP_HOST variable to your Mail Server address.
	-- -----------------------------------------------------------------
   smtp_host               CONSTANT VARCHAR2(256) := 'mail.myserver.com';
   smtp_port               CONSTANT PLS_INTEGER := 25;
   -- REQUIRED:  Change the SMTP_DOMAIN to your domain address.
   smtp_domain             CONSTANT VARCHAR2(256) := 'myserver.com';

   -- END REQUIRED:
	-- -----------------------------------------------------------------
   
   MAILER_ID               CONSTANT VARCHAR2(256) := 'Mailer by Oracle UTL_SMTP';
   BOUNDARY                CONSTANT VARCHAR2(256) := '-----7D81B75CCC90D2974F7A1CBD';
   FIRST_BOUNDARY          CONSTANT VARCHAR2(256) := '--' || BOUNDARY || utl_tcp.CRLF;
   LAST_BOUNDARY           CONSTANT VARCHAR2(256) := '--' || BOUNDARY || '--' ||utl_tcp.CRLF;
   MULTIPART_MIME_TYPE     CONSTANT VARCHAR2(256) := 'multipart/mixed; boundary="'||BOUNDARY || '"';
   MAX_BASE64_LINE_WIDTH   CONSTANT PLS_INTEGER := 76 / 4 * 3;
   START_CHAR              CONSTANT CHAR(1) := '<';
   END_CHAR                CONSTANT CHAR(1) := '>';
   MAX_LINE_WIDTH          PLS_INTEGER := 54;
   vErrMsg                 VARCHAR2(1000);
   nErrNum                 NUMBER;
   nArryCount              NUMBER;

   -- Base TYPE for each of the Recipient VARRAYs.
   TYPE eAddr_var IS VARRAY(1000) OF VARCHAR2(1000);

   -- VARRAY to hold SET_RECIPIENT addresses
   rTo   eAddr_var := eAddr_var();
   
   -- VARRAY to Hold SET_CC addresses
   rCC   eAddr_var := eAddr_var();
   
   -- VARRAY to hold SET_BCC addresses
   rBcc  eAddr_var := eAddr_var();

   -- REQUIRED:  Change P_SENDER to reflect your company standard.
   p_sender       VARCHAR2(1000) := '<DoNotReply@myserver.com>'; 
   p_recipients   VARCHAR2(2000);
   p_cc           VARCHAR2(2000);
   p_bcc          VARCHAR2(2000);
   p_subject      VARCHAR2(250);
   p_message      VARCHAR2(4000);
   p_msg_mimetype VARCHAR2(25);
   
   username       VARCHAR2(50);
   password       VARCHAR2(20);
   
-- ----------------------------------------------------------------------------------------------- --
-- Start of Private Program Units
-- These program units hide the complexity of using the UTL_SMTP package.
-- ----------------------------------------------------------------------------------------------- --

   -- get_address - Called by BEGIN_MAIL_IN_SESSION to ensure a properly formatted 
   --             email address.
   -- ---------------------------------------------------------------------------------
   FUNCTION get_address(addr_list IN OUT VARCHAR2) RETURN VARCHAR2 
   IS
      addr VARCHAR2(256);
      i pls_integer;

      --
      -- Private Function LOOKUP_UNQUOTED_CHAR
      -- -------------------------------------------------------------------------------
      FUNCTION lookup_unquoted_char(str IN VARCHAR2,chrs IN VARCHAR2) RETURN pls_integer 
      AS
         c VARCHAR2(5);
         i pls_integer;
         len pls_integer;
         inside_quote BOOLEAN;
      BEGIN
         inside_quote := false;
         i := 1;
         len := length(str);

         WHILE (i <= len) LOOP
            c := substr(str, i, 1);

            IF (inside_quote) THEN
               IF (c = '"') THEN
                  inside_quote := false;
               ELSIF (c = '\') THEN
                  i := i + 1; -- Skip the quote character
               END IF;
            END IF;

            IF (c = '"') THEN
               inside_quote := true;
            END IF;
            IF (instr(chrs, c) >= 1) THEN
               RETURN i;
            END IF;
            i := i + 1;
         END LOOP;
         RETURN 0;
      END lookup_unquoted_char; -- END of private LOOKUP_UNQUOTED_CHAR function.

   BEGIN
      addr_list := ltrim(addr_list);
      i := lookup_unquoted_char(addr_list, ',;');
      IF (i >= 1) THEN
         addr := substr(addr_list, 1, i - 1);
         addr_list := substr(addr_list, i + 1);
      ELSE
         addr := addr_list;
         addr_list := '';
      END IF;
      i := lookup_unquoted_char(addr, '<');
      IF (i >= 1) THEN
         addr := substr(addr, i + 1);
         i := instr(addr, '>');
         IF (i >= 1) THEN
            addr := substr(addr, 1, i - 1);
         END IF;
      END IF;
      RETURN addr;
   END get_address;
   
   -- write_mime_header
   -- -------------------------------------------------------------------------------------
   PROCEDURE write_mime_header(conn IN OUT NOCOPY utl_smtp.connection,name IN VARCHAR2,value IN VARCHAR2) 
   IS
   BEGIN
      utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(name || ': ' || value || utl_tcp.CRLF));
   END write_mime_header;
   
   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE write_boundary(conn IN OUT NOCOPY utl_smtp.connection,last IN BOOLEAN DEFAULT FALSE) 
   AS
   BEGIN
      IF (last) THEN
         utl_smtp.write_data(conn, LAST_BOUNDARY);
      ELSE
         utl_smtp.write_data(conn, FIRST_BOUNDARY);
      END IF;
   END write_boundary;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE write_text(conn IN OUT NOCOPY utl_smtp.connection,message IN VARCHAR2) 
   IS
   BEGIN
      utl_smtp.write_data(conn, message);
   END write_text;

   -- 
   -- -------------------------------------------------------------------------------------
   FUNCTION begin_session RETURN utl_smtp.connection 
   IS
      -- REQUIRED. Change these variables to your application needs.
      username    VARCHAR2(50);--  := 'srv_AutoMail';
      password    VARCHAR2(20);--  := 'EcGdjXwr9K';
      -- END REQUIRED:
      
      conn        utl_smtp.connection;

      
   BEGIN
      -- REQUIRED:  This package defaults to using MS-Exchange 2000.  You will need to alter
      --            this configuration to match your application needs.
      conn := utl_smtp.open_connection(smtp_host, smtp_port);
      
      -- MS-Exchange 2000. (ehlo = Extended SMTP.)
      utl_smtp.ehlo(conn, smtp_domain);  
      
      -- MS-Exchange non-2000 version it doesn't use the Extended SMTP hello.
      --utl_smtp.helo(conn, smtp_domain);
      
      utl_smtp.command(conn,'AUTH LOGIN');
      --
      -- The following lines are needed for Oracle dB 8i and require the 
      -- Java Stored Procedure DEMO_BASE64 to be compiled in the DATABASE
      --
      utl_smtp.command(conn,demo_base64.encode(utl_raw.cast_to_raw(username)));
      utl_smtp.command(conn,demo_base64.encode(utl_raw.cast_to_raw(password)));
        
      RETURN conn;
   END begin_session;

   --
   -- Add support for CC and BCC recipiants.....
   -- 
   PROCEDURE begin_mail_in_session(conn IN OUT NOCOPY utl_smtp.connection,
                                   sender IN VARCHAR2,
                                   recipients IN VARCHAR2,
                                   carbon_copy IN VARCHAR2,
                                   blind_CC IN VARCHAR2,
                                   subject IN VARCHAR2,
                                   mime_type IN VARCHAR2 DEFAULT 'text/plain',priority IN PLS_INTEGER DEFAULT NULL) 
   IS
      my_recipients  VARCHAR2(32767) := recipients;
      my_cc          VARCHAR2(32767) := carbon_copy;
      my_bcc         VARCHAR2(32767) := blind_cc;
      my_sender      VARCHAR2(32767) := sender;
      tzone          CHAR(3);
      mail_date      VARCHAR2(40) := to_char(sysdate,'DY, DD MON YYYY HH24:MI:SS');
                                    --Date: Thu, 13 Jul 2006 01:54:21 -0600
   BEGIN
      BEGIN
         SELECT decode(SESSIONTIMEZONE,'-06:00','MDT','MST') INTO tzone FROM dual;
      END;
      
      utl_smtp.mail(conn, get_address(my_sender));
      
      WHILE (my_recipients IS NOT NULL) LOOP
         utl_smtp.rcpt(conn, get_address(my_recipients));
      END LOOP;
      WHILE (my_cc IS NOT NULL) LOOP
         utl_smtp.rcpt(conn, get_address(my_cc));
      END LOOP;
      WHILE (my_bcc IS NOT NULL) LOOP
         utl_smtp.rcpt(conn,get_address(my_bcc));
      END LOOP;
      
      utl_smtp.open_data(conn);
      write_mime_header(conn, 'Date', mail_date||' '||tzone);
      write_mime_header(conn, 'From', sender);
      write_mime_header(conn, 'To', recipients);
      
      IF (carbon_copy IS NOT NULL ) THEN 
         write_mime_header(conn,'Cc',carbon_copy);
      END IF;
      IF ( blind_cc IS NOT NULL ) THEN 
         write_mime_header(conn,'Bcc',blind_cc);
      END IF;
      
      write_mime_header(conn, 'Subject', subject);
      write_mime_header(conn, 'Content-Type', mime_type);
      write_mime_header(conn, 'X-Mailer', MAILER_ID);
      IF (priority IS NOT NULL) THEN
         write_mime_header(conn, 'X-Priority', priority);
      END IF;
      
      utl_smtp.write_data(conn, utl_tcp.CRLF);
      IF (mime_type LIKE 'multipart/mixed%') THEN
         write_text(conn, 'This is a multi-part message in MIME format.' ||utl_tcp.crlf);
      END IF;
   END begin_mail_in_session;

   -- 
   -- -------------------------------------------------------------------------------------
   FUNCTION begin_mail(sender       IN VARCHAR2,
                       recipients   IN VARCHAR2,
                       carbon_copy  IN VARCHAR2,
                       blind_cc     IN VARCHAR2,
                       subject      IN VARCHAR2,
                       mime_type    IN VARCHAR2 DEFAULT 'text/plain',
                       priority     IN PLS_INTEGER DEFAULT NULL) RETURN utl_smtp.connection 
   IS
      conn utl_smtp.connection;
   BEGIN
      conn := begin_session;
      begin_mail_in_session(conn, sender, recipients, carbon_copy, blind_cc, subject, mime_type);
      RETURN conn;
   END begin_mail;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE end_mail_in_session(conn IN OUT NOCOPY utl_smtp.connection) 
   IS
   BEGIN
      utl_smtp.close_data(conn);
   END end_mail_in_session;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE end_session(conn IN OUT NOCOPY utl_smtp.connection) 
   IS
   BEGIN
      utl_smtp.quit(conn);
   END end_session;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE end_mail(conn IN OUT NOCOPY utl_smtp.connection) 
   IS
   BEGIN
      end_mail_in_session(conn);
      end_session(conn);
   END end_mail;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE mail(sender IN VARCHAR2,recipients IN VARCHAR2, cc IN VARCHAR2, bcc IN VARCHAR2, subject IN VARCHAR2,message IN VARCHAR2) 
   IS
      conn utl_smtp.connection;
   BEGIN
      conn := begin_mail(sender, recipients, cc, bcc, subject);
      write_text(conn, message);
      end_mail(conn);
   END mail;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE write_mb_text(conn IN OUT NOCOPY utl_smtp.connection,message IN VARCHAR2) 
   IS
   BEGIN
      utl_smtp.write_raw_data(conn, utl_raw.cast_to_raw(message));
   END write_mb_text;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE write_raw(conn IN OUT NOCOPY utl_smtp.connection,message IN RAW) 
   IS
   BEGIN
      utl_smtp.write_raw_data(conn, message);
   END write_raw;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE begin_attachment(conn IN OUT NOCOPY utl_smtp.connection,
                              mime_type IN VARCHAR2 DEFAULT 'text/plain',
                              inline IN BOOLEAN DEFAULT TRUE,
                              filename IN VARCHAR2 DEFAULT NULL,
                              transfer_enc IN VARCHAR2 DEFAULT NULL) 
   IS
   BEGIN
      write_boundary(conn);
      write_mime_header(conn, 'Content-Type', mime_type);
      IF (filename IS NOT NULL) THEN
         IF (inline) THEN
            write_mime_header(conn, 'Content-Disposition','inline; filename="'||filename||'"');
         ELSE
            write_mime_header(conn, 'Content-Disposition','attachment; filename="'||filename||'"');
         END IF;
      END IF;
      IF (transfer_enc IS NOT NULL) THEN
         write_mime_header(conn, 'Content-Transfer-Encoding', transfer_enc);
      END IF;
      utl_smtp.write_data(conn, utl_tcp.CRLF);
   END begin_attachment;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE end_attachment(conn IN OUT NOCOPY utl_smtp.connection,last IN BOOLEAN DEFAULT FALSE) 
   IS
   BEGIN
      utl_smtp.write_data(conn, utl_tcp.CRLF);
      IF (last) THEN
         write_boundary(conn, last);
      END IF;
      --utl_smtp.write_data(conn, utl_tcp.CRLF); --CJB testing to seperate multiple binary attachments.      
   END end_attachment;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE attach_text(conn IN OUT NOCOPY utl_smtp.connection,
                         data IN VARCHAR2,
                         mime_type IN VARCHAR2 DEFAULT 'text/plain',
                         inline IN BOOLEAN DEFAULT TRUE,
                         filename IN VARCHAR2 DEFAULT NULL,
                         last IN BOOLEAN DEFAULT FALSE) 
   IS
   BEGIN
      begin_attachment(conn, mime_type, inline, filename);
      write_text(conn, data);
      end_attachment(conn, last);
   END attach_text;

   -- 
   -- -------------------------------------------------------------------------------------
   PROCEDURE attach_base64(conn IN OUT NOCOPY utl_smtp.connection,
                           data IN RAW,
                           mime_type IN VARCHAR2 DEFAULT 'application/octet',
                           inline IN BOOLEAN DEFAULT TRUE,
                           filename IN VARCHAR2 DEFAULT NULL,
                           last IN BOOLEAN DEFAULT FALSE) 
   IS
      i PLS_INTEGER;
      len PLS_INTEGER;  
   BEGIN
      begin_attachment(conn, mime_type, inline, filename, 'base64');
      i := 1;
      len := utl_raw.length(data);

      WHILE (i < len) LOOP
         IF (i + MAX_BASE64_LINE_WIDTH < len) THEN
            utl_smtp.write_raw_data(conn,
            utl_encode.base64_encode(utl_raw.substr(data, i,
            MAX_BASE64_LINE_WIDTH)));
         ELSE
            utl_smtp.write_raw_data(conn,
            utl_encode.base64_encode(utl_raw.substr(data, i)));
         END IF;
         utl_smtp.write_data(conn, utl_tcp.CRLF);
         i := i + MAX_BASE64_LINE_WIDTH;
      END LOOP;
      end_attachment(conn, last);
   END attach_base64; 

   -- 
   -- outside_address_f
   -- The purpose of this Function is to test if the email address given is an interanl
   -- email address.
   -- --------------------------------------------------------------------------------
   FUNCTION OUTSIDE_ADDRESS_F ( p_addr_in VARCHAR2 ) RETURN BOOLEAN IS
      bRetVal  BOOLEAN;
      nTest    NUMBER;
   BEGIN
      -- REQUIRED:  Change this to match your environment.
      nTest := instr(UPPER(p_addr_in),'MYSERVER.COM');
      -- END REQUIRED:
      
      IF ( nTest > 0 ) THEN 
         bRetVal := FALSE;
      ELSE
         bRetVal := TRUE;
      END IF;
      
      RETURN bRetVal;
   END OUTSIDE_ADDRESS_F; 

   -----------------------------------------------------------------------------------
   -- END of Private Program Units
   -----------------------------------------------------------------------------------

   -----------------------------------------------------------------------------------
   -- Start of PUBLIC Program Units
   -----------------------------------------------------------------------------------

   --
   -- set_recipient
   -- PARAMETER:  p_to (Required)
   -- At least one recipient must be set. Who the email being sent to. Multiple calls 
   -- to set_recipient will combine the recipients into a group and the email will 
   -- be sent to each address.
   -- -----------------------------------------------------------------------------
   PROCEDURE set_recipient (p_to VARCHAR2) IS
   BEGIN
      nArryCount := 0;

      IF ( p_to IS NOT NULL ) THEN 
         -- Get the number of records in the rTo VARRAY
         nArryCount := rTo.COUNT;
         
         -- Increment the count by 1
         nArryCount := nArryCount + 1;
         
         rTO.EXTEND;
         rTO(nArryCount) := p_to;
      END IF;

   END set_recipient;
   -- -----------------------------------------------------------------------------

   -- 
   -- set_from
   -- PARAMETER:  p_sender (not Required)
   -- If not set, the default value is:  DoNotReply@browning.com
   -- This parameter does not allow for more than one Sender email address.
   -- -----------------------------------------------------------------------------
   PROCEDURE set_from (p_from VARCHAR2) IS
   BEGIN
      IF ( p_from IS NOT NULL ) THEN
         p_sender := START_CHAR||p_from||END_CHAR;
      END IF;
   END set_from;
   -- -----------------------------------------------------------------------------

   -- 
   -- set_cc
   -- PARAMETER:  p_copy (not Required)
   -- Use this parameter to send a Carbon Copy (CC) to an email address.  This
   -- procedure allows you to send the CC to more than one recipient.
   -- -----------------------------------------------------------------------------
   PROCEDURE set_cc (p_copy VARCHAR2) IS
   BEGIN
      nArryCount := 0;

      IF ( p_copy IS NOT NULL ) THEN 
         -- Get the number of records in the rTo VARRAY
         nArryCount := rCC.COUNT;
         
         -- Increment the count by 1
         nArryCount := nArryCount + 1;
         
         rCC.EXTEND;
         rCC(nArryCount) := p_copy;
      END IF;

   END set_cc;
   -- -----------------------------------------------------------------------------

   --
   -- set_bcc
   -- PARAMETER: p_bcopy
   -- Use this parameter to send a BLIND Carbon Copy (BCC) to an email address.  This 
   -- procedure allows you to send the BCC to more than one recipient.
   -- ------------------------------------------------------------------------------
   PROCEDURE set_bcc (p_bcopy VARCHAR2) IS
   BEGIN
      nArryCount := 0;

      IF ( p_bcopy IS NOT NULL ) THEN 
         -- Get the number of records in the rTo VARRAY
         nArryCount := rBcc.COUNT;
         
         -- Increment the count by 1
         nArryCount := nArryCount + 1;
         
         rBcc.EXTEND;
         rBcc(nArryCount) := p_bcopy;
      END IF;

   END set_bcc;
   -- ------------------------------------------------------------------------------
   
   -- 
   -- set_subject
   -- PARAMETER: p_subj (Required)
   -- Use this parameter to set the subject of your message.  A subject is required.
   -- ------------------------------------------------------------------------------
   PROCEDURE set_subject (p_subj VARCHAR2) IS
   BEGIN
      IF ( p_subj IS NULL ) THEN 
         p_subject := p_subj;
      ELSE
         p_subject := p_subject||' '||p_subj;
      END IF;
   END set_subject;
   -- ------------------------------------------------------------------------------
   
   -- 
   -- set_message
   -- PARAMETER:  p_mtype (Default = TEXT) , p_msg
   -- ** P_MTYPE: This parameter sets the MIME TYPE of the message body.  If HTML, 
   -- ensure the value of P_MSG is appropriated coded with the HTML tags you want 
   -- displayed in your message.  Use the Package Constants (TEXT_MIME_TYPE or HTML_MIME_TYPE)
   -- ** P_MSG: This parameter is the BODY of your email message.  Ensure you have 
   -- formatted your message according to the MIME TYPE specified in P_MTYPE.
   -- ------------------------------------------------------------------------------
   PROCEDURE set_message ( p_msg VARCHAR2, p_mtype VARCHAR2 DEFAULT TEXT_MIME_TYPE) AS
   BEGIN
      IF ( p_mtype IS NOT NULL AND p_mtype IN (TEXT_MIME_TYPE, HTML_MIME_TYPE) ) THEN 
         p_msg_mimetype := p_mtype;
      END IF;
      
      IF ( p_msg IS NOT NULL ) THEN 
         p_message := p_msg;
      END IF;
   END set_message;
   -- ------------------------------------------------------------------------------
   
   --
   -- set_attachment  -  Overloaded
   -- PARAMETERS: p_request_id - Concurrent Request ID
   --             p_display_name - This is the name the file will be given when it is 
   --                               attached to the email.
   --             p_mtype - The MIME type of the attached file - defaults to PDF.
   -- This procedure will allow you to attach the output file from a Concurrent Request
   -- to an email message using the REQUEST_ID of the concurrent request. You can set 
   -- more than one request_id through multiple calls to this procedure.
   -- ------------------------------------------------------------------------------   
   PROCEDURE SET_ATTACHMENT (p_request_id NUMBER, p_display_name VARCHAR2, p_mtype VARCHAR2 DEFAULT PDF_MIME_TYPE) IS
   BEGIN
      IF ( p_request_id IS NOT NULL AND p_display_name IS NOT NULL ) THEN 
         f_files_rec.request_id := p_request_id;
         f_files_rec.file_name := 'NA';
         f_files_rec.mime_type := p_mtype;
         f_files_rec.display_name := p_display_name;
         
         tbl_files(tbl_rownum) := f_files_rec;
         tbl_rownum := tbl_rownum + 1;
      END IF;
   END set_attachment;
   -- ------------------------------------------------------------------------------

   --
   -- SET_ATTACHMENT  -  Overloaded
   -- PARAMETERS: p_filename - Name of the uploaded file to attached to the email.
   --             p_display_name - This is the name the file will be given when it is 
   --                               attached to the email.
   --             p_mtype - The MIME type of the attached file - defaults to TEXT.
   -- This procedure will allow you to attach the output file from a Concurrent Request
   -- to an email message using the REQUEST_ID of the concurrent request. You can set 
   -- more than one request_id through multiple calls to this procedure.
   -- ------------------------------------------------------------------------------   
   PROCEDURE SET_ATTACHMENT (p_filename VARCHAR2, p_display_name VARCHAR2, p_mtype VARCHAR2 DEFAULT TEXT_MIME_TYPE) IS
   BEGIN
      IF ( p_filename IS NOT NULL AND p_display_name IS NOT NULL ) THEN 
         f_files_rec.request_id := 'NA';
         f_files_rec.file_name := p_filename;
         f_files_rec.mime_type := p_mtype;
         f_files_rec.display_name := p_display_name;
         
         tbl_files(tbl_rownum) := f_files_rec;
         tbl_rownum := tbl_rownum + 1;
      END IF;
   END set_attachment;
   -- ------------------------------------------------------------------------------
   
   -- 
   -- SEND  - Returns TRUE if send is successful or FALSE if an Error Occurs
   -- - Ensure all parameters have been set before calling this function.
   --------------------------------------------------------------------------------
   PROCEDURE send ( p_send_outside VARCHAR2 DEFAULT 'YES' ) AS
      conn              UTL_SMTP.CONNECTION;
      crlf              VARCHAR2(2) := chr(13)||chr(10);
      fil               BFILE;
      file_len          PLS_INTEGER;
      modulo            PLS_INTEGER;
      amt               BINARY_INTEGER := 673 * 3; /* Ensures proper format; 2016 */
      filepos           PLS_INTEGER := 1; /* Pointer for the file.  Must be reset to 1 for multiple files. */
      pieces            PLS_INTEGER;
      data              RAW(2100);
      buf               RAW(2100);
      chunks            PLS_INTEGER;
      len               PLS_INTEGER := 1;
      --b_request         BOOLEAN;
      --v_file_handle     UTL_FILE.FILE_TYPE;
      --v_directory_name  VARCHAR2(100) := 'BFILE_DIR';
      nDummy            NUMBER;
      
      vOutputType       VARCHAR2(25);
      vDirName          VARCHAR2(250);
      vFileName         VARCHAR2(50);
      vOutNodeName      VARCHAR2(25);
      vOfileSize        VARCHAR2(10);
      vStatCode         CHAR(2);
      vDummy            VARCHAR2(150);
      vTmpRecipients    VARCHAR2(2000);
      vNewRecipients    VARCHAR2(2000);
      vTmpBCC           VARCHAR2(2000);
      vNewBCC           VARCHAR2(2000);
      bDummy            BOOLEAN;

      -- Collection to store parsed Email addresses.
      TYPE eAddr_var IS VARRAY(1000) OF VARCHAR2(1000);
      rData  eAddr_var := eAddr_var();

   -- Cursor to fetch file information from the APPS table.
   --CURSOR get_request_info (pRequestID NUMBER) IS
   --   select nvl(output_file_type, 'TEXT') AS OUTPUT_TYPE
   --         ,substr(outfile_name,1,instr(outfile_name,'o'||pRequestID)-1) AS dir_name
   --         ,substr(outfile_name,instr(outfile_name,'o'||pRequestID),length(outfile_name)) AS file_name
   --         ,outfile_node_name 
   --         ,ofile_size
   --         ,status_code
   --     from apps.fnd_concurrent_requests
   --    where request_id = pRequestID;

      CURSOR get_db_name IS
         SELECT name
           FROM v$database;
      
      vDBName  VARCHAR2(25);
   
   BEGIN

      -- Check for the minumum requirements to send an email.
      -- These are self-imposed limitations.
      -- 1) Must have a Recipient
      -- 2) Must have a Subject
      -- 3) Must have a Message
      -- ----------------------------------------------------
      
      -- Test Recipient
      nDummy := rTO.COUNT;
      IF ( nDummy = 0 ) THEN 
         RAISE invalid_recipient;
      END IF;
      
      -- Test Subject
      IF ( p_subject IS NULL ) THEN 
         RAISE invalid_subject;
      END IF;
      
      -- Test Message
      IF ( p_message IS NULL ) THEN 
         RAISE invalid_message;
      END IF;

      OPEN get_db_name;
      FETCH get_db_name INTO vDBName;
      CLOSE get_db_name;

      -- This allows you to compile the package in a TEST or PROD environment and 
      -- the Package will tag the Subject Line to indicate the email is coming from a 
      -- TEST or DEV system without having to modify the package.  It ASSUMES you have 
      -- access to the V$DATABASE dba view.  
      -- This section can be commented out or removed if you don't want to use this 
      -- functionality.
      -- --------------------------------------------------------------------------------------------

      -- REQUIRED:
      -- Change the Check here to your Production Datbase Name.
      IF ( vDBName != 'PROD' ) THEN 
      -- END REQUIRED:
      
         vDummy := NULL;
         vDummy := p_subject;
         p_subject := '**'||vDBName||'** '||vDummy;
         vDummy := NULL;
      END IF;
      
      -- Loop list of recipients 
      FOR i IN rTO.FIRST .. rTO.LAST LOOP 
         bDummy := OUTSIDE_ADDRESS_F(rTO(i));
         
         -- Test p_send_outside parameter.
         IF ( p_send_outside = 'YES' ) THEN 
            --7 Parse vArray and reassign to p_recipients variable.
            IF ( i = 1 OR p_recipients IS NULL ) THEN 
               p_recipients := START_CHAR||rTO(i)||END_CHAR;
            ELSE
               p_recipients := p_recipients||','||START_CHAR||rTO(i)||END_CHAR;
            END IF;
         ELSIF ( NOT bDummy ) THEN 
            IF ( i = 1 OR p_recipients IS NULL ) THEN 
               p_recipients := START_CHAR||rTO(i)||END_CHAR;
            ELSE
               p_recipients := p_recipients||','||START_CHAR||rTO(i)||END_CHAR;
            END IF;
         END IF;

      END LOOP;

      nDummy := rCC.COUNT;
      
      IF ( nDummy > 0 ) THEN 
         -- Loop through Carbon Copy Recipients.
         FOR i IN rCC.FIRST .. rCC.LAST LOOP
            vDummy := rCC(i);
            bDummy := outside_address_f(rCC(i));

            -- Test p_send_outside parameter.
            IF ( p_send_outside = 'YES' ) THEN 
               --7 Parse vArray and reassign to p_recipients variable.
               IF ( i = 1 OR p_cc IS NULL ) THEN 
                  p_cc := START_CHAR||rCC(i)||END_CHAR;
               ELSE
                  p_cc := p_cc||','||START_CHAR||rCC(i)||END_CHAR;
               END IF;
            ELSIF ( NOT bDummy ) THEN 
               IF ( i = 1 OR p_cc IS NULL ) THEN 
                  p_cc := START_CHAR||rCC(i)||END_CHAR;
               ELSE
                  p_cc := p_cc||','||START_CHAR||rCC(i)||END_CHAR;
               END IF;
            END IF;

         END LOOP;
      END IF;
      
      nDummy := 0;
      nDummy := rBcc.COUNT;
      
      IF ( nDummy > 0 ) THEN 
         -- Loop through Blind Carbon Copy recipients
         FOR i IN rBcc.FIRST .. rBcc.LAST LOOP
            vDummy := rBcc(i);
            bDummy := outside_address_f(rBcc(i));

            -- Test p_send_outside parameter.
            IF ( p_send_outside = 'YES' ) THEN 
               --7 Parse vArray and reassign to p_recipients variable.
               IF ( i = 1 OR p_bcc IS NULL ) THEN 
                  p_bcc := START_CHAR||rBcc(i)||END_CHAR;
               ELSE
                  p_bcc := p_bcc||','||START_CHAR||rBcc(i)||END_CHAR;
               END IF;
            ELSIF ( NOT bDummy ) THEN 
               IF ( i = 1 OR p_bcc IS NULL ) THEN 
                  p_bcc := START_CHAR||rBcc(i)||END_CHAR;
               ELSE
                  p_bcc := p_Bcc||','||START_CHAR||rBcc(i)||END_CHAR;
               END IF;
            END IF;

         END LOOP;
      END IF;

      -- 
      -- Open the Email Message
      conn := begin_mail ( sender => p_sender,
                           recipients => p_recipients,
                           carbon_copy => p_cc,
                           blind_cc => p_bcc,
                           subject => p_subject,
                           mime_type => MULTIPART_MIME_TYPE);

      -- 
      -- Compose the message body
      attach_text ( conn => conn, 
                    data => p_message||crlf||crlf,
                    mime_type => p_msg_mimetype);

      --
      -- Add file attachement(s)
      IF ( NVL(tbl_files.COUNT,0) > 0 ) THEN 

         -- Process the File Attachement Request ID's
         FOR i IN tbl_files.first .. tbl_files.last LOOP

            begin_attachment( conn => conn,
                              mime_type => tbl_files(i).mime_type,
                              inline => TRUE,
                              filename =>  tbl_files(i).display_name,
                              transfer_enc => 'base64');

            -- This section allows you to use this EMAIL_PKG with Oracle Enterprise Business Suite
            -- to send the resultant file from a Concurrent Request as a file attachement.
            -- --------------------------------------------------------------------------------------
            --IF ( tbl_files(i).request_id != 'NA' ) THEN 
            --   -- Get the Request Information from the tables....
            --   OPEN get_request_info(tbl_files(i).request_id);
            --   FETCH get_request_info INTO vOutputType, vDirName, vFileName, vOutNodeName, vOfileSize, vStatCode;
            --   CLOSE get_request_info;            

            --   fil := BFILENAME('REPORTS_DIR', vFileName);
            -- File attachement is an UPLOADED file.
            --ELSIF ( tbl_files(i).file_name != 'NA' ) THEN 
				IF ( tbl_files(i).file_name != 'NA' ) THEN 
               fil := BFILENAME('UPLOAD_DIR',tbl_files(i).file_name);           
            END IF;
            
            file_len := dbms_lob.getlength(fil);
            modulo := mod(file_len, amt);
            pieces := trunc(file_len / amt);

            IF ( modulo <> 0 ) THEN 
               pieces := pieces + 1;
            END IF;

            dbms_lob.fileopen(fil,dbms_lob.file_readonly);
            dbms_lob.read(fil, amt, filepos, buf);

            -- Ensure the variable is empty before adding to it.
            data := null;

            FOR i IN 1..pieces LOOP
               filepos := i * amt + 1;
               file_len := file_len - amt;
               data := utl_raw.concat(data, buf);
               chunks := trunc(utl_raw.length(data) / MAX_LINE_WIDTH );

               IF ( i <> pieces ) THEN 
                  chunks := chunks -1;
               END IF;
               write_raw ( conn => conn,
                           message => utl_encode.base64_encode(data) );
               data := null;

               IF ( file_len < amt AND file_len > 0 ) THEN 
                  amt := file_len;
               END IF;
               dbms_lob.read(fil, amt, filepos, buf);
            END LOOP;
            
            -- Close the file
            dbms_lob.fileclose(fil);
            -- End the file attachment.
            end_attachment(conn => conn);

            -- Reset the file read variables
            fil := null;
            file_len := null;
            modulo  := null;
            pieces := null;
            data := null;
            filepos := 1;
            chunks := null;

         END LOOP;
         -- Reset the Table holding the file information.
         tbl_files := null_files_tbl;
         
      END IF;

      -- close and send the email
      end_mail(conn => conn);
      
      -- Reset the user variables so multiple emails are not sent.
      rTo.delete;
      rCC.delete;
      rBcc.delete;
      
      p_recipients := NULL;
      p_cc := NULL;
      p_bcc := NULL;
      p_subject := NULL;
      p_message := NULL;
      p_msg_mimetype := NULL;
     
   EXCEPTION
    WHEN utl_smtp.transient_error OR utl_smtp.permanent_error THEN
        end_session(conn);
        raise_application_error(-20000,'Failed to send mail due to the following error: ' || sqlerrm);
        dbms_output.put_line('Failed to send mail due to the following error: ' || sqlerrm);
      WHEN invalid_mime_type THEN 
         vErrMsg := sqlerrm;
         nErrNum := sqlcode;
         RAISE_APPLICATION_ERROR(-20201, 'The message body can be of MIME TYPE: Text or HTML only.');
      WHEN invalid_recipient THEN 
         vErrMsg := sqlerrm;
         nErrNum := sqlcode;
         RAISE_APPLICATION_ERROR(-20202, 'The email RECIPIENT cannot be NULL. Please specify a recipient.'); 
      WHEN invalid_message THEN
         vErrMsg := sqlerrm;
         nErrNum := sqlcode;
         RAISE_APPLICATION_ERROR(-20203, 'The email MESSAGE BODY cannot be NULL.  Please specify a message.');
      WHEN invalid_subject THEN
         vErrMsg := sqlerrm;
         nErrNum := sqlcode;
         RAISE_APPLICATION_ERROR(-20204, 'The email SUBJECT cannot be NULL. Please specify and subject.');         
      WHEN OTHERS THEN 
         vErrMsg := sqlerrm;
         nErrNum := sqlcode;
         end_attachment( conn => conn );
         dbms_lob.fileclose(fil);
         RAISE_APPLICATION_ERROR(-20204, 'The following error occured sending email: '||sqlerrm);         
   END SEND;
   
   -- 
   -- set_message
   -- PARAMETER:  p_mtype (Default = TEXT) , p_msg
   -- ** P_MTYPE: This parameter sets the MIME TYPE of the message body.  If HTML, 
   -- ensure the value of P_MSG is appropriated coded with the HTML tags you want 
   -- displayed in your message.  Use the Package Constants (TEXT_MIME_TYPE or HTML_MIME_TYPE)
   -- ** P_MSG: This parameter is the BODY of your email message.  Ensure you have 
   -- formatted your message according to the MIME TYPE specified in P_MTYPE.
   -- ------------------------------------------------------------------------------
   PROCEDURE set_message_body ( p_msg VARCHAR2, p_mime_type VARCHAR2 DEFAULT 'TEXT') AS
   BEGIN
      IF ( UPPER(p_mime_type) = 'TEXT' ) THEN 
         p_msg_mimetype := TEXT_MIME_TYPE;
      ELSIF ( UPPER(p_mime_type) = 'HTML' ) THEN 
         p_msg_mimetype := HTML_MIME_TYPE;
      ELSIF ( UPPER(p_mime_type) = 'PDF' ) THEN 
         p_msg_mimetype := PDF_MIME_TYPE;
      ELSIF ( UPPER(p_mime_type) = 'XLS' ) THEN 
         p_msg_mimetype := XLS_MIME_TYPE;
      END IF;
      
      IF ( p_msg IS NOT NULL ) THEN 
         p_message := p_msg;
      END IF;
   END set_message_body;
   -- ------------------------------------------------------------------------------

-- END OF Public Program Units
-- ---------------------------

END EMAIL_PKG;
-- End of Package Body
/
show errors;
