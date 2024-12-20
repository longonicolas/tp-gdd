﻿/*
-----------------------

-- PASO 1: Eliminar todas las Foreign Keys del esquema LA_NARANJA_MECANICA_V2 
*/
DECLARE @sql NVARCHAR(MAX) = N'';

-- Genera las instrucciones para eliminar todas las claves for�neas en el esquema
SELECT @sql += 'ALTER TABLE [' + OBJECT_SCHEMA_NAME(parent_object_id) + '].[' 
               + OBJECT_NAME(parent_object_id) + '] DROP CONSTRAINT [' + name + '];' + CHAR(13)
FROM sys.foreign_keys
WHERE schema_id = SCHEMA_ID('LA_NARANJA_MECANICA_V2');

-- Ejecuta el SQL generado para eliminar las claves for�neas
EXEC sp_executesql @sql;

SET @sql = N'';

-- Genera las instrucciones para eliminar todas las funciones en el esquema
SELECT @sql += 'DROP FUNCTION [' + ROUTINE_SCHEMA + '].[' + ROUTINE_NAME + '];' + CHAR(13)
FROM INFORMATION_SCHEMA.ROUTINES
WHERE ROUTINE_SCHEMA = 'LA_NARANJA_MECANICA_V2' AND ROUTINE_TYPE = 'FUNCTION';

-- Ejecuta el SQL generado para eliminar las funciones
EXEC sp_executesql @sql;


SET @sql = N'';

-- Genera las instrucciones para eliminar todas las tablas en el esquema
SELECT @sql += 'DROP TABLE [' + TABLE_SCHEMA + '].[' + TABLE_NAME + '];' + CHAR(13)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'LA_NARANJA_MECANICA_V2';

-- Ejecuta el SQL generado para eliminar las tablas
EXEC sp_executesql @sql;

DROP VIEW LA_NARANJA_MECANICA_V2.V1_PromedioTiempoPublicaciones;
DROP VIEW LA_NARANJA_MECANICA_V2.V2_PromedioStockInicial;
DROP VIEW LA_NARANJA_MECANICA_V2.V3_VentaPromedioMensual;
DROP VIEW LA_NARANJA_MECANICA_V2.V4_RendimientoDeRubros;
DROP VIEW LA_NARANJA_MECANICA_V2.V6_Top3LocalidadesPagosCuotas;
DROP VIEW LA_NARANJA_MECANICA_V2.V7_PorcentajeCumplimientoEnvios;
DROP VIEW LA_NARANJA_MECANICA_V2.V8_LocalidadesCostoEnvio;
DROP VIEW LA_NARANJA_MECANICA_V2.V9_PorcentajeFacturacionPorConcepto;
DROP VIEW LA_NARANJA_MECANICA_V2.V10_Facturacion_Por_Provincia


/*
-- PASO 4: Eliminar el esquema LA_NARANJA_MECANICA_V2 
*/
-- Si deseas eliminar el esquema completo, usa esta l�nea.
DROP SCHEMA LA_NARANJA_MECANICA_V2;

---------------------CREAMOS ESQUEMA-------------------------
USE GD2C2024
GO

CREATE SCHEMA LA_NARANJA_MECANICA_V2;
GO



-- Tabla: cliente
CREATE TABLE LA_NARANJA_MECANICA_V2.cliente(
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(50),
	apellido NVARCHAR(50),
	fecha_nacimiento DATE,
	mail NVARCHAR(50),
	dni decimal(18,0)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.vendedor(
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	razon_social NVARCHAR(50),
	cuit NVARCHAR(50),
	mail NVARCHAR(50),
)


CREATE TABLE LA_NARANJA_MECANICA_V2.usuario(
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	usuario NVARCHAR(50),
	password NVARCHAR(50),
	fecha_creacion DATE,
	id_vendedor decimal(18,0),
	id_cliente decimal(18,0),
	FOREIGN KEY (id_vendedor) REFERENCES LA_NARANJA_MECANICA_V2.vendedor(id),
	FOREIGN KEY (id_cliente) REFERENCES LA_NARANJA_MECANICA_V2.cliente(id)
)


-- Tabla: provincia
CREATE TABLE LA_NARANJA_MECANICA_V2.provincia(
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(50)
)

-- Tabla: localidad
CREATE TABLE LA_NARANJA_MECANICA_V2.localidad(
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	id_provincia decimal(18,0),
	nombre NVARCHAR(50),
	FOREIGN KEY (id_provincia) REFERENCES LA_NARANJA_MECANICA_V2.provincia(id)
)

-- Tabla: domicilio
CREATE TABLE LA_NARANJA_MECANICA_V2.domicilio(
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	id_localidad decimal(18,0),
	id_usuario decimal(18,0),
	calle NVARCHAR(50),
	nro_calle decimal(18,0),
	piso decimal(18,0),
	depto NVARCHAR(50),
	codigo_postal decimal(18,0),
	FOREIGN KEY (id_localidad) REFERENCES LA_NARANJA_MECANICA_V2.localidad(id),
	FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id)
)

-- Tabla: almacen
CREATE TABLE LA_NARANJA_MECANICA_V2.almacen(
	codigo_almacen decimal(18,0) PRIMARY KEY,
	costo_al_dia DECIMAL(18,2),
	id_domicilio decimal(18,0)
	FOREIGN KEY (id_domicilio) REFERENCES LA_NARANJA_MECANICA_V2.domicilio(id)
)

-- Tabla: marca
CREATE TABLE LA_NARANJA_MECANICA_V2.marca(
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	nombre NVARCHAR(50)
)

-- Tabla: rubro
CREATE TABLE LA_NARANJA_MECANICA_V2.rubro(
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	descripcion NVARCHAR(50)
)

-- Tabla: subrubro
CREATE TABLE LA_NARANJA_MECANICA_V2.subrubro(
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	id_rubro decimal(18,0),
	nombre NVARCHAR(50),
	FOREIGN KEY (id_rubro) REFERENCES LA_NARANJA_MECANICA_V2.rubro(id)
)

-- Tabla: modelo_producto
CREATE TABLE LA_NARANJA_MECANICA_V2.modeloProducto (
    codigo_modelo decimal(18,0) PRIMARY KEY,
    descripcion NVARCHAR(50)
);

-- Tabla: producto
CREATE TABLE LA_NARANJA_MECANICA_V2.producto(
	id decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	codigo_producto NVARCHAR(50),
	descripcion NVARCHAR(50),
	precio decimal(18,2),
	codigo_modelo decimal(18,0),
	id_marca decimal(18,0),
	id_subrubro decimal(18,0),
	FOREIGN KEY (codigo_modelo) REFERENCES LA_NARANJA_MECANICA_V2.modeloProducto(codigo_modelo),
	FOREIGN KEY (id_marca) REFERENCES LA_NARANJA_MECANICA_V2.marca(id),
	FOREIGN KEY (id_subrubro) REFERENCES LA_NARANJA_MECANICA_V2.subrubro(id)
)

-- Tabla: publicacion
CREATE TABLE LA_NARANJA_MECANICA_V2.publicacion (
    codigo_publicacion decimal(18,0) PRIMARY KEY,
    descripcion NVARCHAR(50),
    fecha_inicio DATE,
    fecha_fin DATE,
    id_producto decimal(18,0),
    stock decimal(18,0),
    precio DECIMAL(18, 2),
    id_usuario decimal(18,0),
    id_almacen decimal(18,0),
    costo DECIMAL(18, 2),
    porcentaje_por_venta DECIMAL(18, 2),
    FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id),
    FOREIGN KEY (id_almacen) REFERENCES LA_NARANJA_MECANICA_V2.almacen(codigo_almacen),
	FOREIGN KEY (id_producto) REFERENCES LA_NARANJA_MECANICA_V2.producto(id)
)

-- Tabla: detalle_venta
CREATE TABLE LA_NARANJA_MECANICA_V2.detalle_venta (
    id_detalle_venta decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    id_publicacion decimal(18,0),
    cantidad decimal(18,0),
	precio decimal(18,2),-- en la tabla maestra esta como DECIMAL(18, 0) y tambien esta el precio que no lo pusimos aca
    subtotal DECIMAL(18, 2),
    FOREIGN KEY (id_publicacion) REFERENCES LA_NARANJA_MECANICA_V2.publicacion(codigo_publicacion)
);

-- Tabla: venta
CREATE TABLE LA_NARANJA_MECANICA_V2.venta (
    nro_venta decimal(18,0) PRIMARY KEY, 
    id_usuario decimal(18,0),
    id_detalle_venta decimal(18,0),
    fecha DATE,
    total DECIMAL(18, 2),
    FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id),
    FOREIGN KEY (id_detalle_venta) REFERENCES LA_NARANJA_MECANICA_V2.detalle_venta(id_detalle_venta)
);

-- Tabla: tipo_envio
CREATE TABLE LA_NARANJA_MECANICA_V2.tipo_envio (
    id_tipo_envio decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(50)
);

-- Tabla: envio
CREATE TABLE LA_NARANJA_MECANICA_V2.envio (
    nro_envio decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nro_venta decimal(18,0),
    id_domicilio decimal(18,0),
    fecha DATE,
    hora_inicio decimal(18,0),
    hora_fin decimal(18,0),
    costo DECIMAL(18, 2),
    fecha_entrega DATETIME,
    id_tipo_envio decimal(18,0),
    FOREIGN KEY (nro_venta) REFERENCES LA_NARANJA_MECANICA_V2.venta(nro_venta),
    FOREIGN KEY (id_domicilio) REFERENCES LA_NARANJA_MECANICA_V2.domicilio(id),
    FOREIGN KEY (id_tipo_envio) REFERENCES LA_NARANJA_MECANICA_V2.tipo_envio(id_tipo_envio)
);

-- Tabla: concepto
CREATE TABLE LA_NARANJA_MECANICA_V2.concepto (
    id_concepto decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(50)
);

-- Tabla: factura
CREATE TABLE LA_NARANJA_MECANICA_V2.factura (
    nro_factura decimal(18,0) PRIMARY KEY, 
    fecha DATE,
    id_usuario decimal(18,0),
    total DECIMAL(18, 2),
    FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id)
);

-- Tabla: detalle_factura
CREATE TABLE LA_NARANJA_MECANICA_V2.detalle_factura (
    id_detalle_factura decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
	nro_factura decimal(18,0),
    codigo_publicacion decimal(18,0),
    id_concepto decimal(18,0), --FACTURA_DET_TIP�
    cantidad decimal(18,0),
    precio_unitario DECIMAL(18, 2),
	detalle_subtotal decimal(18,2),
    FOREIGN KEY (codigo_publicacion) REFERENCES LA_NARANJA_MECANICA_V2.publicacion(codigo_publicacion),
    FOREIGN KEY (id_concepto) REFERENCES LA_NARANJA_MECANICA_V2.concepto(id_concepto),
	FOREIGN KEY (nro_factura) REFERENCES LA_NARANJA_MECANICA_V2.factura(nro_factura)
);

-- Tabla: tipo_medio_pago
CREATE TABLE LA_NARANJA_MECANICA_V2.tipo_medio_pago (
    id_tipo_medio_pago decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nombre NVARCHAR(50)
)

-- Tabla: medio_pago
CREATE TABLE LA_NARANJA_MECANICA_V2.medio_pago (
    id_medio_pago decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nro_tarjeta NVARCHAR(50),
    fecha_vencimiento DATE,
    id_tipo_medio_pago decimal(18,0),
	nombre_medio_pago NVARCHAR(50),
    FOREIGN KEY (id_tipo_medio_pago) REFERENCES LA_NARANJA_MECANICA_V2.tipo_medio_pago(id_tipo_medio_pago)
);

-- Tabla: pago
CREATE TABLE LA_NARANJA_MECANICA_V2.pago (
    nro_pago decimal(18,0) IDENTITY(1,1) PRIMARY KEY,
    nro_venta decimal(18,0),
    id_medio_pago decimal(18,0),
    importe DECIMAL(18, 2),
    fecha DATE,
    cuotas decimal(18,0),
    FOREIGN KEY (nro_venta) REFERENCES LA_NARANJA_MECANICA_V2.venta(nro_venta),
    FOREIGN KEY (id_medio_pago) REFERENCES LA_NARANJA_MECANICA_V2.medio_pago(id_medio_pago)
);

--------------------------FUNCIONES-----------------------------------

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_rubro(@descripcion NVARCHAR(50))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.rubro
	WHERE descripcion LIKE @descripcion

	RETURN @id
END
GO


-- OBTENER ID DE UN SUBRUBRO
GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_subrubro(@subrubro NVARCHAR(50), @rubro NVARCHAR(50))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.subrubro
	WHERE nombre = @subrubro AND id_rubro = LA_NARANJA_MECANICA_V2.get_id_rubro(@rubro)
	RETURN @id
END
GO
-- OBTENER ID DE UNA MARCA
	
GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_marca(@marca NVARCHAR(50))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.marca
	WHERE nombre = @marca

	RETURN @id
END
GO
	-- OBTENER UN ID DE UN PRODUCTO
GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_producto(@codigo NVARCHAR(50), @descripcion NVARCHAR(50), @marca NVARCHAR(50), @modelo decimal(18,0),@subrubro NVARCHAR(50), @rubro NVARCHAR(50))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)
	
	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.producto p
	WHERE p.codigo_producto = @codigo
		  AND p.descripcion = @descripcion
		  AND p.id_marca = LA_NARANJA_MECANICA_V2.get_id_marca(@marca)
		  AND p.codigo_modelo = @modelo
		  AND p.id_subrubro = LA_NARANJA_MECANICA_V2.get_id_subrubro(@subrubro, @rubro)

	RETURN @id
END
GO
GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.devolver_id_cliente(@nombre NVARCHAR(50), @apellido NVARCHAR(50), @dni decimal(18,0))
RETURNS decimal(18,0)
AS 
BEGIN
    DECLARE @id decimal(18,0);

    SET @id = -1;

    SELECT @id = id 
    FROM LA_NARANJA_MECANICA_V2.cliente 
    WHERE nombre = @nombre 
      AND apellido = @apellido 
      AND dni = @dni;

    RETURN @id;
END
GO
GO
CREATE FUNCTION LA_NARANJA_MECANICA_V2.devolver_id_vendedor(@cuit NVARCHAR(50), @razonSocial NVARCHAR(50))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.vendedor
	WHERE cuit = @cuit AND razon_social = @razonSocial

	RETURN @id
END
GO
GO
CREATE FUNCTION LA_NARANJA_MECANICA_V2.devolver_id_usuario_cliente(@username NVARCHAR(50), @password NVARCHAR(50), @fecha_creacion DATE)
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.usuario
	WHERE usuario = @username AND password = @password AND fecha_creacion = @fecha_creacion

	RETURN @id
END
GO
GO
CREATE FUNCTION  LA_NARANJA_MECANICA_V2.devolver_id_localidad(@nombre NVARCHAR(50), @provincia NVARCHAR(50))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = l.id
	FROM LA_NARANJA_MECANICA_V2.localidad l
	JOIN LA_NARANJA_MECANICA_V2.provincia p ON l.id_provincia = p.id
	WHERE l.nombre = @nombre AND p.nombre = @provincia

	RETURN @id
END
GO
GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_domicilio(@calle NVARCHAR(50), @altura decimal(18,0), @localidad NVARCHAR(50), @provincia NVARCHAR(50))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.domicilio
	WHERE calle = @calle AND nro_calle = @altura AND id_localidad = LA_NARANJA_MECANICA_V2.devolver_id_localidad(@localidad, @provincia)

	RETURN @id
END
GO
GO
CREATE FUNCTION LA_NARANJA_MECANICA_V2.devolver_id_usuario_vendedor(@username NVARCHAR(50), @password NVARCHAR(50), @fecha_creacion DATE)
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.usuario
	WHERE usuario = @username AND password = @password AND fecha_creacion = @fecha_creacion

	RETURN @id
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_tipo_medio_pago(@nombre NVARCHAR(50))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id_tipo_medio_pago
	FROM LA_NARANJA_MECANICA_V2.tipo_medio_pago
	WHERE nombre = @nombre

	RETURN @id
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_medio_pago(@nro_tarjeta NVARCHAR(50), @fecha_vencimiento DATE, @nombre_medio_pago NVARCHAR(50))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id_medio_pago
	FROM LA_NARANJA_MECANICA_V2.medio_pago
	WHERE nombre_medio_pago = @nombre_medio_pago and nro_tarjeta = @nro_tarjeta and fecha_vencimiento = @fecha_vencimiento

	RETURN @id
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_publicacion(@publicacion_codigo decimal(18,0))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = codigo_publicacion
	FROM LA_NARANJA_MECANICA_V2.publicacion
	WHERE codigo_publicacion = @publicacion_codigo

	RETURN @id
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_detalle_venta(@cantidad decimal(18,0), @precio decimal(18,2), @subtotal decimal(18,2))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id_detalle_venta
	FROM LA_NARANJA_MECANICA_V2.detalle_venta
	WHERE cantidad = @cantidad and precio = @precio and subtotal = @subtotal

	RETURN @id
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_venta(@venta_codigo decimal(18,0))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = nro_venta
	FROM LA_NARANJA_MECANICA_V2.venta
	WHERE nro_venta = @venta_codigo

	RETURN @id
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_factura(@nro_factura decimal(18,0))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = nro_factura
	FROM LA_NARANJA_MECANICA_V2.factura
	WHERE nro_factura = @nro_factura

	RETURN @id
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.devolver_id_usuario_vendedor_por_publicacion(@publicacion_codigo decimal(18,0))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id_vendedor decimal(18,0)
	DECLARE @id_publicacion decimal(18,0)

	SELECT @id_vendedor = id_usuario, @id_publicacion = codigo_publicacion
	FROM LA_NARANJA_MECANICA_V2.publicacion
	WHERE codigo_publicacion = @publicacion_codigo

	RETURN @id_vendedor
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_concepto(@nombre_concepto NVARCHAR(50))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id_concepto
	FROM LA_NARANJA_MECANICA_V2.concepto
	WHERE nombre = @nombre_concepto

	RETURN @id
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_tipo_envio(@nombre NVARCHAR(50))
RETURNS DECIMAL(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id_tipo_envio
	FROM LA_NARANJA_MECANICA_V2.tipo_envio
	WHERE nombre = @nombre

	RETURN @id
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_domicilio_cliente(@calle NVARCHAR(50), @altura decimal(18,0), @piso DECIMAL(18,0) , @depto NVARCHAR(50) , @localidad NVARCHAR(50), @provincia NVARCHAR(50))
RETURNS DECIMAL(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.domicilio
	WHERE calle = @calle AND nro_calle = @altura AND id_localidad = LA_NARANJA_MECANICA_V2.devolver_id_localidad(@localidad, @provincia) AND piso = @piso AND depto = @depto

	RETURN @id


END
GO

---------------------MIGRACION-------------------------

-- Crear provincias

INSERT INTO LA_NARANJA_MECANICA_V2.provincia (nombre)
SELECT DISTINCT CLI_USUARIO_DOMICILIO_PROVINCIA FROM gd_esquema.Maestra
WHERE CLI_USUARIO_DOMICILIO_PROVINCIA IS NOT NULL

INSERT INTO LA_NARANJA_MECANICA_V2.provincia
SELECT ALMACEN_PROVINCIA from gd_esquema.Maestra
WHERE ALMACEN_PROVINCIA NOT IN (SELECT nombre from LA_NARANJA_MECANICA_V2.provincia) AND ALMACEN_PROVINCIA IS NOT NULL

-- Crear Localidades

INSERT INTO LA_NARANJA_MECANICA_V2.localidad (id_provincia, nombre) 
SELECT DISTINCT p.id, CLI_USUARIO_DOMICILIO_LOCALIDAD FROM gd_esquema.Maestra
JOIN LA_NARANJA_MECANICA_V2.provincia p ON p.nombre = CLI_USUARIO_DOMICILIO_PROVINCIA
WHERE CLI_USUARIO_DOMICILIO_PROVINCIA IS NOT NULL

INSERT INTO LA_NARANJA_MECANICA_V2.localidad (id_provincia, nombre)
SELECT DISTINCT p.id, VEN_USUARIO_DOMICILIO_LOCALIDAD
FROM gd_esquema.Maestra
JOIN LA_NARANJA_MECANICA_V2.provincia p ON p.nombre = VEN_USUARIO_DOMICILIO_PROVINCIA
WHERE NOT EXISTS (
				  SELECT * from LA_NARANJA_MECANICA_V2.localidad l
				  JOIN LA_NARANJA_MECANICA_V2.provincia p ON p.id = l.id_provincia 
				  WHERE l.nombre = VEN_USUARIO_DOMICILIO_LOCALIDAD AND p.nombre = VEN_USUARIO_DOMICILIO_PROVINCIA)
				  AND VEN_USUARIO_DOMICILIO_CALLE IS NOT NULL


INSERT INTO LA_NARANJA_MECANICA_V2.localidad (id_provincia,nombre)
SELECT DISTINCT p.id, ALMACEN_Localidad from gd_esquema.Maestra
JOIN LA_NARANJA_MECANICA_V2.provincia p ON p.nombre = ALMACEN_PROVINCIA
WHERE NOT EXISTS (SELECT * from LA_NARANJA_MECANICA_V2.localidad l
				  JOIN LA_NARANJA_MECANICA_V2.provincia p ON p.id = l.id_provincia 
				  WHERE l.nombre = ALMACEN_Localidad AND p.nombre = ALMACEN_PROVINCIA) AND ALMACEN_CALLE IS NOT NULL

-- Insertar Clientes y Vendedores

INSERT INTO LA_NARANJA_MECANICA_V2.cliente (nombre, apellido, mail, dni, fecha_nacimiento)
SELECT DISTINCT CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_MAIL, CLIENTE_DNI, CLIENTE_FECHA_NAC FROM gd_esquema.Maestra
WHERE CLIENTE_NOMBRE IS NOT NULL

INSERT INTO LA_NARANJA_MECANICA_V2.vendedor (razon_social, cuit, mail)
SELECT DISTINCT VENDEDOR_RAZON_SOCIAL, VENDEDOR_CUIT, VENDEDOR_MAIL FROM gd_esquema.Maestra
WHERE VENDEDOR_RAZON_SOCIAL IS NOT NULL

-- Insertar Usuarios

INSERT INTO LA_NARANJA_MECANICA_V2.usuario (usuario, password, fecha_creacion, id_cliente)
SELECT DISTINCT CLI_USUARIO_NOMBRE, CLI_USUARIO_PASS, CLI_USUARIO_FECHA_CREACION, LA_NARANJA_MECANICA_V2.devolver_id_cliente(CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_DNI) FROM gd_esquema.Maestra
WHERE CLIENTE_NOMBRE IS NOT NULL

INSERT INTO LA_NARANJA_MECANICA_V2.usuario (usuario, password, fecha_creacion, id_vendedor)
SELECT DISTINCT VEN_USUARIO_NOMBRE, VEN_USUARIO_PASS, VEN_USUARIO_FECHA_CREACION ,LA_NARANJA_MECANICA_V2.devolver_id_vendedor(VENDEDOR_CUIT, VENDEDOR_RAZON_SOCIAL) FROM gd_esquema.Maestra
WHERE VENDEDOR_RAZON_SOCIAL IS NOT NULL

-- Direcciones de usuarios y almacenes

INSERT INTO LA_NARANJA_MECANICA_V2.domicilio (id_localidad, calle, nro_calle, piso, depto, codigo_postal, id_usuario)
SELECT DISTINCT LA_NARANJA_MECANICA_V2.devolver_id_localidad(CLI_USUARIO_DOMICILIO_LOCALIDAD, CLI_USUARIO_DOMICILIO_PROVINCIA) ,CLI_USUARIO_DOMICILIO_CALLE, CLI_USUARIO_DOMICILIO_NRO_CALLE, CLI_USUARIO_DOMICILIO_PISO, CLI_USUARIO_DOMICILIO_DEPTO ,CLI_USUARIO_DOMICILIO_CP ,LA_NARANJA_MECANICA_V2.devolver_id_usuario_cliente(CLI_USUARIO_NOMBRE, CLI_USUARIO_PASS, CLI_USUARIO_FECHA_CREACION) 
FROM gd_esquema.Maestra
WHERE CLI_USUARIO_NOMBRE IS NOT NULL

INSERT INTO LA_NARANJA_MECANICA_V2.domicilio(id_localidad, calle, nro_calle, piso, depto, codigo_postal, id_usuario)
SELECT DISTINCT LA_NARANJA_MECANICA_V2.devolver_id_localidad(VEN_USUARIO_DOMICILIO_LOCALIDAD, VEN_USUARIO_DOMICILIO_PROVINCIA), VEN_USUARIO_DOMICILIO_CALLE, VEN_USUARIO_DOMICILIO_NRO_CALLE, VEN_USUARIO_DOMICILIO_PISO, VEN_USUARIO_DOMICILIO_DEPTO, VEN_USUARIO_DOMICILIO_CP,  LA_NARANJA_MECANICA_V2.devolver_id_usuario_vendedor(VEN_USUARIO_NOMBRE, VEN_USUARIO_PASS, VEN_USUARIO_FECHA_CREACION)
FROM gd_esquema.Maestra
WHERE VEN_USUARIO_NOMBRE IS NOT NULL

INSERT INTO LA_NARANJA_MECANICA_V2.domicilio (id_localidad, calle, nro_calle)
SELECT DISTINCT LA_NARANJA_MECANICA_V2.devolver_id_localidad(ALMACEN_Localidad, ALMACEN_PROVINCIA), ALMACEN_CALLE, ALMACEN_NRO_CALLE
FROM gd_esquema.Maestra
WHERE ALMACEN_CALLE IS NOT NULL

-- Crear Almacenes

INSERT INTO LA_NARANJA_MECANICA_V2.almacen (codigo_almacen, costo_al_dia, id_domicilio)
SELECT DISTINCT ALMACEN_CODIGO, ALMACEN_COSTO_DIA_AL ,LA_NARANJA_MECANICA_V2.get_id_domicilio(ALMACEN_CALLE, ALMACEN_NRO_CALLE, ALMACEN_Localidad, ALMACEN_PROVINCIA)
FROM gd_esquema.Maestra
WHERE ALMACEN_CODIGO IS NOT NULL

-- Crear de Marcas
INSERT INTO LA_NARANJA_MECANICA_V2.marca (nombre)
SELECT DISTINCT PRODUCTO_MARCA
FROM gd_esquema.Maestra
WHERE PRODUCTO_CODIGO IS NOT NULL

-- Crear rubros
INSERT INTO LA_NARANJA_MECANICA_V2.rubro (descripcion)
SELECT DISTINCT PRODUCTO_RUBRO_DESCRIPCION
FROM gd_esquema.Maestra
WHERE PRODUCTO_RUBRO_DESCRIPCION IS NOT NULL

-- Crear subrubros
INSERT INTO LA_NARANJA_MECANICA_V2.subrubro (id_rubro, nombre)
SELECT DISTINCT LA_NARANJA_MECANICA_V2.get_id_rubro(PRODUCTO_RUBRO_DESCRIPCION), PRODUCTO_SUB_RUBRO
FROM gd_esquema.Maestra
WHERE PRODUCTO_SUB_RUBRO IS NOT NULL

-- Crear modelos
INSERT INTO LA_NARANJA_MECANICA_V2.modeloProducto (codigo_modelo, descripcion)
SELECT DISTINCT PRODUCTO_MOD_CODIGO, PRODUCTO_MOD_DESCRIPCION
FROM gd_esquema.Maestra
WHERE PRODUCTO_MOD_CODIGO IS NOT NULL

-- Crear productos
INSERT INTO LA_NARANJA_MECANICA_V2.producto (codigo_producto, descripcion, codigo_modelo, id_marca, id_subrubro, precio)
SELECT DISTINCT PRODUCTO_CODIGO, PRODUCTO_DESCRIPCION, PRODUCTO_MOD_CODIGO, m.id, sr.id, PRODUCTO_PRECIO
FROM gd_esquema.Maestra
JOIN LA_NARANJA_MECANICA_V2.marca m ON m.nombre = PRODUCTO_MARCA
JOIN LA_NARANJA_MECANICA_V2.rubro r ON r.descripcion LIKE PRODUCTO_RUBRO_DESCRIPCION
JOIN LA_NARANJA_MECANICA_V2.subrubro sr ON sr.nombre = PRODUCTO_SUB_RUBRO
WHERE PRODUCTO_CODIGO IS NOT NULL

-- Crear Publicaciones
INSERT INTO LA_NARANJA_MECANICA_V2.publicacion (
    codigo_publicacion, descripcion, stock, fecha_inicio, fecha_fin, precio, costo, 
    porcentaje_por_venta, id_usuario, id_producto, id_almacen
)
SELECT DISTINCT 
    PUBLICACION_CODIGO, 
    PUBLICACION_DESCRIPCION, 
    PUBLICACION_STOCK, 
    PUBLICACION_FECHA, 
    PUBLICACION_FECHA_V, 
    PUBLICACION_PRECIO, 
    PUBLICACION_COSTO, 
    PUBLICACION_PORC_VENTA, 
    LA_NARANJA_MECANICA_V2.devolver_id_usuario_vendedor(VEN_USUARIO_NOMBRE, VEN_USUARIO_PASS, VEN_USUARIO_FECHA_CREACION),
    LA_NARANJA_MECANICA_V2.get_id_producto(
        PRODUCTO_CODIGO, PRODUCTO_DESCRIPCION, PRODUCTO_MARCA, 
        PRODUCTO_MOD_CODIGO, PRODUCTO_SUB_RUBRO, PRODUCTO_RUBRO_DESCRIPCION
    ), 
    ALMACEN_CODIGO
FROM gd_esquema.Maestra
WHERE PUBLICACION_CODIGO IS NOT NULL and VENDEDOR_RAZON_SOCIAL is not null;

--Crear DETALLE VENTAS
INSERT INTO LA_NARANJA_MECANICA_V2.detalle_venta(
	id_publicacion,
	cantidad,
	precio,
	subtotal
)
SELECT DISTINCT
	LA_NARANJA_MECANICA_V2.get_id_publicacion(PUBLICACION_CODIGO),
	VENTA_DET_CANT,
	VENTA_DET_PRECIO,
	VENTA_DET_SUB_TOTAL
FROM gd_esquema.Maestra
WHERE PUBLICACION_CODIGO is not NULL and VENTA_DET_PRECIO is not NULL

--CREAR VENTAS
INSERT INTO LA_NARANJA_MECANICA_V2.venta(
     nro_venta,
    id_usuario,
    id_detalle_venta,
    fecha,
    total
    )
SELECT DISTINCT 
    VENTA_CODIGO, 
    LA_NARANJA_MECANICA_V2.devolver_id_usuario_cliente(CLI_USUARIO_NOMBRE, CLI_USUARIO_PASS, CLI_USUARIO_FECHA_CREACION), 
    LA_NARANJA_MECANICA_V2.get_id_detalle_venta(VENTA_DET_CANT, VENTA_DET_PRECIO, VENTA_DET_SUB_TOTAL), 
    VENTA_FECHA, 
    VENTA_TOTAL
    FROM gd_esquema.Maestra
WHERE VENTA_CODIGO is not null

--Crear tipos medio de pago
INSERT INTO LA_NARANJA_MECANICA_V2.tipo_medio_pago (nombre)
SELECT DISTINCT PAGO_TIPO_MEDIO_PAGO
FROM gd_esquema.Maestra
WHERE PAGO_MEDIO_PAGO IS NOT NULL

--Crear medio de pago
INSERT INTO LA_NARANJA_MECANICA_V2.medio_pago (nro_tarjeta, fecha_vencimiento, id_tipo_medio_pago, nombre_medio_pago)
SELECT DISTINCT PAGO_NRO_TARJETA, PAGO_FECHA_VENC_TARJETA, LA_NARANJA_MECANICA_V2.get_id_tipo_medio_pago(PAGO_TIPO_MEDIO_PAGO), PAGO_MEDIO_PAGO
FROM gd_esquema.Maestra
WHERE PAGO_MEDIO_PAGO IS NOT NULL

--Crear pago
INSERT INTO LA_NARANJA_MECANICA_V2.pago(nro_venta, id_medio_pago, importe, fecha, cuotas)
SELECT DISTINCT
	LA_NARANJA_MECANICA_V2.get_id_venta(VENTA_CODIGO),
	LA_NARANJA_MECANICA_V2.get_id_medio_pago(PAGO_NRO_TARJETA,PAGO_FECHA_VENC_TARJETA,PAGO_MEDIO_PAGO),
	PAGO_IMPORTE,
	PAGO_FECHA,
	PAGO_CANT_CUOTAS
FROM gd_esquema.Maestra
WHERE PAGO_IMPORTE IS NOT NULL

--Crear factura
INSERT INTO LA_NARANJA_MECANICA_V2.factura(nro_factura, fecha, id_usuario, total)
SELECT DISTINCT
	FACTURA_NUMERO,
	FACTURA_FECHA,
	LA_NARANJA_MECANICA_V2.devolver_id_usuario_vendedor_por_publicacion(PUBLICACION_CODIGO),
	FACTURA_TOTAL
FROM gd_esquema.Maestra
WHERE FACTURA_NUMERO is not null

--Crear Conceptos
INSERT INTO LA_NARANJA_MECANICA_V2.concepto(nombre)
SELECT DISTINCT FACTURA_DET_TIPO
FROM gd_esquema.Maestra
WHERE FACTURA_DET_TIPO is not null

--Crear detalle factura
INSERT INTO LA_NARANJA_MECANICA_V2.detalle_factura(nro_factura,codigo_publicacion, id_concepto, cantidad, precio_unitario, detalle_subtotal)
SELECT DISTINCT
	LA_NARANJA_MECANICA_V2.get_id_factura(FACTURA_NUMERO), --HAY QUE HACER LA FUNCION
	LA_NARANJA_MECANICA_V2.get_id_publicacion(PUBLICACION_CODIGO),
	LA_NARANJA_MECANICA_V2.get_id_concepto(FACTURA_DET_TIPO), --HAY QUE HACER LA FUNCION
	FACTURA_DET_CANTIDAD,
	FACTURA_DET_PRECIO, 
	FACTURA_DET_SUBTOTAL
FROM gd_esquema.Maestra
WHERE FACTURA_DET_TIPO is not null

-- Crear tipo de envio
INSERT INTO LA_NARANJA_MECANICA_V2.tipo_envio (nombre)
SELECT DISTINCT ENVIO_TIPO FROM gd_esquema.Maestra
WHERE ENVIO_TIPO IS NOT NULL

-- Crear envio
INSERT INTO LA_NARANJA_MECANICA_V2.envio (nro_venta, id_tipo_envio, id_domicilio, fecha, hora_inicio, hora_fin, costo, fecha_entrega)
SELECT DISTINCT VENTA_CODIGO, 
				LA_NARANJA_MECANICA_V2.get_id_tipo_envio(ENVIO_TIPO),
				LA_NARANJA_MECANICA_V2.get_id_domicilio_cliente(CLI_USUARIO_DOMICILIO_CALLE, CLI_USUARIO_DOMICILIO_NRO_CALLE, CLI_USUARIO_DOMICILIO_PISO, CLI_USUARIO_DOMICILIO_DEPTO, CLI_USUARIO_DOMICILIO_LOCALIDAD, CLI_USUARIO_DOMICILIO_PROVINCIA) 
				,ENVIO_FECHA_PROGAMADA, 
				ENVIO_HORA_INICIO, 
				ENVIO_HORA_FIN_INICIO, 
				ENVIO_COSTO, 
				ENVIO_FECHA_ENTREGA
FROM gd_esquema.Maestra
WHERE VENTA_CODIGO IS NOT NULL
