SELECT    PPF.PERSON_ID , hoi.org_information2  Razon_Social   --REG. PATRONAL 
	                  ,hoi.org_information3 Reg_Patronal 
        			  ,LTRIM(RTRIM(NVL(TO_CHAR(hoi.org_information6/100,'0.0000'),'0.0000'))) Prop_Subsidio 
		        	  ,DECODE(hoi.org_information7,'A','01','B','02','C','03','0') Zona_Economica 
        			  ,DECODE (hoi.org_information13, 
                     'AGS','01','BC','02','BCS','03','CAM','04','COAH','05', 
                     'COL','06','CHIS','07','CHIH','08','DF','09','DGO','10', 
                     'GTO','11','GRO','12','HGO','13','JAL','14','MEX','15', 
                     'MICH','16','MOR','17','NAY','18','NL','19','OAX','20', 
                     'PUE','21','QRO','22','QROO','23','SLP','24','SIN','25', 
                     'SON','26','TAB','27','TAMPS','28','TLAX','29','VER','30', 
                     'YUC','31','ZAC','32','0'   ) Entidad_Federativa 
        			  ,DECODE(LENGTH(ppf.national_identifier),18,ppf.national_identifier,'')  CURP -- curp 
		        	  ,RPAD(ppf.attribute2,13,'0')       RFC 
        	          ,ppf.attribute1       No_seg_social --NO SEG SOC 
        			  ,REPLACE(ppf.last_name,'Ñ','N')        Apellidos --Apellidos 
        			  ,REPLACE(ppf.first_name,'Ñ','N')       Nombres -- Nombres 
        			  ,ppf.last_name||' '||ppf.first_name  Empleado 
        			  ,hkf.segment4         Tipo_Trabajador --TIPO TRABAJADOR 
        			  ,hkf.SEGMENT5         Tipo_Salario --TIPO DE SALARIO 1 
                     ,hkf.segment6         Semana_Jornada --SEMANA JORNADA 
                     ,ppf.effective_start_date       Fecha_alta --FECHA MOVTO. 
        			  ,ppf.employee_number  Clave_trabajador --CLAVE TRABAJADOR 
                     ,paf.position_id        Position_id 
                     ,paf.payroll_id         Payroll_id 
                     ,paf.people_group_id    people_group_id 
                   ,paf.business_group_id  business_group_id 
                   ,paf.assignment_id      ass_id 
       			  ,hoi.organization_id 
       			  ,ppf.person_id 
      FROM             per_all_people_f   ppf 
                               ,per_all_assignments_f   paf 
                               ,hr_soft_coding_keyflex_kfv hkf 
                               ,hr_organization_information hoi 
                               ,hr_organization_units_v    houv 
      WHERE       
	   paf.person_id   = ppf.person_id
      AND     paf.primary_flag                = 'Y' 
      AND     paf.assignment_type             = 'E' 
      AND     paf.soft_coding_keyflex_id      = hkf.soft_coding_keyflex_id 
      AND     hkf.segment1                    = TO_CHAR(hoi.organization_id) 
      AND     hoi.org_information_context     = 'MX Informacion Legal' 
      AND     ppf.person_type_id              IN (123) 
      AND     houv.organization_id            = hoi.organization_id 
      AND     TRUNC(ppf.effective_start_date) <= TRUNC(TO_DATE('31-12-'||2005,'DD-MM-YYYY')) 
      AND     hoi.org_information3            = 'SAC980924A73' 
      AND     ppf.business_group_id           = 81
	  AND     ppf.effective_end_date = (SELECT MAX(ppf2.effective_end_date) 
                                                                                FROM per_all_people_f ppf2 
                                                                                WHERE ppf2.person_id = ppf.person_id) 
    AND       paf.effective_end_date = (SELECT MAX(paf2.effective_end_date) 
                                                                                FROM per_all_assignments_f  paf2 
                                                                                WHERE paf2.person_id = paf.person_id)
