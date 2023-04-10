
--
-- Direcciones
--
SELECT location_xid, location_name, city, province, postal_code, country_code3_gid
FROM glogowner.LOCATION
WHERE domain_name like 'PPGCOMEX'
  -------- Parametro ---------
  AND location_xid like 'OPL3-TPS030405175'
  -- -------------------------
;


select shipment_gid, shipment_xid, num_order_releases, servprov_gid
from glogowner.SHIPMENT 
where 1=1
  --and domain_name like 'PPGCOMEX%KHM%'
 and shipment_xid like '26046114-T'
  --AND num_order_releases > 80
order by  num_order_releases 
  ;

--
-- Lineas de Order Release con Items
--
SELECT o.order_release_gid, o.attribute20, OL.packaged_item_gid
FROM glogowner.order_release        o
    ,glogowner.order_release_line   ol
    ,glogowner.packaged_item        pi
WHERE 1=1
  and o.order_release_gid = ol.order_release_gid (+)
  and ol.packaged_item_gid = pi.packaged_item_gid (+) --'PPGCOMEX.TARIMA PLASTICA SCHOELLER GRIS'
  --AND o.domain_name LIKE 'PPGCOMEX'
  --and indicator = 'G'
  --AND o.order_release_gid LIKE 'PPGCOMEX%FOL1%'
  AND o.attribute20 like '%RECOLECCION%' --Motivo_Salida
;

select ol.order_release_gid, pi.packaged_item_xid
     ,sul.item_package_count, sul.weight, sul.weight_uom_code
from glogowner.order_release_line   ol
    ,glogowner.SHIP_UNIT_LINE       sul
    ,glogowner.SHIP_UNIT            su
    ,glogowner.packaged_item        pi
where 1=1
  and ol.order_release_gid = su.order_release_gid
  and ol.order_release_line_gid = sul.order_release_line_gid
  and su.ship_unit_gid = sul.ship_unit_gid
  and ol.packaged_item_gid = pi.packaged_item_gid
  -- 
  -- Parametro
  and su.order_release_gid = 'PPGCOMEX/KROMA/KMX.161713'
;

--
-- https://docs.oracle.com/cd/E26401_01/doc.122/e48827/T441621T441627.htm
--


-- 
--Pedidos de Venta(ebs) vs Order Base(otm)
--
--oe_order_lines_all.line_id                    =  ob_line.ob_line_gid + DOMINIO
--oe_order_headers_all.orig_sys_document_ref    =  ob_refnum.ob_refnum_value                          
--
select * from glogowner.OB_LINE       WHERE ob_line_xid in ('24196158','24196159') ;
select * from glogowner.OB_REFNUM     WHERE order_base_gid = 'PPGCOMEX/AGA/AGA.28057';
select * from glogowner.OB_ORDER_BASE WHERE order_base_gid = 'PPGCOMEX/AGA/AGA.28057' ;



SELECT * 
FROM glogowner.ORDER_RELEASE_REFNUM   
WHERE order_release_gid = 'PPGCOMEX/KROMA/KMX.REM1'
;

SELECT * FROM glogowner.ORDER_RELEASE_LINE     
WHERE order_release_gid = 'PPGCOMEX/KROMA/KMX.22020011';


--
--Stops con Releases
--
select ssd.shipment_gid
     , ssul.order_release_gid
     , ss.stop_num
     , ss.location_gid
     , to_char(ss.planned_departure, 'YYYY-MM-DD HH24:MI:SS') Departure_Date_Str
     , to_char(ss.planned_arrival, 'YYYY-MM-DD HH24:MI:SS') Arrival_Date_Str
from glogowner.SHIPMENT_STOP    ss
    ,glogowner.SHIPMENT_STOP_D  ssd
    ,glogowner.S_SHIP_UNIT      ssu
    ,glogowner.S_SHIP_UNIT_LINE ssul
where 1=1
  and ss.shipment_gid     = ssd.shipment_gid
  and ss.stop_num         = ssd.stop_num
  and ssd.s_ship_unit_gid = ssu.s_ship_unit_gid
  and ssu.s_ship_unit_gid = ssul.s_ship_unit_gid
  --
  -- Parametros
  --
  and ssd.stop_num           = :P_STOP_NUM 
  and ssd.shipment_gid    like :P_SHIPMENT_GID --'PPGCOMEX/KROMA/KMX.100284205' 100284205
  --
--GROUP BY ssd.shipment_gid
;



--
-- Viajes-Trips(ebs)  vs Embarque-Shipments(otm)
--
-- SHIPMENT.shipment_gid  = WSH_TRIPS.name 
-- SHIPMENT.shipment_gid  = WSH_NEW_DELIVERIES.attribute1 (Agregar "PPGCOMEX/")
--
select * from glogowner.VIEW_SHIPMENT_ORDER_BASE    ;
select * from glogowner.VIEW_SHIPMENT_ORDER_RELEASE where shipment_gid = 'PPGCOMEX/KROMA/KHM.150043302';
select * from glogowner.SHIPMENT        where shipment_gid LIKE 'PPGCOMEX/KROMA/KMX.%';
select * from glogowner.SHIPMENT_REFNUM where shipment_gid like 'PPGCOMEX/KROMA/KMX.100284205';
select * from glogowner.SHIPMENT_STATUS where shipment_gid like 'PPGCOMEX/KROMA/KMX.100284205';


-- Item
select * 
from glogowner.ITEM 
WHERE 1=1
  and ITEM_GID IN (
'PPGCOMEX.CAJA PLASTICA'
,'PPGCOMEX.CINCHOS'
,'PPGCOMEX.TARIMA EXPORTACION'
,'PPGCOMEX.CHEP'
,'PPGCOMEX.RELLENO'
,'PPGCOMEX.BLANCA'
,'PPGCOMEX.BOLSA DE AIRE CHICA'
,'PPGCOMEX.BOLSA DE AIRE GRANDE'
,'PPGCOMEX.BLANCA 4 ENTRADAS'
,'PPGCOMEX.AGLUTINADOS'
,'PPGCOMEX.FUNDAS'
,'PPGCOMEX.CAJA AZUL'
,'PPGCOMEX.CINTURONES ANARANJADOS'
,'PPGCOMEX.TARIMA PLASTICA SCHOELLER GRIS'  
);
  
select *
from glogowner.packaged_item
where domain_name like 'PPGCOMEX'
  and description like '%TARIMA%'
;

--
--Deliveries(ebs) vs Order Release(otm) 
--
--ORDER_RELEASE.order_release_gid              = WSH_NEW_DELIVERIES.name (agregar DOMINIO)
--ORDER_RELEASE_LINE.order_release_line_gid    = WSH_DELIVERY_ASSIGNMENTS.delivery_detail_id (agregar DOMINIO)
--
SELECT s.shipment_gid, o.order_release_gid, o.attribute20, o.plan_to_location_gid, o.dest_location_gid
 FROM glogowner.ORDER_RELEASE                o
   , glogowner.VIEW_SHIPMENT_ORDER_RELEASE  s
   , glogowner.LOCATION l
WHERE 1=1
  and o.order_release_gid = s.order_release_gid
  and o.domain_name like 'PPGCOMEX%'
  and o.dest_location_gid = l.location_gid 
  --and o.order_release_xid = 'REF1600763'
  and s.shipment_gid like 'PPGCOMEX/KROMA/KHM.150043302'
;



-- ***********************************************
--
-- Order Release vs Shipment
--
-- ***********************************************
SELECT o.order_release_gid
     , o.order_release_xid
     , o.source_location_gid
     , o.dest_location_gid
     , round(o.total_weight,4)              o_total_weight
     , round(o.total_net_weight,4)          o_total_net_weight
     , round(o.total_net_weight_base,4)     o_total_net_weight_base
     , round(o.total_weight_base,2)         o_total_weight_base
     , o.total_weight_uom_code     
     , o.total_item_package_count
     , o.indicator                          o_indicador
     , o.total_ship_unit_count
     , o.attribute1
     , o.attribute4
     , o.attribute8
     , v.shipment_gid
     , s.transport_mode_gid
     , round(s.planned_cost,2)              s_planned_cost
     , round(s.planned_cost_base,2)         s_planned_cost_base
     , s.planned_cost_currency_gid
     , s.t_actual_cost_currency_gid
     , s.shipment_type_gid
     , s.shipment_released
     , s.indicator                          s_indicador
     , s.num_order_releases
     , s.num_stops
     , s.attribute20                        s_zona_embarque     
     , o.attribute20
     , s.is_hazardous
     
FROM glogowner.ORDER_MOVEMENT  v  
     --glogowner.VIEW_SHIPMENT_ORDER_RELEASE v
    ,glogowner.SHIPMENT                     s
    ,glogowner.ORDER_RELEASE                o
WHERE v.shipment_gid = s.shipment_gid
  and o.order_release_gid = v.order_release_gid 
  --
  -- Parametros
  --
  and v.shipment_gid like 'PPGCOMEX/KROMA/KHM.150043302'
  --and o.order_release_xid like '161713'
  --AND o.attribute20 like '%ACCESORIOS%'
  -- 
;


--
-- Salida: Fecha y Hora 
--
SELECT to_char(ies.eventdate, 'YYYY-MM-DD HH24:MI:SS') Event_Date_Str
FROM glogowner.ss_status_history    ssh
    ,glogowner.ie_shipmentstatus              ies
    ,glogowner.bs_status_code                 bsc
WHERE 1=1
 and ssh.i_transaction_no = ies.i_transaction_no
 and ies.status_code_gid  = bsc.bs_status_code_gid
 --
 -- Parametros
 --
 and ssh.shipment_stop_num    = :P_STOP_NUM --1
 and bsc.bs_status_code_xid   = :P_EVENT --'SALIDA ANDEN' 'SALIDA INSTALACIONES'
 and ssh.shipment_gid       like :P_SHIPMENT_GID --'PPGCOMEX/KROMA/KMX.100284205'
 ---
;


--
-- Embarque con Deliveries vs Stops
--
select ssd.shipment_gid
     , ssul.order_release_gid
     , ss.stop_num
     , ss.location_gid
     , to_char(ss.planned_departure, 'YYYY-MM-DD HH24:MI:SS') Planned_Departure_Str
     , to_char(ss.planned_arrival, 'YYYY-MM-DD HH24:MI:SS') Planned_Arrival_Str
from glogowner.SHIPMENT_STOP    ss
    ,glogowner.SHIPMENT_STOP_D  ssd
    ,glogowner.S_SHIP_UNIT      ssu
    ,glogowner.S_SHIP_UNIT_LINE ssul
where 1=1
  and ss.shipment_gid     = ssd.shipment_gid
  and ss.stop_num         = ssd.stop_num
  and ssd.s_ship_unit_gid = ssu.s_ship_unit_gid
  and ssu.s_ship_unit_gid = ssul.s_ship_unit_gid
  --
  -- Parametros
  --
  and ssd.stop_num           = :P_STOP_NUM 
  and ssd.shipment_gid    like :P_SHIPMENT_GID --'PPGCOMEX/KROMA/KMX.100284205' 100284205
  --
 GROUP BY ssd.shipment_gid
     , ssul.order_release_gid
     , ss.stop_num
     , ss.location_gid
     , to_char(ss.planned_departure, 'YYYY-MM-DD HH24:MI:SS')
     , to_char(ss.planned_arrival, 'YYYY-MM-DD HH24:MI:SS')
ORDER BY ss.stop_num
;


-- BUSCAR "PLANNED COST"
-- 
--Buy Shipment  -> Pestaña Finanzas
--
SELECT 
       cost
     , cost_base
     , rate_geo_cost_group_gid
     , shipment_cost_seqno
     , sc.cost_gid
FROM glogowner.SHIPMENT_COST    sc
    ,glogowner.COST_TYPE        ct
WHERE 1=1
  and sc.cost_type = ct.cost_type_gid
  and ct.cost_type_gid = 'B' --Base
  and shipment_gid like :P_SHIPMENT_GID -- 'PPGCOMEX/KROMA/KMX.100284205'
;




SELECT pkg.description
      , pkg.attribute2 numero_guia
      , pkg.attribute3 grupo_empaque
      , pkg.attribute4 desc_mercancia
      , pkg.attribute6 un_descripcion
      , pkg.attribute5 cant_ltd
      , pkg.attribute_number1 factor
      , pkg.is_hazardous
FROM glogowner.ITEM             itm
    ,glogowner.PACKAGED_ITEM    pkg
WHERE itm.domain_name = 'PPGCOMEX'
  and itm.item_gid = pkg.item_gid
  and pkg.attribute6 is not null
  -- -----------------------------------
  -- PARAMETRO
--  and item_xid like '19A1402439'  
  -- -----------------------------------
 ;




--
-- Otros
--

select * from glogowner.I_TRANSMISSION where domain_name like 'PPGCOMEX';
select * from glogowner.I_TRANSACTION where element_name not like 'TenderOffer';
select * from glogowner.EXTERNAL_SYSTEM WHERE external_system_gid = 'PPGCOMEX.INTERFACE_ACTUALSHIPMENT_R12';
select * from glogowner.EXTERNAL_SYSTEM_OUT_XML WHERE external_system_gid = 'PPGCOMEX.INTERFACE_ACTUALSHIPMENT_R12';
select * from glogowner.OUT_XML_PROFILE_CHILD WHERE out_xml_profile_gid = 'PPGCOMEX.XXCMX_XML_ACTUALSHIPMENTR12';
select * from glogowner.OUT_XML_PROFILE_D WHERE out_xml_profile_gid = 'PPGCOMEX.XXCMX_XML_ACTUALSHIPMENTR12';
select * from glogowner.OUT_XML_PROFILE_XPATH WHERE out_xml_profile_gid = 'PPGCOMEX.XXCMX_XML_ACTUALSHIPMENTR12';

select * from glogowner.AGENT_ACTION_DETAILS;

select * from glogowner.INT_SAVED_QUERY 
--where query_name like 'SHIPMENT%'
;


select * from glogowner.WEB_SERVICE WHERE WEB_SERVICE_GID = 'PPGCOMEX.WS_INTERFACE_PLANNEDSHIPMENT';;
--http://www.comex.com/PAI/ProducFabricEntregPdtos/ws/SDasEmbarqueOTM
select * from glogowner.WEB_SERVICE_ENDPOINT WHERE WEB_SERVICE_GID = 'PPGCOMEX.WS_INTERFACE_PLANNEDSHIPMENT';;
--http://172.17.100.122:8011/PAI/ProducFabricEntregPdtos/ws/SDasEmbarqueOTM
select * from glogowner.WEB_SVC_OPERATION_PARAM WHERE WEB_SERVICE_GID = 'PPGCOMEX.WS_INTERFACE_PLANNEDSHIPMENT';
