SELECT 
       oha.order_number, 
       ola.line_number line_number,
       ola.ordered_item item_name,
       ola.ordered_quantity,       ola.ordered_quantity * ola.unit_selling_price line_amount,
       rcta.trx_number invoice_number, 
       rcta.trx_date invoice_date,
       rctla.line_number trx_line_number
FROM   oe_order_headers_all oha,
       oe_order_lines_all ola              
       ra_customer_trx_all rcta,
       ra_customer_trx_lines_all rctla
 WHERE oha.header_id = ola.header_id
   AND rcta.customer_trx_id = rctla.customer_trx_id
   AND rctla.interface_line_context = ‘ORDER ENTRY’
   AND rctla.interface_line_attribute6 = TO_CHAR (ola.line_id)
   AND rctla.interface_line_attribute1 = TO_CHAR (oha.order_number)
   AND order_number = :p_order_number