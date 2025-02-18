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

CALL AgregarBicicleta(1,100,10);
CALL ActualizarBicicleta(15,200,9);
CALL EliminarBicicleta(15);
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
    DECLARE v_total DECIMAL(10,2);

    SELECT precio INTO n_precio_unitario
    FROM bicicletas
    WHERE id = v_BicicletaID;

    INSERT INTO detalles_ventas (venta_id, bicicleta_id, cantidad, precio_unitario)
    VALUES (v_VentaID, v_BicicletaID, v_Cantidad, n_precio_unitario);


    UPDATE ventas
    SET total = total + (n_precio_unitario * v_Cantidad)
    WHERE id = v_VentaID;

    SELECT total INTO v_total
    FROM ventas
    WHERE id = v_VentaID; 

    SELECT CONCAT('Bicicleta agregada a la venta ID ', v_VentaID, ' con un total de ', v_total) AS mensaje;
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
        JOIN detalles_ventas dv ON dv.bicicleta_id = b.id
        SET b.stock = (b.stock - dv.cantidad)
        WHERE dv.venta_id = v_VentaID;

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
CALL AgregarBicicletaAVenta(15, 2, 3);
CALL ConfirmarVenta('Y', 15);
```
### Caso de uso 1.3: Gestión de Proveedores y Repuestos
**Descripción:** Este caso de uso descrube cómo el sistema gensitona la información de proveedores y repuestos, permitiendo agregar nuevos proveedores y repuestos, actualizar la información existente y eliminar proveedores y repuesots que ya no están activos

```sql
DELIMITER //

DROP PROCEDURE IF EXISTS AgregarProveedor;
CREATE PROCEDURE AgregarProveedor(
	IN p_Nombre VARCHAR(50), IN p_Contacto VARCHAR(30), IN p_Telefono VARCHAR(13), IN p_Correo VARCHAR(30), IN p_Ciudad INT
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

CALL AgregarProveedor('Proveedor7', 'Contacto7', '123456781', 'correo7@example.com', 1);
CALL AgregarRepuesto('Repuesto8', 'Descripcion8', 100.00, 50, 7);
CALL ActualizarProveedor(7, 'Proveedora7', 'Contacto7', '987654321', 'correo7@example.com', 2);
CALL ActualizarRepuesto(8, 'Repuesto8', 'Descripcion8', 150.00, 30, 7);
CALL EliminarProveedor(7);
CALL EliminarRepuesto(8);
```
### Caso de uso 1.4: Consulta de Historial de Ventas por Cliente
**Descripción:** Este caso de uso describe cómo el sistema permite a un usuario consultar el historial de ventas de un cliente específico, mostrando todas las compras realizadas por el cliente y los detalles de cada venta
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS ListarVentas;
CREATE PROCEDURE ListarVentas(
    IN c_id INT
)
BEGIN
	SELECT id,fecha,cliente_id,total
	FROM ventas
    WHERE cliente_id = c_id;
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

CALL ListarVentas(1);
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

    UPDATE repuestos
    SET stock = stock + c_Cantidad
    WHERE id = c_RepuestoID;

    SELECT CONCAT('Repuesto agregado a la compra ID ', c_CompraID) AS mensaje;
END;
//

DELIMITER ;

CALL AgregarCompra(3, '2024-07-23', 500.00);
CALL AgregarRepuestoACompra(10, 1, 2);
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
            SELECT masub.nombre AS marca, mosub.modelo AS modelo, SUM(dvsub.cantidad) AS total_compras
            FROM marcas masub
            JOIN modelos mosub ON masub.id = mosub.marca_id
            JOIN bicicletas bisub ON mosub.id = bisub.modelo
            JOIN detalles_ventas dvsub ON bisub.id = dvsub.bicicleta_id
            GROUP BY masub.nombre, mosub.modelo
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
    IN v_año INT
)
BEGIN
    SELECT c.id, c.nombre,
        (SELECT SUM(v.total)
        FROM ventas v 
        WHERE v.cliente_id = c.id AND YEAR(v.fecha) = v_año
        ) AS total_gastado
    FROM clientes c
    ORDER BY total_gastado DESC;
END;
//

DELIMITER ;

CALL ListarClientesMasGastoAño(2024);
```
### Caso de Uso 2.3: Proveedores con Más Compras en el Último Mes
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los proveedores que han recibido más compras en el último mes.

```sql
DELIMITER //

DROP PROCEDURE IF EXISTS ListarProveedoresMasComprasUltimoMes;
CREATE PROCEDURE ListarProveedoresMasComprasUltimoMes()
BEGIN
    SELECT p.id, p.nombre,
        (SELECT COUNT(c.id)
        FROM compras c
        WHERE c.proveedor_id = p.id AND TIMESTAMPDIFF(MONTH, c.fecha, CURDATE()) = 0) as total_compras
    FROM proveedores p
    ORDER BY total_compras DESC;
END;
//

DELIMITER ;

CALL ListarProveedoresMasComprasUltimoMes();
```
### Caso de Uso 2.4: Repuestos con Menor Rotación en el Inventario
**Descripción:** Este caso de uso describe cómo el sistema permite consultar los repuestos que han tenido menor rotación en el inventario, es decir, los menos vendidos.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS ListarRepuestosMenorRotacion;
CREATE PROCEDURE ListarRepuestosMenorRotacion()
BEGIN
    SELECT r.id, r.nombre,
        (SELECT SUM(dc.cantidad)
        FROM detalles_compras dc
        WHERE dc.repuesto_id = r.id
        ) AS cantidad_movimientos
    FROM repuestos r
    ORDER BY cantidad_movimientos ASC;
END;
//

DELIMITER ;

CALL ListarRepuestosMenorRotacion();
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

CALL VentasPorCiudad();
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

CALL ProveedoresPorPais();
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

CALL RepuestosPorProveedor();
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

CALL VentasEnRango('2020-07-01','2024-07-02');
```
## Implementar Procedimientos Almacenados
### Caso de Uso 4.1: Actualización de Inventario de Bicicletas
**Descripción:** Este caso de uso describe cómo el sistema actualiza el inventario de bicicletas cuando se realiza una venta.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS actualizarInventarioBicicletas;
CREATE PROCEDURE actualizarInventarioBicicletas (
    IN dv_Bicicleta_id INT, 
    IN dv_Cantidad INT
)
BEGIN
    UPDATE bicicletas
    SET stock = stock - dv_Cantidad
    WHERE id = dv_Bicicleta_id;
END;
//

DROP TRIGGER IF EXISTS trigger_actualizar_inventario;
CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON detalles_ventas
FOR EACH ROW
BEGIN
    CALL actualizarInventarioBicicletas(NEW.bicicleta_id, NEW.cantidad);
END;
//

DELIMITER ;
```
### Caso de Uso 4.2: Registro de Nueva Venta
**Descripción:** Este caso de uso describe cómo el sistema registra una nueva venta, incluyendo la creación de la venta y la inserción de los detalles de la venta.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS CrearVentaYDetalles;
CREATE PROCEDURE CrearVenta(
    IN v_ClienteID INT,
    IN v_BicicletaID INT,
    IN v_Cantidad INT
)
BEGIN
    DECLARE nueva_venta_id INT;
    DECLARE fecha_venta DATE;
    DECLARE total_venta DECIMAL(10, 2);
    DECLARE n_precio_unitario DECIMAL(10, 2);

    SET fecha_venta = CURDATE();

    SELECT precio INTO n_precio_unitario
    FROM bicicletas
    WHERE id = v_BicicletaID;

    INSERT INTO ventas (fecha, cliente_id, total)
    VALUES (fecha_venta, v_ClienteID, 0);

    SET nueva_venta_id = LAST_INSERT_ID();

    INSERT INTO detalles_ventas (venta_id, bicicleta_id, cantidad, precio_unitario)
    VALUES (nueva_venta_id, v_BicicletaID, v_Cantidad, n_precio_unitario);

    UPDATE ventas
    SET total = total + (n_precio_unitario * v_Cantidad)
    WHERE id = nueva_venta_id;

    UPDATE bicicletas
    SET stock = stock - v_Cantidad
    WHERE id = v_BicicletaID;

END;
//

DELIMITER ;

CALL CrearVenta(1,1,1);
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
    IN c_ProveedorID INT,
    IN c_RepuestoID INT,
    IN c_Cantidad INT
)
BEGIN
    DECLARE nueva_compra_id INT;
    DECLARE fecha_compra DATE;
    DECLARE total_compra DECIMAL(10, 2);
    DECLARE n_precio_unitario DECIMAL(10, 2);

    SET fecha_compra = CURDATE();

    INSERT INTO compras (fecha, proveedor_id, total)
    VALUES (fecha_compra, c_ProveedorID, 0);

    SELECT precio INTO n_precio_unitario
    FROM repuestos
    WHERE id = c_RepuestoID;

    SET nueva_compra_id = LAST_INSERT_ID();

    INSERT INTO detalles_compras (compra_id, repuesto_id, cantidad, precio_unitario)
    VALUES (nueva_compra_id, c_RepuestoID, c_Cantidad, n_precio_unitario);

    UPDATE compras
    SET total = total + (n_precio_unitario * c_Cantidad)
    WHERE id = nueva_compra_id;

    UPDATE repuestos
    SET stock = stock + c_Cantidad
    WHERE id = c_RepuestoID;
END;
//

DELIMITER ;

CALL CrearCompra(3,3,10);
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
END; //

DELIMITER ;

CALL ReporteInventario();
```
### Caso de Uso 4.6: Actualización Masiva de Precios
**Descripción:** Este caso de uso describe cómo el sistema permite actualizar masivamente los precios de todas las bicicletas de una marca específica.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS ActualizarMasivamentePrecios;
CREATE PROCEDURE ActualizarMasivamentePrecios(
    IN m_MarcaID INT, IN m_incremento DECIMAL(10, 2)
)
BEGIN
    IF m_incremento > 0 THEN
        UPDATE bicicletas b
        JOIN modelos mo ON b.modelo = mo.id
        SET b.precio = (b.precio * (1 + m_incremento))
        WHERE mo.marca_id = m_MarcaID;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El porcentaje de incremento debe ser superior a 0';
    END IF;

    SELECT CONCAT('Se ha aplicado un incremento del ', m_incremento * 100, '% a las bicicletas de la marca con ID ', m_MarcaID) AS Resultado;
END //

DELIMITER ;

CALL ActualizarMasivamentePrecios(1, 0.1);

```
### Caso de Uso 4.7: Generación de Reporte de Clientes por Ciudad
**Descripción:** Este caso de uso describe cómo el sistema genera un reporte de clientes agrupados por ciudad.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS AgruparClientesCiudad;
CREATE PROCEDURE AgruparClientesCiudad()
BEGIN
    SELECT c.nombre, COUNT(cli.id) as CantidadClientes
    FROM ciudades c
    JOIN clientes cli ON c.id = cli.ciudad_id
    GROUP BY c.nombre;
END;
//

DELIMITER ;

CALL AgruparClientesCiudad();

```
### Caso de Uso 4.8: Verificación de Stock antes de Venta
**Descripción:** Este caso de uso describe cómo el sistema verifica el stock de una bicicleta antes de permitir la venta.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS VerificarStockBicicleta;
CREATE PROCEDURE VerificarStockBicicleta(
    IN b_BicicletaID INT,
    IN b_Cantidad INT,
    OUT mensaje VARCHAR(255)
)
BEGIN
    DECLARE v_stock INT;
    
    SELECT stock INTO v_stock
    FROM bicicletas
    WHERE id = b_BicicletaID;
    
    IF v_stock <= b_Cantidad THEN
        SET mensaje = 'No hay suficiente stock para realizar la venta';
    END IF;
END;
//

DROP TRIGGER IF EXISTS trigger_verificar_stock;
CREATE TRIGGER trigger_verificar_stock
BEFORE INSERT ON detalles_ventas
FOR EACH ROW
BEGIN
    DECLARE mensaje VARCHAR(255);
    
    CALL VerificarStockBicicleta(NEW.bicicleta_id, NEW.cantidad, mensaje);
    
    IF mensaje = 'No hay suficiente stock para realizar la venta' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = mensaje;
    END IF;
END;
//

DELIMITER ;

```
### Caso de Uso 4.9: Registro de Devoluciones
**Descripción:** Este caso de uso describe cómo el sistema registra la devolución de una bicicleta por un cliente.
```sql
DELIMITER //

CREATE PROCEDURE registrarDevolucion(
    IN p_venta_id INT,
)
BEGIN
    DECLARE v_cantidad_existente INT;
    DECLARE v_bicicleta_id INT;
    
    SELECT cantidad INTO v_cantidad_existente 
    FROM detalles_ventas 
    WHERE venta_id = p_venta_id;

    IF v_cantidad_existente IS NOT NULL THEN
        UPDATE detalles_ventas
        SET cantidad = 0
        WHERE venta_id = p_venta_id;

        SELECT bicicleta_id INTO v_bicicleta_id
        FROM detalles_ventas
        WHERE venta_id = p_venta_id;

        UPDATE ventas
        SET total = 0
        WHERE id = p_venta_id;

        UPDATE bicicletas
        SET stock = stock + v_cantidad_existente
        WHERE id = p_bicicleta_id;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Venta o bicicleta no encontrada';
    END IF;

END; 
//

DELIMITER ;
```
### Caso de Uso 4.10: Generación de Reporte de Compras por Proveedor
**Descripción:** Este caso de uso describe cómo el sistema genera un reporte de compras realizadas a un proveedor específico, mostrando todos los detalles de las compras.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS ReporteComprasProveedor;
CREATE PROCEDURE ReporteComprasProveedor(
    IN r_proveedor INT
)
BEGIN
    SELECT cmpr.id, cmpr.fecha, cmpr.total, dtllCmpr.cantidad, dtllCmpr.preico_unitario, rpst.nombre, rpst.descripcion
    FROM compras cmpr
    INNER JOIN detalles_compreas dtllCmpr ON cmpr.id = dtllCmpr.compra_id
    INNER JOIN repuestos rpst ON dtllCmpr.repuesto_id = rpst.id
    WHERE cmpr.proveedor_id = r_proveedor
END; 
//

DELIMITER ;
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
DELIMITER //

DROP FUNCTION IF EXISTS TotalVentasMensuales;
CREATE FUNCTION TotalVentasMensuales(
    f_año INT,
    f_mes INT
) RETURNS DECIMAL(10, 2)
BEGIN
    DECLARE total_ventas DECIMAL(10, 2);
    SELECT SUM(total) INTO total_ventas
    FROM ventas vnts
    WHERE
        YEAR(vnts.fecha) = f_año
        AND MONTH(vnts.fecha) = f_mes;
    RETURN total_ventas;
END; 
//

DELIMITER ;

SELECT TotalVentasMensuales(2024, 7);
```
### Caso de Uso 5.2: Calcular el Promedio de Ventas por Cliente
**Descripción:** Este caso de uso describe cómo el sistema calcula el promedio de ventas realizadas por un cliente específico.
```sql

DELIMITER //

DROP FUNCTION IF EXISTS PromedioVentasClientes;
CREATE FUNCTION PromedioVentasClientes(v_ClienteID INT)
RETURNS DECIMAL (10,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(10,2);
    SELECT AVG(v.total) INTO promedio
    FROM clientes c
    JOIN ventas v ON c.id = v.cliente_id
    WHERE c.id = v_ClienteID;
    RETURN promedio;
END;
//

DELIMITER ;

SELECT PromedioVentasClientes(2);

```
### Caso de Uso 5.3: Contar el Número de Ventas Realizadas en un Rango de
Fechas
**Descripción:** Este caso de uso describe cómo el sistema cuenta el número de ventas realizadas dentro de un rango de fechas específico.
```sql
DELIMITER //

DROP FUNCTION IF EXISTS ContarVentasFechas;
CREATE FUNCTION ContarVentasFechas(
    f_inicio DATE,
    f_final DATE
) RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE num_ventas INT;

    SELECT COUNT(vnts.id) INTO num_ventas
    FROM ventas vnts
    WHERE fecha BETWEEN f_inicio AND end_date;

    RETURN num_ventas;
END;
//

DELIMITER ;

SELECT ContarVentasPorRangoFechas('2024-07-01', '2024-07-31');
```
### Caso de Uso 5.4: Calcular el Total de Repuestos Comprados por Proveedor
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de repuestos comprados a un proveedor específico.
```sql
DELIMITER //

DROP FUNCTION IF EXISTS RepuestosCompradosProveedor;
CREATE FUNCTION RepuestosCompradosProveedor(p_ProveedorID INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE totalRepuestos DECIMAL(10,2);

    SELECT SUM(dc.cantidad) INTO totalRepuestos
    FROM compras c
    JOIN detalles_compras dc ON dc.compra_id = c.id
    WHERE c.proveedor_id = p_ProveedorID;

    RETURN totalRepuestos;
END;
//

DELIMITER ;

SELECT RepuestosCompradosProveedor(2);
```
### Caso de Uso 5.5: Calcular el Ingreso Total por Año
**Descripción:** Este caso de uso describe cómo el sistema calcula el ingreso total generado en un año específico.
```sql
DELIMITER //

DROP FUNCTION IF EXISTS IngresoTotalAnual;
CREATE FUNCTION IngresoTotalAnual(
    f_año INT
) RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total_ingreso DECIMAL(10, 2);

    SELECT SUM(total) INTO total_ingreso
    FROM ventas
    WHERE YEAR(fecha) = f_año;

    RETURN total_ingreso;
END;
//

DELIMITER ;

SELECT IngresoTotalAnual(2024);
```
### Caso de Uso 5.6: Calcular el Número de Clientes Activos en un Mes
**Descripción:** Este caso de uso describe cómo el sistema cuenta el número de clientes que han realizado al menos una compra en un mes específico.
```sql
DELIMITER //

DROP FUNCTION IF EXISTS ContarCantidadClientesVentasMasCero;
CREATE FUNCTION ContarCantidadClientesVentasMasCero(dv_Mes VARCHAR(20), dv_Año INT)
RETURNS VARCHAR(200)
DETERMINISTIC
BEGIN

    DECLARE cantidadClientes INT;
    DECLARE mensaje VARCHAR(200);

    SELECT COUNT(DISTINCT v.cliente_id) INTO cantidadClientes
    FROM ventas v
    WHERE YEAR(v.fecha) = dv_Año AND MONTHNAME(v.fecha) = dv_Mes;

    SET mensaje = CONCAT('La cantidad de clientes que han realizado al menos una compra en el mes ', dv_Mes, ' del año ', dv_Año, ' es ', cantidadClientes);

    RETURN mensaje;
END;
//

DELIMITER ;

SELECT ContarCantidadClientesVentasMasCero('July',2024) as Cantidad_de_Clientes;
```
### Caso de Uso 5.7: Calcular el Promedio de Compras por Proveedor
**Descripción:** Este caso de uso describe cómo el sistema calcula el promedio de compras realizadas a un proveedor específico.
```sql
DELIMITER //

DROP FUNCTION IF EXISTS PromedioComprasProveedor;
CREATE FUNCTION PromedioComprasProveedor(
    f_proveedor INT
) RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE promedio_compras DECIMAL(10, 2);

    SELECT AVG(total) INTO promedio_compras
    FROM compras
    WHERE proveedor_id = f_proveedor;

    RETURN promedio_compras;
END;
//

DELIMITER ;

SELECT PromedioComprasProveedor(1);
```
### Caso de Uso 5.8: Calcular el Total de Ventas por Marca
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ventas agrupadas por la marca de las bicicletas vendidas.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS AgruparMarcasPorTotalVendido;
CREATE PROCEDURE AgruparMarcasPorTotalVendido()
BEGIN
    SELECT ma.nombre, SUM(dv.cantidad * dv.precio_unitario) as total
    FROM detalles_ventas dv
    JOIN bicicletas b ON b.id = dv.bicicleta_id
    JOIN modelos mo ON mo.id = b.modelo
    JOIN marcas ma ON ma.id = mo.marca_id
    GROUP BY ma.nombre;
END;
//

DELIMITER ;

CALL AgruparMarcasPorTotalVendido();
```
### Caso de Uso 5.9: Calcular el Promedio de Precios de Bicicletas por Marca
**Descripción:** Este caso de uso describe cómo el sistema calcula el promedio de precios de las bicicletas agrupadas por marca.
```sql
DELIMITER //

DROP FUNCTION IF EXISTS PromedioPreciosMarca;
CREATE FUNCTION PromedioPreciosMarca(
    f_marca INT
) RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE promedio_precio DECIMAL(10, 2);

    SELECT AVG(bclt.precio) INTO promedio_precio
    FROM bicicletas bclt
    JOIN modelos mdls ON bclt.modelo = mdls.id
    WHERE mdls.marca_id = f_marca;

    RETURN promedio_precio;
END;
//

DELIMITER ;

SELECT PromedioPreciosMarca(1);
```
### Caso de Uso 5.10: Contar el Número de Repuestos por Proveedor
**Descripción:** Este caso de uso describe cómo el sistema cuenta el número de repuestos suministrados por cada proveedor.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS ContarNRepuestosProveedor;
CREATE PROCEDURE ContarNRepuestosProveedor()
BEGIN
    SELECT c.proveedor_id, SUM(dc.cantidad)
    FROM detalles_compras dc
    JOIN compras c ON dc.compra_id = c.id
    GROUP BY c.proveedor_id;
END;
//

DELIMITER ;

CALL ContarNRepuestosProveedor();
```
### Caso de Uso 5.11: Calcular el Total de Ingresos por Cliente
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ingresos generados por cada cliente.
```sql
DELIMITER //

DROP FUNCTION IF EXISTS TotalIngresosCliente;
CREATE FUNCTION TotalIngresosCliente(
    f_cliente INT
) RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total_ingresos DECIMAL(10, 2);

    SELECT SUM(total) INTO total_ingresos
    FROM ventas
    WHERE cliente_id = f_cliente;

    RETURN total_ingresos;
END;
//

DELIMITER ;

SELECT TotalIngresosCliente(1);
```
### Caso de Uso 5.12: Calcular el Promedio de Compras Mensuales
**Descripción:** Este caso de uso describe cómo el sistema calcula el promedio de compras realizadas mensualmente por todos los clientes.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS PromedioCompras;
CREATE PROCEDURE PromedioCompras()
BEGIN
    SELECT MONTHNAME(v.fecha) as mes, YEAR(v.fecha) as año, AVG(dv.cantidad) as Promedio_del_Mes
    FROM detalles_ventas dv
    JOIN ventas v ON dv.venta_id = v.id
    GROUP BY mes, año;
END;
//

DELIMITER ;

CALL PromedioCompras();
```
### Caso de Uso 5.13: Calcular el Total de Ventas por Día de la Semana
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ventas realizadas en cada día de la semana.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS TotalVentasSemana;
CREATE PROCEDURE TotalVentasSemana()
BEGIN
    SELECT
        CASE DAYOFWEEK(fecha)
            WHEN 1 THEN 'Domingo'
            WHEN 2 THEN 'Lunes'
            WHEN 3 THEN 'Martes'
            WHEN 4 THEN 'Miércoles'
            WHEN 5 THEN 'Jueves'
            WHEN 6 THEN 'Viernes'
            WHEN 7 THEN 'Sábado'
        END AS DiaDeLaSemana,
        SUM(total) AS TotalVentas
    FROM
        ventas
    GROUP BY
        DAYOFWEEK(fecha);
END;
//

DELIMITER ;
/* Da este error pendejo :(
ERROR 1055 (42000): Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'campusbike.ventas.fecha' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by
*/

CALL TotalVentasSemana();

DELIMITER //

DROP FUNCTION IF EXISTS TotalVentasSemana;
CREATE FUNCTION TotalVentasSemana(
    dia INT
) RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total_ventas DECIMAL(10, 2);
    
    SELECT
        SUM(total) INTO total_ventas
    FROM
        ventas
    WHERE
        DAYOFWEEK(fecha) = dia;

    RETURN total_ventas;
END;
//

DELIMITER ;

SELECT TotalVentasSemana(3);

```
### Caso de Uso 5.14: Contar el Número de Ventas por Categoría de Bicicleta
**Descripción:** Este caso de uso describe cómo el sistema cuenta el número de ventas realizadas para cada categoría de bicicleta (por ejemplo, montaña, carretera, híbrida).
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS VentasModelos;
CREATE PROCEDURE VentasModelos()
BEGIN
    SELECT mo.modelo, SUM(dv.cantidad) as Cantidad_de_Ventas
    FROM detalles_ventas dv
    JOIN bicicletas b ON b.id = dv.bicicleta_id
    JOIN modelos mo ON mo.id = b.modelo
    GROUP BY mo.modelo;
END;
//

DELIMITER ;

CALL VentasModelos();
```
### Caso de Uso 5.15: Calcular el Total de Ventas por Año y Mes
**Descripción:** Este caso de uso describe cómo el sistema calcula el total de ventas realizadas cada mes, agrupadas por año.
```sql
DELIMITER //

DROP PROCEDURE IF EXISTS TotalVentasAnualMensual;
CREATE PROCEDURE TotalVentasAnualMensual()
BEGIN
    SELECT
        YEAR(fecha) AS Año,
        MONTH(fecha) AS Mes,
        SUM(total) AS TotalVentas
    FROM
        ventas
    GROUP BY
        YEAR(fecha), MONTH(fecha)
    ORDER BY
        Año, Mes;
END;
//

DELIMITER ;

CALL TotalVentasAnualMensual();
```
#### Andrey Jerez & Alejandro Jimenez