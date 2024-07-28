INSERT INTO paises (nombre) VALUES 
('Argentina'), 
('Brasil'), 
('Chile'),
('Perú'),
('Colombia'),
('México'),
('España'),
('Francia'),
('Italia');

INSERT INTO ciudades (nombre, pais_id) VALUES 
('Buenos Aires', 1), 
('São Paulo', 2), 
('Santiago', 3),
('Lima', 4),
('Bogotá', 5),
('Bucaramanga', 5),
('Ciudad de México', 6),
('Madrid', 7),
('Barcelona', 7),
('París', 8),
('Marsella', 8),
('Roma', 9),
('Milán', 9);

INSERT INTO marcas (nombre) VALUES 
('Trek'), 
('Specialized'), 
('Giant'),
('Cannondale'),
('Scott'),
('Canyon'),
('Merida');
('BMC'),
('Orbea');

INSERT INTO modelos (marca_id, modelo) VALUES 
(1, 'X-Caliber'), 
(2, 'Stumpjumper'), 
(3, 'Defy'),
(4, 'Trail 7'),
(5, 'Spark 970'),
(6, 'Big Nine'),
(1, 'Moby Dick'),
(1, 'Gravel'),
(8, 'BMX'),
(2, 'Electrica'),
(5, 'Urbana'),
(9, 'Montaña'),
(6, 'Ruta'),
(9, 'Triatlon');

INSERT INTO bicicletas (modelo, precio, stock) VALUES 
(1, 1200.00, 10), 
(2, 1500.00, 5), 
(3, 1300.00, 8),
(4, 1100.00, 12),
(5, 1460.00, 7),
(6, 1400.00, 6),
(7, 2050.00, 5),
(8, 1400.00, 4),
(9, 1800.00, 16),
(10, 400.00, 20),
(11, 550.00, 5),
(12, 1600.00, 10),
(13, 700.00, 3),
(14, 1250.00, 9);

INSERT INTO clientes (nombre, correo_electronico, telefono, ciudad_id) VALUES 
('Juan Pérez', 'juan.perez@gmail.com', '1234567890', 1), 
('Maria Silva', 'maria.silva@yahoo.com', '0987654321', 2),
('Carlos López', 'carlos.lopez@hotmail.com', '1112223334', 3),
('Ana Torres', 'ana.torres@yahoo.com', '5556667778', 4),
('Luis Rodríguez', 'luis.rodriguez@gmail.com', '9998887776', 5),
('Laura Fernández', 'laura.fernandez@outolook.com', '4445556667', 6);

INSERT INTO ventas (fecha, cliente_id, total) VALUES 
('2022-07-01', 1, 4800.00), 
('2024-11-02', 2, 1500.00),
('2022-04-03', 3, 2600.00),
('2024-07-04', 4, 3300.00),
('2021-07-05', 5, 1460.00),
('2019-02-12', 6, 1400.00),
('2015-02-26', 3, 700.00),
('2020-12-06', 1, 2050.00),
('2019-03-21', 5, 1200.00),
('2024-02-30', 6, 2500.00),
('2024-02-30', 2, 2000.00),
('2024-02-30', 3, 3600.00),
('2024-02-30', 2, 1250.00),
('2024-02-30', 6, 1200.00);

INSERT INTO detalles_ventas (venta_id, bicicleta_id, cantidad, precio_unitario) VALUES 
(1, 1, 4, 1200.00), 
(2, 2, 1, 1500.00),
(3, 3, 2, 1300.00),
(4, 4, 3, 1100.00),
(5, 5, 1, 1460.00),
(6, 6, 1, 1400.00),
(7, 13, 1, 700.00),
(8, 7, 1, 2050.00),
(9, 10, 3, 400.00),
(10, 14, 2, 1250.00),
(11, 10, 5, 400.00),
(12, 9, 2, 1800.00),
(13, 14, 1, 1250.00),
(14, 1, 1, 1200.00);

INSERT INTO proveedores (nombre, contacto, telefono, correo_electronico, ciudad_id) VALUES 
('Bike Parts Co.', 'Santiago Gómez', '1234567890', 'sgomez@bikepartsco.com', 1), 
('Cycling Supply Ltd.', 'Julia Pereira', '0987654321', 'jpereira@cyclingsupply.com', 2),
('Gear Masters Inc.', 'Rodrigo Díaz', '1112223334', 'rdiaz@gearmasters.com', 3),
('Component Hub', 'Natalia Rojas', '5556667778', 'nrojas@componenthub.com', 4),
('Velo World', 'Andrés Paredes', '9998887776', 'apares@veloworld.com', 5),
('Cycle Solutions', 'Mónica Vázquez', '4445556667', 'mvazquez@cyclesolutions.com', 6);

INSERT INTO repuestos (nombre, descripcion, precio, stock, proveedor_id) VALUES 
('Rueda', 'Rueda de repuesto', 50.00, 100, 1), 
('Cadena', 'Cadena de repuesto', 20.00, 360, 2),
('Asiento', 'Asiento de repuesto', 35.00, 150, 3),
('Frenos', 'Juego de frenos', 45.00, 120, 4),
('Pedales', 'Juego de pedales', 25.00, 180, 5),
('Manubrio', 'Manubrio de repuesto', 30.00, 160, 6),
('Cambios', 'Cambios de repuesto', 65.00, 160, 4);

INSERT INTO compras (fecha, proveedor_id, total) VALUES 
('2024-01-01', 1, 2500.00), 
('2020-07-02', 2, 4000.00),
('2023-05-03', 3, 5250.00),
('2021-06-04', 4, 5400.00),
('2017-07-05', 5, 4500.00),
('2024-10-06', 6, 4800.00),
('2024-10-06', 1, 7800.00),
('2024-10-06', 3, 2600.00),
('2024-10-06', 5, 3200.00);

INSERT INTO detalles_compras (compra_id, repuesto_id, cantidad, precio_unitario) VALUES 
(1, 1, 50, 50.00), 
(2, 2, 200, 20.00),
(3, 3, 150, 35.00),
(4, 4, 120, 45.00),
(5, 5, 180, 25.00),
(6, 6, 160, 30.00),
(7, 7, 120, 65.00),
(8, 7, 40, 65.00),
(9, 2, 160, 20.00);
