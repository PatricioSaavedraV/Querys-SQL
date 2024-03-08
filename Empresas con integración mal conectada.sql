-- Empresas con la integración al SII mal conectada -- 
SELECT 
	e.id 'Empresa ID',
	e.rut 'Rut empresa',
	e.usuario_facturador 'Credenciales facturador SII',
	cb.activa 'Bsale activo'
FROM 
	empresas e 
LEFT JOIN 
	credenciales_bsale cb on e.id = cb.empresa_id 
WHERE 
	e.activa = 1 
	AND e.razon_social NOT LIKE '%stark%'
	AND ((e.facturador = 'mipyme' 
			AND e.usuario_facturador <> '' 
			AND e.usuario_facturador = e.rut)
	    OR (e.facturador = 'mipyme' 
			AND e.usuario_facturador <> '' 
			AND cb.activa = 1))
	-- Resultado: 95 empresas --

-- Empresas totales con la integración del SII conectada -- 
SELECT 
	COUNT(e.id) 
FROM 
	empresas e 
WHERE 
	e.activa = 1
	AND e.razon_social NOT LIKE '%stark%'
	AND e.facturador = 'mipyme' 
	AND e.usuario_facturador <> ''
-- Resultado: 474 empresas --

-- Conclusión:
-- De total de empresas que tienen conectada la integración con el facturador del SII, 
-- un 20% la tienen mal conectada 