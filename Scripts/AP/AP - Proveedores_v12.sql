
--
-- Datos de Configuración de Proveedors -> Sucursales -> Datos Bancarios
-- 
-- Copyright 2015 Gerardo's High Technology Corporation

--create table grp_borrame_02 (orden number(15), texto varchar2(4000) );

truncate table bolinf.grp_borrame_01
/


DECLARE

v_supplier_metodo_pago      varchar2(50);
v_assignment_level          varchar2(100);
v_contador                  number(15):=0;

CURSOR c_suppliers IS
    SELECT 
         decode(prv.vendor_type_lookup_code, 
                       'EMPLOYEE', 'Empleados Internos',
                       'Proveedor standard'                                    
                       )                        Tipo_Proveedor                --1 STD
        ,prv.vendor_name                        Nombre                         --2
        ,prv.segment1                           Numero                         --3
        ,num_1099                               Taxpayer_ID                    --6        
        ,prv.attribute1                         ASN_ID                         --7        
        ,prv.attribute2                         Clasificacion                  --8
        ,prv.attribute3                         Familia                        --9
        ,prv.attribute4                         SUB_Familia                    --10
        ,prv.attribute5                         Tipo_Tercero                   --11
        ,prv.attribute6                         Tipo_Operacion                 --12
        ,prv.attribute8                         Unidades_Ariba                 --13
        ,prv.vendor_name_alt                    Nombre_Alterno                 --14
        ,decode(prv.vendor_type_lookup_code,
                      'VENDOR', 'Proveedor',
                      'COMPANY', 'Compañia',
                      'PERSONA FISICA', 'Persona Física',
                      'INTERCOMPANY', 'Intercompañia',
                      'EMPLOYEE', 'Empleado',
                       prv.vendor_type_lookup_code
                 )                             Tipo                           --15
        ,ter.territory_short_name               Tax_Country                    --4
        ,prv.vat_registration_num               Registro_Impositivo            --5        
        ,ptp.process_for_applicability_flag     Aplicabilidad_Tax             --50
        ,case
            when prv.inspection_required_flag = 'N' and prv.receipt_required_flag='N' then '2-Direcciones'
            when prv.inspection_required_flag = 'N' and prv.receipt_required_flag='Y' then '3-Direcciones'
            when prv.inspection_required_flag = 'Y' and prv.receipt_required_flag='Y' then '4-Direcciones'
        end RcvMatchAppr
        ,decode(prv.match_option,
                      'R','Recepcion',
                      'P','Compra', 
                      prv.match_option)                                 Asociacion_Facturas
        ,prv.invoice_currency_code                                      Factura_Divisa
        ,prv.payment_currency_code                                      Pago_Divisa      
        ,prv.payment_priority                                           Pago_Prioridad
        ,trm.name                                                       Termino_Pago
        ,decode(prv.TERMS_DATE_BASIS,
                     'Current','Sistema',
                     'Invoice','Factura',
                     'Invoice Received', 'Recepcion de Facturas',    
                     'Goods Received', 'Recepcion de Mercaderia',                 
                      prv.TERMS_DATE_BASIS )                            Base_Fecha_Plazo
        ,decode(prv.pay_date_basis_lookup_code,                                 
                     'DUE','Vencido',
                     'DISCOUNT','Descuento',
                     prv.pay_date_basis_lookup_code)                    Base_Fecha_Pago  
        ,prv.pay_group_lookup_code                                      Grupo_Pago             
        ,prv.vendor_id
        ,hp.party_id
    FROM ap_suppliers            prv
         ,hz_parties             hp
         ,zx_party_tax_profile   ptp
         ,fnd_territories_vl     ter         
         ,ap_terms               trm         
    WHERE 1=1 
      and prv.party_id = hp.party_id
      and ptp.party_type_code = 'THIRD_PARTY'
      and prv.party_id = ptp.party_id
      and ptp.country_code = ter.territory_code (+)
      and prv.terms_id = trm.term_id (+)     
      and nvl(prv.enabled_flag,'x') = 'Y'
      and nvl(prv.end_date_active,sysdate+1) > sysdate   
--  and prv.vendor_name in (
--    'AXA SEGUROS SA DE CV',
--    'CASA LUX EQUIPO Y MOBILIARIO SA DE CV',
--    'CENTRO DE SOPORTE CONTINUO MAQUINARIA Y EQUIPO SA DE CV'
--    )  
    ;

cursor c_supplier_sites (p_prv_id number) is
    SELECT 
         ter.territory_short_name       Pais                          --16
        ,site.address_line1             Linea_Domicilio1              --17
        ,site.address_line2             Linea_Domicilio2              --18
        ,site.address_line3             Linea_Domicilio3              --19
        ,site.address_line4             Linea_Domicilio4              --20
        ,site.city                      Ciudad                        --21
        ,site.county                    Distrito                      --22
        ,site.state                     Estado                        --23
        ,site.zip                       CP                            --24
        ,site.vendor_site_code          Nombre_Domicilio              --25
        ,site.area_code                 Codigo_Area_Telefono          --26
        ,site.phone                     Numero_Telefono               --27
        ,site.email_address             Correo_Electronico            --28
        ,site.purchasing_site_flag      Proposito_Domicilio_Compra    --29
        ,site.pay_site_flag             Proposito_Domicilio_Pago      --30
        ,ou.name                        Unidad_Operativa              --31 
        ,site.vendor_site_code          Nombre_Sucursal               --32        
        ,fnd_flex_ext.get_segs ('SQLGL','GL#', 50393, site.accts_pay_code_combination_id)      cuenta_pasivo
        ,fnd_flex_ext.get_segs ('SQLGL','GL#', 50393, site.prepay_code_combination_id)         cuenta_anticipo
        ,site.auto_tax_calc_flag        Calcular_Tax                  --51
        ,site.vat_code                  Clasificacion_Tax             --52
        ,hrl.location_code              Ship_Address                  --53
        ,bill.location_code             Bill_Address                  --54
        ,lg.name                        Mayor
        ,site.invoice_currency_code     Factura_Divisa
        ,site.payment_currency_code     Pago_Divisa
        ,site.attribute2                Ref_Bancaria
        ,decode(site.match_option,'R','Recepcion','P','Compra', 'x')     Asociacion_Facturas
        ,site.payment_priority                                           Pago_Prioridad
        ,trm.name                                                        Termino_Pago
        ,decode(site.TERMS_DATE_BASIS,
                     'Current','Sistema',
                     'Invoice','Factura',
                     'Invoice Received', 'Recepcion de Facturas',    
                     'Goods Received', 'Recepcion de Mercaderia',                 
                      site.TERMS_DATE_BASIS )                            Base_Fecha_Plazo
        ,decode(site.pay_date_basis_lookup_code,                                 
                     'DUE','Vencido',
                     'DISCOUNT','Descuento',
                     site.pay_date_basis_lookup_code)                    Base_Fecha_Pago  
        ,site.pay_group_lookup_code                                      Grupo_Pago        
        ,hps.party_site_name                                             Supplier_Site_Name
        ,site.vendor_site_id        
        ,site.party_site_id
        ,site.org_id        
    FROM ap_supplier_sites_all      site
        ,hz_party_sites             hps
        ,hr_operating_units         ou
        --,hr_all_organization_units  OU
        ,gl_ledgers                 lg
        ,hr_locations               hrl
        ,hr_locations               bill
        ,ap_terms                   trm 
        ,fnd_territories_vl         ter
    WHERE 1=1
      and site.party_site_id = hps.party_site_id
      and site.org_id        = ou.organization_id
      and ou.set_of_books_id = lg.ledger_id
      and site.ship_to_location_id = hrl.location_id(+)
      and site.bill_to_location_id = bill.location_id(+)
      and site.terms_id     = trm.term_id (+)
      and site.country      = ter.territory_code
      and site.vendor_id    = p_prv_id
    ;


CURSOR c_supplier_datos_bancarios (p_party_id number)
is
SELECT decode(pm.payment_method_code,
                'CHECK', 'Cheque',
                'EFT', 'Electronico' ,
                'OUTSOURCED_CHECK', 'Cheque Externo',
                pm.payment_method_code
                ) Metodo_Pago
       ,Decode(epa.supplier_site_id, 
              NULL,  Decode(epa.org_id,
                             NULL,  Decode(epa.party_site_id,
                                            NULL, 'Supplier',
                                            'Address'),
                             'Address-Operating unit'), 
              'Site') assignment_level                
    FROM iby_external_payees_all      epa
       , apps.iby_pmt_instr_uses_all  piu
       , iby_ext_party_pmt_mthds      pm
    WHERE 1=1
      and epa.ext_payee_id  = piu.ext_pmt_party_id(+)
      AND epa.ext_payee_id  = pm.ext_pmt_party_id     (+)
      and pm.primary_flag  (+) = 'Y'      
      and epa.supplier_site_id is null
      and epa.payee_party_id = p_party_id      
      ;



CURSOR c_site_datos_bancarios (p_supplier_site_id number) IS
    SELECT 
         null                         Nivel        --39
        ,ter.territory_short_name     Pais         --40
        ,bank.bank_name               Banco        --41
        ,branch.bank_branch_name      Sucursal     --42
        ,branch.bank_branch_type      Tipo         --43
        ,eba.bank_account_num         Cuenta       --44       
        ,eba.currency_code            Divisa       --45
        ,eba.attribute1               Numero_ABA   --46
        ,eba.attribute2               Numero_Swift --47
        ,decode(pm.payment_method_code,
                    'CHECK', 'Cheque',
                    'EFT', 'Electronico' ,
                    'OUTSOURCED_CHECK', 'Cheque Externo',
                    pm.payment_method_code
                ) Metodo_Pago        
        ,piu.order_of_preference      Orden_Preference
        ,own.primary_flag             Cuenta_Primaria 
    FROM iby_external_payees_all      epa
       , iby_ext_party_pmt_mthds      pm    
       , apps.iby_pmt_instr_uses_all  piu
       , apps.iby_ext_bank_accounts   eba
       , apps.iby_ext_banks_v         bank
       , apps.iby_ext_bank_branches_v branch
       , iby_account_owners           own
       , fnd_territories_vl         ter
    WHERE 1=1
      and epa.ext_payee_id  = pm.ext_pmt_party_id (+) 
      and pm.primary_flag  (+) = 'Y'
      and epa.ext_payee_id  = piu.ext_pmt_party_id    (+)
      and piu.instrument_id = eba.ext_bank_account_id (+)
      and eba.bank_id       = bank.bank_party_id      (+)
      and eba.bank_id       = branch.bank_party_id    (+)
      and eba.branch_id     = branch.branch_party_id  (+)
      and eba.ext_bank_account_id = own.ext_bank_account_id (+)
      and bank.country      = ter.territory_code (+)
      and epa.supplier_site_id = p_supplier_site_id
        ;


BEGIN

--
--DBMS_OUTPUT.put_line (
--'Tipo de proveedor|'||    'Nombre Organización|'||    'Número de Proveedor|'||    'País de Impuesto|'||    'Número de registro Impositivo|'||    'ID de Contribuyente|'||    'ASN ID|'||    'CLASIFICACIÓN|'||    'FAMILIA|'||    'SUB_FAMILIA|'||    'TIPO_DE_TERCERO|'||    'TIPO_DE_OPERACIÓN|'||    'UNIDADES ARIBA|'||    'Nombre de Proveedor alterno|'||    'Tipo|'||    'Pais|'||    'LInea de Domicilio 1|'||    'LInea de Domicilio 2|'||    'LInea de Domicilio 3|'||    'LInea de Domicilio 4|'||    'Ciudad|'||    'Distrito|'||    'Estado|'||    'Código Postal|'||    'Nombre de Domicilio|'||    'Código de Área de Teléfono|'||    'Número de Teléfono|'||    'Dirección de Correo Electrónico|'||    'Propósito de Domicilio – Compra|'||    'Propósito de Domicilio – Pago |'||    'Unidad Operativa|'||    'Nombre de Sucursal|'||    'Primer Nombre|'||    'Segundo Nombre|'||    'Apellido|'||    'Dirección de Correo Electrónico|'||    'Código de Área de Teléfono|'||    'Número de Teléfono|'||    'NIVEL|'||    'País|'||    'Nombre del Banco|'||    'Nombre Sucursal|'||    'Tipo Sucursal|'||    'Numero de Cuenta|'||    'Divisa|'||    'Número ABA|'||    'Número Swift|'||    'CUENTA PRIMARIA|'||    'Mayor|'||    'Cuenta de Pasivo|'||    'Anticipo|'||    'Autorizar Aplicabilidad de Impuesto|'||    'Calcular Impuesto|'||    'Clasificación de Impuesto|'||    'Dirección de Envío|'||    'Dirección de Facturación|'||    'Asociar Nivel de Aprobación|'||    'Metodo de Pago por Default|'||    'Divisa de Factura|'||    'Opción Asociación de Facturas|'||    'Divisa de Pago|'||    'Prioridad de Pago|'||    'Términos de Pago|'||    'Base de Fecha de Plazo|'||    'Base de Fecha de Pago|'||    'Grupo de Pago|'||    'Referencia Bancaria|'||    'Email|'||    'Nombre Contacto|'||    'Metodo de Pago por Default|'||    'Opción Asociación de Facturas|'||    'Divisa de Factura|'||    'Prioridad de Pago|'||    'Grupo de Pago|'||    'Términos de Pago|'||    'Base de Fecha de Plazo|'||    'Base de Fecha de Pago|'
--);

insert into grp_borrame_02 values (
0,
'Tipo Prov|'||    
'Organización|'||    
'Num Prov|'||    
'Pais Impuesto|'||    
'Reg. Impositivo|'||    
'ID Contribuyente|'||    
'ASN ID|'||    
'Clasificacion|'||    
'Familia|'||    
'SUB_Familia|'||    
'Tipo_Tercero|'||    
'Tipo_Operacion|'||    
'Unidades Ariba|'||    
'Nombre Alterno|'||    
'Tipo|'||    
'Pais|'||    
'Linea Domicilio 1|'||    
'Linea Domicilio 2|'||    
'Linea Domicilio 3|'||    
'Linea Domicilio 4|'||    
'Ciudad|'||    'Distrito|'||    'Estado|'||    'CP|'||    'Nombre Domicilio|'||    
'Codigo Area|'||    'Telefono|'||    
'Correo Electronico|'||    
'Proposito Domicilio–Compra|'||    
'Proposito Domicilio–Pago |'||    
'Unidad Operativa|'||    'Nombre Sucursal|'||    'Primer Nombre|'||    'Segundo Nombre|'||    'Apellido|'||    'Correo Electrónico|'||    
'Código Area|'||    
'Teléfono|'||    
'Nivel|'||    'Pais|'||    'Banco|'||    'Sucursal|'||    'Tipo Sucursal|'||    'Numero Cuenta|'||    
'Divisa|'||    'Numero ABA|'||    'Numero Swift|'||    'Cuenta Primaria|'||    
'Mayor|'||    'Cuenta Pasivo|'||    'Anticipo|'||    
'Autorizar Aplicabilidad Impuesto|'||    
'Calcular Impuesto|'||    'Clasificacion Impuesto|'||    'Direccion Envio|'||    'Dirección Facturación|'||    
'Asociar Nivel Aprobacion|'||    
'Metodo Pago Default|'||    
'Divisa Factura|'||    
'Opcion Asociacion Facturas|'||    
'Divisa Pago|'||    
'Prioridad Pago|'||    
'Terminos Pago|'||    
'Base Fecha Plazo|'||    
'Base Fecha Pago|'||    
'Grupo de Pago|'||    
'Referencia Bancaria|'||    
'Email|'||    'Nombre Contacto|'||    'Metodo Pago Default|'||    
'Opcion Asociacion Facturas|'||    'Divisa Factura|'||    'Prioridad de Pago|'||    'Grupo Pago|'||    'Términos Pago|'||    
'Base Fecha Plazo|'||    'Base Fecha Pago|end'
);

    FOR c_supplier in c_suppliers LOOP

        open c_supplier_datos_bancarios (c_supplier.party_id);
        fetch c_supplier_datos_bancarios into v_supplier_metodo_pago, v_assignment_level;
        close c_supplier_datos_bancarios;

        FOR c_site in c_supplier_sites (c_supplier.vendor_id) LOOP
            FOR c_banco in c_site_datos_bancarios (c_site.vendor_site_id) LOOP
            
                v_contador := v_contador + 1;
                
                insert into grp_borrame_02 values (
                                      v_contador,
                                      c_supplier.Tipo_Proveedor     ||'|'||
                                      c_supplier.Nombre             ||'|'||
                                      c_supplier.Numero             ||'|'||
                                      c_supplier.Tax_Country        ||'|'|| 
                                      c_supplier.Registro_Impositivo||'|'|| 
                                      c_supplier.Taxpayer_ID        ||'|'||
                                      c_supplier.ASN_ID             ||'|'||
                                      c_supplier.Clasificacion      ||'|'||
                                      c_supplier.Familia            ||'|'||
                                      c_supplier.Sub_Familia        ||'|'||
                                      c_supplier.Tipo_Tercero       ||'|'||
                                      c_supplier.Tipo_Operacion     ||'|'||
                                      c_supplier.Unidades_Ariba     ||'|'||
                                      c_supplier.Nombre_Alterno     ||'|'||
                                      c_supplier.Tipo               ||'|'||
                                      c_site.Pais                   ||'|'||
                                      c_site.Linea_Domicilio1       ||'|'||
                                      c_site.Linea_Domicilio2       ||'|'||
                                      c_site.Linea_Domicilio3       ||'|'||
                                      c_site.Linea_Domicilio4       ||'|'||
                                      c_site.Ciudad                 ||'|'||
                                      c_site.Distrito               ||'|'||
                                      c_site.Estado                 ||'|'||
                                      c_site.CP                     ||'|'||
                                      c_site.Supplier_Site_Name     ||'|'||
                                      c_site.Codigo_Area_Telefono   ||'|'||
                                      c_site.Numero_Telefono               ||'|'||
                                      c_site.Correo_Electronico            ||'|'||
                                      c_site.Proposito_Domicilio_Compra    ||'|'||
                                      c_site.Proposito_Domicilio_Pago      ||'|'||
                                      c_site.Unidad_Operativa              ||'|'||
                                      c_site.Nombre_Sucursal               ||'|'||
                                      '|||||'                              ||'|'|| --datos de contacto
                                      v_assignment_level                   ||'|'|| --nivel
                                      c_banco.Pais                         ||'|'|| 
                                      c_banco.Banco                        ||'|'||
                                      c_banco.Sucursal                     ||'|'||
                                      c_banco.Tipo                         ||'|'||
                                      c_banco.Cuenta                       ||'|'||
                                      c_banco.Divisa                       ||'|'||
                                      c_banco.Numero_ABA                   ||'|'||
                                      c_banco.Numero_Swift                 ||'|'||
                                      c_banco.Orden_Preference             ||'|'|| 
                                      c_site.Mayor                         ||'|'|| 
                                      c_site.Cuenta_Pasivo                 ||'|'||
                                      c_site.Cuenta_Anticipo               ||'|'||
                                      c_supplier.Aplicabilidad_Tax         ||'|'||
                                      c_site.Calcular_Tax                  ||'|'||
                                      c_site.Clasificacion_tax             ||'|'||
                                      c_site.Ship_Address                  ||'|'||
                                      c_site.Bill_Address                  ||'|'||
                                      c_supplier.RcvMatchAppr              ||'|'||
                                      v_supplier_metodo_pago               ||'|'|| -- Supplier: metodo de pago
                                      c_supplier.Factura_Divisa            ||'|'||
                                      c_supplier.Asociacion_Facturas       ||'|'||
                                      c_supplier.Pago_Divisa               ||'|'||                                                                          
                                      c_supplier.Pago_Prioridad            ||'|'||
                                      c_supplier.Termino_Pago              ||'|'||
                                      c_supplier.Base_Fecha_Plazo          ||'|'||
                                      c_supplier.Base_Fecha_Pago           ||'|'||
                                      c_supplier.Grupo_Pago                ||'|'||
                                      c_site.Ref_Bancaria                  ||'|'||
                                      ''                                   ||'|'|| --email site
                                      ''                                   ||'|'|| --contacto site
                                      c_banco.Metodo_Pago                  ||'|'|| -- Site: metodo de pago 
                                      c_site.Asociacion_Facturas           ||'|'||
                                      c_site.Factura_Divisa                ||'|'||                                                                                                                                                      
                                      c_site.Pago_Prioridad                ||'|'||
                                      c_site.Grupo_Pago                    ||'|'||
                                      c_site.Termino_Pago                  ||'|'||
                                      c_site.Base_Fecha_Plazo              ||'|'||
                                      c_site.Base_Fecha_Pago              
                                      --c_site.Pago_Divisa                                                
                                      );        
                                                        
            END LOOP; -- c_datos_bancarios
        END LOOP; --c_supplier_sites
    END LOOP; -- c_suppliers

    COMMIT;

END;

/

--SET SERVEROUTPUT off
--
--SET ARRAYSIZE 3000
--SET COLSEP    '|'     
--SET RECSEP    OFF    
--SET PAGESIZE  0 EMBEDDED ON
--SET LINESIZE  2000    
--SET WRAP      OFF      
--SET TRIMOUT   ON       
--SET TRIMSPOOL ON       
--SET TERMOUT   OFF        
--SET HEADING   OFF
--
--SPOOL "C:\PROVEEDORES.TXT"

select texto
from grp_borrame_02
order by orden
;

---SPOOL OFF


