
SELECT a.application_name, b.product_version,  b.patch_level 
FROM fnd_application_tl a
, fnd_product_installations b
where language = 'US' 
and upper(application_name) LIKE upper('%Receivables%')
and a.application_id = b.application_id 
;

sELECT *
  FROM ad_bugs
where bug_number like '17207868'
;


SELECT * 
  FROM ad_applied_patches
where patch_name like '18846783'
  ;
  
SELECT ad_patch.is_patch_applied('R12',-1,17207868)
from dual;  
