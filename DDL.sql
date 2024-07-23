DROP DATABASE IF EXISTS Campusbike;

CREATE DATABASE Campusbike;

USE Campusbike;

CREATE TABLE paises (
    id int AUTO_INCREMENT,
    nombre VARCHAR(30) NOT NULL,
    CONSTRAINT pk_paises_id PRIMARY KEY (id)
);

CREATE TABLE ciudades (
    id int AUTO_INCREMENT,
    nombre VARCHAR(30) NOT NULL,
    pais_id int,
    CONSTRAINT pk_ciudades_id PRIMARY KEY (id),
    CONSTRAINT fk_ciudades_paises_pais_id FOREIGN KEY (pais_id) REFERENCES paises(id)
);

CREATE TABLE marcas (
    id int AUTO_INCREMENT,
    nombre VARCHAR(30) NOT NULL,
    CONSTRAINT pk_marcas_id PRIMARY KEY (id)
);

CREATE TABLE modelos (
    id int AUTO_INCREMENT,
    marca_id int,
    modelo VARCHAR(30) NOT NULL,
    CONSTRAINT pk_modelos_id PRIMARY KEY (id),
    CONSTRAINT fk_modelos_marcas_marca_id FOREIGN KEY (marca_id) REFERENCES marcas(id)
);

CREATE TABLE bicicletas (
    id int AUTO_INCREMENT,
    modelo int,
    precio DECIMAL(10, 2) NOT NULL,
    stock int NOT NULL,
    CONSTRAINT pk_bicicletas_id PRIMARY KEY (id),
    CONSTRAINT fk_bicicletas_modelos_modelo FOREIGN KEY (modelo) REFERENCES modelos(id)
);

CREATE TABLE clientes (
    id int AUTO_INCREMENT, 
    nombre VARCHAR(30) NOT NULL,
    correo_electronico VARCHAR(50) UNIQUE NOT NULL,
    telefono VARCHAR(13) NOT NULL,
    ciudad_id int,
    CONSTRAINT pk_clientes_id PRIMARY KEY (id),
    CONSTRAINT fk_clientes_ciudades_ciudad_id FOREIGN KEY (ciudad_id) REFERENCES ciudades(id)
);

CREATE TABLE ventas (
    id int AUTO_INCREMENT,
    fecha DATE NOT NULL,
    cliente_id int,
    total DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_ventas_id PRIMARY KEY (id),
    CONSTRAINT fk_ventas_clientes_cliente_id FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE detalles_ventas (
    id int AUTO_INCREMENT,
    venta_id int,
    bicicleta_id int,
    cantidad int NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_detalles_ventas_id PRIMARY KEY (id),
    CONSTRAINT fk_detalles_ventas_ventas_venta_id FOREIGN KEY (venta_id) REFERENCES ventas(id),
    CONSTRAINT fk_detalles_ventas_bicibletas_bicicleta_id FOREIGN KEY (bicicleta_id) REFERENCES bicicletas(id)
);

CREATE TABLE proveedores (
    id int,
    nombre VARCHAR(50) NOT NULL,
    contacto VARCHAR(30) NOT NULL,
    telefono VARCHAR(13) NOT NULL,
    correo_electronico VARCHAR(30) NOT NULL,
    ciudad_id int,
    CONSTRAINT pk_proveedores_id PRIMARY KEY (id),
    CONSTRAINT fk_proveedores_ciudades_ciudad_id FOREIGN KEY (ciudad_id) REFERENCES ciudades(id)
);

CREATE TABLE repuestos (
    id int,
    nombre VARCHAR(40) NOT NULL,
    descripcion VARCHAR(80),
    precio DECIMAL(10, 2) NOT NULL,
    stock int NOT NULL,
    proveedor_id int,
    CONSTRAINT pk_repuestos_id PRIMARY KEY (id),
    CONSTRAINT fk_repuestos_proveedores_proveedor_id FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

CREATE TABLE compras (
    id int,
    fecha DATE NOT NULL,
    proveedor_id int,
    total DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_compras_id PRIMARY KEY (id),
    CONSTRAINT fk_compras_proveedores_proveedor_id FOREIGN KEY (proveedor_id) REFERENCES proveedores(id)
);

CREATE TABLE detalles_compras (
    id int,
    compra_id int,
    repuesto_id int,
    cantidad int NOT NULL,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_detalles_compras_id PRIMARY KEY (id),
    CONSTRAINT fk_detalles_compras_compreas_compra_id FOREIGN KEY (compra_id) REFERENCES compras(id),
    CONSTRAINT fk_detalles_compras_repuestos_repuesto_id FOREIGN KEY (repuesto_id) REFERENCES repuestos(id)
);

