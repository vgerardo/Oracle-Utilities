--
-- https://drdavetaylor.com/2010/10/20/oracle-webadi-technical-overview/
-- http://manaskalsa.blogspot.mx/2012/11/web-adi-creation-using-api.html
-- http://blog.optiosys.com/?p=145
--
-- Subir Datos de un Excel hacia una Tabla, usando WEB ADI
--
--1: Create a table
--   Where WEB ADI will store the data. Table might be created in Custom schema.
--   Register Custom Table using AD_DD.register_table and AD_DD.register_column
--
--2. Create a Package.
--   (It has to be in APPS Schema)
--   In this case XX_TRAVEL_EXPENSE_ADI_PKG package,
--   procedure XX_TRAVEL_EXPENSE_PRC.
--** Note XX_TRAVEL_EXPENSE_PRC parameters should start with p_
--(
--
--      p_company             VARCHAR2,
--      p_vendor_name         VARCHAR2,
--      p_invoice_num         VARCHAR2,
--      p_inv_currency        VARCHAR2,
--      p_invoice_date        DATE,
--
--)
--then only prompt will automatically appear company , vendor_name, invoice_num, inv_currency, invoice_date.
--
--3. Once the database object is created,  then create integrator.
--DECLARE
--   ln_application_id    NUMBER;
--   lc_integtr_code      VARCHAR2 (50);
--   lx_interface_code    VARCHAR2 (50);
--   lx_param_list_code   VARCHAR2 (50);
--   ln_application_id    NUMBER;
--   ln_ret       number;
--  
--  --Create integrator 
--   BEGIN
--      bne_integrator_utils.create_integrator
--          (p_application_id            => 20003,
--           p_object_code               => 'XX_TRAVEL_INV',
--           p_integrator_user_name      => 'XX Travel Invoice Upload WEB ADI',
--           p_language                  => 'US',
--           p_source_language           => 'US',
--           p_user_id                   => -1,
--           p_integrator_code           => lc_integtr_code
--          );
--      DBMS_OUTPUT.put_line ('lc_integtr_code =  ' || lc_integtr_code);
--   END;
--
--Check it once it is created
--
--SELECT * FROM bne_integrators_b WHERE integrator_code LIKE 'XX_TRAVEL_INV%';
--
--4. Create Interface
--DECLARE
--   ln_application_id    NUMBER;
--   lc_integtr_code      VARCHAR2 (50);
--   lx_interface_code    VARCHAR2 (50);
--   lx_param_list_code   VARCHAR2 (50);
--   ln_application_id    NUMBER;
--   BEGIN
--      bne_integrator_utils.create_interface_for_api
--           (p_application_id           => 20003,
--            p_object_code              => 'XX_TRAVEL_INV',
--            p_integrator_code          => 'XX_TRAVEL_INV_INTG',
--            p_api_package_name         => 'XX_TRAVEL_EXPENSE_ADI_PKG',
--            p_api_procedure_name       => 'XX_TRAVEL_EXPENSE_PRC',
--            p_interface_user_name      => 'XX Travel Invoice Upload WEB ADI',
--            p_param_list_name          => 'XX Travel Invoice PL',
--            p_api_type                 => 'PROCEDURE',
--            p_api_return_type          => NULL,
--            p_upload_type              => 2,
--            p_language                 => 'US',
--            p_source_lang              => 'US',
--            p_user_id                  => -1,
--            p_param_list_code          => lx_param_list_code,
--            p_interface_code           => lx_interface_code
--           );
--      DBMS_OUTPUT.put_line ('lx_interface_code  =   ' || lx_interface_code);
--      DBMS_OUTPUT.put_line ('lx_param_list_code =   ' || lx_param_list_code);
--   --EXCEPTION
--   --   WHEN OTHERS
--   --   THEN
--   --      DBMS_OUTPUT.put_line ('Error  =      ' || SQLERRM);
--   END;
--
--Check Interface
--
--SELECT *  FROM bne_interface_cols_tl WHERE interface_code LIKE 'XX%' ;
--
--SELECT * FROM bne_interface_cols_vl WHERE interface_code LIKE 'XX%';
--
--SELECT * FROM bne_interface_cols_b WHERE interface_code LIKE 'XX%'
--
--
--5. Create an ADI function with following values:
--
--FunctionName UserFunctionName Description         Type                  MaintainanceMode ContextDependence
--************************************************************************************************************************
--<User defined>  <User defined> <User defined>  SSWA servlet function None   Responsibility
--
--Form Application 
--*********************************************************************************
--Parameter
--***************************************
--<none> <none>  bne:page=BneCreateDoc&bne:noreview=true&bne:integrator=20003:GENERAL%25&bne:reporting=N
--
--HTML Call   Host Name
--*********************************************************************************
--BneApplicationService  http://le0003.oracleads.com:80
--
--
--5. Use the ORACLE WEB ADI responsibility and go to DEFINE LAYOUT option
--
-- Give LAYOUT name
-- From the drop down select the INTERGRATOR USER NAME as defined above and click on 'GO'
-- A screen with all the procedure parameters will appear.
-- Select 'LINE' as placement value for all the parameters and APPLY
--
--7. Create and entry against the USER FUNCTION NAME in the menu under which ADI needs to be accessed.
--ADI is ready to use.
--
--
--
--Additional Steps:
--Add Date LOV in the WEB ADI Column
--
--
--DECLARE
--   ln_application_id    NUMBER;
--   lc_integtr_code      VARCHAR2 (50);
--   lx_interface_code    VARCHAR2 (50);
--   lx_param_list_code   VARCHAR2 (50);
--   ln_application_id    NUMBER;
--BEGIN
--   bne_integrator_utils.create_calendar_lov
--                                (p_application_id          => 20003,
--                                 p_interface_code          => 'XX_TRAVEL_INV_INTF',
--                                 p_interface_col_name      => 'P_INVOICE_DATE',--proc params
--                                 p_window_caption          => 'Select Date',
--                                 p_window_width            => 400,
--                                 p_window_height           => 300,
--                                 p_table_columns           => 'INVOICE_DATE',
--                                 p_user_id                 => 10803
--                                );
--END;
--
--ADD Lov in the fields,
--
--DECLARE
--   ln_application_id    NUMBER;
--   lc_integtr_code      VARCHAR2 (50);
--   lx_interface_code    VARCHAR2 (50);
--   lx_param_list_code   VARCHAR2 (50);
--   ln_application_id    NUMBER;  
--BEGIN
--   bne_integrator_utils.create_table_lov
--                                (p_application_id          => 20003,
--                                 p_interface_code          => 'XX_TRAVEL_INV_INTF',
--                                 p_interface_col_name      => 'P_INV_CURRENCY',
--                                 p_id_col                  => 'CURRENCY_CODE',
--                                 p_mean_col                => 'CURRENCY_CODE',
--                                 p_desc_col                => 'CURRENCY_CODE',                               
--                                 p_table                   => 'GL_CURRENCIES',
--                                 p_addl_w_c                => 'NVL (ENABLED_FLAG, ''N'') = ''Y''',
--                                 p_window_caption          => 'Select Currency',
--                                 p_window_width            => 400,
--                                 p_window_height           => 300,
--                                 p_table_block_size        => 10,
--                                 p_table_sort_order        => 'Yes',
--                                 p_user_id                 => 0
--                                );
--END;
--
--Other usefull API:
--1. Delete Integrator
--DECLARE
--   v_value   NUMBER;
--BEGIN
--   v_value :=
--      bne_integrator_utils.delete_integrator (20003, 'XX_TRAVEL_INV_INTG');
--   DBMS_OUTPUT.put_line (v_value);
--END;
--
--2. delete Interface
--DECLARE
--   v_value   NUMBER;
--BEGIN
--   v_value :=
--      bne_integrator_utils.DELETE_INTERFACE (20003, 'XX_TRAVEL_INV_INTF');
--   DBMS_OUTPUT.put_line (v_value);
--END; 
--
--Change the Prompt lebel,
--UPDATE bne_interface_cols_tl
--      SET prompt_left = 'Company',
--          prompt_above = 'Company',
--          user_hint = '*List - Text'
--    WHERE prompt_left = 'COMPANY'
--      AND interface_code = 'XX_TRAVEL_INV_INTF'
--      AND LANGUAGE = 'US';
--
-- UPDATE bne_interface_cols_tl
--      SET prompt_left = 'Invoice Date',
--          prompt_above = 'Invoice Date',
--          user_hint = '*List - Date'
--    WHERE prompt_left = 'INVOICE_DATE'
--      AND interface_code = 'XX_TRAVEL_INV_INTF'
--      AND LANGUAGE = 'US';
--
--
-- * NOW in to EBS, into Web ADI Responsibility
--     "Create Document"
--     "Create Data Template"



DECLARE
    p_integrator_code        VARCHAR2(30);
    p_interface_code         VARCHAR2(30);
    p_layout_code            VARCHAR2(30);
    p_application_id         NUMBER(15);
    p_object_code            VARCHAR2(20);
    p_integrator_user_name   VARCHAR2(240);
    p_language               VARCHAR2(4);
    p_source_language        VARCHAR2(4);
    p_user_id                NUMBER(15);
    p_interface_table_name   VARCHAR2(50);
    p_interface_user_name    VARCHAR2(240);
    p_force                  BOOLEAN;
    p_all_columns            BOOLEAN := false;
BEGIN
-- Define Constants
-- Application ID of the product that will own this Integrator
    p_application_id := 50201;  --50201=XBOL
    p_language := 'US';
    p_source_language := 'US';
-- Applications Database User ID that owns this Integrator
    p_user_id := 5801;
    p_object_code := 'GVP_001';   -- table name
--ADI details
    p_integrator_user_name := 'BOLINF';  -- este no toy seguro!
    p_interface_table_name := 'GVP_001'; -- Where WEB ADI will store the data. Table might be created in Custom schema..
    p_interface_user_name := 'GVP 001'; -- Name of the table that will be displayed in 
    p_force := false;
    p_all_columns := FALSE;
    
    bne_integrator_utils.create_integrator(
             p_application_id,
             p_object_code,
             p_integrator_user_name,
             p_language,
             p_source_language,
             p_user_id,
             p_integrator_code
        );

    bne_integrator_utils.create_interface_for_table(
            p_application_id,
            p_object_code,
            p_integrator_code,
            p_interface_table_name,
            p_interface_user_name,
            p_language,
            p_source_language,
            p_user_id,
            p_interface_code
        );
        
    --BNE_INTEGRATOR_UTILS.create_interface_for_api        

    bne_integrator_utils.create_default_layout(
           p_application_id,
           p_object_code,
           p_integrator_code,
           p_interface_code,
           p_user_id,
           p_force,
           p_all_columns,
           p_layout_code
        );

    COMMIT;
END;