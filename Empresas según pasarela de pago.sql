SELECT 
	DISTINCT e.id,
	p.nombre
FROM 	
	empresas e 
JOIN 
	compras c ON c.empresa_id = e.id 
JOIN 	
	planes p ON p.id = e.plan_id 
WHERE 
	e.activa = 1	                                 -- Empresas activas -- 
	and e.id <> 8	                                 -- Se quitó a Chipax --
	and e.razon_social NOT LIKE '%stark%'            -- Se quitaron las empresas starks --
	and c.rut_emisor IN ('77190692-3','77398220-1')  -- Compras de Getnet o Mercadolibre -- 
	and c.fecha_emision >= '2023-01-01'              -- Facturas de compras emitidas en 2023 --
	and e.plan_id NOT IN (8, 30, 32);                -- Se quitaron los trials, Chipay y FreeCL --