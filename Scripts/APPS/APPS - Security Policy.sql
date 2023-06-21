--
-- Ejemplo de Data Security Policy
-- 
-- Data security includes the mechanisms that control the access to and use of the database at the object level. 
-- Your data security policy determines which users have access to a specific schema object, and the specific types 
-- of actions allowed for each user on the object. For example, the policy could establish that user scott can issue 
-- SELECT and INSERT statements but not DELETE statements using the emp table. Your data security policy should also 
-- define the actions, if any, that are audited for each schema object.
--
-- Overall data security should be based on the sensitivity of data. If information is not sensitive, 
-- then the data security policy can be more lax. However, if data is sensitive, then a security policy 
-- should be developed to maintain tight control over access to objects.
--
-- http://docs.oracle.com/cd/B19306_01/network.102/b14266/apdvpoli.htm#i1008538
-- https://docs.oracle.com/database/121/DBFSG/data_security.htm#DBFSG99154 
-- http://www.dba-oracle.com/concepts/restricting_access.htm
--
SET SERVEROUTPUT ON


CREATE OR REPLACE PACKAGE GRP_Olimpo_sec AUTHID DEFINER AS
    --PROCEDURE set_pay_contexto;
    FUNCTION olimpo_check ( obj_schema VARCHAR2, obj_name VARCHAR2 ) RETURN VARCHAR2;
    PRAGMA restrict_references ( olimpo_check, wnds );
END;
/

SET ARRAYSIZE 1
SHOW ERR

CREATE OR REPLACE PACKAGE BODY GRP_Olimpo_Sec 
AS

-- este debería ir en un trigger como logon o algo así 
-- para inicializar el contexto
PROCEDURE set_pay_contexto 
IS
BEGIN    
    
    IF fnd_global.user_name LIKE 'EXT-GVARGAS' THEN
        DBMS_SESSION.SET_CONTEXT('GRP_Olimpo_Sec','PAY_USER', 'DEVELOPER');
    ELSIF fnd_global.user_name  IS NULL THEN
        DBMS_SESSION.SET_CONTEXT('GRP_Olimpo_Sec','PAY_USER', 'APPS');
    END IF;
END set_pay_contexto;


FUNCTION Olimpo_Check ( obj_schema VARCHAR2, obj_name VARCHAR2 ) RETURN VARCHAR2 
AS
        d_predicate    VARCHAR2 (2000);
        user_context   VARCHAR2 (32);        
        v_olimpo        varchar2(15);
BEGIN    
    
    --set_pay_contexto;
    --user_context   := sys_context ('grp_olimpo_sec', 'PAY_USER');
    
    SELECT SYS_CONTEXT ('USERENV', 'SESSION_USER') 
    into user_context
    FROM DUAL;        
    
    SELECT SYS_CONTEXT ('USERENV', 'CLIENT_IDENTIFIER')
    INTO v_olimpo
    FROM DUAL;
        
        IF v_olimpo = 'OLIMPO' THEN            
                d_predicate   := ' emisor_rfc IN (''CGP971212L56'')';  
                
        ELSIF v_olimpo = 'MORTAL' THEN
            d_predicate   := ' emisor_rfc NOT IN (''CGP971212L56'')';
            
        ELSIF v_olimpo = 'TODO' THEN
            d_predicate   := ' 1=1'; 
            
        ELSE
                IF user_context = 'NEXT_ACCNT' THEN
                    d_predicate   := ' 1=1'; 
                ELSIF  user_context IN ('BOLINF', 'APPS') THEN   
                    d_predicate   := ' emisor_rfc NOT IN (''CGP971212L56'')';
                END IF;                  
        END IF;        
       
    dbms_output.put_line (d_predicate);    
    
    RETURN d_predicate;
        
END Olimpo_Check;
END;
/

SHOW ERR

-- 
-- Ejecutar con APPS
--
/*
BEGIN
dbms_rls.add_policy(
    'next_accnt','GRP_PAY_TMBRDO_RESPONSES_T','OLIMPO_POLICY',
    'next_accnt','GRP_OLIMPO_SEC.Olimpo_CHECK',
    'SELECT,INSERT,UPDATE,DELETE'
    );
END; 
/

BEGIN
dbms_rls.drop_policy (object_schema => 'next_accnt',
                        object_name => 'GRP_PAY_TMBRDO_RESPONSES_T',
                        policy_name => 'OLIMPO_POLICY'
                        );
END;
/

DBMS_RLS.ENABLE_POLICY (
   object_schema => 'next_accnt',
   object_name   => 'GRP_PAY_TMBRDO_RESPONSES_T',
   policy_name   => 'OLIMPO_POLICY'
   enable        => TRUE
 );
/
*/

 