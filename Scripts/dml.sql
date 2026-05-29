/* ============================================================
   Proyecto Final - BI para decisiones estrategicas
   Dominio: Bodega / Inventario y pedidos
   Script: DML
   ============================================================ */

/* ============================================================
   PROVEEDORES
   ============================================================ */

INSERT INTO bd_proveedores (nit, nombre, telefono, email, estado)
VALUES ('900100001-1', 'Distribuidora Norte', '3001112233', 'ventas@norte.com', 'ACTIVO');

INSERT INTO bd_proveedores (nit, nombre, telefono, email, estado)
VALUES ('900100002-2', 'Alimentos La Sabana', '3002223344', 'contacto@sabana.com', 'ACTIVO');

INSERT INTO bd_proveedores (nit, nombre, telefono, email, estado)
VALUES ('900100003-3', 'Aseo Total SAS', '3003334455', 'pedidos@aseototal.com', 'ACTIVO');

INSERT INTO bd_proveedores (nit, nombre, telefono, email, estado)
VALUES ('900100004-4', 'Empaques Andinos', '3004445566', 'comercial@empaques.com', 'ACTIVO');

INSERT INTO bd_proveedores (nit, nombre, telefono, email, estado)
VALUES ('900100005-5', 'Bebidas Central', '3005556677', 'ventas@bebidascentral.com', 'ACTIVO');

INSERT INTO bd_proveedores (nit, nombre, telefono, email, estado)
VALUES ('900100006-6', 'Lacteos del Valle', '3006667788', 'contacto@lacteosvalle.com', 'ACTIVO');

COMMIT;

/* ============================================================
   CLIENTES
   ============================================================ */

INSERT INTO bd_clientes (tipo_documento, num_documento, nombre, email, estado)
VALUES ('NIT', '800200001-1', 'Supermercado El Ahorro', 'compras@elahorro.com', 'ACTIVO');

INSERT INTO bd_clientes (tipo_documento, num_documento, nombre, email, estado)
VALUES ('NIT', '800200002-2', 'Tienda La 80', 'admin@tiendala80.com', 'ACTIVO');

INSERT INTO bd_clientes (tipo_documento, num_documento, nombre, email, estado)
VALUES ('CC', '1010101010', 'Carlos Mendoza', 'carlos@email.com', 'ACTIVO');

INSERT INTO bd_clientes (tipo_documento, num_documento, nombre, email, estado)
VALUES ('NIT', '800200003-3', 'Restaurante Buen Sabor', 'compras@buensabor.com', 'ACTIVO');

INSERT INTO bd_clientes (tipo_documento, num_documento, nombre, email, estado)
VALUES ('CC', '2020202020', 'Ana Gomez', 'ana@email.com', 'ACTIVO');

INSERT INTO bd_clientes (tipo_documento, num_documento, nombre, email, estado)
VALUES ('NIT', '800200004-4', 'Minimercado La Esquina', 'compras@laesquina.com', 'ACTIVO');

COMMIT;

/* ============================================================
   PRODUCTOS
   ============================================================ */

INSERT INTO bd_productos (proveedor_id, codigo_producto, nombre, categoria, precio_unitario, stock_actual, stock_minimo, estado)
VALUES ((SELECT proveedor_id FROM bd_proveedores WHERE nit = '900100001-1'), 'PROD-001', 'Arroz x 25 kg', 'ALIMENTOS', 85000, 20, 8, 'ACTIVO');

INSERT INTO bd_productos (proveedor_id, codigo_producto, nombre, categoria, precio_unitario, stock_actual, stock_minimo, estado)
VALUES ((SELECT proveedor_id FROM bd_proveedores WHERE nit = '900100002-2'), 'PROD-002', 'Aceite x 12 unidades', 'ALIMENTOS', 120000, 14, 6, 'ACTIVO');

INSERT INTO bd_productos (proveedor_id, codigo_producto, nombre, categoria, precio_unitario, stock_actual, stock_minimo, estado)
VALUES ((SELECT proveedor_id FROM bd_proveedores WHERE nit = '900100003-3'), 'PROD-003', 'Detergente x 20 kg', 'ASEO', 95000, 7, 10, 'ACTIVO');

INSERT INTO bd_productos (proveedor_id, codigo_producto, nombre, categoria, precio_unitario, stock_actual, stock_minimo, estado)
VALUES ((SELECT proveedor_id FROM bd_proveedores WHERE nit = '900100004-4'), 'PROD-004', 'Caja carton mediana', 'EMPAQUES', 2500, 150, 40, 'ACTIVO');

INSERT INTO bd_productos (proveedor_id, codigo_producto, nombre, categoria, precio_unitario, stock_actual, stock_minimo, estado)
VALUES ((SELECT proveedor_id FROM bd_proveedores WHERE nit = '900100005-5'), 'PROD-005', 'Agua x 24 botellas', 'BEBIDAS', 36000, 30, 12, 'ACTIVO');

INSERT INTO bd_productos (proveedor_id, codigo_producto, nombre, categoria, precio_unitario, stock_actual, stock_minimo, estado)
VALUES ((SELECT proveedor_id FROM bd_proveedores WHERE nit = '900100005-5'), 'PROD-006', 'Gaseosa x 12 unidades', 'BEBIDAS', 48000, 9, 10, 'ACTIVO');

INSERT INTO bd_productos (proveedor_id, codigo_producto, nombre, categoria, precio_unitario, stock_actual, stock_minimo, estado)
VALUES ((SELECT proveedor_id FROM bd_proveedores WHERE nit = '900100006-6'), 'PROD-007', 'Leche x 12 unidades', 'LACTEOS', 42000, 18, 8, 'ACTIVO');

COMMIT;

/* ============================================================
   PEDIDOS
   ============================================================ */

INSERT INTO bd_pedidos (num_pedido, cliente_id, fecha_pedido, estado, observacion)
VALUES ('PED-001', (SELECT cliente_id FROM bd_clientes WHERE tipo_documento = 'NIT' AND num_documento = '800200001-1'), DATE '2026-05-01', 'DESPACHADO', 'Pedido entregado completo');

INSERT INTO bd_pedidos (num_pedido, cliente_id, fecha_pedido, estado, observacion)
VALUES ('PED-002', (SELECT cliente_id FROM bd_clientes WHERE tipo_documento = 'NIT' AND num_documento = '800200002-2'), DATE '2026-05-03', 'PENDIENTE', 'Pendiente por revisar inventario');

INSERT INTO bd_pedidos (num_pedido, cliente_id, fecha_pedido, estado, observacion)
VALUES ('PED-003', (SELECT cliente_id FROM bd_clientes WHERE tipo_documento = 'CC' AND num_documento = '1010101010'), DATE '2026-05-05', 'DESPACHADO', 'Cliente recoge en bodega');

INSERT INTO bd_pedidos (num_pedido, cliente_id, fecha_pedido, estado, observacion)
VALUES ('PED-004', (SELECT cliente_id FROM bd_clientes WHERE tipo_documento = 'NIT' AND num_documento = '800200003-3'), DATE '2026-05-08', 'PENDIENTE', 'Entrega solicitada para la tarde');

INSERT INTO bd_pedidos (num_pedido, cliente_id, fecha_pedido, estado, observacion)
VALUES ('PED-005', (SELECT cliente_id FROM bd_clientes WHERE tipo_documento = 'CC' AND num_documento = '2020202020'), DATE '2026-05-10', 'CANCELADO', 'Cliente cancelo el pedido');

INSERT INTO bd_pedidos (num_pedido, cliente_id, fecha_pedido, estado, observacion)
VALUES ('PED-006', (SELECT cliente_id FROM bd_clientes WHERE tipo_documento = 'NIT' AND num_documento = '800200001-1'), DATE '2026-05-12', 'PENDIENTE', 'Pedido recurrente');

COMMIT;

/* ============================================================
   DETALLE DE PEDIDOS
   ============================================================ */

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-001'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-001'), 3, 85000);

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-001'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-005'), 5, 36000);

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-002'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-003'), 2, 95000);

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-002'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-004'), 20, 2500);

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-003'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-002'), 1, 120000);

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-003'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-006'), 4, 48000);

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-004'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-001'), 2, 85000);

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-004'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-003'), 1, 95000);

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-005'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-005'), 2, 36000);

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-006'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-004'), 30, 2500);

INSERT INTO bd_detalle_pedido (pedido_id, producto_id, cantidad, precio_unitario)
VALUES ((SELECT pedido_id FROM bd_pedidos WHERE num_pedido = 'PED-006'), (SELECT producto_id FROM bd_productos WHERE codigo_producto = 'PROD-006'), 2, 48000);

COMMIT;
