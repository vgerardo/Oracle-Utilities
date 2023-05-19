SET SERVEROUTPUT ON
DECLARE
v_payload XXCMXB.xxcmx_wsh_ccp_send_payload ;
BEGIN

    --v_payload.llave       varchar2(50),
    --v_payload.tipo_cfdi   varchar2(1),
    --v_payload.ccp_xml     xmltype

    FOR x IN (SELECT user_data , msgid
              FROM xxcmx.XXCMX_WSH_CCP_SEND_QT
              WHERE enq_time > sysdate-15
              ) LOOP
        --DBMS_OUTPUT.put_line ('Llave: '|| x.user_data.llave || ' Tipo:'||x.user_data.tipo_cfdi);
        IF x.user_data.llave = 351 THEN
            DBMS_OUTPUT.put_line (x.msgid);
        END IF;
    END LOOP;

END;
/


SELECT user_data, sys_xmlgen (user_data)
FROM xxcmx.XXCMX_WSH_CCP_SEND_QT
WHERE msgid = 'D550AA79CAF461CAE05490E2BA54380C'
;
