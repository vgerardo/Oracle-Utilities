--    SELECT * FROM XXCMX.XXCMX_WSH_SALES_ORDERS_ALL;
--
-- Pedidos de Venta creados cada "15" minutos
--
--DROP INDEX xcmx_oe_so_hdrs_n01;
--CREATE INDEX  xcmx_oe_so_hdrs_n01 on ont.oe_order_headers_all (last_update_date, booked_flag, cancelled_flag, ship_from_org_id) TABLESPACE APPS_TS_TX_IDX;

select * from xxcmx_volumetria_SO;


create table xxcmx_volumetria_SO
as

/*
SELECT intervalo_min
     , Header_Status
     , Warehouse
     , count(*)     as count_headers
     , sum (lineas) as sum_lines_total
     , max (lineas) as max_lines_x_so
     , round(avg (lineas),2) as avg_lineas_x_so
FROM (*/

    SELECT oh.header_id
         ,oh.order_number
         ,oh.flow_status_code               AS Header_Status
         --,ou.name                           AS Unidad_Operativa
         ,od.organization_code              AS Warehouse
         ,DECODE (itm.serial_number_control_code
                   ,1, 'No Serial Number Control'
                   ,2, 'Predefined Serial Number'
                   ,5, 'Dynamic Entry at Inventory Receipt'
                   ,6, 'Dynamic Entry at Sales Order Issue'
                   ,   'No identificado'
                   )                        AS Serial_Control
         --, to_char(oh.last_update_date, 'YYYY-MM-DD')  AS Fecha_Actualizacion          
         ,to_char (
                TRUNC(oh.last_update_date) + (floor ((oh.last_update_date - TRUNC(oh.last_update_date)) * 1440 / 60) * 60)/1440
                , 'YYYY-MM-DD HH24'
                ) intervalo_min
         , COUNT(ol.line_id)                AS lineas_pedido
    FROM ont.oe_order_headers_all           oh
       , oe_order_lines_all             ol
       --, hr_all_organization_units      ou
       , org_organization_definitions   od
       , mtl_system_items_b             itm       
    WHERE oh.org_id           = ol.org_id
      and oh.header_id        = ol.header_id
      --and oh.org_id           = ou.organization_id
      --and ou.type             = 'OPERATING UNIT'
      and ol.ship_from_org_id = od.organization_id
      and ol.ship_from_org_id = itm.organization_id
      and ol.inventory_item_id= itm.inventory_item_id
      and oh.booked_flag    = 'Y'
      and oh.cancelled_flag = 'N'
      and ol.cancelled_flag = 'N'
      and od.set_of_books_id= 2021  --Solo México
      and oh.last_update_date BETWEEN to_date('2021-01-01 00:00:00', 'YYYY-MM-DD HH24:MI:SS') 
                                  AND to_date('2021-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
    GROUP BY oh.header_id
         ,oh.order_number
         ,oh.flow_status_code
         --,ou.name
         ,od.organization_code
         ,itm.serial_number_control_code
         ,to_char(oh.last_update_date, 'YYYY-MM-DD')
         ,to_char (
                TRUNC(oh.last_update_date) + (floor ((oh.last_update_date - TRUNC(oh.last_update_date)) * 1440 / 60) * 60)/1440
                , 'YYYY-MM-DD HH24'
                )

/*    )
GROUP BY Header_Status
      , Warehouse
      , intervalo_15_min
ORDER BY sum_lines_total desc
*/
;
