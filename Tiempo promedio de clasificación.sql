WITH ProrratasOrdenadas AS (
    SELECT
        p.id,
        p.empresa_id,
        p.created AS prorrata_created,
        p.filtro_id,
        LEAD(p.created) OVER (PARTITION BY p.empresa_id ORDER BY p.created) AS siguiente_created
    FROM
        prorratas p
    JOIN
        empresas e ON e.id = p.empresa_id
    WHERE
        p.deleted = 0 -- Solo prorratas activas
        AND e.activa = 1
        AND p.created IS NOT NULL
        AND p.created >= '2023-12-01' -- Filtrar por periodo --
        AND p.created <= '2023-12-31' -- Filtrar por periodo --
        -- AND e.id = 1 -- En caso de querer filtrar por empresa
)
, TiempoPromedio AS (
    SELECT
        po.id,
        po.filtro_id,
        po.empresa_id,
        TIMESTAMPDIFF(SECOND, po.prorrata_created, po.siguiente_created) AS tiempo_diff
    FROM
        ProrratasOrdenadas po
)
SELECT
    empresa_id,
    AVG(CASE WHEN tiempo_diff <= 840 AND po.filtro_id IS NULL THEN tiempo_diff END) AS tiempo_promedio_con_filtro,
    COUNT(DISTINCT po.id) as Q_prorratas,
    COUNT(DISTINCT CASE WHEN po.filtro_id IS NOT NULL THEN po.id END) AS Q_prorratas_con_filtro
FROM
    TiempoPromedio po
GROUP BY
    po.empresa_id;