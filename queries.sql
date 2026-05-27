/* ============================================================
   Proyecto Final - BI para decisiones estrategicas
   Dominio: Bodega / Inventario y pedidos
   Script: Consultas para la aplicacion

   El proyecto pide minimo 2 vistas o consultas distintas.
   Dejamos 3 consultas: minimo + 1.
   ============================================================ */

/* ============================================================
   1. Inventario general con proveedor
   ============================================================ */

SELECT
    p.producto_id,
    p.codigo_producto,
    p.nombre AS producto,
    p.categoria,
    pr.nombre AS proveedor,
    p.precio_unitario,
    p.stock_actual,
    p.stock_minimo,
    p.estado
FROM bd_productos p
JOIN bd_proveedores pr ON pr.proveedor_id = p.proveedor_id
ORDER BY p.categoria, p.nombre;

/* ============================================================
   2. Productos bajo stock
   ============================================================ */

SELECT
    p.codigo_producto,
    p.nombre AS producto,
    p.categoria,
    p.stock_actual,
    p.stock_minimo,
    (p.stock_minimo - p.stock_actual) AS unidades_faltantes
FROM bd_productos p
WHERE p.stock_actual < p.stock_minimo
ORDER BY unidades_faltantes DESC;

/* ============================================================
   3. Pedidos con cliente y valor total
   ============================================================ */

SELECT
    pe.pedido_id,
    pe.num_pedido,
    c.nombre AS cliente,
    pe.fecha_pedido,
    pe.estado,
    NVL(SUM(dp.cantidad * dp.precio_unitario), 0) AS valor_pedido
FROM bd_pedidos pe
JOIN bd_clientes c ON c.cliente_id = pe.cliente_id
LEFT JOIN bd_detalle_pedido dp ON dp.pedido_id = pe.pedido_id
GROUP BY pe.pedido_id, pe.num_pedido, c.nombre, pe.fecha_pedido, pe.estado
ORDER BY pe.fecha_pedido DESC;

COMMIT;
