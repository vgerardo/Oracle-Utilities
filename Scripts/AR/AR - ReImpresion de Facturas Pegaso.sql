
        SELECT    ']CFD'
               || ']]]]]^]Emisor]'               
               || h.rfc --rfc_emisor
               || ']^]Transaccion]'
               || (f.name || '_' || trx_number)  -- id transaccion
               || ']REENVIO]^]Receptor]'               
               || b.tax_reference --rfc_receptor               
               || ']'
               || 
                NVL (
                     a.attribute5,
                     (SELECT mail_stop              ----para jalar los correos
                      FROM hz_org_contacts x
                      WHERE party_relationship_id =
                                        (SELECT MAX (relationship_id)
                                           FROM hz_relationships y
                                          WHERE subject_id = b.party_id
                                            AND subject_type = 'ORGANIZATION'))) -- email receptor               
               || ']]]*]'               
               facturas_reimpresion_pegaso       
          FROM 
               ra_customer_trx_all              a,
               ra_customers                     b,
               ra_cust_trx_types_all            f,               
               BOLINF.CSA_AR_EMISORES_FACTURAS  h --tabla customizada de emisores
         WHERE     b.customer_id = a.bill_to_customer_id              
               AND DECODE (h.TIPO_TRANSACCION, 'NAPTPZ', 'NAPTPZ1', h.TIPO_TRANSACCION) = SUBSTR (f.name, 1, INSTR (f.name, '_') - 1)
               AND f.cust_trx_type_id = a.cust_trx_type_id
               AND a.printing_option = 'PRI'               
               AND (f.TYPE = 'CM' OR f.TYPE = 'INV')               
               AND b.customer_id = b.customer_id
               AND a.status_trx = 'OP'
               AND a.complete_flag = 'Y' -- solo facturas finalizadas
               AND a.trx_date between to_date ('2013-12-16', 'yyyy-mm-dd') 
                                  and to_date ('2013-12-19 23:59:59', 'yyyy-mm-dd hh24:mi:ss')               

