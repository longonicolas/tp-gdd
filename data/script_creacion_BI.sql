
------- DIMENSIONES - MODELO BI ----------

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Tiempo(
	
	codigo INT IDENTITY PRIMARY KEY NOT NULL,
	anio INT,
	cuatrimestre INT,
	mes INT,
	semana INT,
	dia INT
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Ubicacion(

	ubi_id decimal(18,0) PRIMARY KEY,
	ubi_provincia decimal(18,0),
	ubi_nombre nvarchar(255)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_RangoEtario(

    rango_id INT PRIMARY KEY,
    descripcion NVARCHAR(20), 
    edad_minima INT,         
    edad_maxima INT            
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_RangoHorario(
	
	rango_id INT PRIMARY KEY,
    descripcion NVARCHAR(20), 
	hora_minima TIME,         
    hora_maxima TIME  
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_MedioDePago(
	
	id_tipo_medio_pago decimal(18,0),
    nombre_tipo_pago NVARCHAR(50),
	nombre_banco NVARCHAR(50)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Envio(

	nro_envio decimal(18,0) PRIMARY KEY,
	id_tipo_envio decimal(18,0),
	nombre_tipo_envio NVARCHAR(50)
)

CREATE TABLE LA_NARANJA_MECANICA_V2.BI_Rubro(

	id decimal(18,0) PRIMARY KEY,
	id_subrubro decimal(18,0),
	id_producto decimal(18,0)
)


---- MIGRADO DE DATOS DEL MODELO TRANSACCIONAL -------

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Ubicacion (ubi_id, ubi_provincia, ubi_nombre)
SELECT id, id_provincia, nombre
FROM LA_NARANJA_MECANICA_V2.localidad

INSERT INTO LA_NARANJA_MECANICA_V2.BI_RangoEtario(rango_id, descripcion, edad_minima, edad_maxima)
VALUES 
    (1, '-25', 0, 24),
    (2, '25-35', 25, 34),
    (3, '35-50', 35, 50),
    (4, '50+', 51, NULL);

INSERT INTO LA_NARANJA_MECANICA_V2.BI_RangoHorario(rango_id, descripcion, hora_minima, hora_maxima)
VALUES 
    (1, '00:00-06:00', '00:00:00', '05:59:59'),
    (2, '06:00-12:00', '06:00:00', '11:59:59'),
    (3, '12:00-18:00', '12:00:00', '17:59:59'),
    (4, '18:00-24:00', '18:00:00', '23:59:59');


INSERT INTO LA_NARANJA_MECANICA_V2.BI_MedioDePago(id_tipo_medio_pago, nombre_tipo_pago, nombre_banco)
SELECT DISTINCT tmp.id_tipo_medio_pago, nombre, nombre_medio_pago
FROM LA_NARANJA_MECANICA_V2.tipo_medio_pago as tmp
JOIN LA_NARANJA_MECANICA_V2.medio_pago as mp ON tmp.id_tipo_medio_pago = mp.id_tipo_medio_pago

INSERT INTO LA_NARANJA_MECANICA_V2.BI_Envio(nro_envio, id_tipo_envio, nombre_tipo_envio)
SELECT nro_envio, e.id_tipo_envio, nombre
FROM LA_NARANJA_MECANICA_V2.envio as e
JOIN LA_NARANJA_MECANICA_V2.tipo_envio as tp ON tp.id_tipo_envio = e.id_tipo_envio


GO

CREATE OR ALTER FUNCTION LA_NARANJA_MECANICA_V2.get_id_rubro(@id_rubro decimal(18,0))
RETURNS decimal(18,0)
AS
BEGIN
	DECLARE @id decimal(18,0)

	SELECT @id = id_rubro
	FROM LA_NARANJA_MECANICA_V2.subrubro
	WHERE id_rubro = @id_rubro

	RETURN @id
END
GO


--NO MIGRA, REVISAR
INSERT INTO LA_NARANJA_MECANICA_V2.BI_Rubro(id, id_subrubro, id_producto)
SELECT r.id, sr.id, p.id
FROM LA_NARANJA_MECANICA_V2.rubro as r
JOIN LA_NARANJA_MECANICA_V2.subrubro as sr ON r.id = sr.id_rubro
JOIN LA_NARANJA_MECANICA_V2.producto as p ON sr.id = p.id_subrubro
