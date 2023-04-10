--
-- Este script debe ejecutarse con mucha cautela
-- Es peligroso hacer esto, solo se debe hacer en caso extremadamente necesario
--

UPDATE org_acct_periods 
SET open_flag = 'Y', 
period_close_date = NULL, 
summarized_flag = 'N' 
WHERE organization_id = &&org_id 
AND acct_period_id >= &&acct_period_id; 

DELETE mtl_period_summary 
WHERE organization_id = &org_id 
AND acct_period_id >= &acct_period_id; 

DELETE mtl_period_cg_summary 
WHERE organization_id = &org_id 
AND acct_period_id >= &acct_period_id; 

DELETE mtl_per_close_dtls 
WHERE organization_id = &org_id 
AND acct_period_id >= &acct_period_id;
 
DELETE cst_period_close_summary 
WHERE organization_id = &org_id 
AND acct_period_id >= &acct_period_id;