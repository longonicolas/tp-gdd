------- DIMENSIONES - MODELO BI ----------

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Tiempo(
	id_tiempo decimal(18,0) IDENTITY PRIMARY KEY,
	anio decimal(18,0),
	cuatrimestre decimal(18,0),
	mes decimal(18,0),
)

	CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Hecho_Venta(
	id INTEGER IDENTITY(1,1) PRIMARY KEY,
	cant_ventas INTEGER,
	localidad VARCHAR(255),
	cuatrimestre INTEGER,
	anio_venta SMALLINT,
	rubro VARCHAR(255),
	rango_etario INTEGER,
	provincia_id DECIMAL(18,0)
	FOREIGN KEY (provincia_id) REFERENCES LA_NARANJA_MECANICA_V2.provincia(id),
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Ubicacion(
	id_ubicacion decimal(18,0) PRIMARY KEY, --Es el ID localidad no se si esta bien
	provincia decimal(18,0),
	nombre NVARCHAR(50)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_RangoEtario(
    id_rango_etario decimal(18,0) PRIMARY KEY,
    descripcion NVARCHAR(20), 
    edad_minima decimal(18,0),         
    edad_maxima decimal(18,0)            
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_RangoHorario(
	id_rango_horario decimal(18,0) PRIMARY KEY,
    descripcion NVARCHAR(20), 
	hora_minima TIME,         
    hora_maxima TIME  
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_TipoMedioDePago( -- No se si hay que vincularla con tipo medio de pago o con medio de pago
	id_tipo_medio_pago decimal(18,0), 
    nombre NVARCHAR(50)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_TipoEnvio(
	id_tipo_envio decimal(18,0) PRIMARY KEY,
	nombre NVARCHAR(50)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Rubro (
    id_rubro DECIMAL(18,0) PRIMARY KEY,
    descripcion NVARCHAR(50)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Subrubro (
    id_subrubro DECIMAL(18,0) PRIMARY KEY,
    id_rubro DECIMAL(18,0),
    descripcion NVARCHAR(50),
    FOREIGN KEY (id_rubro) REFERENCES LA_NARANJA_MECANICA_V2.BI_Rubro (id_rubro)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Marca (
    id_marca DECIMAL(18,0) PRIMARY KEY,
    nombre NVARCHAR(50)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Producto( --Debería ser una dimensión???
	id_producto DECIMAL(18,0) PRIMARY KEY,
    descripcion NVARCHAR(50),
    id_subrubro DECIMAL(18,0),
    id_marca DECIMAL(18,0),
    FOREIGN KEY (id_subrubro) REFERENCES LA_NARANJA_MECANICA_V2.BI_Subrubro(id_subrubro),
    FOREIGN KEY (id_marca) REFERENCES LA_NARANJA_MECANICA_V2.BI_Marca(id_marca)
)


GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_rango_etario(@fecha DATE)
RETURNS decimal(18,0)
AS
BEGIN
    DECLARE @edad DECIMAL(10,0)
	DECLARE @rango DECIMAL(10,0)

    SET @edad = DATEDIFF(YEAR, @fecha, GETDATE()) - 
    CASE 
        WHEN MONTH(@fecha) > MONTH(GETDATE()) OR 
             (MONTH(@fecha) = MONTH(GETDATE()) AND DAY(@fecha) > DAY(GETDATE())) 
        THEN 1 
        ELSE 0 
    END

	SET @rango = CASE
		WHEN @edad BETWEEN 0 AND 24 THEN 1
		WHEN @edad BETWEEN 25 AND 35 THEN 2
		WHEN @edad BETWEEN 36 AND 50 THEN 3
		WHEN @edad > 50 THEN 4
	END

    RETURN @rango
END
GO

GO
CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_cuatrimestre(@fecha DATE)
RETURNS INTEGER
AS
BEGIN
    DECLARE @mes INT
    DECLARE @cuatrimestre INTEGER

    -- Obtener el mes de la fecha
    SET @mes = MONTH(@fecha)

    -- Determinar el cuatrimestre
    SET @cuatrimestre = CASE
        WHEN @mes BETWEEN 1 AND 4 THEN 1
        WHEN @mes BETWEEN 5 AND 8 THEN 2
        WHEN @mes BETWEEN 9 AND 12 THEN 3
        ELSE 0
    END

    RETURN @cuatrimestre
END
GO

	
---- MIGRADO DE DATOS DEL MODELO TRANSACCIONAL -------

-- Evitar duplicados en BI_Tiempo al insertar desde factura
INSERT INTO LA_NARANJA_MECANICA_V2.BI_Tiempo (anio, cuatrimestre, mes, dia, fecha)
SELECT DISTINCT
    YEAR(F.fecha) AS anio,
    CASE 
        WHEN MONTH(F.fecha) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(F.fecha) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END AS cuatrimestre,
    MONTH(F.fecha) AS mes,
    DAY(F.fecha) AS dia,
    F.fecha AS fecha
FROM LA_NARANJA_MECANICA_V2.factura AS F
WHERE NOT EXISTS (
    SELECT 1
    FROM LA_NARANJA_MECANICA_V2.BI_Tiempo T
    WHERE T.fecha = F.fecha
);

-- Evitar duplicados en BI_Tiempo al insertar desde fecha_inicio de publicación
INSERT INTO LA_NARANJA_MECANICA_V2.BI_Tiempo (anio, cuatrimestre, mes, dia, fecha)
SELECT DISTINCT
    YEAR(P.fecha_inicio) AS anio,
    CASE 
        WHEN MONTH(P.fecha_inicio) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(P.fecha_inicio) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END AS cuatrimestre,
    MONTH(P.fecha_inicio) AS mes,
    DAY(P.fecha_inicio) AS dia,
    P.fecha_inicio AS fecha
FROM LA_NARANJA_MECANICA_V2.publicacion AS P
WHERE NOT EXISTS (
    SELECT 1
    FROM LA_NARANJA_MECANICA_V2.BI_Tiempo T
    WHERE T.fecha = P.fecha_inicio
);

-- Evitar duplicados en BI_Tiempo al insertar desde fecha_fin de publicación
INSERT INTO LA_NARANJA_MECANICA_V2.BI_Tiempo (anio, cuatrimestre, mes, dia, fecha)
SELECT DISTINCT
    YEAR(P.fecha_fin) AS anio,
    CASE 
        WHEN MONTH(P.fecha_fin) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(P.fecha_fin) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END AS cuatrimestre,
    MONTH(P.fecha_fin) AS mes,
    DAY(P.fecha_fin) AS dia,
    P.fecha_fin AS fecha
FROM LA_NARANJA_MECANICA_V2.publicacion AS P
WHERE NOT EXISTS (
    SELECT 1
    FROM LA_NARANJA_MECANICA_V2.BI_Tiempo T
    WHERE T.fecha = P.fecha_fin
);


INSERT INTO LA_NARANJA_MECANICA_V2.BI_Ubicacion
SELECT id, id_provincia, nombre
FROM LA_NARANJA_MECANICA_V2.localidad

INSERT INTO LA_NARANJA_MECANICA_V2.BI_RangoEtario(id_rango_etario, descripcion, edad_minima, edad_maxima)
VALUES 
    (1, '-25', 0, 24),
    (2, '25-35', 25, 35),
    (3, '36-50', 36, 50),
    (4, '50+', 51, NULL);

INSERT INTO LA_NARANJA_MECANICA_V2.BI_RangoHorario(id_rango_horario, descripcion, hora_minima, hora_maxima)
VALUES 
    (1, '00:00-06:00', '00:00:00', '05:59:59'),
    (2, '06:00-12:00', '06:00:00', '11:59:59'),
    (3, '12:00-18:00', '12:00:00', '17:59:59'),
    (4, '18:00-24:00', '18:00:00', '23:59:59');


INSERT INTO LA_NARANJA_MECANICA_V2.BI_TipoMedioDePago
SELECT id_tipo_medio_pago, nombre
FROM LA_NARANJA_MECANICA_V2.tipo_medio_pago

INSERT INTO LA_NARANJA_MECANICA_V2.BI_TipoEnvio
SELECT id_tipo_envio, nombre
FROM LA_NARANJA_MECANICA_V2.tipo_envio

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Rubro
SELECT id, descripcion FROM LA_NARANJA_MECANICA_V2.rubro

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Subrubro
SELECT id, id_rubro, nombre FROM LA_NARANJA_MECANICA_V2.subrubro

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Marca
SELECT id, nombre FROM LA_NARANJA_MECANICA_V2.marca

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Producto
SELECT id, descripcion, id_subrubro, id_marca FROM LA_NARANJA_MECANICA_V2.producto

--TABLAS DE HECHOS
CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Publicaciones (
    id_publicacion DECIMAL(18,0) PRIMARY KEY,
    id_producto DECIMAL(18,0),
	stock DECIMAL(18,0),
    id_tiempo_inicio DECIMAL(18,0),
	id_tiempo_fin DECIMAL(18,0)
    FOREIGN KEY (id_producto) REFERENCES LA_NARANJA_MECANICA_V2.BI_Producto(id_producto),
    FOREIGN KEY (id_tiempo_inicio) REFERENCES LA_NARANJA_MECANICA_V2.BI_Tiempo(id_tiempo),
	FOREIGN KEY (id_tiempo_fin) REFERENCES LA_NARANJA_MECANICA_V2.BI_Tiempo(id_tiempo)
)

-- Insertar datos en la tabla de hechos BI_Publicaciones
INSERT INTO LA_NARANJA_MECANICA_V2.BI_Publicaciones
SELECT DISTINCT
    P.codigo_publicacion,
    P.id_producto,
	P.stock,
    T.id_tiempo, -- ID de tiempo asociado a la fecha de inicio
	T2.id_tiempo -- ID de tiempo asociado a la fecha de fin
FROM LA_NARANJA_MECANICA_V2.publicacion AS P
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T ON YEAR(P.fecha_inicio) = T.anio AND MONTH(P.fecha_inicio) = T.mes AND DAY(P.fecha_inicio) = T.dia
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T2 ON YEAR(P.fecha_fin) = T2.anio AND MONTH(P.fecha_fin) = T2.mes AND DAY(P.fecha_fin) = T2.dia
JOIN LA_NARANJA_MECANICA_V2.BI_Producto AS Prod ON P.id_producto = Prod.id_producto

-- Vista para calcular el promedio de tiempo de publicaciones
GO
CREATE or ALTER VIEW LA_NARANJA_MECANICA_V2.vw_PromedioTiempoPublicaciones AS
SELECT
    S.descripcion AS subrubro,
    T.anio,
    T.cuatrimestre,
    AVG(DATEDIFF(DAY, T.fecha, T2.fecha)) AS promedio_tiempo_vigente_dias -- Promedio de los tiempos vigentes en días
FROM
    LA_NARANJA_MECANICA_V2.BI_Publicaciones P
JOIN
    LA_NARANJA_MECANICA_V2.BI_Producto Prod ON P.id_producto = Prod.id_producto
JOIN
	LA_NARANJA_MECANICA_V2.BI_Subrubro S ON Prod.id_subrubro = S.id_subrubro
JOIN
    LA_NARANJA_MECANICA_V2.BI_Tiempo T ON P.id_tiempo_inicio = T.id_tiempo
JOIN
    LA_NARANJA_MECANICA_V2.BI_Tiempo T2 ON P.id_tiempo_fin = T2.id_tiempo
GROUP BY
    S.descripcion, -- Subrubro
    T.anio,       -- Año
    T.cuatrimestre -- Cuatrimestre
GO

-- Vista para calcular el promedio de stock inicial según la marca por año
GO
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.vw_PromedioStockInicial AS
SELECT
    M.nombre AS marca,      -- Nombre de la marca
    T.anio,                 -- Año
    AVG(P.stock) AS promedio_stock_inicial -- Promedio de stock inicial
FROM
    LA_NARANJA_MECANICA_V2.BI_Publicaciones P
JOIN
    LA_NARANJA_MECANICA_V2.BI_Producto Prod ON P.id_producto = Prod.id_producto
JOIN
    LA_NARANJA_MECANICA_V2.BI_Marca M ON Prod.id_marca = M.id_marca
JOIN
    LA_NARANJA_MECANICA_V2.BI_Tiempo T ON P.id_tiempo_inicio = T.id_tiempo
GROUP BY
    M.nombre, -- Marca
    T.anio    -- Año
GO

-- Vista Rendimiento de rubros

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Hecho_Venta (cant_ventas, localidad, provincia_id ,cuatrimestre, anio_venta, rubro, rango_etario)
SELECT DISTINCT COUNT(DISTINCT v.nro_venta) cant_ventas, l.nombre localidad , l.id_provincia provincia_id ,LA_NARANJA_MECANICA_V2.get_cuatrimestre(v.fecha) cuatrimestre_venta ,YEAR(v.fecha) anio_venta, rub.descripcion rubro, LA_NARANJA_MECANICA_V2.get_rango_etario(c.fecha_nacimiento) rango_etario 
FROM LA_NARANJA_MECANICA_V2.venta v
JOIN LA_NARANJA_MECANICA_V2.usuario u on u.id = v.id_usuario
JOIN LA_NARANJA_MECANICA_V2.cliente c ON c.id = u.id_cliente
JOIN LA_NARANJA_MECANICA_V2.detalle_venta dv on dv.id_detalle_venta = v.id_detalle_venta
JOIN LA_NARANJA_MECANICA_V2.publicacion p on p.codigo_publicacion = dv.id_publicacion
JOIN LA_NARANJA_MECANICA_V2.producto produ ON p.id_producto = produ.id
JOIN LA_NARANJA_MECANICA_V2.subrubro sr ON sr.id = produ.id_subrubro
JOIN LA_NARANJA_MECANICA_V2.rubro rub On rub.id = sr.id_rubro
JOIN LA_NARANJA_MECANICA_V2.domicilio d ON d.id_usuario = u.id
JOIN LA_NARANJA_MECANICA_V2.localidad l ON d.id_localidad = l.id
GROUP BY rub.descripcion, LA_NARANJA_MECANICA_V2.get_rango_etario(c.fecha_nacimiento), YEAR(v.fecha), l.nombre, LA_NARANJA_MECANICA_V2.get_cuatrimestre(v.fecha), l.id_provincia

	
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.vista_rendimiento_rubros
AS
SELECT *
FROM LA_NARANJA_MECANICA_V2.BI_Hecho_Venta hv
WHERE hv.rubro IN
( SELECT TOP 5 hv2.rubro
	FROM LA_NARANJA_MECANICA_V2.BI_Hecho_Venta hv2
	WHERE hv2.anio_venta = hv.anio_venta 
	AND hv2.cuatrimestre = hv.cuatrimestre 
	AND hv2.localidad = hv.localidad
	AND hv2.provincia_id = hv.provincia_id
	AND hv2.rango_etario = hv.rango_etario
	ORDER BY hv2.cant_ventas DESC
)
GO

-- Vista 10
CREATE VIEW LA_NARANJA_MECANICA_V2.bi_monto_facturado_segun_provincia
AS
SELECT pro.nombre as 'Provincia',  
	   ven.razon_social as 'Vendedor', 
	   SUM(v.total) as 'Total Facturado', 
	   YEAR(v.fecha) as 'Año', 
	   LA_NARANJA_MECANICA_V2.get_cuatrimestre(v.fecha) as 'Cuatrimestre' 
	   FROM LA_NARANJA_MECANICA_V2.venta v
JOIN LA_NARANJA_MECANICA_V2.detalle_venta dv ON dv.id_detalle_venta = v.id_detalle_venta
JOIN LA_NARANJA_MECANICA_V2.publicacion p ON p.codigo_publicacion = dv.id_publicacion
JOIN LA_NARANJA_MECANICA_V2.usuario u ON u.id = p.id_usuario
JOIN LA_NARANJA_MECANICA_V2.vendedor ven ON ven.id = u.id_vendedor
JOIN LA_NARANJA_MECANICA_V2.domicilio dom ON dom.id_usuario = v.id_usuario
JOIN LA_NARANJA_MECANICA_V2.localidad lo ON lo.id = dom.id_localidad
JOIN LA_NARANJA_MECANICA_V2.provincia pro ON pro.id = lo.id_provincia
GROUP BY pro.nombre , ven.razon_social, YEAR(v.fecha), LA_NARANJA_MECANICA_V2.get_cuatrimestre(v.fecha)
GO
