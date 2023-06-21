--
-- Creacion de Indice para columna tipo XMLTYPE
-- Si el XML tiene más de UN nodo detalle, entonces se deben
-- crear tantos "parametros" como detalles se deseen indexar.
--

SELECT * from DBA_xml_indexes;
select * from all_objects where object_name like '%XML%' order by created desc;
                                         
EXECUTE DBMS_XMLIndex.DropParameter ('xxcmx_wms_up_AllocRequest_prm');
EXECUTE DBMS_XMLIndex.DropParameter ('xxcmx_wms_up_Conteiners_prm');
DROP INDEX xxcmx.gvp_xml;

--
-- Creación de INDICE
--
CREATE INDEX xxcmx.gvp_xml 
ON xxcmx.xxcmx_wms_up_interface_all (PAYLOAD)
INDEXTYPE IS XDB.XMLIndex
PARAMETERS ('PATH TABLE    xxcmx_wms_up_path_tbl
             PIKEY INDEX   xxcmx_wms_up_pikey
             PATH ID INDEX xxcmx_wms_up_path_id
             VALUE INDEX   xxcmx_wms_up_value 
            ')
;

--
-- Creación de 1er parametro para el 1er DETALLE (Shipments Allocations)
--
BEGIN
    DBMS_XMLINDEX.RegisterParameter(
        paramname => 'xxcmx_wms_up_AllocRequest_prm',
        paramstr  => 'ADD_GROUP GROUP xxcmx_wms_up_AllocRequest
                        XMLTABLE xxcmx_Shipment_Header_1
                                 ''/Shipment/Details''
                        COLUMNS 
                             interface_id         number(15) path ''UserDef8''
                            ,AllocRequest_Virtual xmltype    path ''ShipmentDetail'' VIRTUAL
                      
                         XMLTABLE xxcmx_Alloc_Request
                                  ''//ShipmentAllocRequest''
                         PASSING AllocRequest_Virtual
                         COLUMNS
                                 InternalShipmentAllocNum number(15)   path ''InternalShipmentAllocNum''
                        ');
END;
/

--
-- Agregar los parametros al Indice
--
ALTER INDEX xxcmx.gvp_xml PARAMETERS ('PARAM xxcmx_wms_up_AllocRequest_prm');


--
-- Creación del 2do Parámetro para el 2do Detalle (Conteiners Details)
--
BEGIN
    DBMS_XMLINDEX.RegisterParameter(
        paramname => 'xxcmx_wms_up_Conteiners_prm',
        paramstr  => 'ADD_GROUP GROUP xxcmx_wms_up_Conteiners
                        XMLTABLE xxcmx_Shipment_Header_2
                                 ''/Shipment/Containers''
                        COLUMNS 
                             interface_id        number(15) path ''UserDef8''
                            ,Conteiners_Virtual  xmltype    path ''ShippingContainer'' VIRTUAL
                      
                         XMLTABLE xxcmx_Conteiners
                                  ''//ContainerDetails/ContainerDetail''
                         PASSING Conteiners_Virtual
                         COLUMNS
                                 InternalShipAllocNum number(15)   path ''InternalShipAllocNum''
                        ');
END;
/

--
-- Se agrega el Parámetro al Indice
--
ALTER INDEX xxcmx.gvp_xml PARAMETERS ('PARAM xxcmx_wms_up_Conteiners_prm');




                            