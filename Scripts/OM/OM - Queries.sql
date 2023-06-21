



select oeh.order_number, oeh.flow_status_code
     ,oeh.*
     , oel.*
from  oe_order_headers_all           oeh
   , oe_order_lines_all             oel
   , qp_secu_list_headers_v         lh
where 1=1
  and oeh.header_id           = oel.header_id
  and oel.price_list_id       = lh.list_header_id
  --AND oeh.order_type_id       = 1142
  --AND oeh.flow_status_code    = 'AWAITING_SHIPPING'
  --AND oel.flow_status_code    = 'AWAITING_SHIPPING'
  and oel.flow_status_code NOT IN ('CANCELLED','CLOSED')
  and lh.active_flag = 'Y'
  and nvl(lh.end_date_active,SYSDATE+1)  > SYSDATE
  --and oel.header_id = 22125
  ;
  
       
       select *
       from qp_list_lines_v
       where LIST_HEADER_ID = 1928175
         and product_attr_val_disp = 'LT0408SSA.48'
         --and product_id = 
       ;