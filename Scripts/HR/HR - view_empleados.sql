DROP VIEW BOLINF.CSA_CONE_EMPLEADOS_V;


/* Formatted on 2009/06/08 09:52:05 a.m. (QP5 v5.115.810.9015) */
CREATE OR REPLACE FORCE VIEW BOLINF.CSA_CONE_EMPLEADOS_V
(
   PERSON_ID,
   FECHA_PK1,
   FECHA_PK2,
   ASSIGNMENT_ID,
   NO_COLABORADOR,
   NOMBRE_COLABORADOR,
   RFC,
   NO_IMSS,
   NO_CRED_INFONAVIT,
   FECHA_NACIMIENTO,
   EMAIL_ADDRESS,
   FECHA_ANTIGUEDAD,
   FECHA_INICIO_VACACIOMES,
   FECHA_FIN_CONTRATO,
   NIVEL,
   CENTRO_COSTOS_ID,
   CENTRO_COSTOS,
   CENTRO_COSTOS_GL,
   NO_PUESTO,
   NOMBRE_PUESTO,
   PERSON_ID_SUPERVISOR,
   NOMINA_ID,
   NOMINA,
   CURP,
   ID_COLABORADOR_ING,
   ID_CONTRATO_ING,
   CLAVE_ING
)
AS
SELECT   DISTINCT
         ppf.person_id,
         ppf.effective_start_date fecha_pk1,
         ppf.effective_end_date fecha_pk2,
         paf.assignment_id assignment_id,
         ppf.employee_number no_colaborador,
         ppf.full_name nombre_colaborador,
         ppf.attribute2 rfc,
         ppf.attribute1 no_imss,
         hkf.segment8 no_cred_infonavit,
         ppf.date_of_birth fecha_nacimiento,
         ppf.email_address,
         NVL (TO_DATE (ppf.attribute5, 'YYYY/MM/DD HH24:MI:SS'),
              pps.date_start)
            fecha_antiguedad,
         NVL (TO_DATE (ppf.attribute8, 'YYYY/MM/DD HH24:MI:SS'),
              pps.date_start)
            fecha_inicio_vacaciomes,
         ppf.effective_end_date fecha_fin_contrato,
         pg.NAME nivel,
         hou.organization_id          centro_costos_id,
         REPLACE (hou.NAME, '-', '')  centro_costos,
         cuentas.gl_cc                centro_costos_gl,
         SUBSTR (hpf.NAME, 1, INSTR (hpf.NAME, '.') - 1) no_puesto,
         hpf.NAME nombre_puesto,
         paf.supervisor_id person_id_supervisor,
         paf.payroll_id nomina_id,
         pap.payroll_name nomina,
         ppf.national_identifier,
         ppf.attribute9 ID_Colaborador_ING,
         ppf.attribute10 ID_Contrato_ING,
         ppf.attribute11 Clave_ING
  FROM   per_all_people_f ppf,
         per_all_assignments_f paf,
         per_periods_of_service pps,
         hr_all_positions_f hpf,
         per_grades pg,
         hr_all_organization_units hou,
         pay_all_payrolls_f pap
         ,hr_soft_coding_keyflex_kfv hkf     
         ,(  --
             -- Este query, a traves del número de asignación devuelve la compañia y centro de costos
             -- donde se envía el costeo de la nómina (en este caso, SUELDO BASE COS)
             -- Cuando el enlace contable no trea el centro de costos, es porque existe un Prorrateo
             --
             SELECT paf.assignment_id                    assignment_id
                  , paf.organization_id                  hr_org_id 
                  , nvl(pca.segment1,pcaf.segment1)      gl_cia
                  , nvl(pca.segment2,pcaf.segment2)      gl_cc
              FROM   per_all_assignments_f          paf,
                     hr_all_organization_units      org,
                     pay_element_links_f            pel,
                     pay_cost_allocation_keyflex    pca,
                     pay_element_types_f            pet,         
                     pay_cost_allocation_keyflex    pcaf,
                     pay_cost_allocations_f         pay
             WHERE   1 = 1 
                 and paf.organization_id            = org.organization_id
                 AND paf.effective_end_date         >= sysdate              
                 AND paf.organization_id            = pel.organization_id(+)
                 AND pel.cost_allocation_keyflex_id = pca.cost_allocation_keyflex_id(+)
                 AND pel.element_type_id            = pet.element_type_id(+)
                 AND (pet.effective_end_date is null OR pet.effective_end_date > SYSDATE)
                 AND (pet.element_name       is null OR pet.element_name = 'Sueldo Base COS')         
                 and paf.assignment_id              = pay.assignment_id (+)      
                 and pay.cost_allocation_keyflex_id = pcaf.cost_allocation_keyflex_id (+)
                 and (pay.effective_end_date is null or pay.effective_end_date >= sysdate)      
                 -- en caso de Prorrateos, solo me interesa un registro.
                 and (pay.proportion is null OR 
                      pay.proportion = (select max(pay2.proportion) 
                                       from pay_cost_allocations_f pay2 
                                       where pay2.assignment_id = paf.assignment_id
                                        and pay2.effective_end_date >= sysdate
                                       )         
                     )                     
                 --and paf.assignment_id = :v_asignacion_id         
         ) cuentas
 WHERE       paf.person_id = ppf.person_id
         AND paf.period_of_service_id = pps.period_of_service_id
         AND paf.position_id = hpf.position_id
         AND paf.grade_id = pg.grade_id
         AND paf.organization_id = hou.organization_id
         AND paf.payroll_id = pap.payroll_id
         AND paf.soft_coding_keyflex_id = hkf.soft_coding_keyflex_id
         AND ppf.person_type_id IN (120)
         AND SYSDATE BETWEEN ppf.effective_start_date
                         AND  ppf.effective_end_date
         AND paf.effective_end_date =
               (SELECT   MAX (paf2.effective_end_date)
                  FROM   per_all_assignments_f paf2
                 WHERE   paf2.person_id = paf.person_id)
         and paf.assignment_id = cuentas.assignment_id
         --and paf.assignment_id =62216
