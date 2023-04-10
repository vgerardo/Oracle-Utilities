
--drop package XXCMX_MY_WEBADI_001;
--create table XXCMX_MY_WEBADI (p1 varchar2(50), p2 varchar2(50));

---------------------------------------------------------
-- Ejemplo de PACKAGE
CREATE OR REPLACE PACKAGE XXCMX_MY_WEBADI_001
AS
PROCEDURE Enter_Data (
                p_parametro_1 varchar2
                ,p_parametro_2 varchar2
            );
END;
/

CREATE OR REPLACE PACKAGE BODY XXCMX_MY_WEBADI_001
AS
PROCEDURE Enter_Data (
                p_parametro_1 varchar2
                ,p_parametro_2 varchar2
            )
IS
BEGIN
    INSERT into XXCMX_MY_WEBADI VALUES (p_parametro_1, p_parametro_2);
   -- raise_application_error(-20001,'Así se mandan los errores: ' || SQLERRM );
EXCEPTION
    WHEN OTHERS THEN
        raise_application_error(-20001,'Así se mandan MAS errores: ' || SQLERRM );
END Enter_Data;
END;
/
---------------------------------------------------------

select 
--'SELECT * FROM '||lower(TABLE_NAME)||' WHERE last_updated_by=19282 ORDER BY last_update_date DESC; ' 
'DELETE '||lower(TABLE_NAME)||' WHERE last_updated_by=19282;'
from all_tables where table_name like 'BNE_%'
;

SELECT * FROM BNE_ATTRIBUTES 
WHERE attribute1 like 'FUNCTION'
;

SELECT * FROM BNE_ATTRIBUTES        order by last_update_date desc; 
select * from BNE_LAYOUT_COLS       order by last_update_date desc; 
SELECT * FROM BNE_INTERFACE_COLS_B  order by last_update_date desc; 
SELECT * FROM BNE_INTERFACE_COLS_TL order by last_update_date desc; 
SELECT * FROM BNE_LAYOUTS_B         order by last_update_date desc; 
SELECT * FROM BNE_LAYOUT_BLOCKS_B   order by last_update_date desc; 
select * from bne_integrators_b     where integrator_code like 'XXCMX%CCP%'; --order by last_update_date desc;
select * from bne_integrators_tl order by last_update_date desc;
select * from bne_interfaces_b      WHERE integrator_code = 'XXCMX_WSH_CCP_CMX_DET_XINTG' ;order by last_update_date desc;
select * from bne_interfaces_tl order by last_update_date desc;

select * from bne_attributes where ATTribute_code like 'XXCMX_WSH_CCP_CMX_DET__UP_A0';

--
-- Integrador asociado a una Función o Proceure
--
select bit.user_name Integrator_User_Name
     , ba.attribute1, ba.attribute2 
from bne_integrators_tl bit
   , bne_interfaces_b   bib
   , bne_param_lists_b  bpl
   , bne_attributes     ba
where 1=1
  and bit.integrator_code        = bib.integrator_code
  and bib.upload_param_list_code = bpl.param_list_code
  and bpl.attribute_code         = ba.attribute_code
  and bit.language               = 'ESA'
  --and bit.user_name like 'XXCMX WSH CCP Comex Detail'
  and upper(ba.attribute2) like '%CARGAR_WEB_ADI'
  ;

    , bne_attributes; where interface_name like 'CARGAR_WEB_ADI';

--



SELECT * FROM BNE_COMPONENTS_B WHERE LENGTH(REPLACE(COMPONENT_CODE,'_XX_'))=30;
SELECT * FROM BNE_MAPPINGS_B order by last_update_date desc; 
SELECT * FROM BNE_SECURITY_RULES;
---------------------------------------------------------
LOVS
---------------------------------------------------------
--Validation Type = TABLE
--Validation Entity = 
(SELECT hou.organization_id, mp.organization_code, hou.name org_name FROM hr_organization_units hou, mtl_parameters mp WHERE mp.organization_id = hou.organization_id) ORG
--Where Clause
org.organization_id IN (SELECT organization_id FROM org_access WHERE responsibility_id = $env$.respid )
--Lov Type = Pop List

--Variables de Ambiente
--OAUSER.ID


SET SERVEROUTPUT ON
DECLARE
v_result number;
BEGIN

    BNE_INTEGRATOR_UTILS.DELETE_LAYOUT   (P_APPLICATION_ID  => ,
                                            P_LAYOUT_CODE   => 
                                        );


    v_result := BNE_INTEGRATOR_UTILS.delete_interface (
                                            p_application_id => 231,
                                            p_interface_code => 'XXCMX_ONT_CARGA_ACUERD_INTF1'
                                            );
    DBMS_OUTPUT.put_line ('v_result = ' || v_result);
    
    v_result := BNE_INTEGRATOR_UTILS.delete_integrator (
                                            p_application_id => 231,
                                            p_integrator_code => 'XXCMX_ONT_CARGA_ACUERD_INTF1'
                                            );
END;
/

