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

INSERT INTO proveedores (id, nombre, contacto, telefono, correo_electronico, ciudad_id) VALUES
(1, 'Proveedor A', 'Contacto A', '111333555', 'proveedora@example.com', 1),
(2, 'Proveedor B', 'Contacto B', '222444666', 'proveedorb@example.com', 2),
(3, 'Proveedor C', 'Contacto C', '333555777', 'proveedorc@example.com', 3);

INSERT INTO repuestos (id, nombre, descripcion, precio, stock, proveedor_id) VALUES
(1, 'Repuesto 1', 'Descripción del Repuesto 1', 49.99, 20, 1),
(2, 'Repuesto 2', 'Descripción del Repuesto 2', 59.99, 15, 2),
(3, 'Repuesto 3', 'Descripción del Repuesto 3', 69.99, 10, 3);

INSERT INTO compras (id, fecha, proveedor_id, total) VALUES
(1, '2024-06-15', 1, 199.96),
(2, '2024-06-20', 2, 179.97),
(3, '2024-06-25', 3, 139.98);

INSERT INTO detalles_compras (id, compra_id, repuesto_id, cantidad, precio_unitario) VALUES
(1, 1, 1, 4, 49.99),
(2, 2, 2, 3, 59.99),
(3, 3, 3, 2, 69.99);

DELIMITER //

CREATE PROCEDURE AgregarBicicleta(
    IN p_Modelo INT,
    IN p_Precio DECIMAL(10, 2),
    IN p_Stock INT
)
BEGIN
    INSERT INTO bicicletas (modelo, precio, stock)
    VALUES (p_Modelo, p_Precio, p_Stock);
END //

CREATE PROCEDURE ActualizarBicicleta(
    IN p_id INT,
    IN p_Precio DECIMAL(10, 2),
    IN p_Stock INT
)
BEGIN
    UPDATE bicicletas 
    SET precio = p_Precio, stock = p_Stock
    WHERE id = p_id;
END //

CREATE PROCEDURE EliminarBicicleta(
    IN p_id INT
)
BEGIN
    DELETE FROM bicicletas
    WHERE id = p_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE CrearVenta(
    IN p_ClienteID INT
)
BEGIN
    DECLARE nueva_venta_id INT;
    DECLARE fecha_venta DATE;
    DECLARE total_venta DECIMAL(10, 2);

    -- Obtener la fecha actual para la venta
    SET fecha_venta = CURDATE();

    -- Insertar la nueva venta y obtener el ID generado
    INSERT INTO ventas (fecha, cliente_id, total)
    VALUES (fecha_venta, p_ClienteID, 0); -- El total se actualizará posteriormente

    -- Obtener el ID de la venta insertada
    SET nueva_venta_id = LAST_INSERT_ID();

    -- Devolver el ID de la nueva venta
    SELECT nueva_venta_id AS venta_id;
END //

CREATE PROCEDURE AgregarBicicletaAVenta(
    IN p_VentaID INT,
    IN p_BicicletaID INT,
    IN p_Cantidad INT
)
BEGIN
    DECLARE precio_unitario DECIMAL(10, 2);

    -- Obtener el precio unitario de la bicicleta
    SELECT precio INTO precio_unitario
    FROM bicicletas
    WHERE id = p_BicicletaID;

    -- Insertar la bicicleta en los detalles de la venta
    INSERT INTO detalles_ventas (venta_id, bicicleta_id, cantidad, precio_unitario)
    VALUES (p_VentaID, p_BicicletaID, p_Cantidad, precio_unitario);

    -- Actualizar el total de la venta
    UPDATE ventas
    SET total = total + (precio_unitario * p_Cantidad)
    WHERE id = p_VentaID;

    -- Devolver mensaje de éxito
    SELECT CONCAT('Bicicleta agregada a la venta ID ', p_VentaID) AS mensaje;
END //

CREATE PROCEDURE ConfirmarVenta(
    IN p_confirmacion VARCHAR(1), -- Cambiado a VARCHAR(1) para simplificar la confirmación
    IN p_VentaID INT
)
BEGIN
    IF p_confirmacion = 'Y' THEN
        -- Actualizar el inventario de bicicletas
        UPDATE bicicletas b
        INNER JOIN (
            SELECT bicicleta_id, SUM(cantidad) AS cantidad_vendida
            FROM detalles_ventas
            WHERE venta_id = p_VentaID
            GROUP BY bicicleta_id
        ) dv ON b.id = dv.bicicleta_id
        SET b.stock = b.stock - dv.cantidad_vendida;

        -- Devolver mensaje de confirmación
        SELECT CONCAT('Venta ID ', p_VentaID, ' confirmada y el inventario actualizado') AS mensaje;
        
    ELSEIF p_confirmacion = 'n' THEN
        -- Devolver mensaje de cancelación
        SELECT CONCAT('Venta ID ', p_VentaID, ' cancelada') AS mensaje;

        -- Eliminar la venta y sus detalles
        DELETE FROM ventas WHERE id = p_VentaID;
        DELETE FROM detalles_ventas WHERE venta_id = p_VentaID;
        
    ELSE
        -- Devolver mensaje de error si la confirmación no es válida
        SELECT 'Confirmación no válida. Utilizar "Y" para confirmar o "n" para cancelar.' AS mensaje;
    END IF;
END //

DELIMITER ;