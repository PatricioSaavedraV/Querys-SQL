-- TRASPASAR AL BALANCE - MOVIMIENTOS --
SELECT DISTINCT 
	vs.empresa_id
	,c.fecha as 'Fecha del movimiento'
	,c.abono as 'Monto movimiento (abono)'
	,c.cargo as 'Monto movimiento (cargo)'
	,vs.created as 'Fecha del traspaso'
	,vs.monto as 'Validación'
	,c2.nombre as 'Nombre cuenta'
	,tc.nombre as 'Tipo cuenta'
FROM 
	validacion_saldos vs 
INNER JOIN cartolas c on c.id = vs.foreign_key 
INNER JOIN tipos_validaciones tv on vs.tipo_validacion_id = tv.id 
INNER JOIN cuentas c2 on vs.cuenta_id = c2.id 
INNER JOIN tipo_cuentas tc on c2.tipo_cuenta_id = tc.id 
WHERE 
	vs.tipo_validacion_id = (4)
	and vs.last_record = 1 
	and vs.modelo = 'Cartola'
	and vs.empresa_id = (1466)  -- > Ingresa ID empresa < --
-- and c2.nombre = 'PRUEBA MAY' -- > Úsalo si quieres filtrar por cuenta < --
-- and c.fecha >= ('2020-01-01') -- > Úsalo si quieres filtrar desde una fecha en específico < --
-- and c.fecha <= ('2024-01-01') -- > Úsalo si quieres filtrar hasta una fecha en específico < --

-- TRASPASAR AL BALANCE - DOCUMENTOS --
SELECT
	p.empresa_id,
	p.modelo as 'Tipo documento',
	COALESCE(
        c.folio, -- compra
	    g.id, -- gasto
	    h.numero_boleta, -- honorarios
	    bt.numero_boleta, -- boletas terceros
	    r.id -- remuneraciones
    ) as 'Folio/id documento',
	COALESCE(
        c.monto_total, -- compra
	    g.monto, -- gasto
	    h.monto_liquido, -- honorarios
	    bt.monto_liquido, -- boletas terceros
	    r.monto_liquido -- remuneraciones
    ) as 'Monto del documento',
	p.created as 'Fecha del traspaso',
	p.monto as 'Monto traspasado al balance',
	c2.nombre as 'Nombre cuenta',
	tc.nombre as 'Tipo de cuenta'
FROM prorratas p
LEFT JOIN compras c on c.id = p.foreign_key and p.modelo = 'Compra'
LEFT JOIN gastos g on g.id = p.foreign_key and p.modelo = 'Gasto'
LEFT JOIN honorarios h on h.id = p.foreign_key and p.modelo = 'Honorario'
LEFT JOIN boletas_terceros bt on bt.id = p.foreign_key and p.modelo = 'BoletaTercero'
LEFT JOIN remuneraciones r on r.id = p.foreign_key and p.modelo = 'Remuneracion'
LEFT JOIN cuentas c2 on p.cuenta_id = c2.id
LEFT JOIN tipo_cuentas tc on c2.tipo_cuenta_id = tc.id
WHERE
	c2.tipo_cuenta_id in (1,4,5,6)
	and p.deleted = 0
	and p.empresa_id = 1466
-- and c2.nombre = 'Documentos y cuentas por pagar' -- > Úsalo si quieres filtrar por cuenta < --


-- DIFERENCIA TIPO DE CAMBIO --
SELECT DISTINCT 
	vs.empresa_id,
	c.fecha as 'Fecha del movimiento',
	c.abono as 'Monto movimiento (abono)',
	c.cargo as 'Monto movimiento (cargo)',
	vs.ingreso as 'Validación (Ingreso)',
	vs.gasto as 'Validación (Gasto)'
FROM 
	validacion_saldos vs 
INNER JOIN cartolas c on c.id = vs.foreign_key AND vs.modelo = 'Cartola'
INNER JOIN tipos_validaciones tv on vs.tipo_validacion_id = tv.id 
WHERE 
	vs.tipo_validacion_id = (2)
	AND vs.last_record = 1
	AND vs.empresa_id = (1466)  -- > Ingresa ID empresa < --
-- and c.fecha >= ('2020-01-01') -- > Úsalo si quieres filtrar desde una fecha en específico < --
-- and c.fecha <= ('2024-01-01') -- > Úsalo si quieres filtrar hasta una fecha en específico < --


-- INCOBRABLE Y LIQUIDAR DEUDA --
SELECT DISTINCT 
	vs.empresa_id, 
	vs.modelo,
	o.otro_ingreso as 'NV(0)/Otro Ingreso(1)',
	tv.nombre as 'Tipo Validaci�n',
	COALESCE(
		d.fecha_emision,
		c.fecha_emision,
		o.fecha) as 'Fecha emisi�n documento',
	COALESCE(
		d.folio,
		c.folio,
		o.folio) as 'Folio documento',
	COALESCE(
		d.monto_total,
		c.monto_total,
		o.monto_neto) as 'Monto del documento',
	vs.ingreso as 'Validaci�n (Ingreso)',
	vs.gasto as 'Validaci�n (Gasto)',
	vs.fecha as 'Fecha clasificación'
FROM 
	validacion_saldos vs 
LEFT JOIN dtes d on d.id = vs.foreign_key AND vs.modelo = 'Dte'
LEFT JOIN compras c on c.id = vs.foreign_key AND vs.modelo = 'Compra'
LEFT JOIN ots o on o.id = vs.foreign_key AND vs.modelo = 'ot'
LEFT JOIN tipos_validaciones tv on vs.tipo_validacion_id = tv.id 
WHERE 
	vs.last_record = 1
	AND vs.tipo_validacion_id in (3, 15)
	AND vs.empresa_id = (9241)  -- > Ingresa ID empresa < --

-- MARCAR COMO PAGADO --
SELECT DISTINCT 
	c.empresa_id, 
	cd.modelo as 'Tipo documento',
	o.otro_ingreso as 'NV(0)/Otros ingresos(1)',
	COALESCE (
		h.numero_boleta,
		bt.numero_boleta,
		com.folio,
		d.folio,
		o.folio,
		CONCAT_WS(' ',e.nombre,e.apellido)
	) as 'Folio/Nombre empleado',
	COALESCE (
		h.fecha_emision,
		bt.fecha_emision,
		com.fecha_emision,
		d.fecha_emision,
		g.fecha ,
		r.periodo,
		o.fecha 
	) as 'Fecha/periodo emisión del documento',
	COALESCE (
		h.monto_liquido,
		bt.monto_liquido,
		d.monto_total,
		r.monto_liquido
	) as 'Monto líquido',
	COALESCE (
		com.monto_neto,
		d.monto_total,
		o.monto_neto 
	) as 'Monto neto',
	COALESCE (
		h.monto_bruto ,
		bt.monto_bruto ,
		com.monto_total,
		d.monto_total,
		g.monto
	) as 'Monto total',
	c.fecha as 'Fecha del movimiento',
	c.cargo as 'Monto movimiento (Cargo)',
	c.abono as 'Monto movimiento (Abono)'
FROM 
	cartolas c
LEFT JOIN cartolas_documentos cd on c.id = cd.cartola_id 
LEFT JOIN honorarios h on cd.foreign_key = h.id AND cd.modelo = 'Honorario'
LEFT JOIN boletas_terceros bt on cd.foreign_key = bt.id AND cd.modelo = 'BoletaTercero'
LEFT JOIN compras com on cd.foreign_key = com.id AND cd.modelo = 'Compra'
LEFT JOIN dtes d on cd.foreign_key = d.id AND cd.modelo = 'Dte'
LEFT JOIN gastos g on cd.foreign_key = g.id AND cd.modelo = 'Gasto'
LEFT JOIN remuneraciones r on cd.foreign_key = r.id AND cd.modelo = 'Remuneracion'
LEFT JOIN empleados e on r.empleado_id = e.id 
LEFT JOIN ots o on cd.foreign_key = o.id AND cd.modelo = 'ot'
WHERE 
	cd.last_record = 1
	and c.tipo_cartola_id = (5)
	and c.empresa_id = (8239)  -- > Ingresa ID empresa < --
-- 	and cd.modelo = 'Compra'-- > Ingresa tipo de documento < --




