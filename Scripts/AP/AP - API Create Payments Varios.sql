--
-- Creating a Paymanet for several Invoices
--
SET SERVEROUTPUT ON

DECLARE

v_row_id                    VARCHAR2(100);
v_external_bank_account_id  NUMBER(15);
v_bank_account_number       varchar2(100);
v_factura_reg               AP.ap_invoices_all%rowtype;
v_check_id                  NUMBER(15);
v_importe_total             NUMBER(15,4) := 0;
v_accounting_event_id       NUMBER(15);
v_token                     NUMBER(15);
v_invoice_num               VARCHAR2(50);
v_invoice_id_list           VARCHAR2(500):= '';

v_invoice_num_list          VARCHAR2(500):= 'FICUCG28203736,'; --siempre debe terminar con coma ','
v_bank_account_name         VARCHAR2(50) := 'CADENAS_GPO MXN'; --'GPO_OPER_966370'; 
v_check_date                DATE         := TO_DATE('2018-05-23 09:00:01', 'YYYY-MM-DD HH24:MI:SS');
v_sucursal                  VARCHAR2(50) := 'FICUCG';
v_check_number              VARCHAR2(100):= ''; -- Cuando es CHEQUE MANUAL, se debe poner un Dato.

v_return_status             VARCHAR2(100);
v_msg_count                 NUMBER(15);
v_msg_data                  VARCHAR2(500);
v_errorIDs                  IBY_DISBURSE_SINGLE_PMT_PKG.trxnErrorIdsTab;
v_dummy                     VARCHAR2(1000);

v_internal_bank_account_id  NUMBER(15);
v_bank_acct_use_id          number(15);
v_payment_document_id       NUMBER(15);
v_payment_profile_id        NUMBER(15);
v_payment_format_code       varchar2(50);
v_exchange_rate_type        VARCHAR2(10) := NULL;
v_exchange_rate             NUMBER(15,4) := NULL;
v_exchange_date             DATE := NULL;

CURSOR c_vendor_info ( p_org_id NUMBER, 
                       p_party_id NUMBER, 
                       p_vendor_site_id NUMBER, 
                       p_supplier_id NUMBER,
                       p_check_date date
                       )
IS
SELECT 
    asup.vendor_name,
    iep.payee_party_id,
    site.vendor_site_code,
    site.vendor_site_id,
    hzl.address1 address_line1,
    hzl.address2 address_line2,
    hzl.address3 address_line3,
    hzl.address4 address_line4,
    nvl(B.address_style, 'DEFAULT') address_style,
    hzl.city,
    hzl.county,
    hzl.state,
    hzl.province,
    hzl.postal_code zip,
    hzl.country,
    FT.territory_short_name,
    DECODE(SIGN(TO_DATE(TO_CHAR(site.INACTIVE_DATE,'YYYY/MM/DD'),'YYYY/MM/DD') -
    TO_DATE(TO_CHAR(SYSDATE,'YYYY/MM/DD'),'YYYY/MM/DD')),-1,'',0,'','*') active,
    site.always_take_disc_flag,
    site.hold_all_payments_flag,
    site.org_id,
    mo_global.get_ou_name(site.org_id) operating_unit,
    site.party_site_id,
    iep.payment_function,
    iep.bank_charge_bearer,
    iep.settlement_priority,
    asp.set_of_books_id   
FROM  ap_suppliers          asup,
      ap_supplier_sites_ALL site,
      hz_locations          hzl ,
      fnd_territories_tl    ft,
     FND_TERRITORIES        B,
      iby_external_payees_all iep,
      ap_system_parameters_all asp
WHERE 1=1  
  and asup.vendor_id = site.vendor_id
  and asp.org_id = site.org_id
  AND site.pay_site_flag = 'Y'  
  AND site.location_id = hzl.location_id
  AND site.party_site_id = iep.party_site_id
  AND site.vendor_site_id = iep.supplier_site_id (+)
  AND site.org_id = iep.org_id
  AND hzl.country = FT.territory_code (+)
  AND B.TERRITORY_CODE = FT.TERRITORY_CODE 
  AND FT.LANGUAGE = USERENV('LANG')
  AND B.TERRITORY_CODE = hzl.country  
  AND iep.payee_party_id = asup.party_id  
  ------------------------------------
  and asup.party_id = p_party_id
  AND asup.vendor_id = p_supplier_id  
  AND site.org_id = p_org_id
  AND site.vendor_site_id = p_vendor_site_id
  ------------------------------------
  ;


v_vendor_info c_vendor_info%rowtype;
v_ready varchar2(100);
v_restante number(15,4);

BEGIN

    v_token := 1;
    
    LOOP    
    
        v_check_number := '';
    
        -- Recore la lista de valores delimitados por "comas"
        v_invoice_num := regexp_substr (v_invoice_num_list, '[^,]+',1, v_token);
        v_token := v_token + 1;
        
        EXIT WHEN v_invoice_num is null;
        
        dbms_output.put_line ('invoice_num= ' || v_invoice_num);
        
        -- busca datos de la Factura
        BEGIN
        SELECT api.*            
        INTO v_factura_reg 
        FROM ap_invoices_all        api,
             ap_supplier_sites_all  site
             --ap_invoices_ready_to_pay_v
        WHERE 1=1
          AND api.vendor_id = site.vendor_id
          and api.vendor_site_id = site.vendor_site_id
          AND api.payment_status_flag in ('N', 'P')  -- (N)No pagada (P)Pago Parcial
          AND NOT EXISTS (
                        -- la factura no debe estar seleccionada para Pago
                        -- por ningún otro proceso.
                        SELECT 1
                        FROM ap_selected_invoices_all
                        WHERE invoice_id = api.invoice_id
                       )
          --AND org_id = 241
          --AND invoice_id  = 1694354                       
          and api.invoice_num LIKE v_invoice_num 
        ;
        
        -- 
        -- Falta realizar vadaciones para ver que las Facturas cumplan con:
        -- 1. Mismo proveedor
        -- 2. Misma Moneda
        -- 3. Misma Unidad Operativa (organización)
        -- 4. Etc
        --
        -- Aquí podrían ir dichas validaciones.
        --
        
        v_invoice_id_list := v_invoice_id_list ||' '|| v_factura_reg.invoice_id;        
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                dbms_output.put_line ('La factura NO exite o YA fue Pagada');
        END;        

    END LOOP;

    IF v_invoice_id_list IS NULL THEN
        dbms_output.put_line ('NO hay facturas que procesar');
        return;
    end if;

    dbms_output.put_line ('v_invoice_list_id= '||v_invoice_id_list ||
                          ' v_org_id= ' || v_factura_reg.org_id || 
                          ' v_payment_method_code= ' || v_factura_reg.payment_method_code ||
                          ' party_id = ' || v_factura_reg.party_id||
                          ' vendor_id = ' || v_factura_reg.vendor_id||
                          ' vendor_site_id = ' || v_factura_reg.vendor_site_id
                          );

    -- ------------------------------------------------------
    -- Inicializa Entorno
    FND_GLOBAL.apps_initialize ( 
                             user_id      => 1123   -- CONE-LGOMEZ
                            ,resp_id      => 50833  -- GRP_ALL_AP_CONE_GTE
                            ,resp_appl_id => 200    -- SQLAP
                           );        
    MO_GLOBAL.init('SQLAP'); -- product short name: AR, SQLAP                           
    MO_GLOBAL.set_policy_context('S', v_factura_reg.org_id); 
    CEP_STANDARD.init_security; --The table CE_SECURITY_PROFILES_GT is populated through this call 
    -- ------------------------------------------------------
    
    
    -- Valida que las Facturas se pueda Pagar
    FOR c_id IN (
                select trim(regexp_substr(v_invoice_id_list,'[^ ]+', 1, level) ) id
                from dual
                connect by regexp_substr(v_invoice_id_list, '[^ ]+', 1, level) is not null                
                )
    LOOP           
        BEGIN
        SELECT invoice_num, amount_remaining
        INTO v_ready, v_restante
        from AP_INVOICES_READY_TO_PAY_V
         WHERE invoice_id = c_id.id
        ; 
        v_importe_total   := v_importe_total + v_restante;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_ready := 'NO_READY';
                exit;
        END;
    END LOOP;    
    
    IF v_ready = 'NO_READY' then
        dbms_output.put_line ('La factura no se puede pagar');
        return;    
    end if;
    --
    -- Para habilitar el LOG del API, los resultados se guardan en FND_LOG_MESSAGES
    --
    --fnd_profile.put('AFLOG_ENABLED', 'Y');
    --fnd_profile.put('AFLOG_MODULE', '%');
    --fnd_profile.put('AFLOG_LEVEL','1'); -- Level 1 is Statement Level
    --fnd_log_repository.init;
    --DBMS_OUTPUT.put_line ('G_CURRENT_RUNTIME_LEVEL = ' || FND_LOG.G_CURRENT_RUNTIME_LEVEL);
    --DBMS_OUTPUT.put_line ('LEVEL_STATEMENT         = ' || FND_LOG.LEVEL_STATEMENT);

    IF v_factura_reg.invoice_currency_code <> 'MXN' THEN
         v_exchange_rate_type  := 'Corporate';
         v_exchange_date       := TO_DATE('2017-10-13 00:00:01', 'YYYY-MM-DD HH24:MI:SS');
         --v_exchange_rate       := 17.5;         
--        ap_utilities_pkg.get_exchange_rate(
--                                    l_inv_rec.pmt_currency_code,
--                                    l_asp_rec.base_currency_code,
--                                    l_check_rec.xrate_type,
--                                    l_check_rec.xrate_date,
--                                    'APAYFULB');         
    END IF;

    -- Cuenta INTERNA
    --
    SELECT ba.bank_account_id, bau.bank_acct_use_id
    INTO v_internal_bank_account_id, v_bank_acct_use_id
    FROM ce_bank_accounts BA
         ,ce_bank_acct_uses_all BAU
    WHERE 1=1
      AND ba.bank_account_id = bau.bank_account_id
      AND nvl(ba.end_date,sysdate+1) > sysdate 
      AND bau.org_id           = v_factura_reg.org_id      
      and ba.bank_account_name = v_bank_account_name
    ;

    dbms_output.put_line ('v_internal_bank_account_id = ' || v_internal_bank_account_id);

    -- Cuenta EXTERNA
    --
    BEGIN
    SELECT b.ext_bank_account_id bank_account_id,  b.bank_account_number
    INTO   v_external_bank_account_id, v_bank_account_number
    FROM
        IBY_PMT_INSTR_USES_ALL  ibyu,
        IBY_EXT_BANK_ACCOUNTS_V b,
        IBY_EXTERNAL_PAYEES_ALL ibypayee
    WHERE  1=1
     AND ibyu.ext_pmt_party_id = ibypayee.ext_payee_id
     AND ibyu.instrument_id    = b.ext_bank_account_id
     AND ibyu.instrument_type  = 'BANKACCOUNT'
     AND nvl(ibyu.end_date, sysdate+1) >= sysdate
     and nvl(b.end_date, sysdate+1) >= sysdate     
     AND ibypayee.ORG_ID            = v_factura_reg.org_id
     AND ibypayee.PAYEE_PARTY_ID    = v_factura_reg.party_id
     AND ibypayee.SUPPLIER_SITE_ID  = v_factura_reg.vendor_site_id
     and b.currency_code            = v_factura_reg.invoice_currency_code
    ;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_external_bank_account_id := -1;
            dbms_output.put_line ('No se encontró "External Bank Account ID"');
    END;

    dbms_output.put_line ('v_external_bank_account_id = ' || v_external_bank_account_id);

    SELECT payment_profile_id, payment_format_code
    INTO v_payment_profile_id, v_payment_format_code
    FROM iby_payment_profiles 
    WHERE system_profile_name = decode(v_factura_reg.payment_method_code, 'CHECK', 'GRP_AP_CHEQUES', 'GRP_AP_ELECTRONICO')
    ;  

    dbms_output.put_line ('v_payment_profile_id = '|| v_payment_profile_id || '  payment_format_code= '||v_payment_format_code);

    SELECT payment_document_id
    into v_payment_document_id
    FROM ce_payment_documents 
    WHERE 1=1      
      --and replace(payment_document_name,'  ',' ') = DECODE(v_factura_reg.payment_method_code, 'CHECK', 'CHEQUE MANUAL', 'TRANSFERENCIA ELECTRONICA')
      AND internal_bank_account_id = v_internal_bank_account_id
      and format_code = v_payment_format_code
      ;
      
    dbms_output.put_line ('v_payment_document_id = ' || v_payment_document_id);


    OPEN c_vendor_info (
                       v_factura_reg.org_id, 
                       v_factura_reg.party_id, 
                       v_factura_reg.vendor_site_id, 
                       v_factura_reg.vendor_id,
                       TO_DATE('2017-09-06', 'yyyy-mm-dd')
        );
    FETCH c_vendor_info INTO v_vendor_info;
    close c_vendor_info;


    IF v_check_number IS NULL  THEN

        -- Obtiene el número del Cheque
        IBY_DISBURSE_UI_API_PUB_PKG.Validate_Paper_Doc_Number
            (p_api_version    => 1.0, 
             p_init_msg_list  => FND_API.G_TRUE, 
             p_payment_doc_id => v_payment_document_id, 
             x_paper_doc_num  => v_check_number, 
             x_return_status  => v_return_status,
             x_msg_count      => v_msg_count, 
             x_msg_data       => v_msg_data,
             show_warn_msgs_flag => 'T'
             ); 
        
    END IF;

        dbms_output.put_line ('v_check_number: ' || v_check_number);

        SELECT ap_checks_s.NEXTVAL
        into   v_check_id
        FROM   SYS.dual;        

        AP_CHECKS_PKG.Insert_Row (
            X_Rowid                     => v_row_id, 
            X_Amount                    => v_importe_total,    --:PAY_SUM_FOLDER.Amount,
            X_CE_Bank_Acct_Use_Id       => v_bank_acct_use_id, --:PAY_SUM_FOLDER.Bank_Account_Id,
            X_Bank_Account_Name         => v_bank_account_name,
            X_Check_Date                => v_check_date,
            X_Check_Id                  => v_check_id, 
            X_Check_Number              => v_check_number, 
            X_Currency_Code             => v_factura_reg.invoice_currency_code, --:PAY_SUM_FOLDER.Currency_Code,
            X_Last_Updated_By           => 0, 
            X_Last_Update_Date          => SYSDATE, 
            X_Payment_Type_Flag         => 'Q', --:PAY_SUM_FOLDER.Payment_Type_Flag,
            X_Address_Line1             => v_vendor_info.Address_Line1,
            X_Address_Line2             => v_vendor_info.Address_Line2,
            X_Address_Line3             => v_vendor_info.Address_Line3,
            X_Checkrun_Name             => 'Pago Rápido: ID='||v_check_id, --:PAY_SUM_FOLDER.Checkrun_Name,
            --X_Check_Format_Id           => :PAY_SUM_FOLDER.Check_Format_Id,
            --X_Check_Stock_Id            => :PAY_SUM_FOLDER.check_stock_Id,
            X_City                      => v_vendor_info.City,
            X_Country                   => v_vendor_info.Country,
            X_Created_By                => 0,
            X_Creation_Date             => sysdate,
            X_Last_Update_Login         => 0,
            X_Status_Lookup_Code        => 'NEGOTIABLE', --:PAY_SUM_FOLDER.Status_Lookup_Code,
            X_Vendor_Name               => v_vendor_info.vendor_name, 
            X_Vendor_Site_Code          => v_vendor_info.vendor_site_code, 
            X_External_Bank_Account_Id  => v_external_bank_account_id, 
            X_Zip                       => v_vendor_info.Zip,
            X_Bank_Account_Num          => v_bank_account_number, --PAY_SUM_FOLDER.Bank_Account_Num,
            --X_Bank_Account_Type         => :PAY_SUM_FOLDER.Bank_Account_Type,
            --X_Bank_Num                  => :PAY_SUM_FOLDER.Bank_Num,
            --X_Check_Voucher_Num         => :PAY_SUM_FOLDER.Check_Voucher_Num,
            --X_Cleared_Amount            => :PAY_SUM_FOLDER.Cleared_Amount,
            --X_Cleared_Date              => :PAY_SUM_FOLDER.Cleared_Date,
            --X_Doc_Category_Code         => :PAY_SUM_FOLDER.Doc_Category_Code,
            --X_Doc_Sequence_Id           => :PAY_SUM_FOLDER.Doc_Sequence_Id,
            --X_Doc_Sequence_Value        => :PAY_SUM_FOLDER.Doc_Sequence_Value,
            --X_Province                  => :PAY_SUM_FOLDER.Province,
            --X_Released_Date             => :PAY_SUM_FOLDER.Released_Date,
            --X_Released_By               => :PAY_SUM_FOLDER.Released_By,
            X_State                     => v_vendor_info.STATE,
            --X_Stopped_Date              => :PAY_SUM_FOLDER.Stopped_Date,
            --X_Stopped_By                => :PAY_SUM_FOLDER.Stopped_By,
            --X_Void_Date                 => :PAY_SUM_FOLDER.Void_Date,
            --X_Attribute1                => :PAY_SUM_FOLDER.Attribute1,
            --X_Attribute10               => :PAY_SUM_FOLDER.Attribute10,
            --X_Attribute11               => :PAY_SUM_FOLDER.Attribute11,
            --X_Attribute12               => :PAY_SUM_FOLDER.Attribute12,
            --X_Attribute13               => :PAY_SUM_FOLDER.Attribute13,
            --X_Attribute14               => :PAY_SUM_FOLDER.Attribute14,
            --X_Attribute15               => :PAY_SUM_FOLDER.Attribute15,
            --X_Attribute2                => :PAY_SUM_FOLDER.Attribute2,
            --X_Attribute3                => :PAY_SUM_FOLDER.Attribute3,
            --X_Attribute4                => :PAY_SUM_FOLDER.Attribute4,
            --X_Attribute5                => :PAY_SUM_FOLDER.Attribute5,
            --X_Attribute6                => :PAY_SUM_FOLDER.Attribute6,
            --X_Attribute7                => :PAY_SUM_FOLDER.Attribute7,
            --X_Attribute8                => :PAY_SUM_FOLDER.Attribute8,
            --X_Attribute9                => :PAY_SUM_FOLDER.Attribute9,
            --X_Attribute_Category        => :PAY_SUM_FOLDER.Attribute_Category,
            --X_Future_Pay_Due_Date       => :PAY_SUM_FOLDER.Future_Pay_Due_Date,
            --X_Treasury_Pay_Date         => :PAY_SUM_FOLDER.Treasury_Pay_Date,
            --X_Treasury_Pay_Number       => :PAY_SUM_FOLDER.Treasury_Pay_Number,
            --X_Withholding_Status_Lkup_Code=> :PAY_SUM_FOLDER.Withholding_Status_Lookup_Code,
            --X_Reconciliation_Batch_Id   => :PAY_SUM_FOLDER.Reconciliation_Batch_Id,
            --X_Cleared_Base_Amount       => :PAY_SUM_FOLDER.Cleared_Base_Amount,
            --X_Cleared_Exchange_Rate     => :PAY_SUM_FOLDER.Cleared_Exchange_Rate,
            --X_Cleared_Exchange_Date     => :PAY_SUM_FOLDER.Cleared_Exchange_Date,
            --X_Cleared_Exchange_Rate_Type=> :PAY_SUM_FOLDER.Cleared_Exchange_Rate_Type,
            X_Address_Line4             => v_vendor_info.Address_Line4,
            X_County                    => v_vendor_info.County,
            --X_Address_Style             => :PAY_SUM_FOLDER.Address_Style,
            X_Org_Id                    => v_factura_reg.org_id, 
            X_Vendor_Id                 => v_factura_reg.Vendor_Id, 
            X_Vendor_Site_Id            => v_factura_reg.Vendor_Site_Id, 
            X_Exchange_Rate             => v_factura_reg.exchange_rate, 
            X_Exchange_Date             => v_factura_reg.exchange_date, 
            X_Exchange_Rate_Type        => v_factura_reg.exchange_rate_type, 
            --X_Base_Amount               => :PAY_SUM_FOLDER.Base_Amount,
            --X_Checkrun_Id               => :PAY_SUM_FOLDER.Checkrun_Id,
            --X_Global_Attribute_Category   => :PAY_SUM_FOLDER.Global_Attribute_Category,
            --X_Global_Attribute1           => :PAY_SUM_FOLDER.Global_Attribute1,
            --X_Global_Attribute2           => :PAY_SUM_FOLDER.Global_Attribute2,
            --X_Global_Attribute3           => :PAY_SUM_FOLDER.Global_Attribute3,
            --X_Global_Attribute4           => :PAY_SUM_FOLDER.Global_Attribute4,
            --X_Global_Attribute5           => :PAY_SUM_FOLDER.Global_Attribute5,
            --X_Global_Attribute6           => :PAY_SUM_FOLDER.Global_Attribute6,
            --X_Global_Attribute7           => :PAY_SUM_FOLDER.Global_Attribute7,
            --X_Global_Attribute8           => :PAY_SUM_FOLDER.Global_Attribute8,
            --X_Global_Attribute9           => :PAY_SUM_FOLDER.Global_Attribute9,
            --X_Global_Attribute10          => :PAY_SUM_FOLDER.Global_Attribute10,
            --X_Global_Attribute11          => :PAY_SUM_FOLDER.Global_Attribute11,
            --X_Global_Attribute12          => :PAY_SUM_FOLDER.Global_Attribute12,
            --X_Global_Attribute13          => :PAY_SUM_FOLDER.Global_Attribute13,
            --X_Global_Attribute14          => :PAY_SUM_FOLDER.Global_Attribute14,
            --X_Global_Attribute15          => :PAY_SUM_FOLDER.Global_Attribute15,
            --X_Global_Attribute16          => :PAY_SUM_FOLDER.Global_Attribute16,
            --X_Global_Attribute17          => :PAY_SUM_FOLDER.Global_Attribute17,
            --X_Global_Attribute18          => :PAY_SUM_FOLDER.Global_Attribute18,
            --X_Global_Attribute19          => :PAY_SUM_FOLDER.Global_Attribute19,
            --X_Global_Attribute20          => :PAY_SUM_FOLDER.Global_Attribute20,
            --X_transfer_priority           => :PAY_SUM_FOLDER.transfer_priority,
            --X_maturity_exchange_rate_type => :PAY_SUM_FOLDER.maturity_exchange_rate_type,
            --X_maturity_exchange_date      => :PAY_SUM_FOLDER.maturity_exchange_date,
            --X_maturity_exchange_rate      => :PAY_SUM_FOLDER.maturity_exchange_rate,
            --X_description                 => :PAY_SUM_FOLDER.description,
            --X_anticipated_value_date      => :PAY_SUM_FOLDER.anticipated_value_date,
            --X_actual_value_date           => :PAY_SUM_FOLDER.actual_value_date,            
            x_payment_method_code         => v_factura_reg.payment_method_code, 
            x_payment_profile_id          => v_payment_profile_id, 
            --x_bank_charge_bearer          => :PAY_SUM_FOLDER.bank_charge_bearer,
            --x_settlement_priority         => :PAY_SUM_FOLDER.settlement_priority,
            x_payment_document_id         => v_payment_document_id, 
            x_party_id                    => v_factura_reg.party_id, 
            x_party_site_id               => v_factura_reg.party_site_id, 
            x_legal_entity_id             => v_factura_reg.legal_entity_id, 
            --x_payment_id                => ***:PAY_SUM_FOLDER.payment_id,            
            --x_remit_to_supplier_name	  => :PAY_SUM_FOLDER.remit_to_supplier_name,
            --x_remit_to_supplier_id	  => :PAY_SUM_FOLDER.remit_to_supplier_id,
            --x_remit_to_supplier_site	  => :PAY_SUM_FOLDER.remit_to_supplier_site,
            --x_remit_to_supplier_site_id => :PAY_SUM_FOLDER.remit_to_supplier_site_id,
            --x_relationship_id		      => :PAY_SUM_FOLDER.relationship_id,
            --x_paycard_authorization_number=> :PAY_SUM_FOLDER.p_paycard_auth_number,
            --x_paycard_reference_id        => :PAY_SUM_FOLDER.paycard_reference_id
            X_Calling_Sequence          => 'MY_API'            
        );
      

    dbms_output.put_line ('v_check_id = '|| v_check_id);
        
    --COMMIT;
        
    AP_RECONCILIATION_PKG.Insert_Payment_History (
           x_check_id                => v_check_id,
           x_transaction_type        => 'PAYMENT CREATED',
           x_accounting_date         => v_check_date,
           x_trx_bank_amount         => NULL,
           x_errors_bank_amount      => NULL,
           x_charges_bank_amount     => NULL,
           x_bank_currency_code      => NULL,
           x_bank_to_base_xrate_type => NULL,
           x_bank_to_base_xrate_date => NULL,
           x_bank_to_base_xrate      => NULL,
           x_trx_pmt_amount          => v_importe_total,   -- esto debe ser igual al total del cheque
           x_errors_pmt_amount       => NULL,
           x_charges_pmt_amount      => NULL,
           x_pmt_currency_code       => v_factura_reg.invoice_currency_code, 
           x_pmt_to_base_xrate_type  => v_factura_reg.exchange_rate_type, 
           x_pmt_to_base_xrate_date  => v_factura_reg.exchange_date,
           x_pmt_to_base_xrate       => v_factura_reg.exchange_rate,
           x_trx_base_amount         => v_factura_reg.base_amount,
           x_errors_base_amount      => NULL,
           x_charges_base_amount     => NULL,
           x_matched_flag            => NULL,
           x_rev_pmt_hist_id         => NULL,
           x_creation_date           => sysdate,
           x_created_by              => 0,
           x_last_update_date        => sysdate,
           x_last_updated_by         => 0,
           x_last_update_login       => 0,
           x_program_update_date     => NULL,
           x_program_application_id  => NULL,
           x_program_id              => NULL,
           x_request_id              => NULL,
           x_calling_sequence        => 'MY_API.Insert_Payment_History',
           x_accounting_event_id     => NULL,
           x_org_id                  => v_factura_reg.org_id,
           x_invoice_adjustment_event_id => NULL
         );


    select accounting_event_id
    into v_accounting_event_id
    from ap_payment_history_all
    where check_id = v_check_id
      AND transaction_type = 'PAYMENT CREATED'
      ;
	
	AP_PAY_IN_FULL_PKG.AP_CREATE_PAYMENTS(
        v_invoice_id_list,                      --:parameter.invoice_id_list,
        NULL,                                   --:parameter.payment_num_list,
        v_check_id,                             --:pay_sum_folder.check_id,
        'Q',                                    --:pay_sum_folder.payment_type_flag,
        v_factura_reg.payment_method_code,      --:pay_sum_folder.payment_method_code,  --IBY:SP
        v_bank_acct_use_id,                     --:pay_sum_folder.bank_account_id,
        v_bank_account_number,                  --:pay_sum_folder.bank_account_num,
        NULL,                                   --:pay_sum_folder.bank_account_type,
        NULL,                                   --:pay_sum_folder.bank_num,
        v_check_date,                           --:pay_sum_folder.check_date,
        to_char(v_check_date, 'MON-YY', 'NLS_DATE_LANGUAGE=spanish'),    --:pay_sum_folder.period_name,
        v_factura_reg.invoice_currency_code,    --:pay_sum_folder.currency_code,
        'MXN',                                  --:parameter.base_currency_code,
        NULL,                                   --:pay_sum_folder.checkrun_name,
        NULL,                                   --:pay_sum_folder.doc_sequence_value,
        NULL,                                   --:pay_sum_folder.doc_sequence_id,
        v_factura_reg.exchange_rate,            --:pay_sum_folder.exchange_rate,
        v_factura_reg.exchange_rate_type,       --:pay_sum_folder.exchange_rate_type,
        v_factura_reg.exchange_date,            --:pay_sum_folder.exchange_date,
        NULL,                                   --:parameter.pay_in_full_take_discount,
        'N',                                    --:parameter.sys_auto_calc_int_flag,
        'N',                                    --:pay_sum_folder.auto_calculate_interest_flag,
        v_factura_reg.set_of_books_id,          --:pay_sum_folder.set_of_books_id,
        NULL,                                   --:pay_sum_folder.future_pay_code_combination_id,
        0,                                      --:pay_sum_folder.last_updated_by,
        0,                                      --:pay_sum_folder.last_update_login,
        'APXPAWKB',
        'N',                                    --:parameter.seq_numbers,
        v_accounting_event_id,                  --:PARAMETER.accounting_Event_id, 
        v_factura_reg.org_id        
        );

--
--    -- no toy seguro pero creo que tambien lanza estos
--          IBY_DISBURSE_SINGLE_PMT.SUBMIT_SINGLE_PAYMENT;
--      AP_CHECKS_PKG.Subscribe_To_Payment_Event(
--               P_Event_Type       => 'PAYMENT_CREATED',
--               P_Check_ID         => :PAY_SUM_FOLDER.check_id,
--               P_Application_ID   => l_application_id,
--               P_Return_Status    => l_return_status,
--               P_Msg_Count        => l_msg_count,
--               P_Msg_Data         => l_msg_data,
--               P_Calling_Sequence => 'ADJ_INV_PAY_INSERT.POST_INSERT');
--          
--
     
     DBMS_OUTPUT.put_line ('v_return_status: '||v_return_status);
     DBMS_OUTPUT.put_line ('v_msg_count    : '|| nvl(v_msg_count,0) );
     DBMS_OUTPUT.put_line ('v_msg_data     : '|| nvl(v_msg_data, 'null'));
     
     /*
    FOR i IN 1 .. fnd_msg_pub.count_msg
    LOOP                   
       v_dummy := SUBSTR(fnd_msg_pub.get (p_msg_index   => i
                                         ,p_encoded     => 'F'
                                         )
                         , 0, 4000
                         )  ;
                     
        dbms_output.put_line ( to_char(i) || ': '||v_dummy);
    END LOOP;       
     
    IF v_return_status = FND_API.G_RET_STS_SUCCESS THEN
        COMMIT;
        
        SELECT check_id 
        INTO v_check_id
        FROM ap_invoice_payments_all x 
        WHERE x.invoice_id = v_factura_reg.invoice_id
        ;
        
        DBMS_OUTPUT.put_line ('Check_ID     : '|| nvl(to_char(v_check_id), 'null'));
        
        --
        -- Algunas Actualizaciones, para finalizar chido!
        --
        
        -- Se actualiza para reflejar correctamente la Cuenta Bancaria en la Pantalla de Facturas
        UPDATE ap_checks_all SET
        ce_bank_acct_use_id = v_bank_acct_use_id
        WHERE check_id = v_check_id
        ;                   
        
        -- Este no sé para que se use, pero cuando se crea el pago desde la Pantalla Estandar
        -- el campo sí contiene un número. Pero con el API el campo queda Nulo.
        UPDATE ap_invoice_payments_all SET
        accounting_event_id = (SELECT accounting_event_id 
                               FROM ap_payment_history_all x
                               WHERE transaction_type = 'PAYMENT CREATED'
                                 and check_id = v_check_id)
        --gain_code_combination_id = 
        --loss_code_combination_id =                              
        WHERE check_id = v_check_id
        ;
        
        COMMIT;
        
    ELSE
        ROLLBACK;
    END IF;
    */
     
END;                                 
/

--SELECT module, message_text, callstack, errorstack
--FROM FND_LOG_MESSAGES
--WHERE 1=1
-- and TIMESTAMP > SYSDATE-.5
-- AND user_id = 1123 
--ORDER BY log_sequence
--;
