
--
-- Order Management Super User
-- Shipping -> Transactions -> Search For (Deliveries) -> From Delivery Name=10961737 -> Find
--


--
-- Order Management Super User -> Shipping -> Transactions -> 
--      Search for: (*)Trips ->  From Trip Name= KROMA/KMX.100284205
--
SELECT  trip.name "Trip Name"
       ,wnd.delivery_id 
       ,wnd.name "Delivery Name"
       ,wnd.initial_pickup_location_id
       ,wnd.ultimate_dropoff_location_id
       ,wts_up.stop_sequence_number "PickUp Sequence", wts_up.stop_location_id "PIckUp Location", to_char(wts_up.planned_arrival_date,'YYYY-MM-DD HH24:MI:SS') "Pick UP Date"
       ,wts_off.stop_sequence_number "PickOFF Sequence", wts_off.stop_location_id "Drop OFF Stop Location", to_char(wts_off.planned_arrival_date,'YYYY-MM-DD HH24:MI:SS') "Drop OFF Date"
       , wts_off.departure_gross_weight, wts_off.weight_uom_code
       ,wnd.ultimate_dropoff_date
       ,wnd.customer_id
       ;
       SELECT trip.*
 FROM 
     wsh.wsh_new_deliveries  wnd
    ,wsh.wsh_delivery_legs   leg
    ,wsh.wsh_trips           trip
    ,wsh.wsh_trip_stops      wts_up
    ,wsh.wsh_trip_stops      wts_off
WHERE 1=1
    and wnd.delivery_id      = leg.delivery_id
    AND leg.pick_up_stop_id  = wts_up.stop_id
    AND leg.drop_off_stop_id = wts_off.stop_id
    AND wts_up.trip_id       = trip.trip_id
    AND wnd.delivery_type    = 'STANDARD'
    --
    and trip.name            like 'KROMA%'
  --  and wnd.name             = '22033769'
    --
ORDER BY 2    
    ;



SELECT ooh.*
FROM wsh.wsh_new_deliveries wnd
    ,wsh.wsh_delivery_assignments wda
    ,wsh.wsh_delivery_details wdd
    ,ont.oe_order_headers_all ooh
    ,ont.oe_order_lines_all ool
    ,apps.xxcmx_inv_org_definitions_v org
    ,inv.mtl_system_items_b msi                    
WHERE 1 = 1
     AND wnd.delivery_id                = wda.delivery_id(+)
     AND wda.delivery_detail_id         = wdd.delivery_detail_id(+)
     AND wdd.inventory_item_id          = msi.inventory_item_id(+)
     AND wdd.organization_id            = msi.organization_id(+)
     AND wnd.organization_id            = org.organization_id
     AND wdd.source_header_id           = ooh.header_id
     AND wdd.source_line_id             = ool.line_id
     AND ooh.header_Id                  = ool.header_id
     AND wnd.status_code                IN ('OP','CL')
     AND wdd.released_status            IN ('Y','C') --Interfaced C
     AND wnd.delivery_id                = 10382038
    --AND wnd.attribute1 = SUBSTR(p_dominio, INSTR(p_dominio,'/', 1, 1)+1) || '.' || TO_CHAR(p_shipment_id)
    --AND org.organization_code  = SUBSTR(p_dominio, INSTR(p_dominio,'/', 1, 2)+1) 
;


SELECT *
FROM wsh_new_deliveries
WHERE delivery_id = 10382038
;


--
-- Relación Delivery vs Pedido Venta
-- Nota: Un Pedido Venta puede tener más de Un Delivery (1-N)
--       Pero un Delivery no deberia tener varios Pedidos de Venta.
--
--SELECT delivery_id, COUNT(*)
--FROM (
--
SELECT  null id
      , hp.party_name, hca.account_number
      , null siglas
      , ooh.attribute2 calle
      --, ooh.attribute4 colonia
      , null ciudad
      , null estado
      , ooh.attribute6 cp
      , null full_address
      , wda.delivery_id, ooh.order_number, ooh.context
FROM wsh.wsh_delivery_assignments   wda
   , wsh.wsh_delivery_details       wdd
   , ont.oe_order_headers_all       ooh
   , hz_cust_accounts               hca   
   , hz_parties                     hp   
WHERE 1=1
  and wda.delivery_detail_id= wdd.delivery_detail_id
  AND wdd.source_header_id  = ooh.header_id (+)
  and ooh.sold_to_org_id    = hca.cust_account_id (+)
  and hca.party_id          = hp.party_id (+)
  --and ooh.context           = 'MX_FOLIO/ENTREGAS_FINALES'  
  --
  and wda.delivery_id       = 15397843
  --
GROUP BY hca.account_number, hp.party_name
      , ooh.attribute2, ooh.attribute4, ooh.attribute6
      , wda.delivery_id, ooh.order_number, ooh.context

--)
--GROUP BY delivery_id
--HAVING COUNT(*)>1
;



--
-- Detalle de las Lineas
--
SELECT *
FROM wsh_dlvy_deliverables_v wdv
WHERE  1=1
  and wdv.delivery_id = 10777816
  --and wdv.ship_from_location_id = 164
;
 
select*
from wsh_delivery_stops_v
where 1=1
AND delivery_id = 10777816 
ORDER BY stop_sequence_number
;

select org_id, ship_from_location_id, count(*)
--org_id
from wsh.wsh_delivery_details wdd 
--where ship_from_location_id = 165
group by org_id, ship_from_location_id
order by 3
;

select wnd.initial_pickup_location_id, wnd.ultimate_dropoff_location_id, wnd.carrier_id 
,wdd.source_header_type_name, wdd.carrier_id, wdd.hazard_class_id, wdd.ship_from_location_id, wdd.ship_to_location_id, wdd.deliver_to_location_id
FROM wsh.wsh_new_deliveries wnd 
    ,wsh.wsh_delivery_assignments wda 
    ,wsh.wsh_delivery_details wdd 
WHERE 1=1
 and wnd.delivery_id = wda.delivery_id
 and wda.delivery_detail_id = wdd.delivery_detail_id
 --and wnd.delivery_id= 162918
 --and wnd.initial_pickup_location_id <> wdd.ship_from_location_id
  and wnd.ultimate_dropoff_location_id <> wdd.deliver_to_location_id
 ;

SELECT *
--carrier_id, hazard_class_id, ship_from_location_id, ship_to_location_id, deliver_to_location_id
FROM wsh.wsh_delivery_details wdd 
where 1=1
  --and delivery_detail_id = 455643
  --and ship_to_location_id is null
  and ship_to_location_id <> deliver_to_location_id
  --and source_header_type_name not in ('KMR_WLMRT_FORANEO','KMR_WLMRT_LOCAL', 'KMR_LIVERPOOL_LOCAL')
;

operating_unit in (
164,
108,
523,
163,
107,
144,
173,
114,
81,
109,
143,
105,
147,
522,
162
)
;
