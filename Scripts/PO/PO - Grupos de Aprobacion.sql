--
-- GRUPOS DE APROBACIÓN
--
SELECT
  pcg.org_id, ou.name 
, pcg.control_group_name, pcg.description
, pcr.rule_type_code, pcr.amount_limit
, (pcr.segment1_low ||':' || pcr.segment1_high ) CIA
, (pcr.segment2_low ||':' || pcr.segment2_high ) CC
, (pcr.segment3_low ||':' || pcr.segment3_high ) CNTA
, (pcr.segment4_low ||':' || pcr.segment4_high ) SCTA
, (pcr.segment5_low ||':' || pcr.segment5_high ) INTERCO
, (pcr.segment6_low ||':' || pcr.segment6_high ) FUT1
, (pcr.segment7_low ||':' || pcr.segment7_high ) FUT2
    FROM PO_CONTROL_GROUPS_ALL      pcg
      , PO_CONTROL_RULES            pcr
      , hr_all_organization_units   ou
    --  , hr_all_organization_units   ou_inv
WHERE pcg.control_group_id = pcr.control_group_id
  and pcg.org_id = ou.organization_id
  --and pcg.control_group_id = 263
  and pcr.object_code = 'ACCOUNT_RANGE'
  and substr(ou.name,1,4) = substr(pcg.control_group_name, 1,4)

