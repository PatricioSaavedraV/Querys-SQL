SELECT 
	DISTINCT d.empresa_id,
	u.id,
	u.email 
FROM 
    dtes d
LEFT JOIN 
	empresas e ON e.id = d.empresa_id 
LEFT JOIN 
	saldos s ON d.id = s.foreign_key 
LEFT JOIN 
	usuarios_empresas ue ON ue.empresa_id = e.id 
LEFT JOIN
	usuarios u ON ue.usuario_id = u.id
LEFT JOIN
	grupos g ON g.id = ue.grupo_id  
WHERE 
	u.activo = 1
	AND ue.last_record = 1
	AND g.nombre in ('Super-Admin', 'Administrador')
    AND e.activa = 1 -- Empresas activas --
    AND e.plan_id <> 32 -- Se quitan las empresas con plan free --
    AND d.fecha_emision >= '2023-11-01' -- Dte emitidos desde noviembre 2023 en adelante -- 
  	AND d.fecha_emision <= '2024-01-31'-- Dte emitidos hasta enero 2024 -- 
		AND d.tipo IN (39,41,48) -- Son Dte resúmenes de BOL-EL, BOL-EE y CPE --
    AND d.deleted = 0 -- No son Dtes eliminadas --
   	AND s.modelo = 'Dte' -- Corresponden a modelo Dte -- 
    AND s.last_record = 1 -- Se verifica su saldo actual --
    AND s.saldo_deudor  <> d.monto_total -- Si el s.saldo_deudor y el d.monto total son diferentes, quiere decir que se ha conciliado una parte --
		AND d.monto_corregido = 0 -- Son resúmenes de boletas a las cuales no se han asociado NC o si se asociaron pero se anulo en su totalidad --   
		AND s.saldo_deudor > 0 -- Para quitar los resúmenes de boletas que han sido anuladas en su totalidad, buscamos que su saldo_deudor sea mayor a 0 --
    AND d.empresa_id NOT IN (SELECT empresa_id 
    	FROM credenciales_bsale cb 
    	WHERE cb.activa = 1) -- No tienen Bsale --
    AND d.empresa_id NOT IN (SELECT DISTINCT d2.empresa_id 
    	FROM rango_folios_resumen_boletas rfrb 
    	LEFT JOIN dtes d2 ON d2.id = rfrb.dte_id 
    	WHERE rfrb.created >= '2023-11-01') -- No ha solicitado asociar NC a boletas masivamente -- 
    AND d.empresa_id IN (SELECT d3.empresa_id 
    	FROM dtes d3 
    	LEFT JOIN saldos s ON d3.id = s.foreign_key
    	WHERE d3.tipo IN (56,61) 
    	AND d3.tipo_documento_referencia in (39,41,48) 
    	AND d3.fecha_emision >= '2023-11-01'
    	AND s.modelo = 'Dte'
    	AND s.last_record = 1
		  AND s.saldo_acreedor > 0) -- Tienen NC/ND emitidas posterior a noviembre 2023, con referencia a BOL-EL, BOL-EE y CPE y su s.saldo_acreedor es mayor a 0, por tanto no han sido asociadas a un documento --
ORDER BY
	d.empresa_id ASC