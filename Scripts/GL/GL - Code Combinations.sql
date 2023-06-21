
select
    GL_FLEXFIELDS_PKG.Get_Concat_Description (/*chart_of_accounts_id =>*/ 50408, /*code_combination_id =>*/ 2179)
FROM DUAL;

SELECT *
FROM GL_CODE_COMBINATIONS
WHERE SEGMENT1 = '3601';