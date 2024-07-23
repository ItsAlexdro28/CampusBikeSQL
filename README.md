# Campusbike

base de datos para la gestion eficiente de la informaicon de este negocio

- [Casos de uso](#casos-de-uso)
- [Uso Subconsultas](#subconsultas)
- [Uso Joins](#joins)
- [Funciones Resumen](#funciones-resumen) 

## Casos de uso

### Caso de uso 1.1: Gestión de Inventario de Bicicletas
**Descripción:** Este caso de uso describe cómo el sistema gestiona el inventario de bicicletas,
permitiendo agregar nuevas bicicletas, actualizar la información existente y eliminar bicicletas que
ya no están disponibles.
```sql

```
### Caso de uso 1.2: Registro de Ventas
**Descripción:** Este caso de uso describe el proceso de registro de una venta de bicicletas incluyendo la creación de una nueva venta, la selección de bicicletas vendidas y el cálculo del total de la venta 
```sql

```
### Caso de uso 1.3: Gestión de Proveedores y Repuestos
**Descripción:** Este caso de uyso descrube cómo el sistema gensitona la información de proveedores y repuestos, permitiendo agregar nuevos proveedores y repuestos, actualizar la información existente y eliminar proveedores y repuesots que ya no están activos
```sql

```
### Caso de uso 1.4: Consulta de Historial de Ventas por Cliente
**Descripción:** Este caso de uso describe cómo el sistema permite a un usuario consultar el historial de ventas de un cliente específico, mostrando todas las compras realizadas por el cliente y los detalles de cada venta
```sql

```
### Caso de Uso 1.5: Gestión de Compras de Repuestos
**Descripción:** Este caso de uso describe cómo el sistema gestiona las compras de repuestos a
proveedores, permitiendo registrar una nueva compra, especificar los repuestos comprados y
actualizar el stock de repuestos.
```sql

```
## Subconsultas
### Caso de Uso 2.1 Consulta de Bicicletas Más Vendidas por Marca
**Descripción:** Este caso de uso describe cómo el sistema permite a un usuario consultar las bicicletas más vendidas por cada marca.
```sql

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