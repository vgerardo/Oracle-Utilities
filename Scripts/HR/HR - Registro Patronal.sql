


select 
     paf.effective_start_date,
     paf.effective_end_date,
     org.org_information1,  
     org.org_information2  registro_patronal 
     
from per_all_assignments_f          paf,
     hr_soft_coding_keyflex         sck,
     hr_organization_information    org 
     
where 1=1
  and paf.soft_coding_keyflex_id = sck.soft_coding_keyflex_id
  and sck.segment1 = org.organization_id
  and org.org_information_context = 'MX_SOC_SEC_DETAILS'
  and paf.assignment_id = 25773
  