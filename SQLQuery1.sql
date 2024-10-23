 /*--para eliminar todas las tabglas y vovler a empezar
-- PASO 1: Eliminar todas las Foreign Keys del esquema LA_NARANJA_MECANICA_V2
DECLARE @sql NVARCHAR(MAX) = N'';

-- Elimina todas las claves foráneas en el esquema
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
-- Si deseas eliminar el esquema completo, usa esta línea.
DROP SCHEMA LA_NARANJA_MECANICA_V2;

*/


---------------------CREAMOS ESQUEMA-------------------------

CREATE SCHEMA LA_NARANJA_MECANICA_V2;
GO

-- Tabla: cliente
CREATE TABLE LA_NARANJA_MECANICA_V2.cliente (
    id_cliente BIGINT IDENTITY PRIMARY KEY,
    nombre NVARCHAR(50),
    apellido NVARCHAR(50),
    fecha_nacimiento DATE,
	mail NVARCHAR(50),
	dni DECIMAL(18,0)
);

-- Tabla: vendedor
CREATE TABLE LA_NARANJA_MECANICA_V2.vendedor (
    id_vendedor BIGINT IDENTITY PRIMARY KEY,
    razon_social nvarchar(50),
    cuit VARCHAR(12),
    mail NVARCHAR(50)
);

-- Tabla: usuario
CREATE TABLE LA_NARANJA_MECANICA_V2.usuario (
    id_usuario BIGINT IDENTITY PRIMARY KEY,
    usuario NVARCHAR(50),
    password NVARCHAR(50),
    fecha_creacion DATE,
    id_vendedor BIGINT,
    id_cliente BIGINT,
    FOREIGN KEY (id_vendedor) REFERENCES LA_NARANJA_MECANICA_V2.vendedor(id_vendedor),
    FOREIGN KEY (id_cliente) REFERENCES LA_NARANJA_MECANICA_V2.cliente(id_cliente)
);

-- Tabla: provincia
CREATE TABLE LA_NARANJA_MECANICA_V2.provincia (
    id_provincia BIGINT PRIMARY KEY,
    nombre NVARCHAR(50)
);

-- Tabla: localidad
CREATE TABLE LA_NARANJA_MECANICA_V2.localidad (
    id_localidad BIGINT PRIMARY KEY,
    id_provincia BIGINT,
    nombre NVARCHAR(50),
    FOREIGN KEY (id_provincia) REFERENCES LA_NARANJA_MECANICA_V2.provincia(id_provincia)
);

-- Tabla: almacen
CREATE TABLE LA_NARANJA_MECANICA_V2.almacen (
    codigo_almacen BIGINT PRIMARY KEY,
    costo_al_dia FLOAT
);

-- Tabla: domicilio
CREATE TABLE LA_NARANJA_MECANICA_V2.domicilio (
    id_domicilio BIGINT PRIMARY KEY,
    id_usuario BIGINT,
    codigo_almacen BIGINT,
    id_localidad BIGINT,
    calle NVARCHAR(50),
    nro_calle SMALLINT,
    piso NVARCHAR(3),
    depto NVARCHAR(2),
    codigo_postal NVARCHAR(4),
    FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id_usuario),
    FOREIGN KEY (codigo_almacen) REFERENCES LA_NARANJA_MECANICA_V2.almacen(codigo_almacen),
    FOREIGN KEY (id_localidad) REFERENCES LA_NARANJA_MECANICA_V2.localidad(id_localidad)
);

-- Tabla: publicacion
CREATE TABLE LA_NARANJA_MECANICA_V2.publicacion (
    codigo_publicacion BIGINT PRIMARY KEY,
    descripcion TEXT,
    fecha_inicio DATE,
    fecha_fin DATE,
    id_producto BIGINT,
    stock SMALLINT,
    precio DECIMAL(18, 2),
    id_usuario BIGINT,
    id_almacen BIGINT,
    costo DECIMAL(18, 2),
    porcentaje_por_venta DECIMAL(18, 2),
    FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id_usuario),
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
    id_usuario BIGINT,
    id_detalle_venta BIGINT,
    fecha DATE,
    total DECIMAL(18, 2),
    FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id_usuario),
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
    id_domicilio BIGINT,
    fecha DATE,
    hora_inicio NVARCHAR(5),--DECIMAL(18, 0) en tabla maestra
    hora_fin NVARCHAR(5),--DECIMAL(18, 0) en tabla maestra
    costo DECIMAL(18, 2),
    fecha_entrega DATETIME,
    id_tipo_envio BIGINT,
    FOREIGN KEY (nro_venta) REFERENCES LA_NARANJA_MECANICA_V2.venta(nro_venta),
    FOREIGN KEY (id_domicilio) REFERENCES LA_NARANJA_MECANICA_V2.domicilio(id_domicilio),
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
    id_usuario BIGINT,
    id_detalle_factura BIGINT,
    total DECIMAL(18, 2),
    FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.usuario(id_usuario),
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

-- Tabla: rubro
CREATE TABLE LA_NARANJA_MECANICA_V2.rubro (
    id_rubro BIGINT PRIMARY KEY,
    descripcion NVARCHAR(50)
);

-- Tabla: subrubro
CREATE TABLE LA_NARANJA_MECANICA_V2.subrubro (
    id_subrubro BIGINT PRIMARY KEY,
    id_rubro BIGINT,
    nombre NVARCHAR(50),
    FOREIGN KEY (id_rubro) REFERENCES LA_NARANJA_MECANICA_V2.rubro(id_rubro)
);

-- Tabla: marca
CREATE TABLE LA_NARANJA_MECANICA_V2.marca (
    id_marca BIGINT PRIMARY KEY,
    nombre NVARCHAR(50)
);

-- Tabla: modelo_producto
CREATE TABLE LA_NARANJA_MECANICA_V2.modelo_producto (
    codigo_modelo BIGINT PRIMARY KEY,
    descripcion NVARCHAR(50)
);

-- Tabla: producto. Tabla maestra tiene producto_precio y aca no lo tenemos
CREATE TABLE LA_NARANJA_MECANICA_V2.producto (
    codigo_producto BIGINT PRIMARY KEY,
    descripcion NVARCHAR(50),
    codigo_modelo BIGINT,
    id_marca BIGINT,
	id_subrubro BIGINT,
    FOREIGN KEY (codigo_modelo) REFERENCES LA_NARANJA_MECANICA_V2.modelo_producto(codigo_modelo),
    FOREIGN KEY (id_marca) REFERENCES LA_NARANJA_MECANICA_V2.marca(id_marca),
	FOREIGN KEY (id_subrubro) REFERENCES LA_NARANJA_MECANICA_V2.subrubro(id_subrubro)
);

---------------------MIGRACION-------------------------

-- Migrar cliente
INSERT INTO LA_NARANJA_MECANICA_V2.cliente (nombre, apellido, fecha_nacimiento, mail, dni)
SELECT CLIENTE_NOMBRE, CLIENTE_APELLIDO, CLIENTE_FECHA_NAC, CLIENTE_MAIL, CLIENTE_DNI
FROM gd_esquema.Maestra
WHERE CLIENTE_NOMBRE IS NOT NULL; -- Aseguramos que sean registros de clientes

-- Migrar vendedor
INSERT INTO LA_NARANJA_MECANICA_V2.vendedor (razon_social, cuit, mail)
SELECT VENDEDOR_RAZON_SOCIAL, VENDEDOR_CUIT, VENDEDOR_MAIL
FROM gd_esquema.Maestra
WHERE VENDEDOR_RAZON_SOCIAL IS NOT NULL; -- Aseguramos que sean registros de vendedores

-- Migrar usuario (para clientes)
INSERT INTO LA_NARANJA_MECANICA_V2.usuario (usuario, password, fecha_creacion, id_cliente)
SELECT CLI_USUARIO_NOMBRE, CLI_USUARIO_PASS, CLI_USUARIO_FECHA_CREACION, C.id_cliente
FROM gd_esquema.Maestra M
JOIN LA_NARANJA_MECANICA_V2.cliente C ON M.CLIENTE_DNI = C.dni
WHERE CLI_USUARIO_NOMBRE IS NOT NULL;


-- Migrar usuario (para vendedores)
INSERT INTO LA_NARANJA_MECANICA_V2.usuario (usuario, password, fecha_creacion, id_vendedor)
SELECT VEN_USUARIO_NOMBRE, VEN_USUARIO_PASS, VEN_USUARIO_FECHA_CREACION, V.id_vendedor
FROM gd_esquema.Maestra M
JOIN LA_NARANJA_MECANICA_V2.vendedor V ON M.VENDEDOR_CUIT = V.cuit
WHERE VEN_USUARIO_NOMBRE IS NOT NULL;

-- Migrar provincias (clientes, vendedores y almacenes)
INSERT INTO LA_NARANJA_MECANICA_V2.provincia (nombre)
SELECT DISTINCT VEN_USUARIO_DOMICILIO_PROVINCIA 
FROM gd_esquema.Maestra
WHERE VEN_USUARIO_DOMICILIO_PROVINCIA IS NOT NULL
UNION
SELECT DISTINCT CLI_USUARIO_DOMICILIO_PROVINCIA 
FROM gd_esquema.Maestra
WHERE CLI_USUARIO_DOMICILIO_PROVINCIA IS NOT NULL
UNION
SELECT DISTINCT ALMACEN_PROVINCIA
FROM gd_esquema.Maestra
WHERE ALMACEN_PROVINCIA IS NOT NULL;

-- Migrar localidades (clientes, vendedores y almacenes)
INSERT INTO LA_NARANJA_MECANICA_V2.localidad (id_provincia, nombre)
SELECT DISTINCT P.id_provincia, M.VEN_USUARIO_DOMICILIO_LOCALIDAD
FROM gd_esquema.Maestra M
JOIN LA_NARANJA_MECANICA_V2.provincia P ON M.VEN_USUARIO_DOMICILIO_PROVINCIA = P.nombre
WHERE M.VEN_USUARIO_DOMICILIO_LOCALIDAD IS NOT NULL
UNION
SELECT DISTINCT P.id_provincia, M.CLI_USUARIO_DOMICILIO_LOCALIDAD
FROM gd_esquema.Maestra M
JOIN LA_NARANJA_MECANICA_V2.provincia P ON M.CLI_USUARIO_DOMICILIO_PROVINCIA = P.nombre
WHERE M.CLI_USUARIO_DOMICILIO_LOCALIDAD IS NOT NULL
UNION
SELECT DISTINCT P.id_provincia, M.ALMACEN_Localidad
FROM gd_esquema.Maestra M
JOIN LA_NARANJA_MECANICA_V2.provincia P ON M.ALMACEN_PROVINCIA = P.nombre
WHERE M.ALMACEN_Localidad IS NOT NULL;

-- Migrar datos de almacenes
INSERT INTO LA_NARANJA_MECANICA_V2.almacen (codigo_almacen, costo_al_dia)
SELECT ALMACEN_CODIGO, ALMACEN_COSTO_DIA_AL 
FROM gd_esquema.Maestra
WHERE ALMACEN_CODIGO IS NOT NULL;

-- Migrar datos de domicilios para vendedores
INSERT INTO LA_NARANJA_MECANICA_V2.domicilio (id_usuario, id_localidad, calle, nro_calle, piso, depto, codigo_postal)
SELECT U.id_usuario, L.id_localidad, M.VEN_USUARIO_DOMICILIO_CALLE, M.VEN_USUARIO_DOMICILIO_NRO_CALLE, 
       M.VEN_USUARIO_DOMICILIO_PISO, M.VEN_USUARIO_DOMICILIO_DEPTO, M.VEN_USUARIO_DOMICILIO_CP
FROM gd_esquema.Maestra M
JOIN LA_NARANJA_MECANICA_V2.usuario U ON U.id_vendedor = (
    SELECT V.id_vendedor 
    FROM LA_NARANJA_MECANICA_V2.vendedor V 
    WHERE V.mail = M.VENDEDOR_MAIL -- Usamos el email o algún campo único para obtener el ID del vendedor
)
JOIN LA_NARANJA_MECANICA_V2.localidad L ON M.VEN_USUARIO_DOMICILIO_LOCALIDAD = L.nombre
WHERE M.VEN_USUARIO_DOMICILIO_CALLE IS NOT NULL;


-- Migrar datos de domicilios para clientes
INSERT INTO LA_NARANJA_MECANICA_V2.domicilio (id_usuario, id_localidad, calle, nro_calle, piso, depto, codigo_postal)
SELECT U.id_usuario, L.id_localidad, M.CLI_USUARIO_DOMICILIO_CALLE, M.CLI_USUARIO_DOMICILIO_NRO_CALLE, 
       M.CLI_USUARIO_DOMICILIO_PISO, M.CLI_USUARIO_DOMICILIO_DEPTO, M.CLI_USUARIO_DOMICILIO_CP
FROM gd_esquema.Maestra M
JOIN LA_NARANJA_MECANICA_V2.usuario U ON U.id_cliente = (
    SELECT C.id_cliente 
    FROM LA_NARANJA_MECANICA_V2.cliente C 
    WHERE C.dni = M.CLIENTE_DNI -- Usamos el DNI para obtener el ID del cliente
)
JOIN LA_NARANJA_MECANICA_V2.localidad L ON M.CLI_USUARIO_DOMICILIO_LOCALIDAD = L.nombre
WHERE M.CLI_USUARIO_DOMICILIO_CALLE IS NOT NULL;

