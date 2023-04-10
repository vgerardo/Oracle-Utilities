
declare

v_sec   number(15) := 0;

CURSOR c_cuentas
is
    SELECT hca.account_number        
         , hca.orig_system_reference
         , hca.cust_account_id       
         , hca.party_id
    FROM HZ_CUST_ACCOUNTS       hca
    WHERE 1=1
    ;

CURSOR c_sites (p_cust_account_id number)
IS
    SELECT
          hcs.orig_system_reference
         ,hcs.cust_acct_site_id
         ,hcs.party_site_id
    from HZ_CUST_ACCT_SITES_ALL hcs    
    where 1=1
    AND hcs.cust_account_id = p_cust_account_id
    AND orig_system_reference NOT LIKE '%@%'
    ;

CURSOR c_party (p_party_id number)
IS
    SELECT hp.orig_system_reference
         , hp.party_id
    FROM HZ_PARTIES             hp
    WHERE 1=1
    and hp.party_id = p_party_id
         ;

CURSOR c_party_sites (p_party_site_id NUMBER)
IS
    SELECT hps.orig_system_reference 
         ,hps.location_id
         ,hps.party_id
         ,hps.party_site_id                          
    FROM hz_party_sites         hps    
    WHERE 1=1
    and hps.party_site_id = p_party_site_id 
;


CURSOR c_locations (p_location_id number)
IS
SELECT hl.orig_system_reference
      ,hl.location_id 
from HZ_LOCATIONS           hl
where 1=1
 and hl.location_id     = p_location_id
 ;
     


begin    

    for c in c_cuentas loop
      
        --dbms_output.put_line ('----------------------------------');
        --dbms_output.put ('Account Number = ' ||c.account_number || '   cust_account_id = ' ||  c.cust_account_id); 
                              
        IF c.account_number||'5' <> c.orig_system_reference THEN                        
                        
            UPDATE AR.HZ_CUST_ACCOUNTS SET
              --orig_system_reference = 'dummy_'||v_sec
              orig_system_reference = c.account_number||'5'
            WHERE cust_account_id = c.cust_account_id
             ;           
        END IF;                        
        
        v_sec := v_sec + 1;

        FOR p IN c_party (c.party_id) LOOP
        
            IF c.account_number||'5' <> p.orig_system_reference THEN
                UPDATE HZ_PARTIES   SET
                  --orig_system_reference = 'dummy_'||v_sec
                  orig_system_reference = c.account_number||'5'
                WHERE party_id = p.party_id                  
                ;
            END IF;
        
            v_sec := v_sec + 1;
            
        END LOOP;


        
        FOR cs IN c_sites (c.cust_account_id) LOOP
        
            IF c.account_number||'5' <> cs.orig_system_reference THEN
            
                --dbms_output.put ('  cust_acct_site_id = ' || cs.cust_acct_site_id);
                 
                BEGIN
                UPDATE HZ_CUST_ACCT_SITES_ALL  SET
                  --orig_system_reference = 'dummy_'||v_sec
                  orig_system_reference = c.account_number||'5'
                WHERE cust_account_id = c.cust_account_id
                  AND cust_acct_site_id = cs.cust_acct_site_id
                ;
                EXCEPTION
                    WHEN DUP_VAL_ON_INDEX THEN
                        dbms_output.put ('  Error: Valor duplicado '||cs.cust_acct_site_id);
                END;
            END IF;
        
            v_sec := v_sec + 1;
            

            FOR ps IN c_party_sites (cs.party_site_id) LOOP
            
                IF c.account_number||'5' <> ps.orig_system_reference THEN
                    UPDATE hz_party_sites  SET
                      --orig_system_reference = 'dummy_'||v_sec
                      orig_system_reference = c.account_number||'5'
                    WHERE party_site_id  = ps.party_site_id                      
                    ;
                END IF;

                v_sec := v_sec + 1;
                                
                FOR loc IN c_locations (ps.location_id) LOOP
                
                    IF c.account_number||'5' <> loc.orig_system_reference THEN
                        UPDATE HZ_LOCATIONS  SET
                          --orig_system_reference = 'dummy_'||v_sec
                          orig_system_reference = c.account_number||'5'
                        WHERE location_id  = loc.location_id
                        ;
                    END IF;

                    v_sec := v_sec + 1;
                END LOOP;                
                
            END LOOP;        
        
            v_sec := v_sec + 1;
            
        END LOOP;

        
    END LOOP;

    COMMIT;

end;