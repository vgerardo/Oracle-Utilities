

SELECT  ATTRIBUTE_NAME, user_attribute_name,
        decode(control_level,1,'master',2,'org',3,'view only')                
FROM MTL_ITEM_ATTRIBUTES
ORDER BY control_level, attribute_name

