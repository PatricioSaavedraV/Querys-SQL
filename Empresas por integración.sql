-- Empresas totales activas con acceso al módulo de Integraciones --
SELECT 
	COUNT(DISTINCT e.id) 
FROM 
	empresas e 
WHERE 
	e.activa = 1
	AND e.plan_id in (2,4,6,9,11,13,14,15,16,20,21,22,23,25,26,28,29)

-- Empresas totales activas con acceso al módulo de Integraciones sin integraciones activas --
SELECT 
	COUNT(DISTINCT e.id) 
FROM 
	empresas e 
WHERE 
	e.activa = 1
	AND e.plan_id in (2,4,6,9,11,13,14,15,16,20,21,22,23,25,26,28,29)
	AND e.id NOT IN(SELECT e2.id FROM empresas e2 WHERE e2.usuario_facturador IS NOT NULL and e2.usuario_facturador>'')
	AND e.id NOT IN(SELECT cd.empresa_id FROM credenciales_bsale cd WHERE cd.activa = 1)
	AND e.id NOT IN(SELECT cs.empresa_id FROM credenciales_simpledte cs WHERE cs.activa = 1)
	AND e.id NOT IN(SELECT cb.empresa_id FROM credenciales_buk cb  WHERE cb.activa = 1)
	AND e.id NOT IN(SELECT ct.empresa_id FROM credenciales_talana ct WHERE ct.activa = 1)
	
-- Empresas totales activas con integración conectada del facturador del SII --
SELECT 
	COUNT(DISTINCT e.id) 
FROM 
	empresas e
WHERE 
	e.activa = 1
	AND e.usuario_facturador IS NOT NULL and e.usuario_facturador>''

-- Empresas totales activas con integración conectada de BSALE --
SELECT 
	COUNT(DISTINCT e.id) 
FROM 
	empresas e
LEFT JOIN
	credenciales_bsale cb ON cb.empresa_id = e.id 
WHERE 
	e.activa = 1
	AND cb.activa = 1
	
-- Empresas totales activas con integración conectada de SimpleDTE --
SELECT 
	COUNT(DISTINCT e.id) 
FROM 
	empresas e
LEFT JOIN
	credenciales_simpledte cs ON cs.empresa_id = e.id 
WHERE 
	e.activa = 1
	AND cs.activa = 1
	
-- Empresas totales activas con integración conectada de BUK --
SELECT 
	COUNT(DISTINCT e.id) 
FROM 
	empresas e
LEFT JOIN
	credenciales_buk cb ON cb.empresa_id = e.id 
WHERE 
	e.activa = 1
	AND cb.activa = 1
	
-- Empresas totales activas con integración conectada de Talana --
SELECT 
	COUNT(DISTINCT e.id) 
FROM 
	empresas e
LEFT JOIN
	credenciales_talana ct ON ct.empresa_id = e.id 
WHERE 
	e.activa = 1
	AND ct.activa = 1