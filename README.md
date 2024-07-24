# Campusbike

base de datos para la gestion eficiente de la informaicon de este negocio

- [Casos de uso](#casos-de-uso)
- [Uso Subconsultas](#subconsultas)
- [Uso Joins](#joins)
- [Almacenados](#implementar-procedimientos-almacenados)
- [Funciones Resumen](#funciones-resumen) 

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
END //

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
END //

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
END //

DELIMITER ;

DELIMITER //
```
### Caso de uso 1.2: Registro de Ventas
**Descripción:** Este caso de uso describe el proceso de registro de una venta de bicicletas incluyendo la creación de una nueva venta, la selección de bicicletas vendidas y el cálculo del total de la venta 
```sql
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
END //

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

    SELECT CONCAT('Bicicleta agregada a la venta ID ', v_VentaID) AS mensaje;
END //

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
END //

DELIMITER ;

CALL CrearVenta(1);
CALL AgregarBicicletaAVenta(1, 2, 3);
CALL ConfirmarVenta('Y', 1);
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
    
    -- UPDATE compras
    -- SET total = total + (n_precio_unitario * c_Cantidad)
    -- WHERE id = c_CompraID;

    SELECT CONCAT('Repuesto agregado a la compra ID ', c_CompraID) AS mensaje;
END //

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
    SELECT ma.nombre AS marca, mo.modelo AS modelo
    FROM marcas ma
    JOIN modelos mo ON ma.id = mo.marca_id
    JOIN bicicletas b ON mo.id = b.modelo
    WHERE mo.id IN (
        SELECT modelo_vendido_id
        FROM (
            SELECT mosub.id as modelo_vendido_id , COUNT(*) as modelos_vendidos
            FROM modelos mosub
            JOIN bicicletas bisub ON mosub.id = bisub.modelo
            GROUP BY mosub.id
        ) as ventas_de_modelos
        WHERE mo.id = ventas_de_modelos.id
        ORDER BY modelos_vendidos DESC
        LIMIT 1
    );
END;
//

DELIMITER ;

CALL BicicletasVendidasXMarca();
```
### Caso de Uso 2.2: Clientes con Mayor Gasto en un Año Específico
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los clientes que han gastado más en un año específico.

```sql

```
### Caso de Uso 2.3: Proveedores con Más Compras en el Último Mes
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los proveedores que han recibido más compras en el último mes.

```sql

```
### Caso de Uso 2.4: Repuestos con Menor Rotación en el Inventario
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los repuestos que han tenido menor rotación en el inventario, es decir, los menos vendidos.
```sql

```
### Caso de Uso 2.5: Ciudades con Más Ventas Realizadas
**Descripción:** Este caso de uso describe cómo el sistema permite consultar las ciudades donde se han realizado más ventas de bicicletas.
```sql

```
## Joins
### Caso de Uso 3.1: Consulta de Ventas por Ciudad
**Descripción:** Este caso de uso describe cómo el sistema permite consultar el total de ventas realizadas en cada ciudad.
```sql

```
### Caso de Uso 3.2: Consulta de Proveedores por País
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los proveedores agrupados por país.
```sql

```
### Caso de Uso 3.3: Compras de Repuestos por Proveedor
**Descripción:** Este caso de uso describe cómo el sistema permite consultar el total de repuestos comprados a cada proveedor.
```sql

```
### Caso de Uso 3.4: Clientes con Ventas en un Rango de Fechas
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los clientes que han realizado compras dentro de un rango de fechas específico.
```sql

```
## Implementar Procedimientos Almacenados
### Caso de Uso 4.1: Actualización de Inventario de Bicicletas
**Descripción:** Este caso de uso describe cómo el sistema actualiza el inventario de bicicletas cuando se realiza una venta.
```sql

```
### Caso de Uso 4.2: Registro de Nueva Venta
**Descripción:** Este caso de uso describe cómo el sistema registra una nueva venta, incluyendo la creación de la venta y la inserción de los detalles de la venta.
```sql

```
### Caso de Uso 4.3: Generación de Reporte de Ventas por Cliente
**Descripción:** Este caso de uso describe cómo el sistema genera un reporte de ventas para un cliente específico, mostrando todas las ventas realizadas por el cliente y los detalles de cada venta.
```sql

```
### Caso de Uso 4.4: Registro de Compra de Repuestos
**Descripción:** Este caso de uso describe cómo el sistema registra una nueva compra de repuestos a un proveedor.
```sql

```
### Caso de Uso 4.5: Generación de Reporte de Inventario
**Descripción:** Este caso de uso describe cómo el sistema genera un reporte de inventario de bicicletas y repuestos.
```sql

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