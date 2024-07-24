INSERT INTO paises (nombre) VALUES
('España'),
('Francia'),
('Italia');

INSERT INTO ciudades (nombre, pais_id) VALUES
('Madrid', 1),
('Barcelona', 1),
('París', 2),
('Marsella', 2),
('Roma', 3),
('Milán', 3);

INSERT INTO marcas (nombre) VALUES
('Marca A'),
('Marca B'),
('Marca C');

INSERT INTO modelos (marca_id, modelo) VALUES
(1, 'Modelo X'),
(1, 'Modelo Y'),
(2, 'Modelo Z'),
(3, 'Modelo W');

INSERT INTO bicicletas (modelo, precio, stock) VALUES
(1, 599.99, 10),
(2, 699.99, 8),
(3, 799.99, 5),
(4, 899.99, 3);

INSERT INTO clientes (nombre, correo_electronico, telefono, ciudad_id) VALUES
('Cliente 1', 'cliente1@example.com', '123456789', 1),
('Cliente 2', 'cliente2@example.com', '987654321', 2),
('Cliente 3', 'cliente3@example.com', '111222333', 3);

INSERT INTO ventas (fecha, cliente_id, total) VALUES
('2024-07-01', 1, 1199.98),
('2024-07-02', 2, 1399.97),
('2024-07-03', 3, 1599.96);

INSERT INTO detalles_ventas (venta_id, bicicleta_id, cantidad, precio_unitario) VALUES
(1, 1, 2, 599.99),
(2, 2, 1, 699.99),
(3, 3, 2, 799.99),
(3, 4, 1, 899.99);

INSERT INTO proveedores (nombre, contacto, telefono, correo_electronico, ciudad_id) VALUES
('Proveedor A', 'Contacto A', '111333555', 'proveedora@example.com', 1),
('Proveedor B', 'Contacto B', '222444666', 'proveedorb@example.com', 2),
('Proveedor C', 'Contacto C', '333555777', 'proveedorc@example.com', 3);

INSERT INTO repuestos (nombre, descripcion, precio, stock, proveedor_id) VALUES
('Repuesto 1', 'Descripción del Repuesto 1', 49.99, 20, 1),
('Repuesto 2', 'Descripción del Repuesto 2', 59.99, 15, 2),
('Repuesto 3', 'Descripción del Repuesto 3', 69.99, 10, 3);

INSERT INTO compras (fecha, proveedor_id, total) VALUES
('2024-06-15', 1, 199.96),
('2024-06-20', 2, 179.97),
('2024-06-25', 3, 139.98);

INSERT INTO detalles_compras (compra_id, repuesto_id, cantidad, precio_unitario) VALUES
(1, 1, 4, 49.99),
(2, 2, 3, 59.99),
(3, 3, 2, 69.99);