CREATE OR REPLACE PROCEDURE BOLINF.CMR_OM_AR_INTERFACE_GASTOS (
                                             ERRBUF OUT VARCHAR2
                                            ,RETCODE OUT NUMBER
                                         ) 
IS
--
--Este pl/sql inserta en la tabla de interfaz de AR las líneas de pedidos de venta
--que tienen destino tipo GASTO, y que ya fueron embarcadas en OM. 
--Esto lo hace porque el proceso estándar de Oracle no está diseñado para tal caso, 
--"Crear Facturas AR Intercompañía", y en los SR no dijeron que era mejor una customización. 
--

CURSOR C_LINEAS_GASTO 
IS
    SELECT distinct  
          'INTERCOMPANY'                    interface_line_context
        , dlv.source_header_number          interface_line_attribute1
        , oel.line_number                    interface_line_attribute2
        , oel.ship_from_org_id                interface_line_attribute3
        , sil.org_id                        interface_line_attribute4
        , oel.sold_from_org_id                 interface_line_attribute5
        , oel.line_id                        interface_line_attribute6
        , mt.transaction_id                    interface_line_attribute7
        , oel.sold_from_org_id                 interface_line_attribute8
        , 'Intercompany'                    batch_source_name
        , '1002'                             set_of_books_id
        , 'LINE'                            line_type
        , dlv.item_description                description
        , dlv.currency_code                    currency_code
        , round (dlv.shipped_quantity * ll.operand,2)    amount
        , oel.line_type_id                    cust_trx_type_id
        , oel.payment_term_id                term_id
        , oel.sold_to_org_id                orig_system_bill_customer_id
        , csu.cust_acct_site_id                orig_system_bill_address_id
        , oel.sold_to_org_id                orig_system_sold_customer_id
        ,'Corporate'                         conversion_type
        , oel.actual_shipment_date            conversion_date
        , mt.transaction_date                gl_date
        , null                               line_number
        , (dlv.shipped_quantity)                quantity
        , dlv.src_requested_quantity        quantity_ordered
        , ll.operand                        unit_selling_price
        , ll.operand                        unit_standard_price
        , oel.tax_code                         tax_code
        , oel.actual_shipment_date            ship_date_actual
        , oel.salesrep_id                    primary_salesrep_id
        , dlv.source_header_number          sales_order
        , oel.line_number                    sales_order_line
        , oeh.ordered_date                    sales_order_date
        , oel.inventory_item_id                inventory_item_id
        , dlv.requested_quantity_uom        uom_code
        , 1                                  interface_line_attribute10   -- no sé de donde sale
        , 'Y'                                interface_line_attribute15   -- no sé de donde sale
        , dlv.source_header_id                interface_line_attribute9
        , 1                                  created_by
        ,sysdate                            creation_date
        ,dlv.org_id                            org_id
        ,dlv.organization_id                warehouse_id   
                     
    from wsh_deliverables_v             dlv
       , oe_order_headers_all           oeh
       , oe_order_lines_all             oel      
       , po_requisition_lines_all       sil       
       , hz_cust_site_uses_all          csu 
       , qp_list_lines_v                LL 
       , mtl_material_transactions      mt 
    WHERE dlv.source_header_id    = oeh.header_id      
      and oel.source_document_id  = sil.requisition_header_id
      AND oel.source_document_line_id  = sil.requisition_line_id
      and oel.price_list_id       = ll.list_header_id  (+)
      and oel.inventory_item_id   = ll.product_id (+)
      --and oel.ordered_item        = ll.product_attr_val_disp (+) 
      and oeh.org_id              = oel.org_id       
      and oeh.header_id           = oel.header_id
      and oel.invoice_to_org_id   = csu.site_use_id
      and csu.site_use_code       = 'BILL_TO'
      AND csu.org_id              = oel.org_id --293
      and dlv.source_line_id      = oel.line_id
      and dlv.source_header_id    = mt.TRANSACTION_REFERENCE 
      and dlv.source_line_id      = mt.TRX_SOURCE_LINE_ID
      and dlv.inventory_item_id   = mt.inventory_item_id
      and dlv.SUBINVENTORY        = mt.SUBINVENTORY_CODE
      and dlv.organization_id     = mt.ORGANIZATION_ID        
      and dlv.delivery_line_id    = mt.picking_line_id            
      -- ---------------------------------------------------------------
      -- Estas 2 banderas indican estado  = INTERFACED
      --
      --AND dlv.RELEASED_STATUS not in ( 'D', 'B', 'R') --D=Cancelled B=Pedido Pendiente (Backordered) R=Listo para Despacho (Ready to Release)
      AND dlv.RELEASED_STATUS     = 'C'                    --C=Interfaced    
      AND dlv.OE_INTERFACED_FLAG  = 'Y'
      and dlv.inv_interfaced_flag = 'Y'        
      -- -------------------------------------------------------- 
      -- La facturación de OM, empezó apartir del 01-Octubre-2010, desde entonces los artículos con destino tipo GASTO
      -- no se habian estado facturado por limitante de la funcionalidad estandar del sistema de Oracle.
      -- Por tal motivo, apartir de esta fecha, se empezaron a insertar directamente los artículos de este tipo a la interfaz
      -- de AR, para que sea procesada por el "Programa de Facturación Automática de AR"
      -- 
      and dlv.last_update_date BETWEEN to_date ('01-04-2011 00:00:00', 'DD-MM-YYYY HH24:MI:SS')
                                   AND SYSDATE + 1 
      and sysdate > to_date ('01-04-2011 00:00:00', 'DD-MM-YYYY HH24:MI:SS')                             
      -- --------------------------------------------------------  
      and dlv.source_document_type_id = 10      
      and dlv.source_code             = 'OE'
      and dlv.released_status_name  = Decode(USERENV('LANG'), 'ESA', 'Enviado', 'US', 'Shipped')      
      and sil.destination_type_code   = 'EXPENSE'
      --
      -- Considera SOLO las líneas que aún NO tiene una Factura en AR
      -- y que aún no están en la interfaz
      --
      AND NOT EXISTS (
            SELECT 1
            FROM ra_customer_trx_lines_all  arl
            WHERE arl.ORG_ID                    = dlv.org_id 
              and arl.sales_order               = dlv.source_header_number
              and arl.inventory_item_id         = dlv.inventory_item_id
              and arl.interface_line_attribute6 = dlv.source_line_id
              
            UNION 
            
            SELECT 2
            FROM RA_INTERFACE_LINES_ALL rai
            WHERE batch_source_name like 'Intercompany'
              and interface_line_context = 'INTERCOMPANY'
              and interface_line_attribute1 = dlv.source_header_number
              and interface_line_attribute2 = oel.line_number
              and interface_line_attribute3 = oeh.ship_from_org_id
              and interface_line_attribute4 = sil.org_id
              and interface_line_attribute5 = oeh.sold_from_org_id 
              and interface_line_attribute6 = oel.line_id
              and interface_line_attribute7 =  mt.transaction_id
              and interface_line_attribute8 = oeh.sold_from_org_id 
       )       
      --and oeh.order_number            = '12553'      

    ORDER BY 2, 3, 5
    
  ;  


v_lg            C_LINEAS_GASTO%rowtype;
v_sales_order   varchar2(50);
v_so_total      number(15);
v_running       varchar2(10);


BEGIN
  
    
    --
    -- Esto va ser util en un futuro "cercano", porque evitará que este programa sea ejecutado varias veces
    -- de forma simultanea. 
    --
    BEGIN

        SELECT 'SI'
        INTO v_running
        FROM   fnd_concurrent_requests        re
              ,fnd_concurrent_programs_tl     pr
        WHERE re.program_application_id = pr.application_id
         AND  re.concurrent_program_id  = pr.concurrent_program_id
         AND  pr.language IN ('ESA')  
         --AND  UPPER(pr.user_concurrent_program_name) = UPPER('CMR Crear Facturas AR Intercompañía – Destino GASTO')
         AND  re.phase_code = 'R'
         AND  pr.concurrent_program_id IN (                
                    SELECT concurrent_program_id
                    FROM fnd_concurrent_requests cr        
                    WHERE cr.request_id = fnd_profile.value('CONCURRENT_REQUEST_ID')
              )
          AND ROWNUM < 2
          ;
              
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_running := 'NO'   ;   
    END;

  APPS.FND_FILE.put_LINE (APPS.FND_FILE.LOG, 'corriendo: ' || v_running );
--  
--  IF v_running = 'SI' THEN
--        RETCODE := 2; -- Advertencia
--        ERRBUF  := 'No se puede ejecutar más de una vez de forma simultanea';
-- 
--  ELSE
--     

          APPS.FND_FILE.put_LINE (APPS.FND_FILE.output, 'INTERFACE DE OM -> AR');
          APPS.FND_FILE.put_LINE (APPS.FND_FILE.output, 'Fecha Ejecución: ' || to_char(sysdate,'dd-mon-yyyy hh24:mi'));
          APPS.FND_FILE.NEW_LINE (APPS.FND_FILE.output);
          
          APPS.FND_FILE.put_LINE (APPS.FND_FILE.output, LPAD('ORD.VENTA',12,' ') || LPAD('NUM.LINEA',12,' '));
          APPS.FND_FILE.put_LINE (APPS.FND_FILE.output, LPAD('=========',12,' ') || LPAD('=========',12,' '));
          
          v_sales_order := 'x';    
          v_so_total    := 0;
          
          OPEN C_LINEAS_GASTO ;
          
          LOOP
          

              FETCH C_LINEAS_GASTO  INTO v_lg;
              
              EXIT WHEN C_LINEAS_GASTO%NOTFOUND ;      

              APPS.FND_FILE.put_LINE (APPS.FND_FILE.output, LPAD(v_lg.sales_order,12,' ') || LPAD(v_lg.sales_order_line,12,' ') );
              
              
              if v_sales_order <> v_lg.sales_order then
                  v_sales_order := v_lg.sales_order ;
                  v_so_total := v_so_total + 1;
                  -- 
                  -- se insertan ordenes de venta completas en la interfaz
                  -- 
                  COMMIT;
              end if;
                    
             
              INSERT INTO RA_INTERFACE_LINES_ALL (
                 interface_line_context
                ,interface_line_attribute1
                ,interface_line_attribute2
                ,interface_line_attribute3
                ,interface_line_attribute4
                ,interface_line_attribute5
                ,interface_line_attribute6
                ,interface_line_attribute7
                ,interface_line_attribute8
                ,batch_source_name
                ,set_of_books_id
                ,line_type
                ,description
                ,currency_code
                ,amount
                ,cust_trx_type_id
                ,term_id
                ,orig_system_bill_customer_id
                ,orig_system_bill_address_id
                ,orig_system_sold_customer_id
                ,conversion_type
                ,conversion_date
                ,gl_date
                ,line_number
                ,quantity
                ,quantity_ordered
                ,unit_selling_price
                ,unit_standard_price
                ,tax_code
                ,ship_date_actual
                ,primary_salesrep_id
                ,sales_order
                ,sales_order_line
                ,sales_order_date
                ,inventory_item_id
                ,uom_code
                ,interface_line_attribute10
                ,interface_line_attribute15
                ,interface_line_attribute9
                ,created_by
                ,creation_date
                ,org_id
                ,warehouse_id       
                ) 
            VALUES (
                 v_lg.interface_line_context
                ,v_lg.interface_line_attribute1
                ,v_lg.interface_line_attribute2
                ,v_lg.interface_line_attribute3
                ,v_lg.interface_line_attribute4
                ,v_lg.interface_line_attribute5
                ,v_lg.interface_line_attribute6
                ,v_lg.interface_line_attribute7
                ,v_lg.interface_line_attribute8
                ,v_lg.batch_source_name
                ,v_lg.set_of_books_id
                ,v_lg.line_type
                ,v_lg.description
                ,v_lg.currency_code
                ,v_lg.amount
                ,v_lg.cust_trx_type_id
                ,v_lg.term_id
                ,v_lg.orig_system_bill_customer_id
                ,v_lg.orig_system_bill_address_id
                ,v_lg.orig_system_sold_customer_id
                ,v_lg.conversion_type
                ,v_lg.conversion_date
                ,v_lg.gl_date
                ,v_lg.line_number
                ,v_lg.quantity
                ,v_lg.quantity_ordered
                ,v_lg.unit_selling_price
                ,v_lg.unit_standard_price
                ,v_lg.tax_code
                ,v_lg.ship_date_actual
                ,v_lg.primary_salesrep_id
                ,v_lg.sales_order
                ,v_lg.sales_order_line
                ,v_lg.sales_order_date
                ,v_lg.inventory_item_id
                ,v_lg.uom_code
                ,v_lg.interface_line_attribute10
                ,v_lg.interface_line_attribute15
                ,v_lg.interface_line_attribute9
                ,v_lg.created_by
                ,v_lg.creation_date
                ,v_lg.org_id
                ,v_lg.warehouse_id 
                );
             

            
          END LOOP ;


          COMMIT;

          --
          -- SE INSERTARON cursor%ROWCOUNT LINEAS EN LA INTERFAZ DE AR   
          --
          APPS.FND_FILE.NEW_LINE (APPS.FND_FILE.output);  
          APPS.FND_FILE.put_LINE (APPS.FND_FILE.output, 'CANTIDAD DE ORDENES DE VENTA Y LINEAS INSERTADAS EN LA INTERFAZ DE AR: ' || v_so_total || ' - ' ||C_LINEAS_GASTO%ROWCOUNT  );


          CLOSE C_LINEAS_GASTO;
    
  
    APPS.FND_FILE.NEW_LINE (APPS.FND_FILE.output);  
    APPS.FND_FILE.put_LINE (APPS.FND_FILE.output, 'Ordenes de Venta interfazadas, pero por algún motivo aún no ha sido creada su factura en AR');
    --
    -- Ordenes de Venta con más de 2 hrs en la Interface de AR, 
    -- Y las respectivas facturas aun no han sido creadas
    --
    FOR c_sales IN (SELECT to_char(x.creation_date,'DD-MON-YYYY HH24:MI') fecha, x.SALES_ORDER
                    FROM RA_INTERFACE_LINES_ALL x
                    WHERE x.interface_line_context = 'INTERCOMPANY'
                      and x.CREATION_DATE < sysdate-(2/24)
                      and NOT EXISTS (
                            SELECT 1
                            FROM ra_customer_trx_lines_all 
                            WHERE sales_order = x.SALES_ORDER
                             and SALES_ORDER_LINE = x.SALES_ORDER_line
                             )
                    GROUP BY x.SALES_ORDER, to_char(x.creation_date,'DD-MON-YYYY HH24:MI')
                    ORDER BY to_char(x.creation_date,'DD-MON-YYYY HH24:MI')  
                )
    LOOP
    
        APPS.FND_FILE.put_LINE (APPS.FND_FILE.output, '  *  ' || c_sales.fecha || '-' ||c_sales.sales_order);  
        
    END LOOP;                    
    
  
END;
/
