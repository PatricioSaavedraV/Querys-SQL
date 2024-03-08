-- Empresas con errores de saldo en facturas de compra
SELECT 
	COUNT(DISTINCT s.empresa_id) AS Q_empresas
FROM 
	saldos s 
JOIN
	empresas e ON e.id = s.empresa_id 
    and e.activa = 1	
    and e.id <> 8	
    and e.razon_social NOT LIKE '%stark%' -- Empresas activas y quitando Chipax (8) y starks --
JOIN
	compras c ON c.id = s.foreign_key 
    and c.tipo in (33,34) 
    and c.estado_compra_id NOT IN (3,4) -- Solo FAC-EL y FAC-EE --
WHERE 
	s.modelo = 'Compra'
	and s.saldo_deudor > 2 -- Facturas de compra con saldo negativo mayor a $-2 --
	and s.last_record = 1
	
-- Empresas con errores de saldo en facturas de venta
SELECT 
	DISTINCT s.empresa_id,
	COUNT(s.id)  
FROM 
	saldos s 
JOIN
	empresas e ON e.id = s.empresa_id 
    and e.activa = 1	
    and e.id <> 8	
    and e.razon_social NOT LIKE '%stark%' -- Empresas activas y quitando Chipax (8) y starks --
JOIN
	dtes d ON d.id = s.foreign_key 
    and d.tipo in (33,34) -- Solo FAC-EL y FAC-EE --
WHERE 
	s.modelo = 'Dte'
	and s.saldo_acreedor > 2 -- Facturas de venta con saldo negativo mayor a $-2 --
	and s.last_record = 1
GROUP BY 
	s.empresa_id 
	
-- Empresas con errores de saldo en facturas de compra y venta
SELECT 
	-- Count(DISTINCT empresa_id)
    empresa_id, 
    COUNT(DISTINCT CASE WHEN modelo = 'Compra' THEN foreign_key END) AS Q_facturas_compra,
    COUNT(DISTINCT CASE WHEN modelo = 'Dte' THEN foreign_key END) AS Q_facturas_venta
FROM (
    SELECT 
        s.empresa_id,
        s.foreign_key,
        s.modelo
    FROM 
        saldos s 
    JOIN
        empresas e ON e.id = s.empresa_id 
        AND e.activa = 1 
        AND e.id <> 8
        AND e.razon_social NOT LIKE '%stark%'
    JOIN
        compras c ON c.id = s.foreign_key 
        AND c.tipo IN (33,34) 
        AND c.estado_compra_id NOT IN (3,4)
    WHERE 
        s.modelo = 'Compra'
        AND s.saldo_deudor > 2
        AND s.last_record = 1
    UNION
    SELECT 
        s.empresa_id,
        s.foreign_key,
        s.modelo
    FROM 
        saldos s 
    JOIN
        empresas e ON e.id = s.empresa_id 
        AND e.activa = 1 
        AND e.id <> 8
        AND e.razon_social NOT LIKE '%stark%'
    JOIN
        dtes d ON d.id = s.foreign_key 
        AND d.tipo IN (33,34)
    WHERE 
        s.modelo = 'Dte'
        AND s.saldo_acreedor > 2
        AND s.last_record = 1
) AS combined_data
GROUP BY 
	empresa_id;