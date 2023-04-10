SET SERVEROUTPUT ON 
declare

v_check_id          number(15) := 1573392;
v_void_date         date  := to_date('2020-06-30', 'YYYY-MM-DD');

v_org_id            number(15);
v_num_cancelled		number;
v_num_not_cancelled	number;
v_return_status		varchar2(1);
v_msg_count			number(15);
v_msg_data			varchar2(500);
BEGIN

    FND_GLOBAL.apps_initialize(
                             1123 -- CONE-LGOMEZ
                           , 50833 --GRP_ALL_AP_CONE_GTE
                           , 200
                        ); --AP
    MO_GLOBAL.init('SQLAP'); 
    
    --mo_global.set_org_context ( 204, NULL, 'SQLAP' ) ; 
    
    SELECT org_id
    INTO v_org_id
    FROM AP_CHECKS_ALL
    WHERE check_id = v_check_id
    ;

    MO_GLOBAL.set_policy_context('S', v_org_id);

	--
	-- Este api es el que usa la Pantalla para revertir el pago
	--
	AP_VOID_PKG.Ap_Reverse_Check(                    
                P_Check_Id                 => v_check_id,
                P_Replace_Flag             => 'Y',
			    P_Reversal_Date            => v_void_date,
			    P_Reversal_Period_Name     => 'JUN-20',
			    P_Checkrun_Name            => 'Pago Rápido: 1571377' ,
			    P_Invoice_Action           => 'NONE',
			    P_Hold_Code                => '',  
			    P_Hold_Reason              => '',  
                P_Vendor_Auto_Calc_Int_Flag=> NULL,                
                P_Sys_Auto_Calc_Int_Flag   => 'N', 
			    p_last_updated_by          => FND_PROFILE.VALUE('USER_ID'),
                p_last_update_login        => FND_PROFILE.VALUE('LOGIN_ID'),
                P_Calling_Module           => 'SQLAP',
			    P_Calling_Sequence         => 'GRP_AP_APP_PAGO_QRY',
			    P_Num_Cancelled            => v_num_cancelled,
                P_Num_Not_Cancelled        => v_num_not_cancelled,
                X_return_status            => v_return_status,
                X_msg_count                => v_msg_count,
                X_msg_data                 => v_msg_data                    
				); 

    DBMS_OUTPUT.put_line ('Estatus = '|| v_return_status);

	IF v_return_status = 'S' THEN
        EXECUTE IMMEDIATE 'UPDATE AP_CHECKS_ALL SET status_lookup_code = ''VOIDED'', void_date = :v_void_date WHERE check_id = :v_check_id'
        USING v_void_date, v_check_id
        ;
        
        SELECT CHECK_NUMBER ||' '|| STATUS_LOOKUP_CODE ||' ' || TO_CHAR( VOID_DATE, 'YYYY-MM-DD')
        into v_msg_data
        FROM AP_CHECKS_ALL
        WHERE CHECK_ID = v_check_id
        ;

    DBMS_OUTPUT.put_line ('Cheque = '|| v_msg_data);        
    else
		IF v_msg_count = 1 THEN
            DBMS_OUTPUT.put_line ('Error: '||v_msg_data);
        ELSE
            DBMS_OUTPUT.put_line ('Errores: '||v_msg_data);
        END IF;                
	END IF;

END;
/

