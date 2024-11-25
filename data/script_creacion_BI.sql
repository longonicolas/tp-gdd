------- DIMENSIONES - MODELO BI ----------

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Tiempo(
	id_tiempo decimal(18,0) IDENTITY PRIMARY KEY,
	anio decimal(18,0),
	cuatrimestre decimal(18,0),
	mes decimal(18,0),
	dia decimal(18,0),
	fecha datetime
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Ubicacion(
	id_ubicacion decimal(18,0) PRIMARY KEY, --Es el ID localidad no se si esta bien
	localidad NVARCHAR(50),
	provincia NVARCHAR(50)
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
	id_tipo_medio_pago decimal(18,0) PRIMARY KEY, 
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

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Concepto (
    id_concepto DECIMAL(18,0) PRIMARY KEY,
    nombre NVARCHAR(50)
)

--TABLAS DE HECHOS
CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Hecho_Publicaciones (
    id_publicacion DECIMAL(18,0) PRIMARY KEY,
    id_producto DECIMAL(18,0),
	stock DECIMAL(18,0),
    id_tiempo_inicio DECIMAL(18,0),
	id_tiempo_fin DECIMAL(18,0)
    FOREIGN KEY (id_producto) REFERENCES LA_NARANJA_MECANICA_V2.BI_Producto(id_producto),
    FOREIGN KEY (id_tiempo_inicio) REFERENCES LA_NARANJA_MECANICA_V2.BI_Tiempo(id_tiempo),
	FOREIGN KEY (id_tiempo_fin) REFERENCES LA_NARANJA_MECANICA_V2.BI_Tiempo(id_tiempo)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Hecho_Ventas(
	id_hecho_venta DECIMAL(18,0) PRIMARY KEY,
	id_tiempo DECIMAL(18,0),
	id_producto DECIMAL(18,0),
	id_ubicacion DECIMAL(18,0),
	id_rango_etario DECIMAL(18,0),
	cantidad DECIMAL(18,0),
	total_venta DECIMAL(18,0)
	FOREIGN KEY (id_tiempo) REFERENCES LA_NARANJA_MECANICA_V2.BI_Tiempo(id_tiempo),
	FOREIGN KEY (id_producto) REFERENCES LA_NARANJA_MECANICA_V2.BI_Producto(id_producto),
	FOREIGN KEY (id_ubicacion) REFERENCES LA_NARANJA_MECANICA_V2.BI_Ubicacion(id_ubicacion),
	FOREIGN KEY (id_rango_etario) REFERENCES LA_NARANJA_MECANICA_V2.BI_RangoEtario(id_rango_etario)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Hecho_Pagos (
    id_hecho_pago DECIMAL(18,0) PRIMARY KEY,
    id_tiempo DECIMAL(18,0),
    id_tipo_medio_pago DECIMAL(18,0), 
    id_ubicacion DECIMAL(18,0), 
    cantidad_cuotas DECIMAL(18,0), 
    importe_pago DECIMAL(18,2),
    FOREIGN KEY (id_tiempo) REFERENCES LA_NARANJA_MECANICA_V2.BI_Tiempo (id_tiempo),
    FOREIGN KEY (id_tipo_medio_pago) REFERENCES LA_NARANJA_MECANICA_V2.BI_TipoMedioDePago (id_tipo_medio_pago),
    FOREIGN KEY (id_ubicacion) REFERENCES LA_NARANJA_MECANICA_V2.BI_Ubicacion (id_ubicacion)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Hecho_Envios(
	id_hecho_envio DECIMAL(18,0) PRIMARY KEY,
	id_fecha_entrega DECIMAL(18,0),
	id_fecha_programada DECIMAL(18,0),
	id_ubicacion_almacen DECIMAL(18,0),
	id_ubicacion_cliente DECIMAL(18,0),
	costo DECIMAL(18,2),
	tiempo_cumplido SMALLINT,
	FOREIGN KEY (id_fecha_entrega) REFERENCES LA_NARANJA_MECANICA_V2.BI_Tiempo(id_tiempo),
	FOREIGN KEY (id_fecha_programada) REFERENCES LA_NARANJA_MECANICA_V2.BI_Tiempo(id_tiempo),
	FOREIGN KEY (id_ubicacion_almacen) REFERENCES LA_NARANJA_MECANICA_V2.BI_Ubicacion(id_ubicacion),
	FOREIGN KEY (id_ubicacion_cliente) REFERENCES LA_NARANJA_MECANICA_V2.BI_Ubicacion(id_ubicacion)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Hecho_Facturaciones(
	id_hecho_facturacion DECIMAL(18,0) IDENTITY(1,1) PRIMARY KEY,
	id_tiempo DECIMAL(18,0),
	id_concepto DECIMAL(18,0),
	id_ubicacion DECIMAL(18,0),
	monto DECIMAL(18,2),
	FOREIGN KEY (id_tiempo) REFERENCES LA_NARANJA_MECANICA_V2.BI_Tiempo(id_tiempo),
	FOREIGN KEY (id_concepto) REFERENCES LA_NARANJA_MECANICA_V2.BI_Concepto(id_concepto),
	FOREIGN KEY (id_ubicacion) REFERENCES LA_NARANJA_MECANICA_V2.BI_Ubicacion(id_ubicacion)
)

---- MIGRADO DE DATOS DEL MODELO TRANSACCIONAL -------

--FUNCIONES NECESARIAS
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

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Tiempo (anio, cuatrimestre, mes, dia, fecha)
SELECT DISTINCT
    YEAR(E.fecha) AS anio,
    CASE 
        WHEN MONTH(E.fecha) BETWEEN 1 AND 4 THEN 1
        WHEN MONTH(E.fecha) BETWEEN 5 AND 8 THEN 2
        ELSE 3
    END AS cuatrimestre,
    MONTH(E.fecha) AS mes,
    DAY(E.fecha) AS dia,
    E.fecha AS fecha
FROM LA_NARANJA_MECANICA_V2.envio AS E
WHERE NOT EXISTS (
    SELECT 1
    FROM LA_NARANJA_MECANICA_V2.BI_Tiempo T
    WHERE T.fecha = E.fecha
);

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Ubicacion
SELECT D.id, L.nombre, P.nombre
FROM LA_NARANJA_MECANICA_V2.domicilio AS D
JOIN LA_NARANJA_MECANICA_V2.localidad AS L ON id_localidad = L.id
JOIN LA_NARANJA_MECANICA_V2.provincia AS P ON L.id_provincia = P.id

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

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Concepto
SELECT * FROM LA_NARANJA_MECANICA_V2.concepto

-- Insertar datos en la tabla de hechos BI_Publicaciones
INSERT INTO LA_NARANJA_MECANICA_V2.BI_Hecho_Publicaciones
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

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Hecho_Ventas
SELECT
	V.nro_venta,
	T.id_tiempo,
	PU.id_producto,
	A.id_domicilio,
	LA_NARANJA_MECANICA_V2.get_rango_etario(C.fecha_nacimiento),
	DV.cantidad,
	V.total
FROM LA_NARANJA_MECANICA_V2.venta V
JOIN LA_NARANJA_MECANICA_V2.detalle_venta DV ON V.id_detalle_venta = DV.id_detalle_venta
JOIN LA_NARANJA_MECANICA_V2.publicacion PU ON PU.codigo_publicacion = DV.id_publicacion
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T ON T.anio = YEAR(V.fecha) AND T.mes = MONTH(V.fecha) AND T.dia = DAY(V.fecha)
JOIN LA_NARANJA_MECANICA_V2.almacen A ON A.codigo_almacen = PU.id_almacen
JOIN LA_NARANJA_MECANICA_V2.usuario U ON U.id = V.id_usuario
JOIN LA_NARANJA_MECANICA_V2.cliente C ON C.id = U.id_cliente

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Hecho_Pagos (
    id_hecho_pago,
    id_tiempo,
    id_tipo_medio_pago,
    id_ubicacion,
    cantidad_cuotas,
    importe_pago
)
SELECT
	P.nro_pago,
	T.id_tiempo,
	TMP.id_tipo_medio_pago,
	D.id,
	P.cuotas,
	P.importe
FROM LA_NARANJA_MECANICA_V2.pago P
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T ON T.anio = YEAR(P.fecha) AND T.mes = MONTH(P.fecha) AND T.dia = DAY(P.fecha)
JOIN LA_NARANJA_MECANICA_V2.medio_pago MP ON P.id_medio_pago = MP.id_medio_pago
JOIN LA_NARANJA_MECANICA_V2.tipo_medio_pago TMP ON MP.id_tipo_medio_pago = TMP.id_tipo_medio_pago
JOIN LA_NARANJA_MECANICA_V2.venta V ON P.nro_venta = V.nro_venta
JOIN LA_NARANJA_MECANICA_V2.envio E ON E.nro_venta = V.nro_venta
JOIN LA_NARANJA_MECANICA_V2.domicilio D ON D.id = E.id_domicilio
WHERE
    P.cuotas > 1 AND D.id_usuario is not null

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Hecho_Envios(id_hecho_envio, id_fecha_entrega, id_fecha_programada, id_ubicacion_almacen, id_ubicacion_cliente, costo, tiempo_cumplido)
SELECT
    E.nro_envio,
    T.id_tiempo,
	T1.id_tiempo,
    A.id_domicilio,
	E.id_domicilio,
	E.costo,
	CASE 
        WHEN DATEPART(HOUR, E.fecha_entrega) between E.hora_inicio and E.hora_fin THEN 1 ELSE 0 
    END AS tiempo_cumplido
FROM LA_NARANJA_MECANICA_V2.envio E
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T ON T.anio = YEAR(E.fecha_entrega)
                  AND T.mes = MONTH(E.fecha_entrega)
                  AND T.dia = DAY(E.fecha_entrega)
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T1 ON T1.anio = YEAR(E.fecha)
                  AND T1.mes = MONTH(E.fecha)
                  AND T1.dia = DAY(E.fecha)
JOIN LA_NARANJA_MECANICA_V2.venta V ON V.nro_venta = E.nro_venta
JOIN LA_NARANJA_MECANICA_V2.detalle_venta DV ON DV.id_detalle_venta = V.id_detalle_venta
JOIN LA_NARANJA_MECANICA_V2.publicacion P ON P.codigo_publicacion = DV.id_publicacion
JOIN LA_NARANJA_MECANICA_V2.almacen A ON A.codigo_almacen = P.id_almacen

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Hecho_Facturaciones (id_tiempo, id_concepto, id_ubicacion, monto)
SELECT     
    T.id_tiempo AS id_tiempo,            
    C.id_concepto AS id_concepto,  
	D.id,
    DF.detalle_subtotal                      
FROM LA_NARANJA_MECANICA_V2.detalle_factura DF
JOIN LA_NARANJA_MECANICA_V2.factura F ON F.nro_factura = DF.nro_factura
JOIN LA_NARANJA_MECANICA_V2.usuario U ON F.id_usuario = U.id 
JOIN LA_NARANJA_MECANICA_V2.domicilio D ON D.id_usuario = U.id
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T ON T.anio = YEAR(F.fecha) AND T.mes = MONTH(F.fecha) AND T.dia = DAY(F.fecha)
JOIN LA_NARANJA_MECANICA_V2.BI_Concepto C ON C.id_concepto = DF.id_concepto

--VISTAS

-- VISTA 1:
GO
CREATE or ALTER VIEW LA_NARANJA_MECANICA_V2.V1_PromedioTiempoPublicaciones AS
SELECT
    S.descripcion AS subrubro,
    T.anio,
    T.cuatrimestre,
    AVG(DATEDIFF(DAY, T.fecha, T2.fecha)) AS promedio_tiempo_vigente_dias -- Promedio de los tiempos vigentes en días
FROM
    LA_NARANJA_MECANICA_V2.BI_Hecho_Publicaciones P
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

-- VISTA 2:
GO
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.V2_PromedioStockInicial AS
SELECT
    M.nombre AS Marca,      
    T.anio AS AÑO,          
    AVG(P.stock) AS PromedioStockInicial 
FROM
    LA_NARANJA_MECANICA_V2.BI_Hecho_Publicaciones P
JOIN
    LA_NARANJA_MECANICA_V2.BI_Producto Prod ON P.id_producto = Prod.id_producto
JOIN
    LA_NARANJA_MECANICA_V2.BI_Marca M ON Prod.id_marca = M.id_marca
JOIN
    LA_NARANJA_MECANICA_V2.BI_Tiempo T ON P.id_tiempo_inicio = T.id_tiempo
GROUP BY
    M.nombre,
    T.anio    
GO

--VISTA 3:
GO
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.V3_VentaPromedioMensual AS
SELECT
    U.provincia AS Provincia,
    T.anio AS Año,
    T.mes AS Mes,
    AVG(H.total_venta) AS VentaPromedioMensual
FROM
    LA_NARANJA_MECANICA_V2.BI_Hecho_Ventas H
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T ON H.id_tiempo = T.id_tiempo
JOIN LA_NARANJA_MECANICA_V2.BI_Ubicacion U ON H.id_ubicacion = U.id_ubicacion
GROUP BY
    U.provincia, T.anio, T.mes;
GO

--VISTA 4:
GO
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.V4_RendimientoDeRubros AS
SELECT
    anio,
    cuatrimestre,
    localidad,
    rango_etario,
    rubro,
    total_ventas
FROM (
    SELECT
        T.anio,
        T.cuatrimestre,
        U.localidad,
        RE.descripcion AS rango_etario,
        R.descripcion AS rubro,
        SUM(V.total_venta) AS total_ventas,
        ROW_NUMBER() OVER (
            PARTITION BY T.anio, T.cuatrimestre, U.localidad, RE.descripcion
            ORDER BY SUM(V.total_venta) DESC
        ) AS fila
    FROM
        LA_NARANJA_MECANICA_V2.BI_Hecho_Ventas V
    JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T
        ON V.id_tiempo = T.id_tiempo
    JOIN LA_NARANJA_MECANICA_V2.BI_Producto P
        ON V.id_producto = P.id_producto
    JOIN LA_NARANJA_MECANICA_V2.BI_Subrubro SR
        ON P.id_subrubro = SR.id_subrubro
    JOIN LA_NARANJA_MECANICA_V2.BI_Rubro R
        ON SR.id_rubro = R.id_rubro
    JOIN LA_NARANJA_MECANICA_V2.BI_Ubicacion U
        ON V.id_ubicacion = U.id_ubicacion
    JOIN LA_NARANJA_MECANICA_V2.BI_RangoEtario RE
        ON V.id_rango_etario = RE.id_rango_etario
    GROUP BY
        T.anio, T.cuatrimestre, U.localidad, RE.descripcion, R.descripcion
) AS VentasPorRubro
WHERE fila <= 5;
GO

--VISTA 5
--NO REALIZADA DADO QUE LA FECHA NO TIENE EL HORARIO DE LA MISMA

--VISTA 6
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.V6_Top3LocalidadesPagosCuotas AS
SELECT 
    anio,
    mes,
    medio_pago,
    localidad,
    total_importe
FROM 
   (
    SELECT 
        T.anio,
        T.mes,
        TMP.nombre AS medio_pago,
        U.localidad,
        SUM(HP.importe_pago) AS total_importe,
        ROW_NUMBER() OVER (
            PARTITION BY T.anio, T.mes, TMP.nombre 
            ORDER BY SUM(HP.importe_pago) DESC
        ) AS ranking
    FROM 
        LA_NARANJA_MECANICA_V2.BI_Hecho_Pagos HP
    JOIN 
        LA_NARANJA_MECANICA_V2.BI_Tiempo T ON HP.id_tiempo = T.id_tiempo
    JOIN 
        LA_NARANJA_MECANICA_V2.BI_TipoMedioDePago TMP ON HP.id_tipo_medio_pago = TMP.id_tipo_medio_pago
    JOIN 
        LA_NARANJA_MECANICA_V2.BI_Ubicacion U ON HP.id_ubicacion = U.id_ubicacion
    WHERE 
        HP.cantidad_cuotas > 1
    GROUP BY 
        T.anio, T.mes, TMP.nombre, U.localidad
	) as ranking
WHERE 
    ranking <= 3
GO

--VISTA 7
GO
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.V7_PorcentajeCumplimientoEnvios AS
SELECT
    U.provincia AS Provincia,             
    T.anio AS Año,                        
    T.mes AS Mes,                         
    COUNT(CASE WHEN H.tiempo_cumplido = 1 THEN 1 END) * 100.0 / COUNT(*) AS PorcentajeCumplimiento
FROM
    LA_NARANJA_MECANICA_V2.BI_Hecho_Envios H
JOIN LA_NARANJA_MECANICA_V2.BI_Ubicacion U ON H.id_ubicacion_almacen = U.id_ubicacion
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T ON H.id_fecha_entrega = T.id_tiempo
GROUP BY
    U.provincia, T.anio, T.mes;
GO

--VISTA 8
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.V8_LocalidadesCostoEnvio AS 
SELECT
    Localidad,
    TotalCostoEnvio
FROM (
    SELECT
        U.localidad AS Localidad,             
        SUM(H.costo) AS TotalCostoEnvio,
        ROW_NUMBER() OVER (ORDER BY SUM(H.costo) DESC) AS Rnk
    FROM
        LA_NARANJA_MECANICA_V2.BI_Hecho_Envios H
    JOIN LA_NARANJA_MECANICA_V2.BI_Ubicacion U ON H.id_ubicacion_cliente = U.id_ubicacion
    GROUP BY
        U.localidad
) AS CostoEnvios
WHERE Rnk <= 5
GO

--VISTA 9
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.V9_PorcentajeFacturacionPorConcepto AS
SELECT
    T.anio,
    T.mes,
    C.nombre,
    (SUM(HF.monto) * 100.0 / (SELECT SUM(H1.monto) FROM LA_NARANJA_MECANICA_V2.BI_Hecho_Facturaciones H1 where H1.id_concepto = HF.id_concepto))
		AS PorcentajeFacturacion
FROM 
	LA_NARANJA_MECANICA_V2.BI_Hecho_Facturaciones HF
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T ON HF.id_tiempo = T.id_tiempo
JOIN LA_NARANJA_MECANICA_V2.BI_Concepto C ON HF.id_concepto = C.id_concepto
Group BY
	T.anio, T.mes, C.nombre, HF.id_concepto
GO

--VISTA 10
CREATE OR ALTER VIEW LA_NARANJA_MECANICA_V2.V10_Facturacion_Por_Provincia AS
SELECT
	T.anio,
	T.cuatrimestre,
	U.provincia,
	SUM(HF.monto) AS MontoFacturado
FROM
	LA_NARANJA_MECANICA_V2.BI_Hecho_Facturaciones HF
JOIN LA_NARANJA_MECANICA_V2.BI_Tiempo T ON HF.id_tiempo = T.id_tiempo
JOIN LA_NARANJA_MECANICA_V2.BI_Ubicacion U ON HF.id_ubicacion = U.id_ubicacion
GROUP BY 
	T.anio, T.cuatrimestre, U.provincia
GO