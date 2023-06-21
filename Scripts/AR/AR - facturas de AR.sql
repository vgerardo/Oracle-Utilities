BEGIN
    fnd_global.apps_initialize    (
        user_id        => 1134,     -- ext-gvargas
        resp_id        => 50834,    -- GRP_ALL_AR_CONE_GTE
        resp_appl_id    => 222     -- AR
    );
    mo_global.init ('AR');
    mo_global.set_policy_context('S',85);
END;
/


SET SERVEROUTPUT ON 

DECLARE
x_amount_due_remaining  NUMBER(15,4);
x_acctd_amount_due_remaining NUMBER(15);
x_return_status         VARCHAR2(20);
x_msg_count             NUMBER(15);
x_msg_data              VARCHAR2(500);
begin

    arp_global.functional_currency     := 'MXN';
    --arp_global.set_of_books_id         := 2;
    apps.AR_INVOICE_API_PUB.GET_TRXN_LINE_BALANCE (
         p_api_version                 => '1.0'
         ,p_customer_trx_id             => 8593908     
         ,x_amount_due_remaining        => x_amount_due_remaining
         ,x_acctd_amount_due_remaining  => x_acctd_amount_due_remaining
         ,x_return_status               => x_return_status
         ,x_msg_count                   => x_msg_count
         ,x_msg_data                    => x_msg_data
    );
    
    DBMS_OUTPUT.put_line ( x_amount_due_remaining);   
end;
/ 

SELECT    
    org_id, legal_entity_id,
    bs_batch_source_name,
    trx_number,    
    rab_batch_name,
    rac_bill_to_customer_name,
    rac_bill_to_customer_num,
    bill_to_taxpayer_id,    
    ctt_class,
    comments,    
    complete_flag,    
    invoice_currency_code,
    ps_dispute_amount,
    term_due_date,
    exchange_rate,
    gd_gl_date,
    printing_option,
    ct_reference,
    ras_primary_salesrep_name,
    ras_primary_salesrep_num,
    status_trx,
    trx_date,
    ctt_type_name,
    customer_trx_id,
    cust_trx_type_id,
    batch_id,
    batch_source_id,
    reason_code,
    term_id,
    primary_salesrep_id,
    ctt_allow_overapplication_flag,
    raa_bill_to_address_id,
    activity_flag
FROM    ra_customer_trx_partial_v
WHERE trx_number = 'FARFG1846060' 
ORDER BY    customer_trx_id
;

select ct.trx_number, ct.trx_date, ct.org_id, ct.customer_trx_id, 
       ctl.line_number, ctl.line_type, ctl.extended_amount, ctl.description, ctl.customer_Trx_line_id,
       --ra.amount_applied, ra.line_applied, ra.tax_applied, ra.apply_date, ra.status, ra.reversal_gl_date, ra.application_type     
       ctt.name tipo_code, ctt.type clase,
       bs.name origen,  
       hca.account_number, hca.account_name
	   ,ou.name
from ra_customer_trx_all        ct,
     ra_customer_trx_lines_all  ctl,
     ra_cust_trx_types_all      ctt,
     ra_batch_sources_all       bs  --origen = source               
     ,hz_cust_accounts          hca
	 , hr_operating_units       ou
where 1=1
  and ct.customer_trx_id    = ctl.customer_trx_id
  and ct.org_id             = ctl.org_id
  and ct.cust_trx_type_id   = ctt.cust_trx_type_id
  and ct.batch_source_id    = bs.batch_source_id
  and ct.bill_to_customer_id = hca.cust_account_id
  and ct.org_id             = ou.organization_id
  --and ct.customer_trx_id = ra.applied_customer_trx_id
  and ct.trx_number = 'FARFG1845552'
  --and ct.customer_Trx_id    = 8593908  
order by ct.customer_trx_id, ctl.line_number  
;

--
-- 
--
SELECT  lgd.gl_date, lgd.gl_posted_date, lgd.amount, lgd.acctd_amount
       ,ctl.line_number, ctl.line_type, ctl.interface_line_context, ctl.interface_line_attribute1, ctl.interface_line_attribute2
       ,ctl_line.line_number, ctl_line.description, ctl_line.quantity_invoiced, ctl_line.unit_selling_price, ctl_line.line_type, ctl_line.extended_amount
       ,gcc.segment1 s_cia, gcc.segment2 s_cc, gcc.segment3 s_cnta, gcc.segment4 s_sbcta, gcc.segment5 s_intrco, gcc.segment6 s_fut1, gcc.segment7 s_fut2  
     FROM ra_cust_trx_line_gl_dist_all lgd,
          gl_code_combinations         gcc,          
          ra_customer_trx_lines_all     ctl,
          ra_customer_trx_lines_all     ctl_line,
          ar_lookups al_class,
          ar_lookups al_type,
          ra_rules                      rr
    WHERE     LGD.CUSTOMER_TRX_LINE_ID = CTL.CUSTOMER_TRX_LINE_ID(+)
          AND CTL.LINK_TO_CUST_TRX_LINE_ID = CTL_LINE.CUSTOMER_TRX_LINE_ID(+)
          AND LGD.CODE_COMBINATION_ID = GCC.CODE_COMBINATION_ID          
          AND AL_CLASS.LOOKUP_TYPE = 'AUTOGL_TYPE'
          AND AL_CLASS.LOOKUP_CODE = LGD.ACCOUNT_CLASS
          AND AL_TYPE.LOOKUP_TYPE(+) = 'STD_LINE_TYPE'
          AND AL_TYPE.LOOKUP_CODE(+) = CTL.LINE_TYPE
          AND CTL.ACCOUNTING_RULE_ID = RR.RULE_ID(+)
          --AND (CTL_LINE.CUSTOMER_TRX_ID = 5768261)
         --AND (CTL_LINE.CUSTOMER_TRX_LINE_ID = 45241254)
         AND (account_set_flag = 'N')         
         --and CTL_LINE.DESCRIPTION in ('RENHAB','RENCOM') --'PAGAND'
         AND LGD.GL_DATE BETWEEN :F1 AND :F2         
         and gcc.segment1 = '1118'
         and gcc.segment3 = '7111001'
         -- --------------------------------------------------------------
         /*and gcc.segment2 = '0001'  -- habitaciones
         AND (                      -- Ingresos de Habitaciones
                (gcc.segment3 in('4110001', '4110002') AND gcc.segment4 = '037')
                OR
                (gcc.segment3 = '4110003')
             )
             */
         -- --------------------------------------------------------------    
      ORDER BY LGD.GL_DATE
         ;
         
         
select 
amount_due_original, tax_original, amount_due_remaining, amount_line_items_original, amount_line_items_remaining, tax_remaining
from AR_PAYMENT_SCHEDULES_ALL         
where customer_trx_id = 8587635
;

select 1020.9/7593.03
from dual;
         