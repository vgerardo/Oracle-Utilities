
/*
-- Validar datos en la interface
--
select h.status, l.po_number, h.invoice_num, h.invoice_amount, 
       l.line_number, l.line_type_lookup_code, l.amount,
       rh.reject_lookup_code header_reject,
       rl.reject_lookup_code line_reject
from ap_invoices_interface H,
     ap_invoice_lines_interface L,
     ap_interface_rejections  Rh,     
     ap_interface_rejections  Rl
WHERE 1=1
  AND h.invoice_id = l.invoice_id
  and h.invoice_id = rh.parent_id (+)
  and l.invoice_line_id = rl.parent_id (+)
  and h.po_number in ('36548', '36549')
 AND h.creation_date > SYSDATE-.5
ORDER BY h.creation_date DESC, l.po_number, l.po_line_number
;
 ;
*/


/*
A partir del número de una Orden de Compra, el script inserta datos en la Open Interface de Payables,
y asocia la factura con su PO y Recepción. Hace falta afinar la parte de la linea de impuestos, ya que
fallaría si existe más de 1 impuesto en una PO (16%, 0%, No gravable). Pero en general funciona chido!
*/
SET SERVEROUTPUT ON 

DECLARE

CURSOR c_ordenes_sin_factura 
IS
    SELECT
           poh.org_id  operating_unit_id,       
           (SELECT name
            FROM HR_ALL_ORGANIZATION_UNITS
            WHERE organization_id =   poh.org_id   
            ) OU_name,
           poh.po_header_id             po_header_id,
           poh.segment1                 po_number,
           poh.authorization_status,       
           poh.vendor_id                po_vendor_id,
           poh.vendor_site_id           po_vendor_site_id,
            (select Inventory_Organization_Id
            from HR_LOCATIONS_ALL
            where location_id = poh.ship_to_location_id --location_code = 'GRP_FARFG'
            ) inv_org_id,
           poh.terms_id,
           poh.currency_code            po_currency_code,
           pol.unit_price               po_unit_price,   
           Pol.Unit_Meas_Lookup_Code,
           pol.po_line_id,
           pol.line_num                 line_number,
           pol.item_id,
           pol.item_description,
           (itm.segment1 ||'.'|| itm.segment2 ||'.'|| itm.segment3) item_code,
           pll.line_location_id,
           Pll.Need_By_Date,
           Pll.Promised_Date,
           pll.quantity,
           pll.quantity_received        pll_quantity_received,
           pll.quantity_billed,
           pll.match_option,
           pll.amount_billed,       
           sh.receipt_num,
           sl.quantity_shipped,
           sl.quantity_received             rcv_quantity_received,
           sl.shipment_line_Status_code,       
           itm.purchasing_tax_code,       
            (select transaction_id
            from rcv_transactions
            where shipment_header_id = sl.shipment_header_id
              and shipment_line_id = sl.shipment_line_id
              and transaction_type = 'RECEIVE'
            )  rcv_transaction_id,
            pll.accrue_on_receipt_flag,
            poh.rate_type, 
            poh.rate, 
            poh.rate_date,       
          (SELECT percentage_rate
           FROM ZX_RATES_B
           WHERE TAX_RATE_CODE = itm.purchasing_tax_code
           ) tax_rate
    FROM po_headers_all         poh,
         po_lines_all           pol,
         po_line_locations_all  pll,
         mtl_system_items_b     itm,
         rcv_shipment_headers   sh,
         rcv_shipment_lines     sl     
    WHERE 1=1
      and poh.org_id        = pol.org_id
      and poh.po_header_id  = pol.po_header_id
      and pol.po_line_id    = pll.po_line_id
      and itm.inventory_item_id = sl.item_id
      and itm.organization_id = sh.ship_to_org_id  
      and pll.po_header_id  = sl.po_header_id
      and pll.po_line_id    = sl.po_line_id
      and sl.shipment_header_id = sh.shipment_header_id
      and nvl(pol.cancel_flag,'N') = 'N'
      --
      -- FILTROS 
      --and pll.quantity_received <> 0
      --and pll.quantity_billed = 0
      and poh.org_id        = 85   -- Unidad Operativa 
      and Pll.Promised_Date > sysdate - 15      
      --and poh.PO_HEADER_ID  =650042
      and poh.segment1 = '36535'
      --and pll.ACCRUE_ON_RECEIPT_FLAG = 'Y'  -- esta bandera es solo pa pruebas! :) no sé ni que haga
      and poh.currency_code = 'MXN'  -- se requiere unos pequeños cambios para considerar otras monedas, por ahora solo PESOS!
    ORDER BY 3  
 ;

v_line_id       number(15) := 0;
v_inv_header    AP.AP_INVOICES_INTERFACE%ROWTYPE;
v_amount_16     number(15,4) := 0;

BEGIN

    v_inv_header.invoice_id := ap_invoices_interface_s.NEXTVAL;
    
    DBMS_OUTPUT.Put_Line ('Invoice_id = ' || to_char(v_inv_header.invoice_id) );

    --
    -- inserta las lineas tipo ITEM
    --
    FOR c_po IN c_ordenes_sin_factura LOOP
    
        INSERT INTO AP.AP_INVOICE_LINES_INTERFACE (
            invoice_id, invoice_line_id,      
            org_id,            
            line_number, line_type_lookup_code, 
            amount, 
            description,                        
            tax_classification_code,
            po_header_id,       -- Orden de Compra para Asociar
            rcv_transaction_id, -- Recepción para Asociar
            --match_option
            creation_date,
            last_update_date
            ,DIST_CODE_COMBINATION_ID
        )
        VALUES (
            v_inv_header.invoice_id,
            AP_INVOICE_LINES_INTERFACE_S.NEXTVAL,
            c_po.operating_unit_id,
            c_po.line_number,                  -- line_number
            'ITEM',             -- line_type: ITEM o TAX
            (c_po.po_unit_price * c_po.rcv_quantity_received) ,     -- amount sin tax
            'mi prueba: '|| to_char(sysdate,'yyyy-mm-dd hh24:mi:ss'),  -- description
            c_po.purchasing_tax_code,            
            c_po.po_header_id,     -- PO Header ID
            c_po.rcv_transaction_id,     --Transaction ID            
            SYSDATE,
            SYSDATe
            ,899293
        );

        -- guarda algunos datos para después crear el Encabezado        
        v_inv_header.vendor_id          := c_po.po_vendor_id;
        v_inv_header.vendor_site_id     := c_po.po_vendor_site_id;
        v_inv_header.org_id             := c_po.operating_unit_id;
        v_inv_header.invoice_currency_code := c_po.po_currency_code;
        
        -- acumula el monto del TAX        
        v_amount_16         := v_amount_16 + (c_po.po_unit_price * c_po.rcv_quantity_received) * c_po.tax_rate/100 ;        

    END LOOP;

    DBMS_OUTPUT.Put_Line ('Insertó Líneas tipo ITEM');
--    
--    --
--    -- Inserta linea de TAX
--    -- El impuesto se puede introducir de dos maneras:
--    --   1ra. Calcular el tax e insertarlo directamente en la interface como una linea tipo TAX
--    --   2da. Dejar al EBS que lo calcule, usando: CALC_TAX_DURING_IMPORT_FLAG y ADD_TAX_TO_INV_AMT_FLAG
--    --
    v_line_id := AP_INVOICE_LINES_INTERFACE_S.NEXTVAL;
    
    INSERT INTO AP.AP_INVOICE_LINES_INTERFACE (
        org_id,
        invoice_id, invoice_line_id, 
        line_number, line_type_lookup_code, 
        amount, 
        tax_rate_code,
        creation_date,
        last_update_date
    )
    SELECT 
        org_id,    
        invoice_id,
        v_line_id,
         MAX(line_number)+1  ,      -- line number
        'TAX',        
        --
        -- -- OJO!! Esto fallaría cuando existan más de 1 tax (Ej. 16% y 0%)
        round(v_amount_16, 2),
        tax_classification_code,  
        -- -- --------------------------------------------------------------
        sysdate,
        sysdate
    FROM AP_INVOICE_LINES_INTERFACE
    where invoice_id = v_inv_header.invoice_id
    GROUP BY invoice_id, org_id, tax_classification_code;    
--    
--    DBMS_OUTPUT.Put_Line ('Insertó línea de TAX');
    
    --
    -- Ahora inserta el ENCABEZADO
    --
    INSERT INTO AP.AP_INVOICES_INTERFACE (
      invoice_id, 
      invoice_num, 
      invoice_type_lookup_code, 
      invoice_date, 
      vendor_id, 
      vendor_site_id,
      invoice_amount, 
      invoice_currency_code,
      exchange_rate,
      exchange_rate_type,
      exchange_date,
      --terms_id,
      description,  
      --pay_group_lookup_code,  
      org_id,
      source,
      group_id,  
      last_update_date
      -- =================================================================
      -- (solo sino se introdujo la linea de TAX)
      --,CALC_TAX_DURING_IMPORT_FLAG  -- calcula la linea de TAX 
      --,ADD_TAX_TO_INV_AMT_FLAG     -- agrega el importe de tax al importe total
      -- =================================================================    
      )
    VALUES  (
      v_inv_header.invoice_id ,
      'GVP-'||to_char(sysdate,'hh24miss'),  -- invoice num
      'STANDARD',
      SYSDATE,      -- invoice date
      v_inv_header.vendor_id,               -- vendor id
      v_inv_header.vendor_site_id,          -- vendor site id
      (select sum(amount) from AP_INVOICE_LINES_INTERFACE where invoice_id = v_inv_header.invoice_id),   -- monto de todas las lineas, incluso el tax
      v_inv_header.invoice_currency_code,            -- currency code
      NULL,             -- exchange rate
      '',           -- exchange type: Corporate
      '', --to_date('08/02/17', 'dd/mm/yy'),
      'PRUEBA DE MI 13',
      --'CAD_FALC',
      v_inv_header.org_id, 
      'MANUAL INVOICE ENTRY',
      'GVP',
      SYSDATE      
      --,'Y'
      --,'Y'
    );

    DBMS_OUTPUT.Put_Line ('Insertó HEADER');
  
END;
/
