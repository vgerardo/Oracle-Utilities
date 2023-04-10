-------------------------------------------------------------------------------
-- Query to find Bank, Bank Account, and Bank Branches information
-------------------------------------------------------------------------------
SELECT
    cba.bank_account_iD,
    cba.bank_branch_id, 
    cba.bank_id, 
    cba.account_owner_party_id, 
    cba.account_owner_org_id, 
    cba.object_version_number,
    cba.bank_account_name             "Bank Account Name",
    cba.bank_account_num              "Bank Account Number",
--    cba.multi_currency_allowed_flag   "Multi Currency Flag",
--    cba.zero_amount_allowed           "Zero Amount Flag",
--    cba.account_classification        "Account Classification",
--    bb.bank_name                      "Bank Name",
--    bb.bank_branch_type               "Bank Branch Type",
--    bb.bank_branch_name               "Bank Branch Name",
--    bb.bank_branch_number             "Bank Branch Number",
--    bb.eft_swift_code                 "Swift Code",
--    ou.name                           "Operating Unit",
    gcf.concatenated_segments         "GL Code Combination"
FROM
    ce_bank_accounts cba,
    ce_bank_acct_uses_all bau,
    cefv_bank_branches bb,
    hr_operating_units ou,
    gl_code_combinations_kfv gcf
WHERE
    cba.bank_account_id = bau.bank_account_id
    AND cba.bank_branch_id = bb.bank_branch_id
    AND ou.organization_id = bau.org_id
    AND cba.asset_code_combination_id = gcf.code_combination_id
    --AND ( cba.end_date IS NULL OR cba.end_date > trunc(SYSDATE) )
    AND cba.bank_account_name = 'MCLUBG_CAPT LOC_6136868'
    --AND cba.account_classification <> 'INTERNAL'
    ;
    
    