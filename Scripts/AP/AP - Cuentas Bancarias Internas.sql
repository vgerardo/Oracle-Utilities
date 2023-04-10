--
-- Cuentas Bancarias INTERNAS
--

begin
    FND_GLOBAL.apps_initialize ( 
                             user_id      => 1123   -- CONE-LGOMEZ
                            ,resp_id      => 50833  -- GRP_ALL_AP_CONE_GTE
                            ,resp_appl_id => 200    -- SQLAP
                           );
                           
    MO_GLOBAL.set_policy_context('S', 649);                           
END;
/


SELECT cbau.*
    FROM CE_BANK_ACCOUNTS BA,
            CE_BANK_BRANCHES_V CBB,
            CE_BANK_ACCT_USES_OU_V CBAU
       WHERE CBAU.BANK_ACCOUNT_ID = BA.BANK_ACCOUNT_ID
       AND CBB.branch_party_id = BA.bank_branch_id
       AND  SYSDATE < NVL(BA.END_DATE,SYSDATE+1)
       AND  BA.ACCOUNT_CLASSIFICATION    = 'INTERNAL'
       AND  CBAU.ap_use_enable_flag = 'Y'
       --AND  CBAU.org_id = l_inv_rec.org_id
       --AND  CBAU.bank_account_id = p_internal_bank_acct_id
       ; 