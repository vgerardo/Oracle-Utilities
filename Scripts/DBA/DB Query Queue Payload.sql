SELECT
    sys.xmltype.createxml( tq.user_data ),
    enq_time
FROM xxcmx.xxcmx_wsh_ccp_send_qt tq
WHERE
    extractvalue(
            sys.xmltype.createxml(
                  tq.user_data
             ), '/XXCMX_WSH_CCP_SEND_PAYLOAD/CCP_XML/Comprobante/DocumentId'
    ) = '325'
    ;
    
    select *
    from xxcmx.xxcmx_wsh_ccp_send_qt
    ;