--
--DOC 559956.1
--
-- RCV_HEADERS_INTERFACE            This is the header table
-- RCV_TRANSACTIONS_INTERFACE       This is the transaction lines table 
-- MTL_TRANSACTION_LOTS_INTERFACE   If you utilize LOT numbers
-- MTL_SERIAL_NUMBERS_INTERFACE     If you utilize Serial numbers
-- Receiving Transaction Processor  RVCTP Concurrent request.
--
DECLARE

P_FECHA_RECEPCION   date := to_date ('01-07-2022', 'dd-mm-yyy');
P_NUMERO_FACTURA    varchar2(50) := 'gvp-001';

v_group_id      number(15);
v_header_int_id number(15);
v_trans_int_id  number(15);
BEGIN

    v_group_id      := rcv_interface_groups_s.nextval;
    v_header_int_id := rcv_headers_interface_s.nextval;
    v_trans_int_id  := rcv_transactions_interface_S.nextval;

    --validation_flag = 'Y'

    INSERT INTO RCV_HEADERS_INTERFACE (
             header_interface_id
            , group_id
            , processing_status_code
            , receipt_source_code
            , transaction_type
            --, auto_transact_code
            , last_update_date
            , last_updated_by
            , creation_date
            , created_by
            , validation_flag
            , expected_receipt_date
            , vendor_id
            , vendor_site_id
            , bill_of_lading
            , ship_to_organization_id
            --, employee_id
            , comments
        ) 
        VALUES (
                  v_header_int_id       		    --HEADER_INTERFACE_ID
                , v_group_id                		--GROUP_ID
                , 'PENDING'                 		--PROCESSING_STATUS_CODE
                , 'VENDOR'                  		--RECEIPT_SOURCE_CODE
                , 'NEW'                     		--TRANSACTION_TYPE
                --, G_DELIVER --'DELIVER'							--AUTO_TRANSACT_CODE
                , SYSDATE                   		--LAST_UPDATE_DATE
                , 1        		                    --LAST_UPDATE_BY
                , SYSDATE                   		--CREATION_DATE
                , 1        		                    --CREATED_BY
                , 'Y'                               --VALIDATION_FLAG
                , P_FECHA_RECEPCION	                --EXPECTED_RECEIPT_DATE
                , l_vendor_id               		--VENDOR_ID
                , l_vendor_site_id          		--VENDOR_SITE_ID
                , P_NUMERO_FACTURA     		        --BILL_OF_LADING
                , l_organization_id         		--SHIP_TO_ORGANIZATION_ID
                --, l_employee_id             		--EMPLOYEE_ID
                , 'Recivido desde 3PL'		        --COMMENTS
            );


END;
/