/*  

------------------------------------------------------------------------
-- Equipo: PROGRAMADORES_VIVIENTES (41)
-- Fecha de entrega: 7.07.2025
-- TP CUATRIMESTRAL GDD 2025 1C

-- Ciclo lectivo: 2025
-- Descripcion: Migracion a modelo BI
------------------------------------------------------------------------

*/


USE [GD1C2025]
GO

PRINT '------ PROGRAMADORES_VIVIENTES ------';
GO
PRINT '--- COMENZANDO MIGRACION BI  ---';
GO

/* DROPS */
DECLARE @DropConstraints NVARCHAR(max) = ''

SELECT @DropConstraints += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.'
                        +  QUOTENAME(OBJECT_NAME(parent_object_id)) + ' ' + 'DROP CONSTRAINT' + QUOTENAME(name)
FROM sys.foreign_keys
WHERE name LIKE '%' + 'BI_' + '%';

EXECUTE sp_executesql @DropConstraints;

PRINT '--- CONSTRAINTS BI DROPEADOS CORRECTAMENTE ---';


/* DROPS PROCEDURES */
DECLARE @DropProcedures NVARCHAR(max) = ''

SELECT @DropProcedures += 'DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.procedures
WHERE name LIKE '%' + 'BI_' + '%';

EXECUTE sp_executesql @DropProcedures;

PRINT '--- PROCEDURES BI DROPEADOS CORRECTAMENTE ---';


/* DROPS FUNCTIONS */
DECLARE @DropFunctions NVARCHAR(MAX) = '';

SELECT @DropFunctions += 'DROP FUNCTION ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF') AND name LIKE '%' + 'BI_' + '%';

EXEC sp_executesql @DropFunctions;

PRINT '--- FUNCTIONS BI DROPEADOS CORRECTAMENTE ---';


/* DROPS TABLAS */

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Tiempo]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Tiempo;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Ubicacion]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Ubicacion;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Sucursal]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Sucursal;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Rango_Etario]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Rango_Etario;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Turno]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Turno;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Tipo_Material]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Tipo_Material;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Modelo_Sillon]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Modelo_Sillon;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Estado_Pedido]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Estado_Pedido;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Hechos_Pedido]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Hechos_Pedido;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Hechos_Factura]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Hechos_Factura;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Hechos_Compra]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Hechos_Compra;
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.[BI_Hechos_Envio]', 'U') IS NOT NULL DROP TABLE PROGRAMADORES_VIVIENTES.BI_Hechos_Envio;


PRINT '--- TABLAS BI DROPEADAS CORRECTAMENTE ---';

------------------------------------------------------------------------

PRINT '--- CREACION TABLAS DE DIMENSIONES  ---';
GO

/* BI Tiempo */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Tiempo]
(
    [bi_tiempo_id] numeric(18) IDENTITY NOT NULL,
    [bi_tiempo_anio] numeric(8) NOT NULL,
    [bi_tiempo_cuatrimestre] TINYINT NOT NULL,
    [bi_tiempo_mes] TINYINT NOT NULL
);

/* BI Ubicacion */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Ubicacion]
(
    [bi_ubicacion_id] numeric(18) IDENTITY NOT NULL,
    [provincia_desc] nvarchar(30) NOT NULL,
    [localidad_desc] nvarchar(50) NOT NULL
);

/* BI Sucursal */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Sucursal]
(
    [bi_sucursal_id] numeric(18) IDENTITY NOT NULL,
    [sucursal_desc] decimal(18) NOT NULL 
);


/* BI Rango_Etario */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Rango_Etario]
(
    [bi_rango_etario_id] numeric(18) IDENTITY NOT NULL,
    [rango_etario_desc] nvarchar(12) NOT NULL
);

/* BI Turno */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Turno]
(
    [bi_turno_id] numeric(18) IDENTITY NOT NULL,
    [turno_desc] nvarchar(16) NOT NULL
);


/* BI Tipo_Material */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Tipo_Material]
(
    [bi_tipo_material_id] numeric(18) IDENTITY NOT NULL,
    [tipo_material_nombre] nvarchar(16) NOT NULL
);

/* BI Modelo_Sillon */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Modelo_Sillon]
(
    [bi_modelo_sillon_id] numeric(18) IDENTITY NOT NULL, 
    [modelo_sillon_nombre] nvarchar(50) NOT NULL
);

/* BI Estado_Pedido */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Estado_Pedido]
(
    [bi_estado_pedido_id] numeric(18) IDENTITY NOT NULL,
    [estado_pedido_desc] nvarchar(16) NOT NULL
);


------------------------------------------------------------------------


PRINT '--- CREACION TABLAS DE HECHOS  ---';
GO

/* BI Hechos_Pedido */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Pedido]
(
	pedidos_turno_id numeric(18) NOT NULL,
	pedidos_sucursal_id numeric(18) NOT NULL,
	pedidos_tiempo_id numeric(18) NOT NULL,
	pedidos_estado_id numeric(18) NOT NULL,

	pedidos_cantidad decimal(18) NOT NULL,
);

/* BI Hechos_Facturacion */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Factura]
(
	facturas_tiempo_id numeric(18) NOT NULL,
    facturas_rango_etario_id numeric(18) NOT NULL,
	facturas_sucursal_id numeric(18) NOT NULL, 
	facturas_ubicacion_id numeric(18) NOT NULL, 
	facturas_modelo_sillon_id numeric(18) NOT NULL,

	facturas_cantidad_ventas decimal(18,2) NOT NULL,
	facturas_total_ventas decimal(18,2) NOT NULL,
	facturas_tiempo_promedio_fabricacion decimal(18,2) NOT NULL
);

/* BI Hechos_Envio */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Envio]
(
    envios_tiempo_id numeric(18) NOT NULL,
	envios_ubicacion_id numeric(18) NOT NULL, 

	envios_monto_total decimal(18,2) NOT NULL,
	envios_cantidad_cumplidos decimal(18,2) NOT NULL,
	envios_cantidad_total decimal(18,2) NOT NULL

);


/* BI Hechos_Compra */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Compra]
(
    compras_tiempo_id numeric(18) NOT NULL,
	compras_sucursal_id numeric(18) NOT NULL,
	compras_tipo_material_id numeric(18) NOT NULL,

	compras_cantidad_total decimal(18,2) NOT NULL,
	compras_importe_total decimal(18,2) NOT NULL
);

------------------------------------------------------------------------

PRINT '--- CREACION PKs Dimensiones ---';


/* CONSTRAINT GENERATION - PKs*/

/* Dimensiones - PKs */

ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Tiempo]
    ADD CONSTRAINT [PK_BI_Tiempo] PRIMARY KEY CLUSTERED ([bi_tiempo_id] ASC)
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Sucursal]
    ADD CONSTRAINT [PK_BI_Sucursal] PRIMARY KEY CLUSTERED ([bi_sucursal_id] ASC)
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Ubicacion]
    ADD CONSTRAINT [PK_BI_Ubicacion] PRIMARY KEY CLUSTERED ([bi_ubicacion_id] ASC)
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Turno]
    ADD CONSTRAINT [PK_BI_Turno] PRIMARY KEY CLUSTERED ([bi_turno_id] ASC)
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Rango_Etario]
    ADD CONSTRAINT [PK_BI_Rango_Etario] PRIMARY KEY CLUSTERED ([bi_rango_etario_id] ASC)
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Tipo_Material]
    ADD CONSTRAINT [PK_BI_Tipo_Material] PRIMARY KEY CLUSTERED ([bi_tipo_material_id] ASC)
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Modelo_Sillon]
    ADD CONSTRAINT [PK_BI_Modelo_Sillon] PRIMARY KEY CLUSTERED ([bi_modelo_sillon_id] ASC)
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Estado_Pedido]
    ADD CONSTRAINT [PK_BI_Estado_Pedido] PRIMARY KEY CLUSTERED ([bi_estado_pedido_id] ASC)


PRINT '--- CREACION PKs Hechos ---';

/* Hechos - PKs */
-- Hechos Pedido
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Pedido]
    ADD CONSTRAINT [PK_BI_Hechos_Pedido] PRIMARY KEY CLUSTERED (pedidos_turno_id ASC,
	pedidos_sucursal_id ASC,
	pedidos_tiempo_id ASC,
	pedidos_estado_id ASC)

-- Hechos Factura
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Factura]
    ADD CONSTRAINT [PK_BI_Hechos_Factura] PRIMARY KEY CLUSTERED (facturas_tiempo_id asc,
    facturas_rango_etario_id asc,
	facturas_sucursal_id asc,
	facturas_ubicacion_id asc,
	facturas_modelo_sillon_id asc)

-- Hechos Envio
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Envio]
    ADD CONSTRAINT [PK_BI_Hechos_Envio] PRIMARY KEY CLUSTERED (envios_tiempo_id asc,
	envios_ubicacion_id asc)

-- Hechos Compra
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Compra]
    ADD CONSTRAINT [PK_BI_Hechos_Compra] PRIMARY KEY CLUSTERED (compras_tiempo_id asc,
	compras_sucursal_id asc,
	compras_tipo_material_id asc)


PRINT '--- CREACION FKs  ---';
/* CONSTRAINT GENERATION - FKs*/

-- Hechos Pedido
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Pedido]
    ADD CONSTRAINT [FK_BI_Hechos_Pedido_bi_turno_id] FOREIGN KEY (pedidos_turno_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Turno]([bi_turno_id]);
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Pedido]
    ADD CONSTRAINT [FK_BI_Hechos_Pedido_bi_sucursal_id] FOREIGN KEY (pedidos_sucursal_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Sucursal]([bi_sucursal_id]);
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Pedido]
    ADD CONSTRAINT [FK_BI_Hechos_Pedido_bi_tiempo_id] FOREIGN KEY (pedidos_tiempo_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Tiempo]([bi_tiempo_id]);
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Pedido]
    ADD CONSTRAINT [FK_BI_Hechos_Pedido_bi_estado_pedido_id] FOREIGN KEY (pedidos_estado_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Estado_Pedido]([bi_estado_pedido_id]);

-- Hechos Facturacion
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Factura]
    ADD CONSTRAINT [FK_BI_Hechos_Factura_bi_ubicacion_id] FOREIGN KEY (facturas_ubicacion_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Ubicacion]([bi_ubicacion_id]);
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Factura]
    ADD CONSTRAINT [FK_BI_Hechos_Factura_bi_sucursal_id] FOREIGN KEY (facturas_sucursal_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Sucursal]([bi_sucursal_id]);
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Factura]
    ADD CONSTRAINT [FK_BI_Hechos_Factura_bi_tiempo_id] FOREIGN KEY (facturas_tiempo_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Tiempo]([bi_tiempo_id]);
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Factura]
    ADD CONSTRAINT [FK_BI_Hechos_Factura_bi_modelo_sillon_id] FOREIGN KEY (facturas_modelo_sillon_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Modelo_Sillon]([bi_modelo_sillon_id]);
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Factura]
    ADD CONSTRAINT [FK_BI_Hechos_Factura_bi_rango_etario_id] FOREIGN KEY (facturas_rango_etario_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Rango_Etario]([bi_rango_etario_id]);

-- Hechos Envio

ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Envio]
    ADD CONSTRAINT [FK_BI_Hechos_Envio_bi_ubicacion_id] FOREIGN KEY (envios_ubicacion_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Ubicacion]([bi_ubicacion_id]);
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Envio]
    ADD CONSTRAINT [FK_BI_Hechos_Envio_bi_tiempo_id] FOREIGN KEY (envios_tiempo_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Tiempo]([bi_tiempo_id]);


-- Hechos Compra
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Compra]
    ADD CONSTRAINT [FK_BI_Hechos_Compra_bi_tipo_material_id] FOREIGN KEY (compras_tipo_material_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Tipo_Material]([bi_tipo_material_id]);
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Compra]
    ADD CONSTRAINT [FK_BI_Hechos_Compra_bi_sucursal_id] FOREIGN KEY (compras_sucursal_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Sucursal]([bi_sucursal_id]);
ALTER TABLE [PROGRAMADORES_VIVIENTES].[BI_Hechos_Compra]
    ADD CONSTRAINT [FK_BI_Hechos_Compra_bi_tiempo_id] FOREIGN KEY (compras_tiempo_id)
    REFERENCES [PROGRAMADORES_VIVIENTES].[BI_Tiempo]([bi_tiempo_id]);



------------------------------------------------------------------------

PRINT '--- COMIENZO CARGA DE DATOS ---';


/* CREACION DE FUNCIONES */

PRINT '---		CREACION DE FUNCIONES ---';

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Obtener_Rango_Etario') IS NOT NULL 
    DROP FUNCTION PROGRAMADORES_VIVIENTES.BI_Obtener_Rango_Etario
GO
CREATE FUNCTION [PROGRAMADORES_VIVIENTES].BI_Obtener_Rango_Etario(@unaFechaDeNacimiento datetime)
RETURNS nvarchar(255)
AS
    BEGIN
        DECLARE @unaEdad AS numeric(6) = Datediff(year, @unaFechaDeNacimiento, GETDATE())

        IF @unaEdad < 25
            RETURN '< 25 años'
        IF @unaEdad BETWEEN 25 AND 35
            RETURN '25-35 años'
        IF @unaEdad BETWEEN 35 AND 50
            RETURN '35-50 años'
 
        RETURN '> 50 años'
    END
GO

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Obtener_Turno') IS NOT NULL 
    DROP FUNCTION PROGRAMADORES_VIVIENTES.BI_Obtener_Turno
GO
CREATE FUNCTION PROGRAMADORES_VIVIENTES.BI_Obtener_Turno(@unaFechaHora datetime)
RETURNS nvarchar(255)
AS
    BEGIN
        DECLARE @unHorario AS numeric(6) = datepart(hour, @unaFechaHora)

        IF @unHorario BETWEEN 8 AND 14
            RETURN '08:00 - 14:00'
        IF @unHorario BETWEEN 14 AND 20
            RETURN '14:00 - 20:00'

        RETURN 'Fuera de Turno'
    END
GO

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Obtener_Cuatrimestre') IS NOT NULL
    DROP FUNCTION PROGRAMADORES_VIVIENTES.BI_Obtener_Cuatrimestre;
GO
CREATE FUNCTION PROGRAMADORES_VIVIENTES.BI_Obtener_Cuatrimestre (@unaFecha DATETIME)
RETURNS TINYINT      
AS
BEGIN
    DECLARE @unMes TINYINT = MONTH(@unaFecha);
    RETURN CASE
		WHEN @unMes BETWEEN 1 AND 4 THEN 1
        WHEN @unMes BETWEEN 5 AND 8 THEN 2
        ELSE 3                      
	END
END
GO

/* PROCEDURES */

PRINT '--- PROCEDURES ---';

/*--------------------------------------------------------------
  Carga de dimensión BI_Ubicacion
--------------------------------------------------------------*/

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Ubicacion') IS NOT NULL
	DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Ubicacion;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Ubicacion
AS
BEGIN
    
    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Ubicacion (provincia_desc, localidad_desc)
    SELECT DISTINCT p.pcia_nombre, l.loc_nombre FROM PROGRAMADORES_VIVIENTES.Localidad l     
	JOIN PROGRAMADORES_VIVIENTES.Provincia p ON p.pcia_id = l.loc_provincia        
    WHERE NOT EXISTS 
	(SELECT 1 FROM PROGRAMADORES_VIVIENTES.BI_Ubicacion u
		WHERE u.provincia_desc = p.pcia_nombre
		AND u.localidad_desc = l.loc_nombre)  
END
GO

/*--------------------------------------------------------------
  Carga de dimensión BI_Tiempo
--------------------------------------------------------------*/

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Tiempo') IS NOT NULL
	DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Tiempo;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Tiempo
AS
BEGIN

    WITH Fechas AS (
        /* Reunimos todas las fechas relevantes */
        SELECT fact_fecha AS fecha FROM PROGRAMADORES_VIVIENTES.Factura WHERE fact_fecha IS NOT NULL
        UNION
        SELECT ped_fecha FROM PROGRAMADORES_VIVIENTES.Pedido WHERE ped_fecha IS NOT NULL
        UNION
        SELECT comp_fecha FROM PROGRAMADORES_VIVIENTES.Compra WHERE comp_fecha IS NOT NULL
        UNION
        SELECT env_fecha_programada FROM PROGRAMADORES_VIVIENTES.Envio WHERE env_fecha_programada IS NOT NULL
		UNION
		SELECT env_fecha_entrega FROM PROGRAMADORES_VIVIENTES.Envio WHERE env_fecha_entrega IS NOT NULL
    )
    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Tiempo (bi_tiempo_anio, bi_tiempo_cuatrimestre, bi_tiempo_mes)
    SELECT DISTINCT
           YEAR(fecha) AS anio, PROGRAMADORES_VIVIENTES.BI_Obtener_Cuatrimestre(fecha) AS cuatrimestre, MONTH(fecha) AS mes FROM Fechas
    WHERE NOT EXISTS 
	(SELECT 1 FROM PROGRAMADORES_VIVIENTES.BI_Tiempo t
		WHERE t.bi_tiempo_anio = YEAR(fecha)
		AND t.bi_tiempo_mes  = MONTH(fecha))
	ORDER BY 1,2,3
END
GO

/*--------------------------------------------------------------
  Carga de dimensión BI_Sucursal
--------------------------------------------------------------*/

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Sucursal') IS NOT NULL
    DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Sucursal;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Sucursal
AS
BEGIN

INSERT INTO PROGRAMADORES_VIVIENTES.BI_Sucursal (sucursal_desc)
SELECT s.suc_numero FROM PROGRAMADORES_VIVIENTES.Sucursal s                             
WHERE NOT EXISTS 
(SELECT 1
	FROM PROGRAMADORES_VIVIENTES.BI_Sucursal bs
	WHERE bs.sucursal_desc = s.suc_numero )         
END
GO

/*--------------------------------------------------------------
  Carga de dimensión BI_Tipo_Material
--------------------------------------------------------------*/

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Tipo_Material') IS NOT NULL
    DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Tipo_Material;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Tipo_Material
AS
BEGIN
    
    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Tipo_Material (tipo_material_nombre)
    SELECT DISTINCT m.mat_tipo FROM PROGRAMADORES_VIVIENTES.Material m                              
    WHERE NOT EXISTS 
	( SELECT 1
		FROM PROGRAMADORES_VIVIENTES.BI_Tipo_Material tm
		WHERE tm.tipo_material_nombre = m.mat_tipo )       
END
GO
	
/*--------------------------------------------------------------
  Carga de dimensión BI_Rango_Etario
--------------------------------------------------------------*/
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Rango_Etario') IS NOT NULL
    DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Rango_Etario;
GO	
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Rango_Etario
AS
BEGIN

    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Rango_Etario (rango_etario_desc)
    SELECT DISTINCT PROGRAMADORES_VIVIENTES.BI_Obtener_Rango_Etario(clie_fecha_nac)
    FROM PROGRAMADORES_VIVIENTES.Cliente
    WHERE clie_fecha_nac IS NOT NULL
    AND NOT EXISTS 
	(SELECT 1 FROM PROGRAMADORES_VIVIENTES.BI_Rango_Etario e
		WHERE e.rango_etario_desc = PROGRAMADORES_VIVIENTES.BI_Obtener_Rango_Etario(clie_fecha_nac))
END
GO

/*--------------------------------------------------------------
  Carga de dimensión BI_Turno
--------------------------------------------------------------*/

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Turno') IS NOT NULL
    DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Turno;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Turno
AS
BEGIN

    WITH Fechas AS (
        SELECT ped_fecha f FROM PROGRAMADORES_VIVIENTES.Pedido WHERE ped_fecha IS NOT NULL
        UNION
        SELECT fact_fecha FROM PROGRAMADORES_VIVIENTES.Factura  WHERE fact_fecha IS NOT NULL
        UNION
        SELECT env_fecha_programada FROM PROGRAMADORES_VIVIENTES.Envio WHERE env_fecha_programada IS NOT NULL
		UNION
		SELECT env_fecha_entrega FROM PROGRAMADORES_VIVIENTES.Envio WHERE env_fecha_entrega IS NOT NULL
    )
    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Turno (turno_desc)
    SELECT DISTINCT PROGRAMADORES_VIVIENTES.BI_Obtener_Turno(f)          
    FROM Fechas
    WHERE NOT EXISTS 
	(SELECT 1 FROM PROGRAMADORES_VIVIENTES.BI_Turno t
		WHERE t.turno_desc = PROGRAMADORES_VIVIENTES.BI_Obtener_Turno(f) )

	/*
    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Turno (turno_desc)
    SELECT v.turno
    FROM (VALUES ('08:00 - 14:00'),
                 ('14:00 - 20:00'),
                 ('Fuera de Turno')) v(turno)
    WHERE NOT EXISTS 
	(SELECT 1 FROM PROGRAMADORES_VIVIENTES.BI_Turno t
		WHERE t.turno_desc = v.turno )
	*/
END
GO

/*--------------------------------------------------------------
  Carga de dimensión BI_Modelo_Sillon
--------------------------------------------------------------*/
IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Modelo_Sillon') IS NOT NULL
    DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Modelo_Sillon;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Modelo_Sillon
AS
BEGIN

    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Modelo_Sillon (modelo_sillon_nombre)
    SELECT DISTINCT sill_mod_modelo
    FROM PROGRAMADORES_VIVIENTES.Sillon_Modelo                                 
    WHERE sill_mod_modelo IS NOT NULL
		AND NOT EXISTS 
		(SELECT 1 FROM PROGRAMADORES_VIVIENTES.BI_Modelo_Sillon ms
			WHERE ms.modelo_sillon_nombre = Sillon_Modelo.sill_mod_modelo)
END
GO

/*--------------------------------------------------------------
  Carga de dimensión BI_Estado_Pedido 
--------------------------------------------------------------*/

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Estado_Pedido') IS NOT NULL
    DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Estado_Pedido;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Estado_Pedido
AS
BEGIN

    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Estado_Pedido (estado_pedido_desc)
    SELECT DISTINCT ped_est_estado
    FROM PROGRAMADORES_VIVIENTES.Pedido_Estado
    WHERE ped_est_estado IS NOT NULL
    AND NOT EXISTS ( SELECT 1 FROM PROGRAMADORES_VIVIENTES.BI_Estado_Pedido b
		WHERE b.estado_pedido_desc = Pedido_Estado.ped_est_estado
    )
END
GO

/*--------------------------------------------------------------
  Carga de tabla de hechos Factura
--------------------------------------------------------------*/

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Factura') IS NOT NULL
    DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Factura;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Factura
AS
BEGIN

    TRUNCATE TABLE PROGRAMADORES_VIVIENTES.BI_Hechos_Factura;

    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Hechos_Factura (
        facturas_tiempo_id, facturas_rango_etario_id, facturas_sucursal_id,
        facturas_ubicacion_id, facturas_modelo_sillon_id,
        facturas_cantidad_ventas, facturas_total_ventas, facturas_tiempo_promedio_fabricacion
    )
    SELECT
        ti.bi_tiempo_id,
        re.bi_rango_etario_id,
        sbi.bi_sucursal_id,
        ubi.bi_ubicacion_id,
        msi.bi_modelo_sillon_id,
        COUNT(*), 
        SUM(f.fact_total), 
        CAST(AVG(DATEDIFF(HOUR, p.ped_fecha, f.fact_fecha)) AS DECIMAL(18,2))
    FROM PROGRAMADORES_VIVIENTES.Factura f
    JOIN PROGRAMADORES_VIVIENTES.Detalle_Factura df ON df.det_fact_factura = f.fact_id
    JOIN PROGRAMADORES_VIVIENTES.Detalle_Pedido dp ON dp.det_ped_id = df.det_fact_detalle_pedido
    JOIN PROGRAMADORES_VIVIENTES.Pedido p ON p.ped_id = dp.det_ped_pedido
    JOIN PROGRAMADORES_VIVIENTES.Sillon s ON s.sill_id = dp.det_ped_sillon
    JOIN PROGRAMADORES_VIVIENTES.Sillon_Modelo sm ON sm.sill_mod_id = s.sill_modelo
    JOIN PROGRAMADORES_VIVIENTES.BI_Modelo_Sillon msi ON msi.modelo_sillon_nombre = sm.sill_mod_modelo
    JOIN PROGRAMADORES_VIVIENTES.Sucursal suc ON suc.suc_id = f.fact_sucursal
    JOIN PROGRAMADORES_VIVIENTES.BI_Sucursal sbi ON sbi.sucursal_desc = suc.suc_numero
    JOIN PROGRAMADORES_VIVIENTES.Localidad loc ON loc.loc_id = suc.suc_localidad
    JOIN PROGRAMADORES_VIVIENTES.Provincia prov ON prov.pcia_id = loc.loc_provincia
    JOIN PROGRAMADORES_VIVIENTES.BI_Ubicacion ubi ON ubi.localidad_desc = loc.loc_nombre AND ubi.provincia_desc = prov.pcia_nombre
    JOIN PROGRAMADORES_VIVIENTES.Cliente c ON c.clie_id = f.fact_cliente
    JOIN PROGRAMADORES_VIVIENTES.BI_Rango_Etario re ON re.rango_etario_desc = PROGRAMADORES_VIVIENTES.BI_Obtener_Rango_Etario(c.clie_fecha_nac)
    JOIN PROGRAMADORES_VIVIENTES.BI_Tiempo ti ON ti.bi_tiempo_anio = YEAR(f.fact_fecha)
                                             AND ti.bi_tiempo_mes  = MONTH(f.fact_fecha)
    GROUP BY ti.bi_tiempo_id, re.bi_rango_etario_id, sbi.bi_sucursal_id, ubi.bi_ubicacion_id, msi.bi_modelo_sillon_id
END
GO

/*--------------------------------------------------------------
  Carga de tabla de hechos Pedido
--------------------------------------------------------------*/

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Pedido') IS NOT NULL
    DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Pedido;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Pedido
AS
BEGIN

    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Hechos_Pedido (
        pedidos_turno_id, pedidos_sucursal_id, pedidos_tiempo_id, pedidos_estado_id,
        pedidos_cantidad
    )
    SELECT t.bi_turno_id, sbi.bi_sucursal_id, ti.bi_tiempo_id, epi.bi_estado_pedido_id, COUNT(*) --SUM(dp.det_ped_cantidad), CHECKEAR QUE ESTE BIEN EL COUNT, ANTES ERA EL SUM ESE
    FROM PROGRAMADORES_VIVIENTES.Pedido p
    JOIN PROGRAMADORES_VIVIENTES.Detalle_Pedido dp ON dp.det_ped_pedido = p.ped_id
    JOIN PROGRAMADORES_VIVIENTES.BI_Turno t ON t.turno_desc = PROGRAMADORES_VIVIENTES.BI_Obtener_Turno(p.ped_fecha)
    JOIN PROGRAMADORES_VIVIENTES.Sucursal s ON s.suc_id = p.ped_sucursal
    JOIN PROGRAMADORES_VIVIENTES.BI_Sucursal sbi ON sbi.sucursal_desc = s.suc_numero
    JOIN PROGRAMADORES_VIVIENTES.BI_Tiempo ti ON ti.bi_tiempo_anio = YEAR(p.ped_fecha) AND ti.bi_tiempo_mes  = MONTH(p.ped_fecha)
    JOIN PROGRAMADORES_VIVIENTES.Pedido_Estado pe ON pe.ped_est_id = p.ped_estado
    JOIN PROGRAMADORES_VIVIENTES.BI_Estado_Pedido epi ON epi.estado_pedido_desc = pe.ped_est_estado
    GROUP BY t.bi_turno_id, sbi.bi_sucursal_id, ti.bi_tiempo_id, epi.bi_estado_pedido_id
END
GO

/*--------------------------------------------------------------
  Carga de tabla de hechos Envio
--------------------------------------------------------------*/

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Envio') IS NOT NULL
    DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Envio;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Envio
AS
BEGIN

    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Hechos_Envio (
        envios_tiempo_id, envios_ubicacion_id,
        envios_monto_total, envios_cantidad_cumplidos, envios_cantidad_total
    )
    SELECT
        ti.bi_tiempo_id,
        ubi.bi_ubicacion_id,
        SUM(e.env_total),
        SUM(CASE WHEN e.env_fecha_entrega <= e.env_fecha_programada THEN 1 ELSE 0 END),
        COUNT(*)
    FROM PROGRAMADORES_VIVIENTES.Envio e
    JOIN PROGRAMADORES_VIVIENTES.Factura f ON f.fact_id = e.env_factura
    JOIN PROGRAMADORES_VIVIENTES.Cliente c ON c.clie_id = f.fact_cliente
    JOIN PROGRAMADORES_VIVIENTES.Localidad loc ON loc.loc_id = c.clie_localidad
    JOIN PROGRAMADORES_VIVIENTES.Provincia prov ON prov.pcia_id = loc.loc_provincia
    JOIN PROGRAMADORES_VIVIENTES.BI_Ubicacion ubi ON ubi.localidad_desc = loc.loc_nombre AND ubi.provincia_desc = prov.pcia_nombre
    JOIN PROGRAMADORES_VIVIENTES.BI_Tiempo ti ON ti.bi_tiempo_anio = YEAR(e.env_fecha_programada)
                                             AND ti.bi_tiempo_mes  = MONTH(e.env_fecha_programada)
    GROUP BY ti.bi_tiempo_id, ubi.bi_ubicacion_id
END
GO

/*--------------------------------------------------------------
  Carga de tabla de hechos Compra
--------------------------------------------------------------*/

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Compra') IS NOT NULL
    DROP PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Compra;
GO
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Compra
AS
BEGIN

    INSERT INTO PROGRAMADORES_VIVIENTES.BI_Hechos_Compra (
        compras_tiempo_id, compras_sucursal_id, compras_tipo_material_id,
        compras_cantidad_total, compras_importe_total
    )
    SELECT
        ti.bi_tiempo_id,
        sbi.bi_sucursal_id,
        tmi.bi_tipo_material_id,
        COUNT(*), 
        SUM(c.comp_total) 
    FROM PROGRAMADORES_VIVIENTES.Compra c
    JOIN PROGRAMADORES_VIVIENTES.Detalle_Compra dc ON dc.det_comp_compra = c.comp_id
    JOIN PROGRAMADORES_VIVIENTES.Material m ON m.mat_id = dc.det_comp_material
    JOIN PROGRAMADORES_VIVIENTES.BI_Tipo_Material tmi ON tmi.tipo_material_nombre = m.mat_tipo
    JOIN PROGRAMADORES_VIVIENTES.Sucursal s ON s.suc_id = c.comp_sucursal
    JOIN PROGRAMADORES_VIVIENTES.BI_Sucursal sbi ON sbi.sucursal_desc = s.suc_numero
    JOIN PROGRAMADORES_VIVIENTES.BI_Tiempo ti ON ti.bi_tiempo_anio = YEAR(c.comp_fecha)
                                             AND ti.bi_tiempo_mes  = MONTH(c.comp_fecha)
    GROUP BY ti.bi_tiempo_id, sbi.bi_sucursal_id, tmi.bi_tipo_material_id
END
GO



PRINT '--- COMIENZO EJECUCION DE PROCEDURES PARA DIMENSIONES ---';


EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Ubicacion;
EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Tiempo;
EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Sucursal;
EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Tipo_Material;
EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Rango_Etario;
EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Modelo_Sillon;
EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Turno;
EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Estado_Pedido;

PRINT '--- COMIENZO EJECUCION DE PROCEDURES PARA HECHOS ---';


EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Factura;
EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Pedido;
EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Envio;
EXEC PROGRAMADORES_VIVIENTES.BI_Cargar_Hechos_Compra;


/*
select * from PROGRAMADORES_VIVIENTES.BI_Ubicacion
select * from PROGRAMADORES_VIVIENTES.BI_Tiempo
select * from PROGRAMADORES_VIVIENTES.BI_Sucursal
select * from PROGRAMADORES_VIVIENTES.BI_Modelo_Sillon
select * from PROGRAMADORES_VIVIENTES.BI_Turno
select * from PROGRAMADORES_VIVIENTES.BI_Rango_Etario
select * from PROGRAMADORES_VIVIENTES.BI_Tipo_Material
select * from PROGRAMADORES_VIVIENTES.BI_Hechos_Factura
select * from PROGRAMADORES_VIVIENTES.BI_Hechos_Compra
select * from PROGRAMADORES_VIVIENTES.BI_Hechos_Pedido
select * from PROGRAMADORES_VIVIENTES.BI_Hechos_Envio
*/


-----------------------------------------------------------------------------  

/* CREACION DE VISTAS */

PRINT '--- CREACION DE VISTAS ---';

/*Ganancias: Total de ingresos (facturacion) - total de egresos (compras), por
cada mes, por cada sucursal.*/

-- Vista 1

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Ganancias') IS NOT NULL 
    DROP VIEW PROGRAMADORES_VIVIENTES.BI_Ganancias
GO 
CREATE VIEW PROGRAMADORES_VIVIENTES.BI_Ganancias AS
select isnull(sum(hf.facturas_total_ventas) - (
	select isnull(sum(hc.compras_importe_total),0) from PROGRAMADORES_VIVIENTES.BI_Hechos_Compra hc
	join PROGRAMADORES_VIVIENTES.BI_Tiempo tiempoCompra on tiempoCompra.bi_tiempo_id =  hc.compras_tiempo_id
	join PROGRAMADORES_VIVIENTES.BI_Sucursal sucursalCompra on sucursalCompra.bi_sucursal_id =  hc.compras_sucursal_id
	where tiempoCompra.bi_tiempo_anio = tiempo.bi_tiempo_anio and tiempoCompra.bi_tiempo_mes = tiempo.bi_tiempo_mes and sucursalCompra.sucursal_desc = sucursal.sucursal_desc
	group by tiempoCompra.bi_tiempo_mes, tiempoCompra.bi_tiempo_anio, sucursalCompra.bi_sucursal_id),0) as [Ganancias],
	tiempo.bi_tiempo_mes as [Mes],
	tiempo.bi_tiempo_anio as [Año],
	sucursal.sucursal_desc as [sucursal]
from PROGRAMADORES_VIVIENTES.BI_Hechos_Factura hf
join PROGRAMADORES_VIVIENTES.BI_Tiempo tiempo on tiempo.bi_tiempo_id =  hf.facturas_tiempo_id
join PROGRAMADORES_VIVIENTES.BI_Sucursal sucursal on sucursal.bi_sucursal_id =  hf.facturas_sucursal_id
group by tiempo.bi_tiempo_mes, tiempo.bi_tiempo_anio, sucursal.sucursal_desc
GO


/*Factura promedio mensual. Valor promedio de las facturas (en $) segun la
provincia de la sucursal para cada cuatrimestre de cada año. Se calcula en
funcion de la sumatoria del importe de las facturas sobre el total de las mismas
durante dicho periodo.*/

--Vista 2 

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Factura_Promedio_Mensual') IS NOT NULL 
    DROP VIEW PROGRAMADORES_VIVIENTES.BI_Factura_Promedio_Mensual
GO 
CREATE VIEW PROGRAMADORES_VIVIENTES.BI_Factura_Promedio_Mensual AS
select CAST((avg(hf.facturas_total_ventas / hf.facturas_cantidad_ventas))/4 AS DECIMAL(18,2)) as [Factura promedio mensual],
	u.provincia_desc as [Provincia],
	--s.sucursal_desc as [Sucursal],
	t.bi_tiempo_cuatrimestre as [Cuatrimestre],
	t.bi_tiempo_anio as [Año] 
from PROGRAMADORES_VIVIENTES.BI_Hechos_Factura hf
join PROGRAMADORES_VIVIENTES.BI_Tiempo t on t.bi_tiempo_id = hf.facturas_tiempo_id
join PROGRAMADORES_VIVIENTES.BI_Ubicacion u on u.bi_ubicacion_id = hf.facturas_ubicacion_id
join PROGRAMADORES_VIVIENTES.BI_Sucursal s on s.bi_sucursal_id = hf.facturas_sucursal_id
group by u.provincia_desc, t.bi_tiempo_cuatrimestre, t.bi_tiempo_anio
GO

/* Rendimiento de modelos. Los 3 modelos con mayores ventas para cada
cuatrimestre de cada año segun la localidad de la sucursal y rango etario de los
clientes.*/

-- Vista 3

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Rendimiento_de_Modelos') IS NOT NULL
    DROP VIEW PROGRAMADORES_VIVIENTES.BI_Rendimiento_de_Modelos;
GO
CREATE VIEW PROGRAMADORES_VIVIENTES.BI_Rendimiento_de_Modelos AS
SELECT
    ms.modelo_sillon_nombre AS [Modelo], t.bi_tiempo_cuatrimestre AS [Cuatrimestre], t.bi_tiempo_anio AS [Año],
    u.localidad_desc AS [Localidad], s.sucursal_desc AS [Sucursal], re.rango_etario_desc AS [Rango Etario],
    SUM(hf.facturas_total_ventas) AS [Total Ventas]
FROM PROGRAMADORES_VIVIENTES.BI_Hechos_Factura hf
JOIN PROGRAMADORES_VIVIENTES.BI_Tiempo t ON t.bi_tiempo_id = hf.facturas_tiempo_id
JOIN PROGRAMADORES_VIVIENTES.BI_Modelo_Sillon ms ON ms.bi_modelo_sillon_id = hf.facturas_modelo_sillon_id
JOIN PROGRAMADORES_VIVIENTES.BI_Sucursal s ON s.bi_sucursal_id = hf.facturas_sucursal_id
JOIN PROGRAMADORES_VIVIENTES.BI_Ubicacion u ON u.bi_ubicacion_id = hf.facturas_ubicacion_id
JOIN PROGRAMADORES_VIVIENTES.BI_Rango_Etario re ON re.bi_rango_etario_id = hf.facturas_rango_etario_id
GROUP BY ms.modelo_sillon_nombre,  t.bi_tiempo_cuatrimestre, t.bi_tiempo_anio, u.localidad_desc, s.sucursal_desc, re.rango_etario_desc
HAVING ms.modelo_sillon_nombre IN (    
       SELECT TOP 3 ms2.modelo_sillon_nombre
       FROM PROGRAMADORES_VIVIENTES.BI_Hechos_Factura hf2
       JOIN PROGRAMADORES_VIVIENTES.BI_Tiempo t2  ON t2.bi_tiempo_id = hf2.facturas_tiempo_id
       JOIN PROGRAMADORES_VIVIENTES.BI_Modelo_Sillon ms2 ON ms2.bi_modelo_sillon_id = hf2.facturas_modelo_sillon_id
       JOIN PROGRAMADORES_VIVIENTES.BI_Sucursal s2 ON s2.bi_sucursal_id = hf2.facturas_sucursal_id
       JOIN PROGRAMADORES_VIVIENTES.BI_Ubicacion u2 ON u2.bi_ubicacion_id = hf2.facturas_ubicacion_id
       JOIN PROGRAMADORES_VIVIENTES.BI_Rango_Etario re2 ON re2.bi_rango_etario_id = hf2.facturas_rango_etario_id
       WHERE t2.bi_tiempo_cuatrimestre = t.bi_tiempo_cuatrimestre
         AND t2.bi_tiempo_anio = t.bi_tiempo_anio AND u2.localidad_desc = u.localidad_desc
         AND s2.sucursal_desc = s.sucursal_desc AND re2.rango_etario_desc = re.rango_etario_desc
       GROUP BY ms2.modelo_sillon_nombre
       ORDER BY SUM(hf2.facturas_total_ventas) DESC
)
GO

/*Volumen de pedidos. Cantidad de pedidos registrados por turno, por sucursal
segun el mes de cada año.*/

-- Vista 4

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Volumen_de_Pedidos') IS NOT NULL 
    DROP VIEW PROGRAMADORES_VIVIENTES.BI_Volumen_de_Pedidos
GO 
CREATE VIEW PROGRAMADORES_VIVIENTES.BI_Volumen_de_Pedidos AS
select isnull(sum(hp.pedidos_cantidad),0) as [Cantidad de pedidos],
	tu.turno_desc as [Turno],
	s.sucursal_desc as [Sucursal],
	t.bi_tiempo_mes as [Mes],
	t.bi_tiempo_anio as [Año] 
from PROGRAMADORES_VIVIENTES.BI_Hechos_Pedido hp
join PROGRAMADORES_VIVIENTES.BI_Tiempo t on t.bi_tiempo_id = hp.pedidos_tiempo_id
join PROGRAMADORES_VIVIENTES.BI_Turno tu on tu.bi_turno_id = hp.pedidos_turno_id
join PROGRAMADORES_VIVIENTES.BI_Sucursal s on s.bi_sucursal_id = hp.pedidos_sucursal_id
group by tu.turno_desc, s.sucursal_desc, t.bi_tiempo_mes, t.bi_tiempo_anio
GO

/*Conversión de pedidos. Porcentaje de pedidos según estado, por cuatrimestre
y sucursal.*/

-- Vista 5 

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Conversion_de_Pedidos') IS NOT NULL
    DROP VIEW PROGRAMADORES_VIVIENTES.BI_Conversion_de_Pedidos;
GO
CREATE VIEW PROGRAMADORES_VIVIENTES.BI_Conversion_de_Pedidos AS
SELECT ep.estado_pedido_desc AS [Estado], t.bi_tiempo_cuatrimestre AS [Cuatrimestre],
    t.bi_tiempo_anio AS [Año], s.sucursal_desc AS [Sucursal],

    ISNULL(CAST(100.0 * SUM(hp.pedidos_cantidad) /
            ( SELECT SUM(hp2.pedidos_cantidad)
              FROM PROGRAMADORES_VIVIENTES.BI_Hechos_Pedido hp2
              JOIN PROGRAMADORES_VIVIENTES.BI_Tiempo t2 ON t2.bi_tiempo_id = hp2.pedidos_tiempo_id
              JOIN PROGRAMADORES_VIVIENTES.BI_Sucursal s2 ON s2.bi_sucursal_id = hp2.pedidos_sucursal_id
              WHERE t2.bi_tiempo_cuatrimestre = t.bi_tiempo_cuatrimestre
                AND t2.bi_tiempo_anio = t.bi_tiempo_anio
                AND s2.sucursal_desc = s.sucursal_desc) AS DECIMAL(10,2)), 0) AS [Porcentaje de pedidos]
FROM PROGRAMADORES_VIVIENTES.BI_Hechos_Pedido hp
JOIN PROGRAMADORES_VIVIENTES.BI_Tiempo t ON t.bi_tiempo_id   = hp.pedidos_tiempo_id
JOIN PROGRAMADORES_VIVIENTES.BI_Sucursal s ON s.bi_sucursal_id = hp.pedidos_sucursal_id
JOIN PROGRAMADORES_VIVIENTES.BI_Estado_Pedido ep ON ep.bi_estado_pedido_id = hp.pedidos_estado_id
GROUP BY ep.estado_pedido_desc, t.bi_tiempo_cuatrimestre, t.bi_tiempo_anio, s.sucursal_desc;
GO


/*Tiempo promedio de fabricacion: Tiempo promedio que tarda cada sucursal
entre que se registra un pedido y registra la factura para el mismo. Por 
cuatrimestre.*/

-- Vista 6

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Tiempo_Promedio_de_Fabricacion') IS NOT NULL
    DROP VIEW PROGRAMADORES_VIVIENTES.BI_Tiempo_Promedio_de_Fabricacion
GO
CREATE VIEW PROGRAMADORES_VIVIENTES.BI_Tiempo_Promedio_de_Fabricacion AS
SELECT 
	CAST(ROUND(AVG(isnull(hf.facturas_tiempo_promedio_fabricacion,0)) / 24.0, 2) AS DECIMAL(10,2)) AS [Tiempo promedio de fabricación (días)],
    s.sucursal_desc AS [Sucursal], t.bi_tiempo_cuatrimestre AS [Cuatrimestre],
    t.bi_tiempo_anio AS [Año]
FROM PROGRAMADORES_VIVIENTES.BI_Hechos_Factura hf
JOIN PROGRAMADORES_VIVIENTES.BI_Tiempo t ON t.bi_tiempo_id = hf.facturas_tiempo_id
JOIN PROGRAMADORES_VIVIENTES.BI_Sucursal s ON s.bi_sucursal_id = hf.facturas_sucursal_id
GROUP BY t.bi_tiempo_cuatrimestre, s.sucursal_desc, t.bi_tiempo_anio
GO

/*Promedio de compras: Importe promedio de compras por mes*/

-- Vista 7

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Promedio_de_Compras') IS NOT NULL 
    DROP VIEW PROGRAMADORES_VIVIENTES.BI_Promedio_de_Compras
GO 
CREATE VIEW PROGRAMADORES_VIVIENTES.BI_Promedio_de_Compras AS
	select cast(avg(compras_importe_total/compras_cantidad_total) as decimal(18,2)) as [Promedio de Compras],
	t.bi_tiempo_mes as [Mes],
	t.bi_tiempo_anio as [Año] from PROGRAMADORES_VIVIENTES.BI_Hechos_Compra hc
	join PROGRAMADORES_VIVIENTES.BI_Tiempo t on t.bi_tiempo_id = hc.compras_tiempo_id
	group by t.bi_tiempo_mes, t.bi_tiempo_anio
GO

/*Compras por Tipo de Material. Importe total gastado por tipo de material,
sucursal y cuatrimestre*/

-- Vista 8

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Compras_por_Tipo_de_Material') IS NOT NULL 
    DROP VIEW PROGRAMADORES_VIVIENTES.BI_Compras_por_Tipo_de_Material
GO 
CREATE VIEW PROGRAMADORES_VIVIENTES.BI_Compras_por_Tipo_de_Material AS
	select sum(compras_importe_total) as [Importe total],
	tm.tipo_material_nombre as [Tipo de Material],
	t.bi_tiempo_cuatrimestre as [Cuatrimestre],
	t.bi_tiempo_anio as [Año],
	s.sucursal_desc as [Sucursal] from PROGRAMADORES_VIVIENTES.BI_Hechos_Compra hc
	join PROGRAMADORES_VIVIENTES.BI_Tiempo t on t.bi_tiempo_id = hc.compras_tiempo_id
	join PROGRAMADORES_VIVIENTES.BI_Tipo_Material tm on tm.bi_tipo_material_id = hc.compras_tipo_material_id
	join PROGRAMADORES_VIVIENTES.BI_Sucursal s on s.bi_sucursal_id = hc.compras_sucursal_id

	group by tm.tipo_material_nombre, t.bi_tiempo_cuatrimestre, t.bi_tiempo_anio, s.sucursal_desc
GO

/*Porcentaje de cumplimiento de envios en los tiempos programados por mes.
Se calcula teniendo en cuenta los envios cumplidos en fecha sobre el total de
envios para el periodo.*/

-- Vista 9

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Porcentaje_de_Cumplimiento_de_Envios') IS NOT NULL 
    DROP VIEW PROGRAMADORES_VIVIENTES.BI_Porcentaje_de_Cumplimiento_de_Envios
GO 
CREATE VIEW PROGRAMADORES_VIVIENTES.BI_Porcentaje_de_Cumplimiento_de_Envios AS
	select cast(sum(he.envios_cantidad_cumplidos) * 100 / sum(he.envios_cantidad_total) as decimal(18,2)) as [Porcentaje de cumplimiento],
	t.bi_tiempo_mes as [Mes],
	t.bi_tiempo_anio as [Año]
	from PROGRAMADORES_VIVIENTES.BI_Hechos_Envio he
	join PROGRAMADORES_VIVIENTES.BI_Tiempo t on t.bi_tiempo_id = he.envios_tiempo_id
	group by t.bi_tiempo_mes, t.bi_tiempo_anio
GO

/*Localidades que pagan mayor costo de envio. Las 3 localidades (tomando la
localidad del cliente) con mayor promedio de costo de envio (total).*/

-- Vista 10

IF OBJECT_ID('PROGRAMADORES_VIVIENTES.BI_Localidades_que_pagan_mayor_costo_de_envio') IS NOT NULL 
    DROP VIEW PROGRAMADORES_VIVIENTES.BI_Localidades_que_pagan_mayor_costo_de_envio
GO 
CREATE VIEW PROGRAMADORES_VIVIENTES.BI_Localidades_que_pagan_mayor_costo_de_envio AS
	select top 3 u.localidad_desc  as [localidad]
	from PROGRAMADORES_VIVIENTES.BI_Hechos_Envio he
	join PROGRAMADORES_VIVIENTES.BI_Ubicacion u on u.bi_ubicacion_id = he.envios_ubicacion_id
	group by u.localidad_desc, u.provincia_desc 
	order by avg(he.envios_monto_total / he.envios_cantidad_total) DESC
GO

/*
select * from PROGRAMADORES_VIVIENTES.BI_Ganancias --171
select * from PROGRAMADORES_VIVIENTES.BI_Factura_Promedio_Mensual --35
select * from PROGRAMADORES_VIVIENTES.BI_Rendimiento_de_Modelos --405
select * from PROGRAMADORES_VIVIENTES.BI_Volumen_de_Pedidos --342
select * from PROGRAMADORES_VIVIENTES.BI_Conversion_de_Pedidos --90
select * from PROGRAMADORES_VIVIENTES.BI_Tiempo_Promedio_de_Fabricacion --45 
select * from PROGRAMADORES_VIVIENTES.BI_Promedio_de_Compras --19
select * from PROGRAMADORES_VIVIENTES.BI_Compras_por_Tipo_de_Material --114
select * from PROGRAMADORES_VIVIENTES.BI_Porcentaje_de_Cumplimiento_de_Envios --19
select * from PROGRAMADORES_VIVIENTES.BI_Localidades_que_pagan_mayor_costo_de_envio --3
*/
