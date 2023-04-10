
SELECT * FROM ap.AP_INVOICES_INTERFACE
WHERE GROUP_ID = 'GVP_GRUPO'
;

DELETE Ap.AP_INVOICES_INTERFACE WHERE GROUP_ID = 'GVP_GRUPO';

INSERT INTO ap.AP_INVOICES_INTERFACE (
                invoice_id
                ,invoice_num
                ,invoice_type_lookup_code
                ,invoice_date
                ,invoice_amount
                ,invoice_currency_code
                ,exchange_rate
                ,exchange_rate_type
                ,exchange_date
                ,description
                ,attribute_category
                ,attribute1
                ,po_number                
                ,source
                ,group_id
        )
VALUES (
                 90000001               --invoice_id
                ,'GVP002'               --invoice_num
                ,'STANDARD'             --invoice_type_lookup_code
                ,SYSDATE                --invoice_date
                ,100                    --invoice_amount
                ,'CRC'                  --invoice_currency_code
                ,null                   --exchange_rate
                ,null                   --exchange_rate_type
                ,null                   --exchange_date
                ,'Prueba GVP 001'       --description
                ,'LAN_AP_CABECERA_FACTURA' --attribute_category
                ,'123'                  --attribute1
                ,2802                   --po_number
                ,'FACTXML'              --source
                ,'GVP_GRUPO'            --group_id
    )
;

INSERT INTO ap.ap_invoice_lines_interface (
                invoice_id
                ,line_number
                ,line_type_lookup_code
                ,amount
                ,accounting_date
                ,po_line_number
                ,po_number
                --,receipt_line_number
                --,receipt_number
                --,po_shipment_num
                --,rcv_transaction_id
                ,awt_group_name
                --,org_id
) VALUES (
            90000001
            ,1
            ,'ITEM'
            ,100
            ,SYSDATE    --accounting_date
            ,1          --po_line_number
            ,'2802'     --po_number
            ,null
    );