
DELETE FROM xdo_templates_b  WHERE template_code = 'XXCMX_AR_PA_FE_REP_ESTATUS';
DELETE FROM xdo_templates_tl WHERE template_code = 'XXCMX_AR_PA_FE_REP_ESTATUS';
DELETE FROM xdo_lobs         WHERE lob_code      = 'XXCMX_AR_PA_FE_REP_ESTATUS';

DELETE FROM xdo_ds_definitions_b  WHERE data_source_code = 'XXCMX_AR_PA_FE_REP_ESTATUS_DM';
DELETE FROM xdo_ds_definitions_tl WHERE data_source_code = 'XXCMX_AR_PA_FE_REP_ESTATUS_DM';