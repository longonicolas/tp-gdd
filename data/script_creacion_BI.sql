------- DIMENSIONES - MODELO BI ----------

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Tiempo(
	id_tiempo decimal(18,0) IDENTITY PRIMARY KEY,
	anio decimal(18,0),
	cuatrimestre decimal(18,0),
	mes decimal(18,0),
	--semana decimal(18,0),
	dia decimal(18,0),
	fecha date
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

SELECT * FROM LA_NARANJA_MECANICA_V2.vw_PromedioTiempoPublicaciones