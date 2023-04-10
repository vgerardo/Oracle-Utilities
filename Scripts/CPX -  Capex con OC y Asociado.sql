
alter session set nls_language ='AMERICAN'
   
  
--
--Reporte de Códigos CAPEX, se basó en BOLINF.csa_detalle_compras          
--          
SELECT distinct cpv.po_header_id,cc.attribute1 iniciativa
       ,cc.codigo_capex
       ,cc.descripcion
       ,ltc.description tipo
       ,p.descripcion proyecto
       ,cia.nombre empresa
       ,lg.description grupo
       ,cc.status activo
       ,DECODE (cc.presupuesto,
                'Y', 'Con Presupuesto',
                'N', 'Sin Presupuesto'
                ) presupuesto
       ,cc.tipo_cambio
       ,cpd.descripcion descripcion_partida
       ,cp.monto_usd
       ,cp.monto_mxp
       ,cp.comentario
       ,cc.creation_date fecha_creacion
       ,SUM(cpv.monto_aprobado) aprobado
       ,SUM(cpv.monto_enproceso) en_proceso
       --,SUM(cpcv.monto_movimiento) movimientos
       ,cpcv.monto_movimiento movimientos
       ,cpcv.disponible
       ,cpv.numero_oc
       ,csa_tools.GET_IMP_OC_CAPEX(cpv.po_header_id,'OC') importe_oc
       ,csa_tools.GET_IMP_OC_CAPEX(cpv.po_header_id,'FAC') importe_asoc
  FROM bolinf.csa_cpx_capex cc
       ,bolinf.csa_cpx_proyectos p
       ,apps.fnd_lookup_values_vl ltc
       ,apps.fnd_lookup_values_vl lg
       ,bolinf.csa_cpx_cia_v cia
       ,bolinf.csa_cpx_partidas cp
       ,bolinf.csa_cpx_partidas_desc cpd
       ,bolinf.CSA_CPX_POH_V cpv
       ,csa_cpx_po_capex_p_v cpcv
 WHERE 1=1
   AND cc.status = 'Y'
   AND cpcv.disponible <> 0
--   and cpv.numero_oc = '1979109'
   --AND cc.CODIGO_CAPEX  = 'FISUR-2603-1'
   AND ltc.lookup_type = 'CSA_CPX_TIPO_CAPEX'
   AND ltc.lookup_code = cc.tipo_capex
   AND cc.clave_proyecto = p.clave
   AND lg.lookup_type like 'CSA_CPX_GRUPO%'
   AND lg.lookup_code = cc.grupo
   AND cia.empresa_id = cc.empresa_id
   AND cc.capex_id = cp.capex_id
   AND cp.partida_desc_id = cpd.partida_desc_id
   AND cpv.capex_id = cc.capex_id
   AND cpv.partida_id (+) = cp.partida_id
   AND cpcv.capex_id (+) = cc.capex_id
   AND cpcv.partida_id = cp.partida_id
   GROUP BY cpv.po_header_id, 
       cc.attribute1
       ,cc.codigo_capex
       ,cc.descripcion
       ,ltc.description
       ,p.descripcion
       ,cia.nombre
       ,lg.description
       ,cc.status
       ,cc.presupuesto
       ,cc.tipo_cambio
       ,cpd.descripcion
       ,cp.monto_usd
       ,cp.monto_mxp
       ,cp.comentario
       ,cc.creation_date
       ,cpcv.monto_movimiento
       ,cpcv.disponible
       , cpv.numero_oc
   ;
   
