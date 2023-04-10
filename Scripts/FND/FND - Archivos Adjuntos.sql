
    select 
            attch.entity_name
          , docs.file_name 
          , lobs.file_content_type
          , lobs.file_data
          , lobs.file_format
    
    from fnd_attached_documents attch,
         fnd_documents_tl       docs,
         fnd_lobs               lobs
    where attch.document_id = docs.document_id
      and docs.media_id = lobs.file_id
      and docs.language = 'ESA'
      and pk1_value = 6057085
      --and attch.document_id = 13839
      ;
      
  
  
