SELECT user_name
     , UTL_MATCH.Edit_Distance (user_name, 'EXTGVARGAS') DIST_1             --   0 = iguales
     , UTL_MATCH.Edit_Distance_Similarity (user_name, 'EXTGVARGAS') DIST_2  -- 100 = iguales
     , UTL_MATCH.jaro_winkler (user_name, 'EXT-GVARGAS') DIST_3             --   1 = iguales
     , UTL_MATCH.jaro_winkler_similarity (user_name, 'EXTGVARGAS') DIST_4   -- 100 = iguales
FROM fnd_user
--WHERE  LIKE '%SCOTT%'
ORDER BY