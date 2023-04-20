select 
         g.request_group_name,
         rt.responsibility_name responsibility
         ,r.end_date            resp_end_date
    from FND_REQUEST_GROUPS         g,
         FND_REQUEST_GROUP_UNITS    u,
         FND_APPLICATION_TL         a,
         FND_APPLICATION_TL         a1,
         FND_CONCURRENT_PROGRAMS_TL p,
         FND_CONCURRENT_PROGRAMS    p1,
         FND_RESPONSIBILITY         r,
         FND_RESPONSIBILITY_TL      rt
   where u.application_id = g.application_id
     and u.request_group_id = g.request_group_id
     and (u.request_unit_id = p.concurrent_program_id or u.request_unit_type = 'A')
     and u.unit_application_id = p.application_id
     and p.application_id = a.application_id
     and p.concurrent_program_id = p1.concurrent_program_id
     and g.application_id = a1.application_id
     and r.request_group_id = g.request_group_id
     and r.responsibility_id = rt.responsibility_id
     and rt.language = 'ESA'
     and p.language = 'ESA'
     and a.language = 'ESA'
     and a1.language = 'ESA'
     --and rt.responsibility_name like 'GRP_HER_PROVEEDORES'
     and p.user_concurrent_program_name LIKE 'XXCMX WMS OE Confirma RMA (MS UP)'
   order by 1;

  
  