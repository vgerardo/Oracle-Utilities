set serveroutput on 
begin
    FND_GLOBAL.apps_initialize ( 
                             user_id      => 1123   -- CONE-LGOMEZ
                            ,resp_id      => 50833  -- GRP_ALL_AP_CONE_GTE
                            ,resp_appl_id => 200    -- SQLAP
                           );  
    MO_GLOBAL.init('SQLAP'); -- product short name: AR, SQLAP                           
    MO_GLOBAL.set_policy_context('S', 85); 
    CEP_STANDARD.init_security;
end;
/


select * from CE_STATEMENT_RECONCILS_ALL where STATEMENT_LINE_ID  IN (8979225,8977523 );
SELECT * FROM CE_200_TRANSACTIONS_V WHERE TRX_ID IN (1572370,1571378);

DECLARE
x_errbuf    varchar2(100);
x_retcode   number(15);
BEGIN
  CE_AUTO_BANK_REC.Statement (
            errbuf	                => x_errbuf,
            retcode                 => x_retcode,
            
            p_option                => 'RECONCILE',    --IMPORT, RECONCILE
            p_bank_branch_id        => 4127,
			p_bank_account_id       => 61304,
			p_statement_number_from => 'CTABX13052020.',
			p_statement_number_to   => 'CTABX13052020.',
		 	p_statement_date_from	=> null,
			p_statement_date_to     => null,
            p_org_id		        => 85,
            
			p_gl_date               => to_date ('15-jul-2020', 'dd-MON-YYYY'),
			p_legal_entity_id	    => null,
            p_receivables_trx_id    => null,
            p_payment_method_id     => null,
			p_nsf_handling          => null,
			p_display_debug		    => 'Y',
			p_debug_path		    => null,
			p_debug_file		    => null,
			p_intra_day_flag	    => 'N'  
    );
    
    DBMS_OUTPUT.put_line ('x_retcode = '|| x_retcode);
    DBMS_OUTPUT.put_line ('x_errbuf = '|| x_errbuf);
    
END;
/

select * from CE_RECONCILIATION_ERRORS where STATEMENT_LINE_ID  =8979225;
delete CE_RECONCILIATION_ERRORS;
