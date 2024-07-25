# Campusbike

base de datos para la gestion eficiente de la informaicon de este negocio

- [Casos de uso](#casos-de-uso)
- [Uso Subconsultas](#subconsultas)
- [Uso Joins](#joins)
- [Almacenados](#implementar-procedimientos-almacenados)
- [Funciones Resumen](#funciones-resumen) 

## Diagrama ER

![Diagrama hecho en STARUML](https://media.discordapp.net/attachments/1225410560997458061/1265707007474925670/imagen.png?ex=66a27d02&is=66a12b82&hm=d203898df1214cb4a129a4dc99cb04051895a168931b3802300e2df09f7aec59&=&format=webp&quality=lossless&width=1113&height=668)

## Casos de uso

### Caso de uso 1.1: Gestión de Inventario de Bicicletas
**Descripción:** Este caso de uso describe cómo el sistema gestiona el inventario de bicicletas,
permitiendo agregar nuevas bicicletas, actualizar la información existente y eliminar bicicletas que
ya no están disponibles.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS AgregarBicicleta;
CREATE PROCEDURE AgregarBicicleta(
    IN b_Modelo INT,
    IN b_Precio DECIMAL(10, 2),
    IN b_Stock INT
)
BEGIN
    INSERT INTO bicicletas (modelo, precio, stock)
    VALUES (b_Modelo, b_Precio, b_Stock);
END;
//

DROP PROCEDURE IF EXISTS ActualizarBicicleta;
CREATE PROCEDURE ActualizarBicicleta(
    IN b_id INT,
    IN b_Precio DECIMAL(10, 2),
    IN b_Stock INT
)
BEGIN
    UPDATE bicicletas 
    SET precio = b_Precio, stock = b_Stock
    WHERE id = b_id;
    
    IF ROW_COUNT() = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bicicleta no encontrada';
	END IF;
END;
//

DROP PROCEDURE IF EXISTS EliminarBicicleta;
CREATE PROCEDURE EliminarBicicleta(
    IN b_id INT
)
BEGIN
    DELETE FROM bicicletas
    WHERE id = b_id;
    
    IF ROW_COUNT() = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bicicleta no encontrada';
	END IF;
END;
//

DELIMITER ;
```
### Caso de uso 1.2: Registro de Ventas
**Descripción:** Este caso de uso describe el proceso de registro de una venta de bicicletas incluyendo la creación de una nueva venta, la selección de bicicletas vendidas y el cálculo del total de la venta 
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS AgregarVenta;
CREATE PROCEDURE AgregarVenta(
    IN v_ClienteID INT
)
BEGIN
    DECLARE nueva_venta_id INT;
    DECLARE fecha_venta DATE;
    DECLARE total_venta DECIMAL(10, 2);

    SET fecha_venta = CURDATE();

    INSERT INTO ventas (fecha, cliente_id, total)
    VALUES (fecha_venta, v_ClienteID, 0);

    SET nueva_venta_id = LAST_INSERT_ID();

    SELECT nueva_venta_id AS venta_id;
END;
//

DROP PROCEDURE IF EXISTS AgregarBicicletaAVenta;
CREATE PROCEDURE AgregarBicicletaAVenta(
    IN v_VentaID INT,
    IN v_BicicletaID INT,
    IN v_Cantidad INT
)
BEGIN
    DECLARE n_precio_unitario DECIMAL(10, 2);

    SELECT precio INTO n_precio_unitario
    FROM bicicletas
    WHERE id = v_BicicletaID;

    INSERT INTO detalles_ventas (venta_id, bicicleta_id, cantidad, precio_unitario)
    VALUES (v_VentaID, v_BicicletaID, v_Cantidad, n_precio_unitario);

    UPDATE ventas
    SET total = total + (n_precio_unitario * v_Cantidad)
    WHERE id = v_VentaID;

    SELECT CONCAT('Bicicleta agregada a la venta ID ', v_VentaID, ) AS mensaje;
END;
//

DROP PROCEDURE IF EXISTS ConfirmarVenta;
CREATE PROCEDURE ConfirmarVenta(
    IN v_confirmacion VARCHAR(1),
    IN v_VentaID INT
)
BEGIN
    IF v_confirmacion = 'Y' THEN

        UPDATE bicicletas b
        INNER JOIN (
            SELECT bicicleta_id, SUM(cantidad) AS cantidad_vendida
            FROM detalles_ventas
            WHERE venta_id = v_VentaID
            GROUP BY bicicleta_id
        ) dv ON b.id = dv.bicicleta_id
        SET b.stock = b.stock - dv.cantidad_vendida;


        SELECT CONCAT('Venta ID ', v_VentaID, ' confirmada y el inventario actualizado') AS mensaje;
        
    ELSEIF v_confirmacion = 'n' THEN

        SELECT CONCAT('Venta ID ', v_VentaID, ' cancelada') AS mensaje;

        DELETE FROM detalles_ventas WHERE venta_id = v_VentaID;
        DELETE FROM ventas WHERE id = v_VentaID;
        
    ELSE
        SELECT 'Confirmación no válida. Utilizar "Y" para confirmar o "n" para cancelar.' AS mensaje;
    END IF;
END;
//

DELIMITER ;

CALL AgregarVenta(1);
CALL AgregarBicicletaAVenta(5, 2, 3);
CALL ConfirmarVenta('n', 5);
```
### Caso de uso 1.3: Gestión de Proveedores y Repuestos
**Descripción:** Este caso de uso descrube cómo el sistema gensitona la información de proveedores y repuestos, permitiendo agregar nuevos proveedores y repuestos, actualizar la información existente y eliminar proveedores y repuesots que ya no están activos

```sql
DELIMITER //

DROP PROCEDURE IF EXISTS AgregarProveedor;
CREATE PROCEDURE AgregarProveedor(
	IN p_Nombre VARCHAR(30), IN p_Contacto VARCHAR(30), IN p_Telefono VARCHAR(13), IN p_Correo VARCHAR(30), IN p_Ciudad INT
)
BEGIN
	INSERT INTO proveedores (nombre, contacto, telefono, correo_electronico, ciudad_id)
	VALUES (p_Nombre, p_Contacto, p_Telefono, p_Correo, p_Ciudad);
END;
//

DROP PROCEDURE IF EXISTS AgregarRepuesto;
CREATE PROCEDURE AgregarRepuesto(
	IN r_Nombre VARCHAR(40), IN r_Descripcion VARCHAR(80), IN r_Precio DECIMAL(10,2), IN r_Stock INT, IN r_Proveedor INT
)
BEGIN
	INSERT INTO repuestos (nombre, descripcion, precio, stock, proveedor_id)
	VALUES (r_Nombre, r_Descripcion, r_Precio, r_Stock, r_Proveedor);
END;
//

DROP PROCEDURE IF EXISTS ActualizarProveedor;
CREATE PROCEDURE ActualizarProveedor(
	IN p_ProveedorID INT, IN p_Nombre VARCHAR(50), IN p_Contacto VARCHAR(30), IN p_Telefono VARCHAR(13), IN p_Correo VARCHAR(30), IN p_Ciudad INT
)
BEGIN
	UPDATE proveedores
	SET nombre = p_Nombre, contacto = p_Contacto, telefono = p_Telefono, correo_electronico = p_Correo, ciudad_id = p_Ciudad
	WHERE id = p_ProveedorID;
	
	IF ROW_COUNT() = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Proveedor no encontrado';
	END IF;
END;
//

DROP PROCEDURE IF EXISTS ActualizarRepuesto;
CREATE PROCEDURE ActualizarRepuesto(
	IN r_RepuestoID INT, IN r_Nombre VARCHAR(40), IN r_Descripcion VARCHAR(80), IN r_Precio DECIMAL(10,2), IN r_Stock INT, IN r_Proveedor INT
)
BEGIN
	UPDATE repuestos
	SET nombre = r_Nombre, descripcion = r_Descripcion, precio = r_Precio, stock = r_Stock, proveedor_id = r_Proveedor
	WHERE id = r_RepuestoID;
	
	IF ROW_COUNT() = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Repuesto no encontrado';
	END IF;
END;
//

DROP PROCEDURE IF EXISTS EliminarProveedor;
CREATE PROCEDURE EliminarProveedor(
	IN p_id INT
)
BEGIN
	DELETE FROM proveedores
	WHERE id = p_id;
	
	IF ROW_COUNT() = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Proveedor no encontrado';
	END IF;
END;
//

DROP PROCEDURE IF EXISTS EliminarRepuesto;
CREATE PROCEDURE EliminarRepuesto(
	IN r_id INT
)
BEGIN
	DELETE FROM repuestos
	WHERE id = r_id;
	
	IF ROW_COUNT() = 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Repuesto no encontrado';
	END IF;
END;
//

DELIMITER ;

CALL AgregarProveedor('Proveedor6', 'Contacto6', '123456789', 'correo1@example.com', 1);
CALL AgregarRepuesto('Repuesto7', 'Descripcion7', 100.00, 50, 1);
CALL ActualizarProveedor(4, 'Proveedor2', 'Contacto2', '987654321', 'correo2@example.com', 2);
CALL ActualizarRepuesto(4, 'Repuesto2', 'Descripcion2', 150.00, 30, 2);
CALL EliminarProveedor(4);
CALL EliminarRepuesto(4);
```
### Caso de uso 1.4: Consulta de Historial de Ventas por Cliente
**Descripción:** Este caso de uso describe cómo el sistema permite a un usuario consultar el historial de ventas de un cliente específico, mostrando todas las compras realizadas por el cliente y los detalles de cada venta
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS ListarVentas;
CREATE PROCEDURE ListarVentas()
BEGIN
	SELECT id,fecha,cliente_id,total
	FROM ventas;
END;
//

DROP PROCEDURE IF EXISTS ListarDetallesVenta;
CREATE PROCEDURE ListarDetallesVenta(
	IN v_VentaID INT
)
BEGIN
	SELECT id,venta_id,bicicleta_id,cantidad,precio_unitario 
	FROM detalles_ventas
	WHERE venta_id = v_VentaID;
END;
//

DELIMITER ;

CALL ListarVentas();
CALL ListarDetallesVenta(1);
```
### Caso de Uso 1.5: Gestión de Compras de Repuestos
**Descripción:** Este caso de uso describe cómo el sistema gestiona las compras de repuestos a
proveedores, permitiendo registrar una nueva compra, especificar los repuestos comprados y
actualizar el stock de repuestos.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS AgregarCompra;
CREATE PROCEDURE AgregarCompra(
	IN c_ProveedorID INT, IN c_Fecha DATE, IN c_Total DECIMAL(10,2)
)
BEGIN
	INSERT INTO compras (fecha,proveedor_id,total)
	VALUES (c_Fecha, c_ProveedorID, c_Total);
END;
//

DROP PROCEDURE IF EXISTS AgregarRepuestoACompra;
CREATE PROCEDURE AgregarRepuestoACompra(
    IN c_CompraID INT,
    IN c_RepuestoID INT,
    IN c_Cantidad INT
)
BEGIN
    DECLARE n_precio_unitario DECIMAL(10, 2);

    SELECT precio INTO n_precio_unitario
    FROM repuestos
    WHERE id = c_RepuestoID;

    INSERT INTO detalles_compras (compra_id, repuesto_id, cantidad, precio_unitario)
    VALUES (c_CompraID, c_RepuestoID, c_Cantidad, n_precio_unitario);
    
    UPDATE compras
    SET total = total + (n_precio_unitario * c_Cantidad)
    WHERE id = c_CompraID;

    SELECT CONCAT('Repuesto agregado a la compra ID ', c_CompraID) AS mensaje;
END;
//

DELIMITER ;

CALL AgregarCompra(3, '2024-07-23', 500.00);
CALL AgregarRepuestoACompra(1, 1, 2);
```
## Subconsultas
### Caso de Uso 2.1 Consulta de Bicicletas Más Vendidas por Marca
**Descripción:** Este caso de uso describe cómo el sistema permite a un usuario consultar las bicicletas más vendidas por cada marca.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS BicicletasVendidasXMarca;
CREATE PROCEDURE BicicletasVendidasXMarca()
BEGIN
    SELECT marca, modelo
    FROM (
        SELECT ma.nombre AS marca, mo.modelo AS modelo, SUM(dv.cantidad) AS total_compras
        FROM marcas ma
        JOIN modelos mo ON ma.id = mo.marca_id
        JOIN bicicletas bi ON mo.id = bi.modelo
        JOIN detalles_ventas dv ON bi.id = dv.bicicleta_id
        GROUP BY ma.nombre, mo.modelo
    ) AS ventas_por_modelo
    WHERE total_compras = (
        SELECT MAX(total_compras)
        FROM (
            SELECT ma_sub.nombre AS marca, mo_sub.modelo AS modelo, SUM(dv_sub.cantidad) AS total_compras
            FROM marcas ma_sub
            JOIN modelos mo_sub ON ma_sub.id = mo_sub.marca_id
            JOIN bicicletas bi_sub ON mo_sub.id = bi_sub.modelo
            JOIN detalles_ventas dv_sub ON bi_sub.id = dv_sub.bicicleta_id
            GROUP BY ma_sub.nombre, mo_sub.modelo
        ) AS subconsulta
        WHERE subconsulta.marca = ventas_por_modelo.marca
    );
END //

DELIMITER ;

CALL BicicletasVendidasXMarca();
```
### Caso de Uso 2.2: Clientes con Mayor Gasto en un Año Específico
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los clientes que han gastado más en un año específico.

```sql
DELIMITER //

DROP PROCEDURE IF EXISTS ListarClientesMasGastoAño;
CREATE PROCEDURE ListarClientesMasGastoAño(
    IN año INT
)
BEGIN
    SELECT c.id, c.nombre, SUM(v.total) AS total_gastado
    FROM clientes c
    JOIN ventas v ON c.id = v.cliente_id
    WHERE YEAR(v.fecha) = año
    GROUP BY c.id, c.nombre
    ORDER BY total_gastado DESC;
END;
//

DELIMITER ;

CALL ListarClientesMasGastoAño('2024');
```
### Caso de Uso 2.3: Proveedores con Más Compras en el Último Mes
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los proveedores que han recibido más compras en el último mes.

```sql
DELIMITER //

DROP PROCEDURE IF EXISTS ListarProveedoresMasComprasUltimoMes;
CREATE PROCEDURE ListarProveedoresMasComprasUltimoMes()
BEGIN
    SELECT p.id, p.nombre, COUNT(c.id) AS total_compras
    FROM proveedores p
    JOIN compras c ON c.id = c.proveedor_id
    WHERE TIMESTAMPDIFF(MONTH, c.fecha, CURDATE()) = 0
    GROUP BY p.id, p.nombre
    ORDER BY total_compras DESC;
END;
//

DELIMITER ;

CALL ListarProveedoresMasComprasUltimoMes();
```
### Caso de Uso 2.4: Repuestos con Menor Rotación en el Inventario
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los repuestos que han tenido menor rotación en el inventario, es decir, los menos vendidos.
```sql

```
### Caso de Uso 2.5: Ciudades con Más Ventas Realizadas
**Descripción:** Este caso de uso describe cómo el sistema permite consultar las ciudades donde se han realizado más ventas de bicicletas.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS CiudadesMayorVentas;
CrEATE PROCEDURE CiudadesMayorVentas()
BEGIN
    SELECT ciudades, Nro_Ventas
    FROM (
        SELECT cdes.nombre AS ciudades, COUNT(vnts.id) AS Nro_Ventas
        FROM ciudades cdes
        JOIN clientes clnt ON cdes.id = clnt.ciudad_id
        JOIN ventas vnts ON clnt.id = vnts.cliente_id
        GROUP BY cdes.nombre 
    ) AS ventas_ciudad
    ORDER BY Nro_ventas ASC;
END;
//

DELIMITER ;

CALL CiudadesMayorVentas();
```
## Joins
### Caso de Uso 3.1: Consulta de Ventas por Ciudad
**Descripción:** Este caso de uso describe cómo el sistema permite consultar el total de ventas realizadas en cada ciudad.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS VentasPorCiudad; 
CREATE PROCEDURE VentasPorCiudad()
BEGIN
    SELECT cdes.nombre as ciudades, COUNT(clnt.id) as Nro_Ventas
    FROM ciudades cdes
    INNER JOIN clientes clnt ON cdes.id = clnt.ciudad_id
    GROUP BY cdes.nombre;
END; 
// 
DELIMITER ;
```
### Caso de Uso 3.2: Consulta de Proveedores por País
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los proveedores agrupados por país.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS ProveedoresPorPais; 
CREATE PROCEDURE ProveedoresPorPais()
BEGIN
    SELECT pss.nombre as paises, COUNT(pvdr.id) as Nro_Proveedores
    FROM paises pss
    INNER JOIN ciudades cdes ON pss.id = cdes.pais_id
    INNER JOIN proveedores pvdr ON cdes.id = pvdr.ciudad_id
    GROUP BY pss.nombre;
END;
//
DELIMITER ;
```
### Caso de Uso 3.3: Compras de Repuestos por Proveedor
**Descripción:** Este caso de uso describe cómo el sistema permite consultar el total de repuestos comprados a cada proveedor.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS RepuestosPorProveedor;
CREATE PROCEDURE RepuestosPorProveedor()
BEGIN
    SELECT pvdr.nombre as proveedores, COUNT(rpst.id) as Nro_Repuestos
    FROM proveedores pvdr
    INNER JOIN repuestos rpst ON pvdr.id = rpst.proveedor_id
    GROUP BY pvdr.nombre;
END;
//
DELIMITER ;
```
### Caso de Uso 3.4: Clientes con Ventas en un Rango de Fechas
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los clientes que han realizado compras dentro de un rango de fechas específico.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS VentasEnRango;
CREATE PROCEDURE VentasEnRango(
    IN v_fecha_inicio DATE,
    IN v_fecha_fin DATE
)
BEGIN
    SELECT clnt.nombre as cliente, COUNT(vnts.id) as Nro_Ventas
    FROM clientes clnt
    INNER JOIN ventas vnts ON clnt.id = vnts.cliente_id
    WHERE vnts.fecha BETWEEN v_fecha_inicio AND v_fecha_fin
    GROUP BY clnt.nombre;
END;
//
DELIMITER ;

CALL VentasEnRango('2024-07-01','2024-07-02');
```
## Implementar Procedimientos Almacenados
### Caso de Uso 4.1: Actualización de Inventario de Bicicletas
**Descripción:** Este caso de uso describe cómo el sistema actualiza el inventario de bicicletas cuando se realiza una venta.
```sql
DELIMITER //

CREATE PROCEDURE actualizarInventarioBicicletas (
    IN v_venta_id INT
)
BEGIN
    DECLARE v_bicicleta_id INT;
    DECLARE v_cantidad INT;

    SELECT bicicleta_id, cantidad
    INTO v_bicicleta_id, v_cantidad
    FROM detalles_ventas
    WHERE venta_id = v_venta_id;

    UPDATE bicicletas
    SET stock = stock - v_cantidad
    WHERE id = v_bicicleta_id;
END;
//

CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON ventas
FOR EACH ROW
BEGIN
    CALL actualizarInventarioBicicletas(NEW.id);
END;
//

DELIMITER ;
```
### Caso de Uso 4.2: Registro de Nueva Venta
**Descripción:** Este caso de uso describe cómo el sistema registra una nueva venta, incluyendo la creación de la venta y la inserción de los detalles de la venta.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS CrearVenta;
CREATE PROCEDURE CrearVenta(
    IN v_ClienteID INT
)
BEGIN
    DECLARE nueva_venta_id INT;
    DECLARE fecha_venta DATE;
    DECLARE total_venta DECIMAL(10, 2);

    SET fecha_venta = CURDATE();

    INSERT INTO ventas (fecha, cliente_id, total)
    VALUES (fecha_venta, v_ClienteID, 0);

    SET nueva_venta_id = LAST_INSERT_ID();

    SELECT nueva_venta_id AS venta_id;
END;
//

DROP PROCEDURE IF EXISTS AgregarBicicletaVenta;
CREATE PROCEDURE AgregarBicicletaVenta(
    IN v_VentaID INT,
    IN v_BicicletaID INT,
    IN v_Cantidad INT
)
BEGIN
    DECLARE n_precio_unitario DECIMAL(10, 2);

    SELECT precio INTO n_precio_unitario
    FROM bicicletas
    WHERE id = v_BicicletaID;

    INSERT INTO detalles_ventas (venta_id, bicicleta_id, cantidad, precio_unitario)
    VALUES (v_VentaID, v_BicicletaID, v_Cantidad, n_precio_unitario);

    UPDATE ventas
    SET total = total + (n_precio_unitario * v_Cantidad)
    WHERE id = v_VentaID;

    SELECT CONCAT('Bicicleta agregada a la venta ID ', v_VentaID, ) AS mensaje;

    UPDATE bicicletas b
    SET b.stock = b.stock - dv.cantidad_vendida
    WHERE id = dv.bicicleta_id;
END;
//

DELIMITER ;

CALL CrearVenta(1);
CALL AgregarBicicletaVenta(5, 2, 3);
```
### Caso de Uso 4.3: Generación de Reporte de Ventas por Cliente
**Descripción:** Este caso de uso describe cómo el sistema genera un reporte de ventas para un cliente específico, mostrando todas las ventas realizadas por el cliente y los detalles de cada venta.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS DetallesVentasCliente;
CREATE PROCEDURE DetallesVentasCliente(
    IN v_ClienteID INT
)
BEGIN
    SELECT c.id, c.nombre, v.fecha, v.total, dv.venta_id, dv.bicicleta_id, dv.cantidad, dv.precio_unitario
    FROM clientes c
    JOIN ventas v ON c.id = v.cliente_id
    JOIN detalles_ventas dv ON v.id = dv.venta_id
    WHERE c.id = v_ClienteID;
END;
//

DELIMITER ;

CALL DetallesVentasCliente(2);
```
### Caso de Uso 4.4: Registro de Compra de Repuestos
**Descripción:** Este caso de uso describe cómo el sistema registra una nueva compra de repuestos a un proveedor.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS CrearCompra;
CREATE PROCEDURE CrearCompra(
    IN c_ProveedorID INT
)
BEGIN
    DECLARE nueva_compra_id INT;
    DECLARE fecha_compra DATE;
    DECLARE total_compra DECIMAL(10, 2);

    SET fecha_compra = CURDATE();

    INSERT INTO compras (fecha, proveedor_id, total)
    VALUES (fecha_compra, c_ProveedorID, 0);

    SET nueva_compra_id = LAST_INSERT_ID();

    SELECT nueva_compra_id AS compra_id;
END;
//

DROP PROCEDURE IF EXISTS AgregarRepuestoCompra;

CREATE PROCEDURE AgregarRepuestoCompra(
    IN c_CompraID INT,
    IN c_RepuestoID INT,
    IN c_Cantidad INT
)
BEGIN
    DECLARE n_precio_unitario DECIMAL(10, 2);

    SELECT precio INTO n_precio_unitario
    FROM repuestos
    WHERE id = c_RepuestoID;

    INSERT INTO detalles_compras (compra_id, repuesto_id, cantidad, precio_unitario)
    VALUES (c_CompraID, c_RepuestoID, c_Cantidad, n_precio_unitario);

    UPDATE compras
    SET total = total + (n_precio_unitario * c_Cantidad)
    WHERE id = c_CompraID;

    UPDATE repuestos
    SET stock = stock + c_Cantidad
    WHERE id = c_RepuestoID;

    SELECT CONCAT('Repuesto agregado a la compra ID ', c_CompraID) AS mensaje;
END;
//

DELIMITER ;

CALL CrearCompra(3);
CALL AgregarRepuestoCompra(1, 1, 5);
```
### Caso de Uso 4.5: Generación de Reporte de Inventario
**Descripción:** Este caso de uso describe cómo el sistema genera un reporte de inventario de bicicletas y repuestos.
```sql
DELIMITER //
DROP PROCEDURE IF EXISTS ReporteInventario;
CREATE PROCEDURE ReporteInventario()
BEGIN
    SELECT bicicleta_id AS id, SUM(cantidad) AS cantidad_total, 'Bicicleta' AS tipo
    FROM detalles_ventas
    GROUP BY bicicleta_id

    UNION ALL

    SELECT repuesto_id AS id, SUM(cantidad) AS cantidad_total, 'Repuesto' AS tipo
    FROM detalles_compras
    GROUP BY repuesto_id;
END //

DELIMITER ;

CALL ReporteInventario();
```
### Caso de Uso 4.6: Actualización Masiva de Precios
**Descripción:** Este caso de uso describe cómo el sistema permite actualizar masivamente los precios de todas las bicicletas de una marca específica.
```sql

```
### Caso de Uso 4.7: Generación de Reporte de Clientes por Ciudad
**Descripción:** Este caso de uso describe cómo el sistema genera un reporte de clientes agrupados por ciudad.
```sql

```
### Caso de Uso 4.8: Verificación de Stock antes de Venta
**Descripción:** Este caso de uso describe cómo el sistema verifica el stock de una bicicleta antes de permitir la venta.
```sql

```
### Caso de Uso 4.9: Registro de Devoluciones
**Descripción:** Este caso de uso describe cómo el sistema registra la devolución de una bicicleta por un cliente.
```sql

```
### Caso de Uso 4.10: Generación de Reporte de Compras por Proveedor
**Descripción:** Este caso de uso describe cómo el sistema genera un reporte de compras realizadas a un proveedor específico, mostrando todos los detalles de las compras.
```sql

```
### Caso de Uso 4.11: Calculadora de Descuentos en Ventas
**Descripción:** Este caso de uso describe cómo el sistema aplica un descuento a una venta antes de registrar los detalles de la venta.
```sql
DELIMITER //
DROP PROCEDURE IF EXISTS VentaConDescuento;
CREATE PROCEDURE VentaConDescuento(
    IN v_id INT,
    IN v_descuento INT
)
BEGIN
    DECLARE v_total_venta DECIMAL(10, 2);

    SELECT total INTO v_total_venta
    FROM ventas
    WHERE id = v_id;

    IF v_descuento BETWEEN 0 AND 100 THEN
        UPDATE ventas
        SET total = v_total_venta * (1 - v_descuento / 100)
        WHERE id = v_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El descuento debe ser un valor entre 0 y 100.';
    END IF;
    
    SELECT CONCAT('Se ha aplicado un descuento del ', v_descuento, '% a la venta con ID ', v_id) AS Resultado;
END; 
//

DELIMITER ;
```
## Funciones Resumen
### Caso de Uso 5.1: Calcular el Total de Ventas Mensuales
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ventas realizadas en un mes específico.
```sql

```
### Caso de Uso 5.2: Calcular el Promedio de Ventas por Cliente
**Descripción:** Este caso de uso describe cómo el sistema calcula el promedio de ventas realizadas por un cliente específico.
```sql

```
### Caso de Uso 5.3: Contar el Número de Ventas Realizadas en un Rango de
Fechas
**Descripción:** Este caso de uso describe cómo el sistema cuenta el número de ventas realizadas dentro de un rango de fechas específico.
```sql

```
### Caso de Uso 5.4: Calcular el Total de Repuestos Comprados por Proveedor
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de repuestos comprados a un proveedor específico.
```sql

```
### Caso de Uso 5.5: Calcular el Ingreso Total por Año
**Descripción:** Este caso de uso describe cómo el sistema calcula el ingreso total generado en un año específico.
```sql

```
### Caso de Uso 5.6: Calcular el Número de Clientes Activos en un Mes
**Descripción:** Este caso de uso describe cómo el sistema cuenta el número de clientes que han realizado al menos una compra en un mes específico.
```sql

```
### Caso de Uso 5.7: Calcular el Promedio de Compras por Proveedor
**Descripción:** Este caso de uso describe cómo el sistema calcula el promedio de compras realizadas a un proveedor específico.
```sql

```
### Caso de Uso 5.8: Calcular el Total de Ventas por Marca
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ventas agrupadas por la marca de las bicicletas vendidas.
```sql

```
### Caso de Uso 5.9: Calcular el Promedio de Precios de Bicicletas por Marca
**Descripción:** Este caso de uso describe cómo el sistema calcula el promedio de precios de las bicicletas agrupadas por marca.
```sql

```
### Caso de Uso 5.10: Contar el Número de Repuestos por Proveedor
**Descripción:** Este caso de uso describe cómo el sistema cuenta el número de repuestos suministrados por cada proveedor.
```sql

```
### Caso de Uso 5.11: Calcular el Total de Ingresos por Cliente
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ingresos generados por cada cliente.
```sql

```
### Caso de Uso 5.12: Calcular el Promedio de Compras Mensuales
**Descripción:** Este caso de uso describe cómo el sistema calcula el promedio de compras realizadas mensualmente por todos los clientes.
```sql

```
### Caso de Uso 5.13: Calcular el Total de Ventas por Día de la Semana
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ventas realizadas en cada día de la semana.
```sql

```
### Caso de Uso 5.14: Contar el Número de Ventas por Categoría de Bicicleta
**Descripción:** Este caso de uso describe cómo el sistema cuenta el número de ventas realizadas para cada categoría de bicicleta (por ejemplo, montaña, carretera, híbrida).
```sql

```
### Caso de Uso 5.15: Calcular el Total de Ventas por Año y Mes
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ventas realizadas cada mes, agrupadas por año.
```sql

```
#### Andrey Jerez & Alejandro Jimenez