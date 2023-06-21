
/*
GRANT EXECUTE ON apps.Po_Approved_Supplier_List_Rec TO BOLINF;
GRANT EXECUTE ON apps.po_asl_attributes_rec TO BOLINF;
GRANT EXECUTE ON apps.po_asl_documents_rec TO BOLINF;
GRANT EXECUTE ON apps.chv_authorizations_rec TO BOLINF;
GRANT EXECUTE ON apps.po_supplier_item_capacity_rec TO BOLINF;
GRANT EXECUTE ON apps.po_supplier_item_tolerance_rec TO BOLINF;
GRANT EXECUTE ON apps.Po_Asl_Api_Error_Rec TO BOLINF;
GRANT EXECUTE ON apps.po_tbl_number TO BOLINF;
GRANT EXECUTE ON apps.po_tbl_varchar1 TO BOLINF;
GRANT EXECUTE ON apps.po_tbl_varchar25 TO BOLINF;
GRANT EXECUTE ON apps.po_tbl_varchar30 TO BOLINF;
GRANT EXECUTE ON apps.po_tbl_varchar50 TO BOLINF;
GRANT EXECUTE ON apps.po_tbl_varchar100 TO BOLINF;
GRANT EXECUTE ON apps.po_tbl_varchar240 TO BOLINF;
GRANT EXECUTE ON apps.po_tbl_number TO BOLINF;
GRANT EXECUTE ON apps.po_tbl_date TO BOLINF;
*/

SET SERVEROUTPUT ON 

--The following SQL statement is a sample API to create, update, and delete approved supplier lists.
--Check the errors in 'PO_ASL_API_ERRORS'
--
DECLARE
    asl_rg          po_approved_supplier_list_rec   ;
    asl_attr_rg     po_asl_attributes_rec      ;
    asl_doc_rg      po_asl_documents_rec      ;
    asl_auto_rg     chv_authorizations_rec     ;
    psicrec         po_supplier_item_capacity_rec   ;
    asl_tlrnce_rg   po_supplier_item_tolerance_rec  ;
    x_errors        Po_Asl_Api_Error_Rec;

    v_item_num          varchar2(50) := 'BE.0001.6208';
    --v_org_name          varchar2(240) := 'ADMIN_INV_1GDCE';
    v_org_id            number(15)    := 1363;
    v_vendor_name       varchar2(240) := 'DISTRIBUIDORA ALIMENTICIA PARA HOTELES Y RESTAURANTES S DE RL';
    --v_vendor_site_code  varchar2(240) := '1GDCE'; NO funcionó usando el Code!! hay que usar el ID.
    v_vendor_site_id    number(15)    := 244775;
        
    x_session_key       NUMBER;
    x_return_status     VARCHAR2(30);
    x_return_msg        VARCHAR2(2000);

BEGIN

--In the API call, it is mandatory to pass all the parameters (records
--types) but however you don't need to initialize all the record types. If you
--start initializing a record type, you MUST provide values to all the
--attributes in that record type.


   -- Populating values in asl_rg
    asl_rg                      := new po_approved_supplier_list_rec();
    asl_rg.user_key             := po_tbl_number(1);
    asl_rg.process_action       := po_tbl_varchar30('CREATE'); --CREATE / UPDATE
    asl_rg.global_flag          := po_tbl_varchar1('Y');    
    asl_rg.owning_organization_id := po_tbl_number(v_org_id);
    asl_rg.owning_organization_dsp := po_tbl_varchar240(null);
    asl_rg.vendor_business_type := po_tbl_varchar25('Direct');    --Direct / Distributor
    asl_rg.asl_status_id        := po_tbl_number(NULL);
    asl_rg.asl_status_dsp       := po_tbl_varchar25('Approved');    -- Approved / Debarred
    asl_rg.vendor_id            := po_tbl_number(NULL);    
    asl_rg.vendor_dsp           := po_tbl_varchar240(v_vendor_name);
    asl_rg.item_id              := po_tbl_number(NULL);
    asl_rg.item_dsp             := po_tbl_varchar50(v_item_num);
    asl_rg.vendor_site_id       := po_tbl_number (v_vendor_site_id);
    asl_rg.vendor_site_dsp      := po_tbl_varchar50(null);
    asl_rg.disable_flag         := po_tbl_varchar1('N');
    asl_rg.comments             := po_tbl_varchar240('Created by PO_ASL_API_PUB');
    asl_rg.primary_vendor_item  := po_tbl_varchar25(NULL);
    asl_rg.category_id          := po_tbl_number(NULL);
    asl_rg.category_dsp         := po_tbl_varchar240(NULL);    
    asl_rg.manufacturer_id      := po_tbl_number(NULL);
    asl_rg.manufacturer_dsp     := po_tbl_varchar100(NULL);    
    asl_rg.manufacturer_asl_id  := po_tbl_number(NULL);
    asl_rg.manufacturer_asl_dsp := po_tbl_varchar50(null);
    asl_rg.review_by_date       := po_tbl_date(NULL);    
    asl_rg.attribute_category   := po_tbl_varchar30(NULL);
    asl_rg.attribute1           := po_tbl_varchar240(NULL);
    asl_rg.attribute2           := po_tbl_varchar240(NULL);
    asl_rg.attribute3           := po_tbl_varchar240(NULL);
    asl_rg.attribute4           := po_tbl_varchar240(NULL);
    asl_rg.attribute5           := po_tbl_varchar240(NULL);
    asl_rg.attribute6           := po_tbl_varchar240(NULL);
    asl_rg.attribute7           := po_tbl_varchar240(NULL);
    asl_rg.attribute8           := po_tbl_varchar240(NULL);
    asl_rg.attribute9           := po_tbl_varchar240(NULL);
    asl_rg.attribute10          := po_tbl_varchar240(NULL);
    asl_rg.attribute11          := po_tbl_varchar240(NULL);
    asl_rg.attribute12          := po_tbl_varchar240(NULL);
    asl_rg.attribute13          := po_tbl_varchar240(NULL);
    asl_rg.attribute14          := po_tbl_varchar240(NULL);
    asl_rg.attribute15          := po_tbl_varchar240(NULL);
    asl_rg.request_id           := po_tbl_number(NULL);
    asl_rg.program_application_id := po_tbl_number(NULL);
    asl_rg.program_id           := po_tbl_number(NULL);
    asl_rg.program_update_date  := po_tbl_date(NULL);
    

    -- Populating values in asl_attr_rg
/*    asl_attr_rg                                 := new po_asl_attributes_rec();
    asl_attr_rg.user_key                        := po_tbl_number(1);
    asl_attr_rg.process_action                  := po_tbl_varchar30('ADD');  --ADD / UPDATE
    asl_attr_rg.using_organization_id           := po_tbl_number(-1);
    asl_attr_rg.using_organization_dsp          := po_tbl_varchar240(NULL);
    asl_attr_rg.release_generation_method       := po_tbl_varchar25(NULL);
    asl_attr_rg.release_generation_method_dsp   := po_tbl_varchar50('Automatic Release');
    asl_attr_rg.purchasing_unit_of_measure_dsp  := po_tbl_varchar25('PZA');
    asl_attr_rg.enable_authorizations_flag_dsp  := po_tbl_varchar1('Y');
    asl_attr_rg.vendor_id                       := po_tbl_number(null);
    asl_attr_rg.vendor_dsp                      := po_tbl_varchar240(v_vendor_name);
    asl_attr_rg.vendor_site_id                  := po_tbl_number (v_vendor_site_id);
    asl_attr_rg.vendor_site_dsp                 := po_tbl_varchar50(null);
    asl_attr_rg.item_id                         := po_tbl_number(null);
    asl_attr_rg.item_dsp                        := po_tbl_varchar50(v_item_num);
    asl_attr_rg.enable_plan_schedule_flag_dsp   := po_tbl_varchar1('Y');
    asl_attr_rg.enable_ship_schedule_flag_dsp   := po_tbl_varchar1(null);
    asl_attr_rg.plan_schedule_type              := po_tbl_varchar25(null);
    asl_attr_rg.plan_schedule_type_dsp          := po_tbl_varchar50(null);
    asl_attr_rg.ship_schedule_type              := po_tbl_varchar25(null);
    asl_attr_rg.ship_schedule_type_dsp          := po_tbl_varchar50(null);
    asl_attr_rg.plan_bucket_pattern_id          := po_tbl_number(null);
    asl_attr_rg.plan_bucket_pattern_dsp         := po_tbl_varchar50(null);
    asl_attr_rg.ship_bucket_pattern_id          := po_tbl_number (null);
    asl_attr_rg.ship_bucket_pattern_dsp         := po_tbl_varchar50(null);
    asl_attr_rg.enable_autoschedule_flag_dsp    := po_tbl_varchar1(null);
    asl_attr_rg.scheduler_id                    := po_tbl_number(NULL);
    asl_attr_rg.scheduler_dsp                   := po_tbl_varchar50(null);    
    asl_attr_rg.category_id                     := po_tbl_number(null);
    asl_attr_rg.category_dsp                    := po_tbl_varchar50(null);
    asl_attr_rg.attribute_category              := po_tbl_varchar30(null);
    asl_attr_rg.attribute1                      := po_tbl_varchar240(null);
    asl_attr_rg.attribute2                      := po_tbl_varchar240(null);
    asl_attr_rg.attribute3                      := po_tbl_varchar240(null);
    asl_attr_rg.attribute4                      := po_tbl_varchar240(null);
    asl_attr_rg.attribute5                      := po_tbl_varchar240(null);
    asl_attr_rg.attribute6                      := po_tbl_varchar240(null);
    asl_attr_rg.attribute7                      := po_tbl_varchar240(null);
    asl_attr_rg.attribute8                      := po_tbl_varchar240(null);
    asl_attr_rg.attribute9                      := po_tbl_varchar240(null);
    asl_attr_rg.attribute10                     := po_tbl_varchar240(null);
    asl_attr_rg.attribute11                     := po_tbl_varchar240(null);
    asl_attr_rg.attribute12                     := po_tbl_varchar240(null);
    asl_attr_rg.attribute13                     := po_tbl_varchar240(null);
    asl_attr_rg.attribute14                     := po_tbl_varchar240(null);
    asl_attr_rg.attribute15                     := po_tbl_varchar240(null);
    asl_attr_rg.request_id                      := po_tbl_number(null);
    asl_attr_rg.program_application_id          := po_tbl_number(null);
    asl_attr_rg.program_id                      := po_tbl_number(null);
    asl_attr_rg.program_update_date             := po_tbl_date(null);
    asl_attr_rg.price_update_tolerance_dsp      := po_tbl_number (null);
    asl_attr_rg.processing_lead_time_dsp        := po_tbl_number (null);
    asl_attr_rg.min_order_qty_dsp               := po_tbl_number(null);
    asl_attr_rg.fixed_lot_multiple_dsp          := po_tbl_number(null);
    asl_attr_rg.delivery_calendar_dsp           := po_tbl_varchar25(null);
    asl_attr_rg.country_of_origin_code_dsp      := po_tbl_varchar25(null);
    asl_attr_rg.enable_vmi_flag_dsp             := po_tbl_varchar1(null);
    asl_attr_rg.vmi_min_qty_dsp                 := po_tbl_number(null);
    asl_attr_rg.vmi_max_qty_dsp                 := po_tbl_number(null);
    asl_attr_rg.enable_vmi_auto_replenish_flag  := po_tbl_varchar1(null);
    asl_attr_rg.vmi_replenishment_approval      := po_tbl_varchar30(null);
    asl_attr_rg.vmi_replenishment_approval_dsp  := po_tbl_varchar30(null);
    asl_attr_rg.consigned_from_supp_flag_dsp    := po_tbl_varchar1(null);
    asl_attr_rg.last_billing_date               := po_tbl_date(null);
    asl_attr_rg.consigned_billing_cycle_dsp     := po_tbl_number(null);
    asl_attr_rg.consume_on_aging_flag_dsp       := po_tbl_varchar1(null);
    asl_attr_rg.aging_period_dsp                := po_tbl_number(null);
    asl_attr_rg.replenishment_method            := po_tbl_number(null);
    asl_attr_rg.replenishment_method_dsp        := po_tbl_varchar50(null);
    asl_attr_rg.vmi_min_days_dsp                := po_tbl_number(null);
    asl_attr_rg.vmi_max_days_dsp                := po_tbl_number(null);
    asl_attr_rg.fixed_order_quantity_dsp        := po_tbl_number(NULL);
    asl_attr_rg.forecast_horizon_dsp            := po_tbl_number(null);
*/
    --Populating values in asl_doc_rg
    /*asl_doc_rg := new po_asl_documents_rec();
    asl_doc_rg.user_key := po_tbl_number(1);
    asl_doc_rg.process_action := po_tbl_varchar30('ADD'); --ADD/UPDATE/DELETE
    asl_doc_rg.using_organization_id:= po_tbl_number(-1);
    asl_doc_rg.using_organization_dsp := po_tbl_varchar240(null);
    asl_doc_rg.sequence_num := po_tbl_number (1);
    asl_doc_rg.document_type_code := po_tbl_varchar25(null);
    asl_doc_rg.document_type_dsp:= po_tbl_varchar50(NULL);
    asl_doc_rg.document_header_id := po_tbl_number (NULL);
    asl_doc_rg.document_header_dsp:= po_tbl_varchar50(NULL);
    asl_doc_rg.document_line_id := po_tbl_number (null);
    asl_doc_rg.document_line_num_dsp:= po_tbl_number(1);
    asl_doc_rg.attribute_category := po_tbl_varchar30(null);
    asl_doc_rg.attribute1 := po_tbl_varchar240(null);
    asl_doc_rg.attribute2 := po_tbl_varchar240(null);
    asl_doc_rg.attribute3 := po_tbl_varchar240(null);
    asl_doc_rg.attribute4 := po_tbl_varchar240(null);
    asl_doc_rg.attribute5 := po_tbl_varchar240(null);
    asl_doc_rg.attribute6 := po_tbl_varchar240(null);
    asl_doc_rg.attribute7 := po_tbl_varchar240(null);
    asl_doc_rg.attribute8 := po_tbl_varchar240(null);
    asl_doc_rg.attribute9 := po_tbl_varchar240(null);
    asl_doc_rg.attribute10:= po_tbl_varchar240(null);
    asl_doc_rg.attribute11:= po_tbl_varchar240(null);
    asl_doc_rg.attribute12:= po_tbl_varchar240(null);
    asl_doc_rg.attribute13:= po_tbl_varchar240(null);
    asl_doc_rg.attribute14:= po_tbl_varchar240(null);
    asl_doc_rg.attribute15:= po_tbl_varchar240(null);
    asl_doc_rg.request_id := po_tbl_number(null);
    asl_doc_rg.program_application_id := po_tbl_number(null);
    asl_doc_rg.program_id := po_tbl_number(null);
    asl_doc_rg.program_update_date:= po_tbl_date(null);
    asl_doc_rg.org_id := po_tbl_number(NULL);
*/

    -- Populating values in asl_auto_rg
    /*asl_auto_rg := new chv_authorizations_rec();
    asl_auto_rg.USER_KEY := po_tbl_number(1);
    asl_auto_rg.PROCESS_ACTION := po_tbl_varchar30('ADD'); 
    asl_auto_rg.USING_ORGANIZATION_ID:= po_tbl_number(-1);
    asl_auto_rg.USING_ORGANIZATION_DSP := po_tbl_varchar240(NULL);
    asl_auto_rg.AUTHORIZATION_CODE := po_tbl_varchar25(NULL);
    asl_auto_rg.AUTHORIZATION_CODE_DSP := po_tbl_varchar50('Raw Materials');
    asl_auto_rg.AUTHORIZATION_SEQUENCE_DSP := po_tbl_number(3);
    asl_auto_rg.TIMEFENCE_DAYS_DSP := po_tbl_number(8.95);
    asl_auto_rg.ATTRIBUTE_CATEGORY := po_tbl_varchar30(NULL);
    asl_auto_rg.ATTRIBUTE1 := po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE2 := po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE3 := po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE4 := po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE5 := po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE6 := po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE7 := po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE8 := po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE9 := po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE10:= po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE11:= po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE12:= po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE13:= po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE14:= po_tbl_varchar240(NULL);
    asl_auto_rg.ATTRIBUTE15:= po_tbl_varchar240(NULL);
    asl_auto_rg.REQUEST_ID := po_tbl_number(NULL);
    asl_auto_rg.PROGRAM_APPLICATION_ID := po_tbl_number(NULL);
    asl_auto_rg.PROGRAM_ID := po_tbl_number(NULL);
    asl_auto_rg.PROGRAM_UPDATE_DATE:= po_tbl_date(NULL);
*/

    --Populating values in psicrec
    /*psicrec := NEW po_supplier_item_capacity_rec();
    psicrec.user_key := po_tbl_number(1);
    psicrec.process_action := po_tbl_varchar30('ADD'); 
    psicrec.using_organization_id:= po_tbl_number(-1);
    psicrec.using_organization_dsp := po_tbl_varchar240(NULL);
    psicrec.from_date_dsp:= po_tbl_date('20-JUL-2012');
    psicrec.to_date_dsp:= po_tbl_date('20-DEC-2012');
    psicrec.capacity_per_day_dsp := po_tbl_number(8.95);
    psicrec.attribute_category := po_tbl_varchar30(null);
    psicrec.attribute1 := po_tbl_varchar240(null);
    psicrec.attribute2 := po_tbl_varchar240(null);
    psicrec.attribute3 := po_tbl_varchar240(null);
    psicrec.attribute4 := po_tbl_varchar240(null);
    psicrec.attribute5 := po_tbl_varchar240(null);
    psicrec.attribute6 := po_tbl_varchar240(null);
    psicrec.attribute7 := po_tbl_varchar240(null);
    psicrec.attribute8 := po_tbl_varchar240(null);
    psicrec.attribute9 := po_tbl_varchar240(null);
    psicrec.attribute10:= po_tbl_varchar240(null);
    psicrec.attribute11:= po_tbl_varchar240(null);
    psicrec.attribute12:= po_tbl_varchar240(null);
    psicrec.attribute13:= po_tbl_varchar240(null);
    psicrec.attribute14:= po_tbl_varchar240(null);
    psicrec.attribute15:= po_tbl_varchar240(null);
    psicrec.request_id := po_tbl_number(null);
    psicrec.program_application_id := po_tbl_number(null);
    psicrec.program_id := po_tbl_number(null);
    psicrec.program_update_date:= po_tbl_date(NULL);
*/

    --Populating values in asl_tlrnce_rg
    /*asl_tlrnce_rg := new po_supplier_item_tolerance_rec();
    asl_tlrnce_rg.USER_KEY := po_tbl_number(1);
    asl_tlrnce_rg.PROCESS_ACTION := po_tbl_varchar30('ADD');
    asl_tlrnce_rg.USING_ORGANIZATION_ID:= po_tbl_number(-1);
    asl_tlrnce_rg.USING_ORGANIZATION_DSP := po_tbl_varchar240(NULL);
    asl_tlrnce_rg.NUMBER_OF_DAYS_DSP := po_tbl_number(5.62);
    asl_tlrnce_rg.TOLERANCE_DSP:= po_tbl_number(6.358);
    asl_tlrnce_rg.ATTRIBUTE_CATEGORY := po_tbl_varchar30(NULL);
    asl_tlrnce_rg.ATTRIBUTE1 := po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE2 := po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE3 := po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE4 := po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE5 := po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE6 := po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE7 := po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE8 := po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE9 := po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE10:= po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE11:= po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE12:= po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE13:= po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE14:= po_tbl_varchar240(NULL);
    asl_tlrnce_rg.ATTRIBUTE15:= po_tbl_varchar240(NULL);
    asl_tlrnce_rg.REQUEST_ID := po_tbl_number(NULL);
    asl_tlrnce_rg.PROGRAM_APPLICATION_ID := po_tbl_number(NULL);
    asl_tlrnce_rg.PROGRAM_ID := po_tbl_number(NULL);
    asl_tlrnce_rg.PROGRAM_UPDATE_DATE:= po_tbl_date(NULL);*/

    PO_ASL_API_PUB.create_update_asl (p_asl_rec    =>  asl_rg,
                p_asl_attr_rec   =>  asl_attr_rg,
                p_asl_doc_rec    =>  asl_doc_rg,
                p_chv_auth_rec   =>  asl_auto_rg,
                p_capacity_rec   =>  psicrec,
                p_tolerance_rec  =>  asl_tlrnce_rg,
                p_commit         =>  'N',
                x_session_key    =>  x_session_key,
                x_return_status  =>  x_return_status,
                x_return_msg     =>  x_return_msg,
                x_errors         =>  x_errors
    );

    Dbms_Output.put_line('Session Key>>>>  ' || x_session_key);
    Dbms_Output.put_line('Return Status>>>>' || x_return_status);
    Dbms_Output.put_line('Return Msg>>>>   ' || x_return_msg);

    for i in 1 .. x_errors.user_key.Count loop
     Dbms_Output.put_line('Session Key:  ' || x_errors.session_key(i) || '    user key:' ||x_errors.user_key(i) || '   entity:' ||x_errors.entity_name(i) || '   reason:' ||x_errors.rejection_reason(i));
    end loop;

    for j in 1 .. asl_rg.user_key.Count loop
     Dbms_Output.put_line('user key:' || asl_rg.user_key(j) || '  status:' || asl_rg.process_status(j));
    end loop;
END;