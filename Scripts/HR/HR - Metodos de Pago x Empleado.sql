

select *
     FROM PAY_ORG_PAYMENT_METHODS_F_TL      OPMTL,
          PAY_PERSONAL_PAYMENT_METHODS_F    PPM,
          PAY_ORG_PAYMENT_METHODS_F         OPM,
          PAY_PAYMENT_TYPES_TL              PTTL,
          PAY_PAYMENT_TYPES                 PT,
          HR_COMMENTS                       C,
          PAY_EXTERNAL_ACCOUNTS             PEA,
          PAY_DEFINED_BALANCES              PBD,
          PER_ALL_ASSIGNMENTS_F             PA,
          PAY_LEGISLATION_RULES             PLR       
    WHERE     PT.PAYMENT_TYPE_ID = PTTL.PAYMENT_TYPE_ID
          AND PTTL.LANGUAGE = 'ESA'
          AND OPM.ORG_PAYMENT_METHOD_ID = OPMTL.ORG_PAYMENT_METHOD_ID
          AND OPMTL.LANGUAGE = 'ESA'          
          AND PPM.ORG_PAYMENT_METHOD_ID = OPM.ORG_PAYMENT_METHOD_ID
          AND OPM.PAYMENT_TYPE_ID = PT.PAYMENT_TYPE_ID
          AND PPM.COMMENT_ID = C.COMMENT_ID(+)
          AND PPM.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID(+)
          AND OPM.DEFINED_BALANCE_ID = PBD.DEFINED_BALANCE_ID(+)
          AND ( (ppm.assignment_id IS NOT NULL
                 AND PPM.ASSIGNMENT_ID = PA.ASSIGNMENT_ID)
               OR (ppm.person_id IS NOT NULL AND PPM.person_id = pa.person_id))
          AND PT.TERRITORY_CODE = PLR.LEGISLATION_CODE(+)
          AND PLR.RULE_TYPE(+) = 'E'
and PA.person_id     = 53995
and pa.assignment_id = 45061
and sysdate between pa.effective_start_date and pa.effective_end_date
and sysdate+20 between ppm.effective_start_date and ppm.effective_end_date
  


select *
from PAY_PERSONAL_PAYMENT_METHODS_F    PPM
where 1=1
and sysdate+20 between ppm.effective_start_date and ppm.effective_end_date
--and PA.person_id     = 53995
and ppm.assignment_id = 117058