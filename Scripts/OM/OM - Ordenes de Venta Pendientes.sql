


--
-- ORDENES DE VENTA que no han sido embarcadas o interfazadas con inventarios
--
select wdd.source_header_id
     , ooh.order_number
     , wnd.delivery_id
     , wnd.name
     , wdd.delivery_detail_id
     , wdl.pick_up_stop_id
     , wdd.inv_interfaced_flag 
from wsh_delivery_details wdd
   , wsh_delivery_assignments wda, 
     wsh_new_deliveries wnd
   , wsh_delivery_legs wdl
   , wsh_trip_stops wts,
     oe_order_headers_all ooh
   , oe_order_lines_all ool
where wdd.source_code = 'OE' 
and wdd.released_status = 'C' 
and wdd.inv_interfaced_flag in ('N' ,'P') 
and wdd.organization_id = &organization_id 
and wda.delivery_detail_id = wdd.delivery_detail_id 
and wnd.delivery_id = wda.delivery_id 
and wnd.status_code in ('CL','IT') 
and wdl.delivery_id = wnd.delivery_id 
and trunc(wts.actual_departure_date) BETWEEN TO_DATE('04-10-2010','DD-MM-YYYY') AND TO_DATE('30-10-2010','DD-MM-YYYY')
and wdl.pick_up_stop_id = wts.stop_id
and wdd.source_header_id = ooh.header_id
and wdd.source_line_id = ool.line_id



-- 33
-- 456

SELECT *
FROM 
     oe_order_headers_all ooh
   , oe_order_lines_all   ool
WHERE 1=1
  and ooh.header_id = ool.header_id
  and ooh.source_document_type_id = 10
  and ooh.creation_date BETWEEN TO_DATE('08-10-2010 10:00:01','DD-MM-YYYY HH24:MI:SS') AND TO_DATE('08-10-2010 18:00:01','DD-MM-YYYY HH24:MI:SS')
ORDER BY ooh.creation_date desc
  
      
  
  
  
