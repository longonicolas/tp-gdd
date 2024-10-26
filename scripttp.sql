 /*--para eliminar todas las tabglas y vovler a empezar
-- PASO 1: Eliminar todas las Foreign Keys del esquema LA_NARANJA_MECANICA_V2
DECLARE @sql NVARCHAR(MAX) = N'';

-- Elimina todas las claves for�neas en el esquema
SELECT @sql += N'ALTER TABLE [' + OBJECT_SCHEMA_NAME(parent_object_id) + '].[' + OBJECT_NAME(parent_object_id) + '] DROP CONSTRAINT [' + name + '];' + CHAR(13)
FROM sys.foreign_keys
WHERE schema_id = SCHEMA_ID('LA_NARANJA_MECANICA_V2');

-- Ejecuta el SQL generado
EXEC sp_executesql @sql;

-- PASO 2: Eliminar todas las tablas del esquema LA_NARANJA_MECANICA_V2
SET @sql = N'';

-- Genera los comandos DROP TABLE para todas las tablas en el esquema
SELECT @sql += N'DROP TABLE [' + TABLE_SCHEMA + '].[' + TABLE_NAME + '];' + CHAR(13)
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'LA_NARANJA_MECANICA_V2';

-- Ejecuta los comandos generados para eliminar las tablas
EXEC sp_executesql @sql;

-- PASO 3: Eliminar el esquema LA_NARANJA_MECANICA_V2 (opcional)
-- Si deseas eliminar el esquema completo, usa esta l�nea.
DROP SCHEMA LA_NARANJA_MECANICA_V2;

*/


---------------------CREAMOS ESQUEMA-------------------------

CREATE SCHEMA LA_NARANJA_MECANICA_V2;
GO

-- Tabla: cliente
CREATE TABLE LA_NARANJA_MECANICA_V2.cliente(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(255),
	apellido VARCHAR(255),
	fecha_nacimiento DATE,
	mail VARCHAR(150),
	dni VARCHAR(50)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.vendedor(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	razon_social VARCHAR(255),
	cuit VARCHAR(12),
	mail VARCHAR(150),
)


CREATE TABLE LA_NARANJA_MECANICA_V2.usuario(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	usuario VARCHAR(255),
	password VARCHAR(255),
	fecha_creacion DATE,
	id_vendedor INTEGER,
	id_cliente INTEGER,
	FOREIGN KEY (id_vendedor) REFERENCES LA_NARANJA_MECANICA_V2.vendedor(id),
	FOREIGN KEY (id_cliente) REFERENCES LA_NARANJA_MECANICA_V2.cliente(id)
)


-- Tabla: provincia
CREATE TABLE LA_NARANJA_MECANICA_V2.provincia(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(255)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.localidad(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	id_provincia INTEGER,
	nombre VARCHAR(255),
	FOREIGN KEY (id_provincia) REFERENCES LA_NARANJA_MECANICA_V2.provincia(id)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.domicilio(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	id_localidad INTEGER,
	id_usuario INTEGER,
	calle VARCHAR(255),
	nro_calle SMALLINT,
	piso SMALLINT,
	depto VARCHAR(3),
	codigo_postal VARCHAR(4),
	FOREIGN KEY (id_localidad) REFERENCES LA_NARANJA_MECANICA_V2.localidad(id),
	FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.almacen(
	codigo_almacen INTEGER PRIMARY KEY,
	costo_al_dia DECIMAL(10,2),
	id_domicilio INTEGER
	FOREIGN KEY (id_domicilio) REFERENCES LA_NARANJA_MECANICA_V2.domicilio(id)
)
-- Tabla: publicacion
CREATE TABLE LA_NARANJA_MECANICA_V2.publicacion (
    codigo_publicacion BIGINT PRIMARY KEY,
    descripcion TEXT,
    fecha_inicio DATE,
    fecha_fin DATE,
    id_producto BIGINT,
    stock SMALLINT,
    precio DECIMAL(18, 2),
    id_usuario INTEGER,
    id_almacen INTEGER,
    costo DECIMAL(18, 2),
    porcentaje_por_venta DECIMAL(18, 2),
    FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id),
    FOREIGN KEY (id_almacen) REFERENCES LA_NARANJA_MECANICA_V2.almacen(codigo_almacen)
);

-- Tabla: detalle_venta
CREATE TABLE LA_NARANJA_MECANICA_V2.detalle_venta (
    id_detalle_venta BIGINT PRIMARY KEY,
    id_publicacion BIGINT,
    cantidad SMALLINT,-- en la tabla maestra esta como DECIMAL(18, 0) y tambien esta el precio que no lo pusimos aca
    subtotal DECIMAL(18, 2),
    FOREIGN KEY (id_publicacion) REFERENCES LA_NARANJA_MECANICA_V2.publicacion(codigo_publicacion)
);

-- Tabla: venta
CREATE TABLE LA_NARANJA_MECANICA_V2.venta (
    nro_venta BIGINT PRIMARY KEY,
    id_usuario INTEGER,
    id_detalle_venta BIGINT,
    fecha DATE,
    total DECIMAL(18, 2),
    FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id),
    FOREIGN KEY (id_detalle_venta) REFERENCES LA_NARANJA_MECANICA_V2.detalle_venta(id_detalle_venta)
);

-- Tabla: tipo_envio
CREATE TABLE LA_NARANJA_MECANICA_V2.tipo_envio (
    id_tipo_envio BIGINT PRIMARY KEY,
    nombre NVARCHAR(50)
);

-- Tabla: envio
CREATE TABLE LA_NARANJA_MECANICA_V2.envio (
    nro_envio BIGINT PRIMARY KEY,
    nro_venta BIGINT,
    id_domicilio INTEGER,
    fecha DATE,
    hora_inicio NVARCHAR(5),--DECIMAL(18, 0) en tabla maestra
    hora_fin NVARCHAR(5),--DECIMAL(18, 0) en tabla maestra
    costo DECIMAL(18, 2),
    fecha_entrega DATETIME,
    id_tipo_envio BIGINT,
    FOREIGN KEY (nro_venta) REFERENCES LA_NARANJA_MECANICA_V2.venta(nro_venta),
    FOREIGN KEY (id_domicilio) REFERENCES LA_NARANJA_MECANICA_V2.domicilio(id),
    FOREIGN KEY (id_tipo_envio) REFERENCES LA_NARANJA_MECANICA_V2.tipo_envio(id_tipo_envio)
);

-- Tabla: concepto
CREATE TABLE LA_NARANJA_MECANICA_V2.concepto (
    id_concepto BIGINT PRIMARY KEY,
    nombre NVARCHAR(50)
);

-- Tabla: detalle_factura
CREATE TABLE LA_NARANJA_MECANICA_V2.detalle_factura (
    id_detalle_factura BIGINT PRIMARY KEY,
    codigo_publicacion BIGINT,
    id_concepto BIGINT,--tabla maestra esta detalle_sub_total que no lo pusimos nosotros
    cantidad SMALLINT,--DECIMAL(18, 2) en tabla maestra
    precio_unitario DECIMAL(18, 2),
    FOREIGN KEY (codigo_publicacion) REFERENCES LA_NARANJA_MECANICA_V2.publicacion(codigo_publicacion),
    FOREIGN KEY (id_concepto) REFERENCES LA_NARANJA_MECANICA_V2.concepto(id_concepto)
);

-- Tabla: factura
CREATE TABLE LA_NARANJA_MECANICA_V2.factura (
    nro_factura BIGINT PRIMARY KEY,
    fecha DATE,
    id_usuario INTEGER,
    id_detalle_factura BIGINT,
    total DECIMAL(18, 2),
    FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id),
    FOREIGN KEY (id_detalle_factura) REFERENCES LA_NARANJA_MECANICA_V2.detalle_factura(id_detalle_factura)
);

-- Tabla: tipo_medio_pago
CREATE TABLE LA_NARANJA_MECANICA_V2.tipo_medio_pago (
    id_tipo_medio_pago BIGINT PRIMARY KEY,
    nombre NVARCHAR(50)
);

-- Tabla: medio_pago
CREATE TABLE LA_NARANJA_MECANICA_V2.medio_pago (
    id_medio_pago BIGINT PRIMARY KEY,
    nro_tarjeta NVARCHAR(50),
    fecha_vencimiento DATE,
    id_tipo_medio_pago BIGINT,
    FOREIGN KEY (id_tipo_medio_pago) REFERENCES LA_NARANJA_MECANICA_V2.tipo_medio_pago(id_tipo_medio_pago)
);

--en la tabla maestra existe PAGO_MEDIO_PAGO que no lo usamos en ningun lado

-- Tabla: pago
CREATE TABLE LA_NARANJA_MECANICA_V2.pago (
    nro_pago BIGINT PRIMARY KEY,
    nro_venta BIGINT,
    id_medio_pago BIGINT,
    importe DECIMAL(18, 2),
    fecha DATE,
    cuotas SMALLINT,--DECIMAL(18, 0) en tabla maestra
    FOREIGN KEY (nro_venta) REFERENCES LA_NARANJA_MECANICA_V2.venta(nro_venta),
    FOREIGN KEY (id_medio_pago) REFERENCES LA_NARANJA_MECANICA_V2.medio_pago(id_medio_pago)
);

CREATE TABLE LA_NARANJA_MECANICA_V2.marca(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(255)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.rubro(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	descripcion TEXT
)

CREATE TABLE LA_NARANJA_MECANICA_V2.subrubro(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	id_rubro INTEGER,
	nombre VARCHAR(255),
	FOREIGN KEY (id_rubro) REFERENCES LA_NARANJA_MECANICA_V2.rubro(id)
)

-- Tabla: modelo_producto
CREATE TABLE LA_NARANJA_MECANICA_V2.modeloProducto (
    codigo_modelo INTEGER PRIMARY KEY,
    descripcion TEXT
);

-- Tabla: producto. Tabla maestra tiene producto_precio y aca no lo tenemos
CREATE TABLE LA_NARANJA_MECANICA_V2.producto(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	codigo_producto VARCHAR(255),
	descripcion TEXT,
	codigo_modelo INTEGER,
	id_marca INTEGER,
	id_subrubro INTEGER,
	FOREIGN KEY (codigo_modelo) REFERENCES LA_NARANJA_MECANICA_V2.modeloProducto(codigo_modelo),
	FOREIGN KEY (id_marca) REFERENCES LA_NARANJA_MECANICA_V2.marca(id),
	FOREIGN KEY (id_subrubro) REFERENCES LA_NARANJA_MECANICA_V2.subrubro(id)
)
GO
CREATE FUNCTION LA_NARANJA_MECANICA_V2.get_id_rubro(@descripcion TEXT)
RETURNS INTEGER
AS
BEGIN
	DECLARE @id INTEGER

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.rubro
	WHERE descripcion LIKE @descripcion

	RETURN @id
END
GO


-- OBTENER ID DE UN SUBRUBRO
GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_subrubro(@subrubro VARCHAR(255), @rubro VARCHAR(255))
RETURNS INTEGER
AS
BEGIN
	DECLARE @id INTEGER

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.subrubro
	WHERE nombre = @subrubro AND id_rubro = LA_NARANJA_MECANICA_V2.get_id_rubro(@rubro)
	RETURN @id
END
GO
-- OBTENER ID DE UNA MARCA
	
GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_marca(@marca VARCHAR(255))
RETURNS INTEGER
AS
BEGIN
	DECLARE @id INTEGER

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.marca
	WHERE nombre = @marca

	RETURN @id
END
GO
	-- OBTENER UN ID DE UN PRODUCTO
GO
CREATE FUNCTION LA_NARANJA_MECANICA_V2.get_id_producto(@codigo VARCHAR(255), @descripcion VARCHAR(255), @marca VARCHAR(255), @modelo INTEGER,@subrubro VARCHAR(255), @rubro VARCHAR(255))
RETURNS INTEGER
AS
BEGIN
	DECLARE @id INTEGER
	
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
CREATE FUNCTION LA_NARANJA_MECANICA_V2.devolver_id_cliente(@nombre VARCHAR(255), @apellido VARCHAR(255), @dni VARCHAR(50))
RETURNS INTEGER
AS 
BEGIN
    DECLARE @id INTEGER;

    SET @id = -1;

    SELECT @id = id 
    FROM LA_NARANJA_MECANICA_V2.cliente 
    WHERE nombre = @nombre 
      AND apellido = @apellido 
      AND dni = @dni;

    RETURN @id;
END;
GO
GO
CREATE FUNCTION LA_NARANJA_MECANICA_V2.devolver_id_vendedor(@cuit VARCHAR(12), @razonSocial VARCHAR(255))
RETURNS INTEGER
AS
BEGIN
	DECLARE @id INTEGER

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.vendedor
	WHERE cuit = @cuit AND razon_social = @razonSocial

	RETURN @id
END
GO
GO
CREATE FUNCTION LA_NARANJA_MECANICA_V2.devolver_id_usuario_cliente(@username VARCHAR(255), @password VARCHAR(255), @fecha_creacion DATE)
RETURNS INTEGER
AS
BEGIN
	DECLARE @id INTEGER

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.usuario
	WHERE usuario = @username AND password = @password AND fecha_creacion = @fecha_creacion

	RETURN @id
END
GO
GO
CREATE FUNCTION  LA_NARANJA_MECANICA_V2.devolver_id_localidad(@nombre VARCHAR(255), @provincia VARCHAR(255))
RETURNS INTEGER
AS
BEGIN
	DECLARE @id INTEGER

	SELECT @id = l.id
	FROM LA_NARANJA_MECANICA_V2.localidad l
	JOIN LA_NARANJA_MECANICA_V2.provincia p ON l.id_provincia = p.id
	WHERE l.nombre = @nombre AND p.nombre = @provincia

	RETURN @id
END
GO
GO
CREATE FUNCTION LA_NARANJA_MECANICA_V2.get_id_domicilio(@calle VARCHAR(255), @altura SMALLINT, @localidad VARCHAR(255), @provincia VARCHAR(255))
RETURNS INTEGER
AS
BEGIN
	DECLARE @id INTEGER

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.domicilio
	WHERE calle = @calle AND nro_calle = @altura AND id_localidad = LA_NARANJA_MECANICA_V2.devolver_id_localidad(@localidad, @provincia)

	RETURN @id
END
GO
GO
CREATE FUNCTION LA_NARANJA_MECANICA_V2.devolver_id_usuario_vendedor(@username VARCHAR(255), @password VARCHAR(255), @fecha_creacion DATE)
RETURNS INTEGER
AS
BEGIN
	DECLARE @id INTEGER

	SELECT @id = id
	FROM LA_NARANJA_MECANICA_V2.usuario
	WHERE usuario = @username AND password = @password AND fecha_creacion = @fecha_creacion

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
INSERT INTO LA_NARANJA_MECANICA_V2.producto (codigo_producto, descripcion, codigo_modelo, id_marca, id_subrubro)
SELECT DISTINCT PRODUCTO_CODIGO, PRODUCTO_DESCRIPCION, PRODUCTO_MOD_CODIGO, m.id, sr.id
FROM gd_esquema.Maestra
JOIN LA_NARANJA_MECANICA_V2.marca m ON m.nombre = PRODUCTO_MARCA
JOIN LA_NARANJA_MECANICA_V2.rubro r ON r.descripcion LIKE PRODUCTO_RUBRO_DESCRIPCION
JOIN LA_NARANJA_MECANICA_V2.subrubro sr ON sr.nombre = PRODUCTO_SUB_RUBRO
WHERE PRODUCTO_CODIGO IS NOT NULL

-- Crear Publicaciones
INSERT INTO LA_NARANJA_MECANICA_V2.publicacion (codigo_publicacion, descripcion, stock, fecha_inicio, fecha_vencimiento, precio, costo, porcentaje_por_venta, id_usuario, id_producto, codigo_almacen)
SELECT DISTINCT PUBLICACION_CODIGO, PUBLICACION_DESCRIPCION, PUBLICACION_STOCK, PUBLICACION_FECHA, PUBLICACION_FECHA_V, PUBLICACION_PRECIO, 
				PUBLICACION_COSTO, PUBLICACION_PORC_VENTA, LA_NARANJA_MECANICA_V2.devolver_id_usuario_vendedor(VEN_USUARIO_NOMBRE, VEN_USUARIO_PASS, VEN_USUARIO_FECHA_CREACION), 
				LA_NARANJA_MECANICA_V2.get_id_producto(PRODUCTO_CODIGO, PRODUCTO_DESCRIPCION, PRODUCTO_MARCA, PRODUCTO_MOD_CODIGO, PRODUCTO_SUB_RUBRO, PRODUCTO_RUBRO_DESCRIPCION), ALMACEN_CODIGO
FROM gd_esquema.Maestra
WHERE VEN_USUARIO_NOMBRE IS NOT NULL AND PUBLICACION_CODIGO IS NOT NULL
