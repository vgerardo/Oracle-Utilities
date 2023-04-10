
SELECT LISTAGG ( cp.email_address ) within group (order by cp.email_address) email
FROM hz_contact_points cp,
     fnd_lookup_values al
WHERE 1=1
  AND cp.contact_point_purpose    = al.LOOKUP_CODE(+)
  AND cp.contact_point_purpose    = 'MAIL FE'  
  and cp.contact_point_type       = 'EMAIL'
  AND cp.STATUS                   = 'A'
  AND cp.owner_table_name         = 'HZ_PARTY_SITES'
  AND al.lookup_type(+)           = 'CONTACT_POINT_PURPOSE'  
  AND al.view_application_id(+)   = 222
  AND al.language(+)              = 'US'  
  AND al.enabled_flag             = 'Y'
  and nvl(al.end_date_active,sysdate) > sysdate - 1
  AND cp.owner_table_id           = 382028 --P_party_site_id
 ;