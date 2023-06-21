SET SERVEROUTPUT ON;

DECLARE
-- Change the following two parameters
    var_templatecode   VARCHAR2(100) := 'GRP_AR_MAR_RPRTE_APP_FC';     -- Template Code
    boo_deletedatadef  BOOLEAN := true;     
--delete the associated Data Def.
BEGIN
    FOR rs IN (
        SELECT
            t1.application_short_name    template_app_name,
            t1.data_source_code,
            t2.application_short_name    def_app_name
        FROM
            xdo_templates_b       t1,
            xdo_ds_definitions_b  t2
        WHERE
                t1.template_code = var_templatecode
            AND t1.data_source_code = t2.data_source_code
    ) LOOP
        xdo_templates_pkg.delete_row(
            rs.template_app_name,
            var_templatecode
        );
        DELETE FROM xdo_lobs
        WHERE
                lob_code = var_templatecode
            AND application_short_name = rs.template_app_name
            AND lower(lob_type) IN (
                'template_source',
                'template'
            );

        DELETE FROM xdo_config_values
        WHERE
                application_short_name = rs.template_app_name
            AND template_code = var_templatecode
            AND data_source_code = rs.data_source_code
            AND config_level = 50;

        dbms_output.put_line('Selected template has been '
                             || var_templatecode
                             || ' deleted.');
        IF boo_deletedatadef THEN
            xdo_ds_definitions_pkg.delete_row(
                rs.def_app_name,
                rs.data_source_code
            );
            DELETE FROM xdo_lobs
            WHERE
                    lob_code = rs.data_source_code
                AND application_short_name = rs.def_app_name
                AND lower(lob_type) IN (
                    'xml_schema',
                    'data_template',
                    'xml_sample',
                    'bursting_file'
                );

            DELETE FROM xdo_config_values
            WHERE
                    application_short_name = rs.def_app_name
                AND data_source_code = rs.data_source_code
                AND config_level = 30;

            dbms_output.put_line('Selected Data Defintion has been '
                                 || rs.data_source_code
                                 || ' deleted.');
        END IF;

    END LOOP;

 --   COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        dbms_output.put_line('Unable to delete XML Publisher Template ' || var_templatecode);
        dbms_output.put_line(substr(
            sqlerrm,
            1,
       200
        ));
END;
/