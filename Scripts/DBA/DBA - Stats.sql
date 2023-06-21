

--ICX_CAT_ITEMS_CTX_DTLS_TLP
--ICX_CAT_ITEMS_CTX_HDRS_TLP
--
BEGIN
DBMS_STATS.Gather_Table_Stats(
                    ownname             => 'ICX', 
                    tabname             => 'ICX_CAT_ITEMS_CTX_DTLS_TLP', 
                    estimate_percent    => 100, 
                    cascade             => TRUE, 
                    force               => TRUE
                ) ;
END;
/

BEGIN
DBMS_STATS.Gather_Schema_Stats( - 
                  ownname          => 'INV', 
                  options          => 'GATHER',
                  estimate_percent => 100,
                  method_opt       => 'FOR ALL INDEXED COLUMNS SIZE SKEWONLY',
                  cascade          => TRUE                  
        );
END;
/


BEGIN
DBMS_STATS.Gather_Dictionary_Stats;
DBMS_STATS.Gather_Fixed_Objects_Stats;
END;
/



SELECT MAX(LAST_ANALYZED) FROM DBA_TABLES WHERE owner IN( 'SYSTEM', 'SYS');
BEGIN
--DBMS_STATS.Delete_System_Stats;
DBMS_STATS.Gather_System_Stats ('interval', interval => 10); 
END;
/