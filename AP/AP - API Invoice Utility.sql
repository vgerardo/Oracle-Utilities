
BEGIN
    FND_GLOBAL.apps_initialize (user_id=>14209, resp_id =>53620, resp_appl_id=>200);
    mo_global.init('SQLAP');
END;
/

select AP_INVOICES_UTILITY_PKG.get_po_number            (l_invoice_id =>1862829) from dual;
select AP_INVOICES_UTILITY_PKG.get_receipt_number       (l_invoice_id =>1862829) from dual;
select AP_INVOICES_UTILITY_PKG.get_po_number_list       (l_invoice_id =>1862829) from dual;
select AP_INVOICES_UTILITY_PKG.get_total_prepays        (l_vendor_id=>482954, l_org_id=>162) from dual;
select AP_INVOICES_UTILITY_PKG.get_available_prepays    (l_vendor_id=>482954, l_org_id=>162) from dual;
select AP_INVOICES_UTILITY_PKG.get_prepay_amount_applied(p_invoice_id=>1862829) from dual;
select AP_INVOICES_UTILITY_PKG.get_invoice_num          (p_invoice_id=>1862829) from dual;
select AP_INVOICES_UTILITY_PKG.get_line_total           (p_invoice_id=>1862829) from dual;
select AP_INVOICES_UTILITY_PKG.get_Item_Total           (p_Invoice_Id=>1862829, p_Org_Id=>162) from dual;
      
 