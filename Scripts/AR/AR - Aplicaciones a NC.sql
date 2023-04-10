
select 
    --nc.trx_number nota_credito, fc.trx_number, fc.trx_date, fc.attribute15
    LISTAGG ( fc.attribute15 ) within group (order by fc.attribute15) folio_fiscal,
    LISTAGG ( fc.trx_date ) within group (order by fc.trx_date) fecha_factura
from  
      ar_receivable_applications_all    ra
    , ra_customer_trx_all               fc
    , ra_customer_trx_all               nc
where 1=1
  and ra.applied_customer_trx_id = fc.customer_Trx_id
  and ra.org_id                  = fc.org_id
  and ra.customer_trx_id         = nc.customer_trx_id
  and ra.org_id                  = nc.org_id
  and ra.org_id = 622
  and ra.application_type = 'CM'
  AND ra.status = 'APP'
  and ra.display = 'Y'
  and ra.last_update_date > sysdate-200
;