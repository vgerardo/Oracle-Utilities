SELECT * from DBA_xml_indexes;
select * from all_objects  order by created desc;
                         
DROP INDEX xxcmx.gvp_xml_indx_2;

CREATE INDEX xxcmx.gvp_xml_indx_2 
ON xxcmx.xxcmx_wms_up_interface_all (PAYLOAD)
INDEXTYPE IS XDB.XMLIndex
PARAMETERS ('PATH TABLE    xxcmx_wms_up_path_tbl
             PIKEY INDEX   xxcmx_wms_up_pikey
             PATH ID INDEX xxcmx_wms_up_path_id
             VALUE INDEX   xxcmx_wms_up_value
             
            GROUP xxcmx_wms_up_AllocRequest
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
                        '
                );

ALTER INDEX xxcmx.gvp_xml_indx_2 
PARAMETERS (
                'ADD_GROUP GROUP xxcmx_wms_up_Conteiners
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
                        '
                );
                