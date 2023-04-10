  
SET SERVEROUTPUT ON

declare
v_salida_x  varchar2(500);
V_invoice_payment_id    NUMBER(15);
begin
    FND_GLOBAL.apps_initialize ( 
                             user_id      => 1123   -- CONE-LGOMEZ
                            ,resp_id      => 50833  -- GRP_ALL_AP_CONE_GTE
                            ,resp_appl_id => 200    -- SQLAP
                           );  

     MO_GLOBAL.init('SQLAP'); -- product short name: AR, SQLAP                           
     MO_GLOBAL.set_policy_context('S', 85); 


 SELECT ap_invoice_payments_s.nextval
   INTO V_invoice_payment_id
   FROM sys.dual;  

  AP_PAY_INVOICE_PKG.ap_pay_invoice(
            P_invoice_id		    => 3966180,
            P_check_id     		    => 1569375,
            P_payment_num	    	=> 1,           --:ADJ_INV_PAY.payment_num,
            P_invoice_payment_id	=> V_invoice_payment_id,        --:ADJ_INV_PAY.invoice_payment_id,
            P_old_invoice_payment_id=> null,        --:ADJ_INV_PAY.org_inv_pay_id,
            P_period_name		    => null,        --:ADJ_INV_PAY.period_name,
            P_invoice_type		    => 'STANDARD',  --:ADJ_INV_PAY.invoice_type,
            P_accounting_date   	=> TO_DATE('15-05-2020','DD-MM-YYYY'),        --:ADJ_INV_PAY.accounting_date,         -- Bug 2327530
            P_amount		        => 12.01,       --nvl(:ADJ_INV_PAY.amount,0),
            P_discount_taken	    => 0,           --nvl(:ADJ_INV_PAY.discount_taken_no_db,0),
            P_discount_lost		    => '',
            P_invoice_base_amount	=> '',
            P_payment_base_amount	=> '',
            P_accrual_posted_flag	=> 'N',
            P_cash_posted_flag	    => 'N',
            P_posted_flag		    => 'N',
            P_set_of_books_id	    => 2022,        --:ADJ_INV_PAY.set_of_books_id,
            P_last_updated_by     	=> 1,           --:ADJ_INV_PAY.last_updated_by,
            P_last_update_login	    => 1,           --:ADJ_INV_PAY.last_updated_by,
            P_currency_code		    => 'MXN',       --:pay_sum_folder.currency_code,
            P_base_currency_code	=> 'MXN',       --:parameter.base_currency_code,
            P_exchange_rate		    => NULL,        --:ADJ_INV_PAY.exchange_rate,
            P_exchange_rate_type  	=> NULL,        --:ADJ_INV_PAY.exchange_rate_type,
            P_exchange_date		    => NULL,        --:ADJ_INV_PAY.exchange_date,
            P_CE_bank_acct_use_id	=> 16238,       --:pay_sum_folder.bank_account_id,
            P_bank_account_num	    => NULL,        --:pay_sum_folder.bank_account_num,
            P_bank_account_type	    => NULL,        --:pay_sum_folder.bank_account_type,
            P_bank_num		        => NULL,        --:pay_sum_folder.bank_num,
            P_future_pay_posted_flag=> NULL,        --:ADJ_INV_PAY.future_pay_posted_flag,
            P_exclusive_payment_flag=> NULL,        --:ADJ_INV_PAY.exclusive_payment_flag,
            P_accts_pay_ccid        => NULL,        --:ADJ_INV_PAY.accts_pay_code_combination_id,
            P_gain_ccid	            => '',
            P_loss_ccid   	        => '',
            P_future_pay_ccid       => NULL,        --:ADJ_INV_PAY.future_pay_code_combination_id,
            P_asset_ccid		    => NULL,        --:ADJ_INV_PAY.asset_code_combination_id,
            P_payment_dists_flag	=> 'Y',         /*Different from below*/
            P_payment_mode		    => 'REV',       /*Different from below*/
            P_replace_flag		    => 'N', 
            P_calling_sequence   	=> 'Pay Invoice Forms <- Pre_inser trigger',
            P_accounting_event_id   => NULL,        --:parameter.accounting_event_id,
            P_org_id                => 85           --:PAY_SUM_FOLDER.org_id
        );
 
END;
/

