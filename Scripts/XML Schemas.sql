
--
--El archivo se debe subir a directorio del FTP:
--/u01/oracle/DEV/inbound/xxcmxcarga/
--/u01/oracle/LANDOEA/inbound/xxcmxcarga/
--

SELECT *
FROM DBA_DIRECTORIES
WHERE directory_name like 'XXCMX_IN_FILES'
;

BEGIN
DBMS_XMLSCHEMA.registerSchema(
                    SCHEMAURL => 'InterfaceEntity.xsd',
                    SCHEMADOC => bfilename('XXCMX_IN_FILES','InterfaceEntity.xsd'),
                    LOCAL     => TRUE,
                    GENTYPES  => FALSE, 
                    GenTables => FALSE
                    );
END;
/

BEGIN
    DBMS_XMLSCHEMA.registerSchema(
                    SCHEMAURL => 'Item.xsd',
                    SCHEMADOC => bfilename('XXCMX_IN_FILES','Item.xsd'),
                    LOCAL     => TRUE,
                    GENTYPES  => FALSE, 
                    GenTables => FALSE
                    );
END;
/


BEGIN
 DBMS_XMLSCHEMA.registerSchema(
                    SCHEMAURL => 'ItemDownload.xsd',
                    SCHEMADOC => bfilename('XXCMX_IN_FILES','ItemDownload.xsd'),
                    LOCAL     => TRUE,
                    GENTYPES  => FALSE, 
                    GenTables => FALSE
                    );
END;
/


BEGIN
    DBMS_XMLSCHEMA.registerSchema(
                    SCHEMAURL => 'SerialNumber.xsd',
                    SCHEMADOC => bfilename('XXCMX_IN_FILES','SerialNumber.xsd'),
                    LOCAL     => TRUE,
                    GENTYPES  => FALSE, 
                    GenTables => FALSE
                    );
END;
/

BEGIN
    DBMS_XMLSCHEMA.registerSchema(
                    SCHEMAURL => 'ContainerType.xsd',
                    SCHEMADOC => bfilename('XXCMX_IN_FILES','ContainerType.xsd'),
                    LOCAL     => TRUE,
                    GENTYPES  => FALSE, 
                    GenTables => FALSE
                    );
END;
/

BEGIN
    DBMS_XMLSCHEMA.registerSchema(
                    SCHEMAURL => 'Address.xsd',
                    SCHEMADOC => bfilename('XXCMX_IN_FILES','Address.xsd'),
                    LOCAL     => TRUE,
                    GENTYPES  => FALSE, 
                    GenTables => FALSE
                    );
END;
/

BEGIN
    DBMS_XMLSCHEMA.registerSchema(
                    SCHEMAURL => 'ShippingDownload.xsd',
                    SCHEMADOC => bfilename('XXCMX_IN_FILES','ShippingDownload.xsd'),
                    LOCAL     => TRUE,
                    GENTYPES  => FALSE, 
                    GenTables => FALSE
                    );
END;
/

BEGIN
    DBMS_XMLSCHEMA.registerSchema(
                    SCHEMAURL => 'ShippingSingleDW.xsd',
                    SCHEMADOC => bfilename('XXCMX_IN_FILES','ShippingSingleDW.xsd'),
                    LOCAL     => TRUE,
                    GENTYPES  => FALSE, 
                    GenTables => FALSE
                    );
END;
/

EXEC DBMS_XMLSCHEMA.deleteSchema('ShippingSingleDW.xsd',DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
EXEC DBMS_XMLSCHEMA.deleteSchema('ShippingDownload.xsd',DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
EXEC DBMS_XMLSCHEMA.deleteSchema('Address.xsd',         DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
EXEC DBMS_XMLSCHEMA.deleteSchema('SerialNumber.xsd',    DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
EXEC DBMS_XMLSCHEMA.deleteSchema('ContainerType.xsd',   DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
EXEC DBMS_XMLSCHEMA.deleteSchema('ItemDownload.xsd',    DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
EXEC DBMS_XMLSCHEMA.deleteSchema('Item.xsd',            DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
EXEC DBMS_XMLSCHEMA.deleteSchema('InterfaceEntity.xsd', DBMS_XMLSCHEMA.DELETE_CASCADE_FORCE);
/

SELECT * FROM ALL_xml_schemas;

--
-- Test It
-- Tuve que quitar esto <<xsi:schemaLocation="xxcmx_wms_dw_ItemDownload.xsd">> 
-- porque me marcaba error :)
--
SET SERVEROUTPUT ON
DECLARE
v_str varchar2(4000) := 
'<?xml version="1.0" encoding="UTF-8"?>
<WMWROOT xmlns="http://www.manh.com/ILSNET/Interface" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <WMWDATA>
    <Items>
      <Item>
        <ItemClass>xxxxx</ItemClass>
      </Item>
    </Items>
  </WMWDATA>
</WMWROOT>
';

v_xml XMLType ;

BEGIN
    v_xml := XMLType (v_str, 'ItemDownload.xsd');

    --v_xml := XMLType (v_str);
    
    IF v_xml.isSchemaValid ('ItemDownload.xsd') = 0 THEN
        DBMS_OUTPUT.put_line ('0 = No es Valido' );
        v_xml.schemaValidate;
    ELSE
        DBMS_OUTPUT.put_line ('1 = Valido' );
    END IF;
END;
/


select id
     , payload
     , XmlIsValid (payload,'ShippingDownload.xsd') Valid_Code
     , DECODE (
              --(payload).isSchemaValid ('ShippingSingleDW.xsd')
               (payload).isSchemaValid ('ShippingDownload.xsd')
               ,0, 'NO ES VALIDO'
               ,1, 'SI ES VALIDO'
               ) Valid_Message
    , XMLQuery ('declare namespace ns="http://www.manh.com/ILSNET/Interface"; (::)
                 //ns:Shipment' 
                 passing payload returning content) ship
from xxcmx.xxcmx_wms_dw_interface_all 
WHERE 1=1
  and created_by IN (19282, 21596)  --este soy YO
--  and creation_date > sysdate - 1
--  and id in (23)
ORDER BY creation_date desc
;