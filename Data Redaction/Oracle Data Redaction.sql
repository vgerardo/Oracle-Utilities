
--select parameter, value from v$option where upper(parameter) like '%SECURITY%'; 

BEGIN
    sys.DBMS_REDACT.Add_Policy (
              object_schema          => 'BOLINF',
              object_name            => 'GRP_AR_AUTOFAC_ORDNES_T',
              policy_name            => 'Redact_Prueba',
              policy_description     => 'PRUEBA DE GVP',
              column_name            => 'SAL',
              column_description     => 'prueba de mi',
              function_type          =>  dbms_redact.RANDOM,
              function_parameters    => NULL,
              expression             => '1=1',
              ENABLE                 => TRUE,
              regexp_pattern         => NULL,
              regexp_replace_string  => NULL,
              regexp_position        => 1,
              regexp_occurrence      => 0,
              regexp_match_parameter => NULL
            );
END;
/
