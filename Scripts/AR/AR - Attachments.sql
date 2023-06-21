

SELECT dlt.long_text
FROM fnd_attached_documents     ad
    ,fnd_documents              doc
    --,fnd_documents_short_text   dst
    ,fnd_documents_long_text    dlt
WHERE 1=1
  and ad.document_id  = doc.document_id
  and ad.entity_name  = 'OE_ORDER_HEADERS' --'RA_CUSTOMER_TRX'
  and doc.category_id = 326         -- 1=Miscellaneous 326=Short Text  
  and doc.datatype_id = 2           -- 1=Short Text 2=Long Text
  --and doc.media_id    = dst.media_id (+)
  and doc.media_id    = dlt.media_id (+)
  -- -----------------------
  and ad.pk1_value = 95105    --header_id
;


