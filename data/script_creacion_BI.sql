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

CREATE TABLE LA_NARANJA_MECANICA_V2.bi_cliente(
	id_cliente DECIMAL(18,0) PRIMARY KEY,
	fecha_nacimiento DATE
)

insert into LA_NARANJA_MECANICA_V2.bi_cliente (id_cliente, fecha_nacimiento)
select distinct id, fecha_nacimiento from LA_NARANJA_MECANICA_V2.cliente

CREATE TABLE LA_NARANJA_MECANICA_V2.bi_vendedor(
	id_vendedor DECIMAL(18,0) PRIMARY KEY,
	razon_social VARCHAR(255)
)

insert into LA_NARANJA_MECANICA_V2.bi_vendedor (id_vendedor, razon_social)
select distinct id, razon_social from LA_NARANJA_MECANICA_V2.vendedor


CREATE TABLE LA_NARANJA_MECANICA_V2.bi_usuario(
		id_usuario DECIMAL(18,0) PRIMARY KEY,
		id_cliente DECIMAL(18,0),
		id_vendedor DECIMAL(18,0),
		FOREIGN KEY (id_cliente) REFERENCES LA_NARANJA_MECANICA_V2.bi_cliente(id_cliente),
		FOREIGN KEY (id_vendedor) REFERENCES LA_NARANJA_MECANICA_V2.bi_vendedor(id_vendedor),
)

insert into LA_NARANJA_MECANICA_V2.bi_usuario (id_usuario, id_cliente, id_vendedor)
select distinct id, id_cliente, id_vendedor from LA_NARANJA_MECANICA_V2.usuario




	CREATE TABLE LA_NARANJA_MECANICA_V2.bi_provincia(
	id DECIMAL(18,0) PRIMARY KEY,
	nombre VARCHAR(255)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.bi_localidad(
	id DECIMAL(18,0) PRIMARY KEY,
	nombre VARCHAR(255),
	id_provincia DECIMAL(18,0) REFERENCES LA_NARANJA_MECANICA_V2.bi_provincia
)

CREATE TABLE LA_NARANJA_MECANICA_V2.bi_domicilio(
	id_usuario DECIMAL(18,0),
	id_domicilio DECIMAL(18,0)  PRIMARY KEY,
	id_localidad DECIMAL(18,0) REFERENCES LA_NARANJA_MECANICA_V2.bi_localidad,
	FOREIGN KEY (id_usuario) REFERENCES LA_NARANJA_MECANICA_V2.bi_usuario(id_usuario),
)

CREATE TABLE LA_NARANJA_MECANICA_V2.bi_almacen(
	id DECIMAL(18,0) PRIMARY KEY,
	id_domicilio DECIMAL(18,0) REFERENCES LA_NARANJA_MECANICA_V2.bi_domicilio
	
)

CREATE TABLE LA_NARANJA_MECANICA_V2.bi_hecho_envio(
	nro DECIMAL(18,0) PRIMARY KEY,
	id_tiempo DECIMAL(18,0) REFERENCES LA_NARANJA_MECANICA_V2.bi_tiempo,
	hora_inicio VARCHAR(2),
	hora_fin VARCHAR(2),
	costo DECIMAL(10,2),
	fecha_entrega DATETIME,
	id_tipo_envio INTEGER FOREIGN KEY REFERENCES LA_NARANJA_MECANICA_V2.bi_tipo_envio,
	id__domicilio DECIMAL(18,0) REFERENCES LA_NARANJA_MECANICA_V2.bi_domicilio,
	id_usuario DECIMAL(18,0) REFERENCES LA_NARANJA_MECANICA_V2.bi_usuario,
	id_almacen DECIMAL(18,0) REFERENCES LA_NARANJA_MECANICA_V2.bi_almacen, 
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

	INSERT INTO LA_NARANJA_MECANICA_V2.bi_provincia
SELECT * FROM LA_NARANJA_MECANICA_V2.bi_provincia

INSERT INTO LA_NARANJA_MECANICA_V2.bi_localidad
SELECT id, nombre ,id_provincia  FROM LA_NARANJA_MECANICA_V2.localidad

INSERT INTO LA_NARANJA_MECANICA_V2.bi_domicilio (id_domicilio, id_usuario, id_localidad)
SELECT id, id_usuario, id_localidad
FROM LA_NARANJA_MECANICA_V2.domicilio

INSERT INTO LA_NARANJA_MECANICA_V2.bi_almacen
SELECT a.codigo_almacen, d.id
FROM LA_NARANJA_MECANICA_V2.almacen a
JOIN LA_NARANJA_MECANICA_V2.domicilio d ON d.id = a.id_domicilio

GO
CREATE FUNCTION LA_NARANJA_MECANICA_V2.devolver_id_tiempo(@fecha DATE)
RETURNS DECIMAL(18,0)
AS
BEGIN
	DECLARE @id DECIMAL(18,0),
			@cuatri SMALLINT

	SET @cuatri = LA_NARANJA_MECANICA_V2.get_cuatrimestre(@fecha)

	SET @id = (SELECT id_tiempo FROM LA_NARANJA_MECANICA_V2.BI_Tiempo
			  WHERE cuatrimestre = @cuatri AND mes = MONTH(@fecha) AND anio = YEAR (@fecha) )

	RETURN @id


END
GO

INSERT INTO LA_NARANJA_MECANICA_V2.bi_hecho_envio
SELECT e.nro_envio, 
	   LA_NARANJA_MECANICA_V2.devolver_id_tiempo(e.fecha),
	   e.hora_inicio, 
	   e.hora_fin, 
	   e.costo, 
	   e.fecha_entrega, 
	   e.id_tipo_envio, 
	   e.id_domicilio,
	   d.id_usuario,
	   p.id_almacen
FROM LA_NARANJA_MECANICA_V2.envio e
JOIN LA_NARANJA_MECANICA_V2.domicilio d ON d.id = e.id_domicilio
JOIN LA_NARANJA_MECANICA_V2.venta v ON e.nro_venta = v.nro_venta
JOIN LA_NARANJA_MECANICA_V2.detalle_venta dv ON dv.id_detalle_venta = v.id_detalle_venta
JOIN LA_NARANJA_MECANICA_V2.publicacion p ON p.codigo_publicacion = dv.id_publicacion

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


-- Vista 7
CREATE VIEW LA_NARANJA_MECANICA_V2.bi_porcentaje_cumplimiento_envios
AS
SELECT COUNT(DISTINCT e.nro) * 100 / total_envios.cantidad_envios 'Porcentaje de cumplimiento', t.anio año, t.mes, pro.nombre 'Provincia destino', a.id 'Codigo almacen'
	FROM LA_NARANJA_MECANICA_V2.bi_hecho_envio e
	JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo t ON e.id_tiempo = t.id_tiempo
	JOIN LA_NARANJA_MECANICA_V2.bi_almacen a ON a.id = e.id_almacen
	JOIN LA_NARANJA_MECANICA_V2.bi_domicilio d ON e.id__domicilio = d.id
	JOIN LA_NARANJA_MECANICA_V2.bi_localidad l ON l.id = d.id_localidad
	JOIN LA_NARANJA_MECANICA_V2.bi_provincia pro ON pro.id = l.id_provincia
	JOIN(
		SELECT COUNT(DISTINCT e.nro) cantidad_envios, t.anio año, t.mes, pro.nombre 'Provincia destino', a.id 'Codigo almacen'
		FROM LA_NARANJA_MECANICA_V2.bi_hecho_envio e
		JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo t ON e.id_tiempo = t.id_tiempo
		JOIN LA_NARANJA_MECANICA_V2.bi_almacen a ON a.id = e.id_almacen
		JOIN LA_NARANJA_MECANICA_V2.bi_domicilio d ON e.id__domicilio = d.id
		JOIN LA_NARANJA_MECANICA_V2.bi_localidad l ON l.id = d.id_localidad
		JOIN LA_NARANJA_MECANICA_V2.bi_provincia pro ON pro.id = l.id_provincia
		GROUP BY t.anio, t.mes, pro.nombre, a.id
	) total_envios ON a.id = total_envios.[Codigo almacen] 
				   AND total_envios.[Provincia destino] = pro.nombre 
				   AND total_envios.año = t.anio
				   AND total_envios.mes = t.mes
	WHERE FORMAT(e.fecha_entrega, 'HH') BETWEEN e.hora_inicio AND e.hora_fin 
	GROUP BY t.anio, t.mes, pro.nombre, a.id, total_envios.cantidad_envios

-- Vista 8
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.localidades_costo_envio
AS
SELECT TOP 5 SUM(e.costo) as 'Costo total', d.provincia as 'Provincia', d.localidad as 'Localidad' 
FROM LA_NARANJA_MECANICA_V2.envio e
JOIN LA_NARANJA_MECANICA_V2.bi_domicilio d ON e.id_domicilio = d.id_domicilio
GROUP BY d.provincia, d.localidad
ORDER BY 'Costo total' DESC
GO

-- Vista 9
CREATE VIEW LA_NARANJA_MECANICA_V2.bi_porcentaje_de_facturacion
AS
SELECT  c.nombre as 'Concepto', (SUM(df.detalle_subtotal) / totalPorMes.total_facturado) * 100 as 'Porcentaje de facturacion', MONTH(f.fecha) as 'Mes', YEAR(f.fecha) as 'Año'  
FROM LA_NARANJA_MECANICA_V2.factura f
JOIN LA_NARANJA_MECANICA_V2.detalle_factura df ON df.nro_factura = f.nro_factura
JOIN LA_NARANJA_MECANICA_V2.concepto c ON c.id_concepto = df.id_concepto
JOIN (SELECT SUM(df2.detalle_subtotal) total_facturado, MONTH(f2.fecha) mes, YEAR(f2.fecha) año FROM LA_NARANJA_MECANICA_V2.factura f2
		JOIN LA_NARANJA_MECANICA_V2.detalle_factura df2 ON f2.nro_factura = df2.nro_factura
		GROUP BY MONTH(f2.fecha), YEAR(f2.fecha)) 
		totalPorMes ON MONTH(f.fecha) = totalPorMes.mes AND YEAR(f.fecha) = totalPorMes.año
GROUP BY c.nombre , MONTH(f.fecha), YEAR(f.fecha), totalPorMes.total_facturado
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
