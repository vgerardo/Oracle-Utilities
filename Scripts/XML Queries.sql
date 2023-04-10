
create table my_xml (code varchar2(10), payload xmltype);

SELECT code
    ,XMLQuery ('declare default element namespace "http://www.manh.com/ILSNET/Interface"; (::)
                  //Shipments/Shipment/Containers/ShippingContainer/ContainerDetails/ContainerDetail/Quantity'
                  Passing payload Returning Content
                  )       nodo_shipment
                          
    ,XMLCAST (
        XMLQuery ('declare default element namespace "http://www.manh.com/ILSNET/Interface"; (::)
                  fn:sum(//Shipments/Shipment/Containers/ShippingContainer/ContainerDetails/ContainerDetail/Quantity/text())'
                  Passing payload Returning Content
                ) AS NUMBER
            ) nodo_Containers
FROM my_xml
WHERE 1=1
 AND XMLExists ('declare default element namespace "http://www.manh.com/ILSNET/Interface"; (::)
                 //Shipment (::)
                 [UserDef11 = $MyValue] 
                 '
                 Passing payload
                       , 'OM/SO/XXCMX_WMS_PLANTS_MAIN' as "MyValue" 
                 )
;



SELECT int.id, xh.ShipmentId, xd.*
FROM xxcmx.xxcmx_wms_dw_interface_all int
   , XMLTable (
                XMLNameSpaces (default 'http://www.manh.com/ILSNET/Interface'),
                '//Shipments/Shipment[UserDef11=$P_Process]'
                --[ShipmentId=$P_ShipmentId]
                --'let $i := //Shipments/Shipment
                --where $i/UserDef11=$MyValue 
                --return $i/Details/ShipmentDetail'
               PASSING int.payload
                    , 'WSH|XXCMX_WSH_SHIP_CONFIRM_WMS|XXCMX_WSH_PICK_CONFIRM_WMS' as "P_Process"
                    -- ,'163147610' as "P_ShipmentId"
               COLUMNS 
                     ShipmentId varchar2(50)    path 'ShipmentId'
                    ,xml_detail xmltype         path 'Details/ShipmentDetail'
               ) xh
    ,XMLTable (
                XMLNameSpaces (default 'http://www.manh.com/ILSNET/Interface'),
                '/ShipmentDetail'
               PASSING xh.xml_detail
               COLUMNS 
                      detail_id number(15) path 'ErpOrderLineNum'
                     ,item_num  varchar2(50) path 'SKU/Item'
               ) xd               

where xd.item_num = '19A0427702'
;


--UpdateXML, ya está obsoleto
update xxcmx_wms_up_interface_all set
payload = UpdateXML (payload, '/Shipment/UserDef11/text()', 'WSH|XXCMX_WSH_SHIP/PICK_CONFIRM_WMS')
where id = 304
;


--Ahora debe ser XMLQuery... pero tá feo :(
update xxcmx_wms_up_interface_all set
payload = XMLQuery ('copy $i := $p1 modify
                     (for $j in $i/Shipment/UserDef11
                     return replace value of node $j with $p2)
                     return $i' 
                     PASSING payload as "p1"
                            ,'WSH|XXCMX_WSH_SHIP/PICK_CONFIRM_WMS' as "p2" 
                     returning content
                     )
where id = 304
;

