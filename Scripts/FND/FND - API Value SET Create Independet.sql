SET SERVEROUTPUT ON

DECLARE

v_value_set varchar2(10);
v_api_msg   varchar2(500);

BEGIN 

    v_value_set := 'GER_01';


    IF (FND_FLEX_VAL_API.valueset_exists (v_value_set) )
    THEN
        DBMS_OUTPUT.put_line ('Value set exists.. Deleting it…');
        FND_FLEX_VAL_API.delete_valueset(v_value_set);
    END IF;
  
    FND_FLEX_VAL_API.set_session_mode(session_mode => 'customer_data');	
    FND_FLEX_VAL_API.create_valueset_independent (
                            value_set_name      => v_value_set, 
                            description         => 'MI PRUEBA', 
                            security_available  => 'N',
                            enable_longlist     => 'N', 
                            format_type         => 'C', --<C>har
                            maximum_size        => 30, 
                            precision           => 1, 
                            numbers_only        => 'N',  
                            uppercase_only      => 'N',
                            right_justify_zero_fill => 'N',
                            min_value           => NULL,  
                            max_value           => NULL 
                            );
                                                     
COMMIT;

EXCEPTION
      WHEN OTHERS THEN
        v_api_msg := fnd_flex_val_api.MESSAGE;
        DBMS_OUTPUT.put_line (v_api_msg);
        DBMS_OUTPUT.put_line (SQLERRM);

END;
/

/*
BEGIN
FND_FLEX_VAL_API.CREATE_VALUESET_TABLE
(
 VALUE_SET_NAME =>'PO_VALUE_SET4',
 DESCRIPTION =>'createdfrombackend',
 SECURITY_AVAILABLE =>'N',
 ENABLE_LONGLIST =>'N',
 FORMAT_TYPE   =>'Char',
 MAXIMUM_SIZE =>20,
 precision => NULL,
 numbers_only =>'N',
 uppercase_only  =>'N',
 right_justify_zero_fill =>'N',
 min_value  => NULL,
 MAX_VALUE   => NULL,
 TABLE_APPLICATION => 'Purchasing',
 table_appl_short_name =>'PO' ,
 TABLE_NAME =>'PO_REQUISITION_HEADERS PRH',
 ALLOW_PARENT_VALUES =>'N',
 VALUE_COLUMN_NAME =>'PRH.SEGMENT1',
 VALUE_COLUMN_TYPE  =>'Char',
 value_column_size  =>20,
 meaning_column_name  => NULL,
 meaning_column_type  => NULL,
 MEANING_COLUMN_SIZE  => NULL,
 ID_COLUMN_NAME    =>NULL,--'PRH.SEGMENT1',
 ID_COLUMN_TYPE   =>NULL,--'Char',
 ID_COLUMN_SIZE   =>null,--u20,
 WHERE_ORDER_BY    =>'where rownum<=100',
 ADDITIONAL_COLUMNS => NULL);
 Commit;
  Exception
  WHEN OTHERS THEN
  dbms_output.put_line(sqlerrm);
  end;
/
*/

