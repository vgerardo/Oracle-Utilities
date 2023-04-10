
SET SERVEROUTPUT ON 
DECLARE

v_check_id              number(15) := 1573406;

l_payment_function      varchar2(100);
v_check                 AP_CHECKS_ALL%rowtype;
l_print_immediate_flag  varchar2(10);
l_printer_name          varchar2(100);
l_internal_bank_acct_id NUMBER(15);
l_num_printed_docs      NUMBER;    
l_paper_doc_num         IBY_PAYMENTS_ALL.paper_document_number%TYPE;
l_pmt_ref_num           IBY_PAYMENTS_ALL.payment_reference_number%TYPE;
l_payment_id            number(15);
l_return_status         VARCHAR2(50);
l_errorIds              IBY_DISBURSE_SINGLE_PMT_PKG.trxnErrorIdsTab;
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(1000); 
             
BEGIN

    FND_GLOBAL.apps_initialize ( 
                             user_id      => 1123   -- CONE-LGOMEZ
                            ,resp_id      => 50833  -- GRP_ALL_AP_CONE_GTE
                            ,resp_appl_id => 200    -- SQLAP
                           );  
    MO_GLOBAL.init('SQLAP'); -- product short name: AR, SQLAP                           
    MO_GLOBAL.set_policy_context('S', 85); 
    CEP_STANDARD.init_security;

    --
    --- Para poder ver los mensajes en la tabla: FND_LOG_MESSAGES
    --
    FND_PROFILE.put ('AFLOG_ENABLED', 'Y');
    FND_PROFILE.put ('AFLOG_MODULE', '%');
    FND_PROFILE.put ('AFLOG_LEVEL','1'); -- Level 1 is Statement Level
    FND_LOG_REPOSITORY.init;


      select  *
      into   v_check
      from ap_checks_all
      where check_id =  v_check_id ;

    SELECT DISTINCT payment_function
      INTO l_payment_function 
      FROM IBY_EXTERNAL_PAYEES_ALL
      WHERE payee_party_id = v_check.party_id  --:pay_sum_folder.party_id
      ;    

    SELECT print_instruction_immed_flag, default_printer
      INTO l_print_immediate_flag, l_printer_name
      FROM IBY_PAYMENT_PROFILES
      WHERE payment_profile_id = v_check.payment_profile_id --:pay_sum_folder.payment_profile_id
      ;

		SELECT cba.bank_account_id
		INTO l_internal_bank_acct_id
		FROM ce_bank_branches_v cbb, 
             ce_bank_accounts cba,
             ce_bank_acct_uses_ou_v cbau
		WHERE 1=1
		AND cbau.ap_use_enable_flag = 'Y'  
		AND cbau.bank_account_id = cba.bank_account_id 
		AND sysdate < nvl(cba.end_date,sysdate+1)
		AND cba.bank_branch_id  = cbb.branch_party_id
		AND cbau.org_id = v_check.org_id
        and cba.bank_account_name = v_check.bank_account_name
        ;

  IBY_DISBURSE_SINGLE_PMT_PKG.Submit_Single_Payment(
             p_api_version                =>    1.0,
             p_init_msg_list              =>    'T',
             p_calling_app_id             =>    200,
             p_calling_app_payreq_cd      =>    v_check.checkrun_name,
             p_is_manual_payment_flag     =>    'N', 
             p_payment_function           =>    l_payment_function,
             p_internal_bank_account_id   =>    l_internal_bank_acct_id,
             p_pay_process_profile_id     =>    v_check.payment_profile_id,
             p_payment_method_cd          =>    v_check.payment_method_code,
             p_legal_entity_id            =>    v_check.legal_entity_id,
             p_organization_id            =>    v_check.org_id,
             p_organization_type          =>    'OPERATING_UNIT',
             p_payment_date               =>    v_check.check_date,
             p_payment_amount             =>    v_check.amount,
             p_payment_currency           =>    v_check.currency_code,
             p_payee_party_id             =>    v_check.party_id,
             p_payee_party_site_id        =>    v_check.party_site_id,
             p_supplier_site_id           =>    v_check.vendor_site_id,
             p_payee_bank_account_id      =>    v_check.external_bank_account_id,
             p_override_pmt_complete_pt   =>    'Y', ----AP should always set this parameter to be 'Y'.This ensures that IBY marks the payment complete immediately upon success of the API.
             p_bill_payable_flag          =>    'N', --NVL(:pay_sum_folder.bills_payable, 'N'),
             p_anticipated_value_date     =>    v_check.anticipated_value_date,
             p_maturity_date              =>    v_check.future_pay_due_date,
             p_payment_document_id        =>    v_check.payment_document_id,
             p_paper_document_number      =>    v_check.check_number, --l_check_number_api,
             p_printer_name               =>    l_printer_name,  --  PPP LOV should return this if PPP has PRoceesing type as "Printed"
             p_print_immediate_flag       =>    l_print_immediate_flag,   --  PPP LOV should return this if PPP has PRoceesing type as "Printed"
             p_transmit_immediate_flag    =>    Null,
             p_payee_address_line1        =>    v_check.address_line1,
             p_payee_address_line2        =>    v_check.address_line2,
             p_payee_address_line3        =>    v_check.address_line3,
             p_payee_address_line4        =>    v_check.address_line4,
             p_payee_address_city         =>    v_check.city,
             p_payee_address_county       =>    v_check.county,
             p_payee_address_state        =>    v_check.state,
             p_payee_address_zip          =>    v_check.zip,
             p_payee_address_country      =>    v_check.country,
             p_attribute_category         =>    v_check.attribute_category,
             p_attribute1                 =>    v_check.attribute1,
             p_attribute2                 =>    v_check.attribute2,
             p_attribute3                 =>    v_check.attribute3,
             p_attribute4                 =>    v_check.attribute4,
             p_attribute5                 =>    v_check.attribute5,
             p_attribute6                 =>    v_check.attribute6,
             p_attribute7                 =>    v_check.attribute7,
             p_attribute8                 =>    v_check.attribute8,
             p_attribute9                 =>    v_check.attribute9,
             p_attribute10                =>    v_check.attribute10,
             p_attribute11                =>    v_check.attribute11,
             p_attribute12                =>    v_check.attribute12,
             p_attribute13                =>    v_check.attribute13,
             p_attribute14                =>    v_check.attribute14,
             p_attribute15                =>    v_check.attribute15,
             x_num_printed_docs           =>    l_num_printed_docs,
             x_payment_id                 =>    l_payment_id,
             x_paper_doc_num              =>    l_paper_doc_num,
             x_pmt_ref_num                =>    l_pmt_ref_num,
             x_return_status              =>    l_return_status,
             x_error_ids_tab              =>    l_errorIds,
             x_msg_count                  =>    l_msg_count,
             x_msg_data                   =>    l_msg_data
     );

    DBMS_OUTPUT.put_line ('l_payment_id    = ' || l_payment_id);
    DBMS_OUTPUT.put_line ('l_return_status = ' || l_return_status);    
    DBMS_OUTPUT.put_line ('l_msg_count     = ' || l_msg_count);

    IF l_return_status = 'S' THEN
        UPDATE ap_checks_all SET
        payment_id = l_payment_id
        WHERE check_id = v_check_id
        ;
    
        COMMIT;
        DBMS_OUTPUT.put_line ('Chido! ' || l_payment_id);        
    ELSE        
        IF l_msg_count = 1 THEN
            DBMS_OUTPUT.put_line (l_msg_count ||': '||l_msg_data);
        ELSE
            FOR e IN 1..l_msg_count LOOP          
              l_msg_data := apps.FND_MSG_PUB.Get (apps.FND_MSG_PUB.G_Next, apps.FND_API.G_FALSE);
              IF l_msg_data IS NULL THEN
                EXIT;
              END IF;
                DBMS_OUTPUT.put_line(e || ': '||l_msg_data);
            END LOOP;        
        END IF;
        ROLLBACK;
    END IF;
 
    FND_PROFILE.put ('AFLOG_ENABLED', 'N');
            
END;
/