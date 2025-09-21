/*  

-- Equipo: PROGRAMADORES_VIVIENTES
-- Fecha de entrega: 01.06.2025
-- TP CUATRIMESTRAL GDD 2025 1C

-- Ciclo lectivo: 2025
-- Descripcion: Migracion de Tabla Maestra - Creacion Inicial

*/


USE [GD1C2025]
GO

PRINT '------ PROGRAMADORES_VIVIENTES ------';
GO
PRINT '--- COMENZANDO MIGRACION  ---';
GO

/* DROPS */
DECLARE @DropConstraints NVARCHAR(max) = ''

SELECT @DropConstraints += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.'

                        +  QUOTENAME(OBJECT_NAME(parent_object_id)) + ' ' + 'DROP CONSTRAINT' + QUOTENAME(name)

FROM sys.foreign_keys

EXECUTE sp_executesql @DropConstraints;

PRINT '--- CONSTRAINTS DROPEADOS CORRECTAMENTE ---';

GO

/* DROPS PROCEDURES */
DECLARE @DropProcedures NVARCHAR(max) = ''

SELECT @DropProcedures += 'DROP PROCEDURE ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.procedures;

EXECUTE sp_executesql @DropProcedures;

PRINT '--- PROCEDURES DROPEADOS CORRECTAMENTE ---';

GO

/* DROPS VISTAS */
DECLARE @DropViews NVARCHAR(max) = ''

SELECT @DropViews += 'DROP VIEW ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.views
WHERE name LIKE '%' + 'BI_' + '%';

EXECUTE sp_executesql @DropViews;

PRINT '--- VISTAS DROPEADAS CORRECTAMENTE ---';

GO

/* DROPS FUNCTIONS */
DECLARE @DropFunctions NVARCHAR(MAX) = '';

SELECT @DropFunctions += 'DROP FUNCTION ' + QUOTENAME(SCHEMA_NAME(schema_id)) + '.' + QUOTENAME(name) + ';'
FROM sys.objects
WHERE type IN ('FN', 'IF', 'TF') AND name LIKE '%' + 'BI_' + '%';

EXEC sp_executesql @DropFunctions;

PRINT '--- FUNCTIONS DROPEADOS CORRECTAMENTE ---';

GO

/* DROP TABLES */

DECLARE @DropTables NVARCHAR(max) = ''

SELECT @DropTables += 'DROP TABLE PROGRAMADORES_VIVIENTES. ' + QUOTENAME(TABLE_NAME)

FROM INFORMATION_SCHEMA.TABLES

WHERE TABLE_SCHEMA = 'PROGRAMADORES_VIVIENTES' and TABLE_TYPE = 'BASE TABLE'

EXECUTE sp_executesql @DropTables;

PRINT '--- TABLAS DROPEADAS CORRECTAMENTE ---';

GO

IF EXISTS (SELECT name FROM sys.schemas WHERE name = 'PROGRAMADORES_VIVIENTES')
    DROP SCHEMA PROGRAMADORES_VIVIENTES
GO

CREATE SCHEMA PROGRAMADORES_VIVIENTES;
GO

PRINT '--- SCHEMA PROGRAMADORES_VIVIENTES CREADO CORRECTAMENTE  ---';

/*Creacion de Tablas*/

/* PROVINCIA */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Provincia] (
    [pcia_id] numeric(18) IDENTITY NOT NULL,
    [pcia_nombre] nvarchar(30)
);

/* LOCALIDAD */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Localidad] (
    [loc_id] numeric(18) IDENTITY NOT NULL,
    [loc_nombre] nvarchar(50),
    [loc_provincia] numeric(18) NOT NULL
);

/* CLIENTE */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Cliente] (
    [clie_id] numeric(18) IDENTITY NOT NULL,
    [clie_localidad] numeric(18) NOT NULL,
    [clie_nombre] nvarchar(50),
    [clie_apellido] nvarchar(50),
	[clie_fecha_nac] datetime,
    [clie_dni] numeric(18),
    [clie_mail] nvarchar(50),
    [clie_direccion] nvarchar(100),
    [clie_telefono] numeric(18)
);

/* SUCURSAL */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Sucursal] (
	[suc_id] numeric(18) IDENTITY NOT NULL,
    [suc_numero] decimal(18) NOT NULL,
	[suc_localidad] numeric (18) NOT NULL,
    [suc_direccion] nvarchar(100),
    [suc_telefono] numeric(18),
    [suc_mail] nvarchar(50)
);

/* FACTURA */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Factura] (
	[fact_id] numeric(18) IDENTITY NOT NULL,
    [fact_numero] decimal(18) NOT NULL,
    [fact_cliente] numeric(18) NOT NULL,
    [fact_sucursal] numeric(18) NOT NULL,
    [fact_fecha] datetime,
    [fact_total] decimal(18,2)
);

/* DETALLE_FACTURA */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Factura] (
    [det_fact_factura] numeric(18) NOT NULL,
    [det_fact_detalle_pedido] numeric(18) NOT NULL
);

/* ENVIO */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Envio] (
	[env_id] numeric(18) IDENTITY NOT NULL,
    [env_numero] decimal(18) NOT NULL,
    [env_factura] numeric(18) NOT NULL,
    [env_fecha_programada] datetime,
	[env_fecha_entrega] datetime,
    [env_traslado] decimal(18,2),
    [env_subida] decimal(18,2),
    [env_total] decimal(18,2)
);

/* PEDIDO */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Pedido] (
	[ped_id] numeric(18) IDENTITY NOT NULL,
    [ped_numero] decimal(18) NOT NULL,
    [ped_sucursal] numeric(18) NOT NULL,
	[ped_cliente] numeric(18) NOT NULL,
    [ped_fecha] datetime,
    [ped_estado] numeric(18) NOT NULL,
    [ped_total] decimal(18,2)
);

/* PEDIDO_ESTADO */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Pedido_Estado] (
	[ped_est_id] numeric(18) IDENTITY NOT NULL,
	[ped_est_estado] nvarchar(10)
)

/* PEDIDO_CANCELACION */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Pedido_Cancelacion] (
    [ped_canc_id] numeric(18) IDENTITY NOT NULL,
    [ped_canc_pedido] numeric(18) NOT NULL,
    [ped_canc_fecha] datetime,
    [ped_canc_motivo] nvarchar(50)
);

/* DETALLE_PEDIDO */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Pedido] (
    [det_ped_id] numeric(18) IDENTITY NOT NULL,
    [det_ped_pedido] numeric(18) NOT NULL,
	[det_ped_sillon] numeric(18),
    [det_ped_cantidad] decimal(18),
    [det_ped_precio_unitario] decimal(18,2),
    [det_ped_subtotal] decimal(18,2)
);

/* COMPRA */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Compra] (
	[comp_id] numeric(18) IDENTITY NOT NULL,
    [comp_numero] decimal(18) NOT NULL,
    [comp_sucursal] numeric(18) NOT NULL,
    [comp_proveedor] numeric(18) NOT NULL,
    [comp_fecha] datetime,
    [comp_total] decimal(18,2)
);

/* DETALLE_COMPRA */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Compra] (
    [det_comp_id] numeric(18) IDENTITY NOT NULL,
	[det_comp_compra] numeric(18) NOT NULL,
	[det_comp_material] numeric(18) NOT NULL,
    [det_comp_precio] decimal(18,2),
    [det_comp_cantidad] decimal(18),
    [det_comp_subtotal] decimal(18,2)
);

/* PROVEEDOR */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Proveedor] (
    [prov_id] numeric(18) IDENTITY NOT NULL,
    [prov_localidad] numeric(18) NOT NULL,
    [prov_razon_social] nvarchar(50),
	[prov_cuit] nvarchar(13),
    [prov_direccion] nvarchar(100),
    [prov_telefono] numeric(18),
    [prov_mail] nvarchar(50)
);

/* SILLON_MODELO */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Sillon_Modelo] (
	[sill_mod_id] numeric(18) IDENTITY NOT NULL,
    [sill_mod_codigo] decimal(18) NOT NULL,
    [sill_mod_modelo] nvarchar(50),
    [sill_mod_descripcion] nvarchar(100),
    [sill_mod_precio_base] decimal(18,2)
);

/* SILLON */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Sillon] (
	[sill_id] numeric(18) IDENTITY NOT NULL,
    [sill_codigo] decimal(18) NOT NULL,
    [sill_modelo] numeric(18) NOT NULL,
    [sill_medida] numeric(18) NOT NULL,
    [sill_precio] decimal(18,2)
);

/* SILLON_MEDIDA */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Sillon_Medida] (
    [sill_med_id] numeric(18) IDENTITY NOT NULL,
    [sill_med_alto] decimal(18,2),
    [sill_med_ancho] decimal(18,2),
    [sill_med_profundidad] decimal(18,2),
    [sill_med_precio] decimal(18,2)
);

/* MATERIAL_SILLON */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Material_Sillon] (
    [mat_sill_material] numeric(18) NOT NULL,
    [mat_sill_sillon] numeric(18) NOT NULL
);

/* MATERIAL */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Material] (
    [mat_id] numeric(18) IDENTITY NOT NULL,
    [mat_tipo] nvarchar(7),
    [mat_nombre] nvarchar(15),
    [mat_descripcion] nvarchar(30),
    [mat_precio] decimal(18,2)
);

/* TELA */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Tela] (
    [tela_material] numeric(18) NOT NULL,
    [tela_color] nvarchar(10),
    [tela_textura] nvarchar(15)
);

/* MADERA */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Madera] (
    [mad_material] numeric(18) NOT NULL,
    [mad_color] nvarchar(10),
    [mad_dureza] nvarchar(15)
);

/* RELLENO */
CREATE TABLE [PROGRAMADORES_VIVIENTES].[Relleno] (
    [rell_material] numeric(18) NOT NULL,
    [rell_densidad] decimal(18,2)
);

/* CONSTRAINT GENERATION - PRIMARY KEYS */

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Provincia]
    ADD CONSTRAINT [PK_Provincia] PRIMARY KEY CLUSTERED ([pcia_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Localidad]
    ADD CONSTRAINT [PK_Localidad] PRIMARY KEY CLUSTERED ([loc_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Cliente]
    ADD CONSTRAINT [PK_Cliente] PRIMARY KEY CLUSTERED ([clie_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Sucursal]
    ADD CONSTRAINT [PK_Sucursal] PRIMARY KEY CLUSTERED ([suc_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Factura]
    ADD CONSTRAINT [PK_Factura] PRIMARY KEY CLUSTERED ([fact_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Factura]
    ADD CONSTRAINT [PK_Detalle_Factura] PRIMARY KEY CLUSTERED ([det_fact_factura] ASC, [det_fact_detalle_pedido] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Envio]
    ADD CONSTRAINT [PK_Envio] PRIMARY KEY CLUSTERED ([env_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Pedido]
    ADD CONSTRAINT [PK_Pedido] PRIMARY KEY CLUSTERED ([ped_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Pedido_Estado]
    ADD CONSTRAINT [PK_Pedido_Estado] PRIMARY KEY CLUSTERED ([ped_est_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Pedido_Cancelacion]
    ADD CONSTRAINT [PK_Pedido_Cancelacion] PRIMARY KEY CLUSTERED ([ped_canc_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Pedido]
    ADD CONSTRAINT [PK_Detalle_Pedido] PRIMARY KEY CLUSTERED ([det_ped_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Compra]
    ADD CONSTRAINT [PK_Compra] PRIMARY KEY CLUSTERED ([comp_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Compra]
    ADD CONSTRAINT [PK_Detalle_Compra] PRIMARY KEY CLUSTERED ([det_comp_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Proveedor]
    ADD CONSTRAINT [PK_Proveedor] PRIMARY KEY CLUSTERED ([prov_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Sillon_Modelo]
    ADD CONSTRAINT [PK_Sillon_Modelo] PRIMARY KEY CLUSTERED ([sill_mod_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Sillon]
    ADD CONSTRAINT [PK_Sillon] PRIMARY KEY CLUSTERED ([sill_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Sillon_Medida]
    ADD CONSTRAINT [PK_Sillon_Medida] PRIMARY KEY CLUSTERED ([sill_med_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Material_Sillon]
    ADD CONSTRAINT [PK_Material_Sillon] PRIMARY KEY CLUSTERED ([mat_sill_material] ASC, [mat_sill_sillon] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Material]
    ADD CONSTRAINT [PK_Material] PRIMARY KEY CLUSTERED ([mat_id] ASC);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Tela]
    ADD CONSTRAINT [PK_Tela] PRIMARY KEY CLUSTERED ([tela_material]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Madera]
    ADD CONSTRAINT [PK_Madera] PRIMARY KEY CLUSTERED ([mad_material]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Relleno]
    ADD CONSTRAINT [PK_Relleno] PRIMARY KEY CLUSTERED ([rell_material]);

/* CONSTRAINT GENERATION - FOREIGN KEYS */

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Localidad]
    ADD CONSTRAINT [FK_Localidad_loc_provincia] FOREIGN KEY ([loc_provincia])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Provincia]([pcia_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Cliente]
    ADD CONSTRAINT [FK_Cliente_clie_localidad] FOREIGN KEY ([clie_localidad])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Localidad]([loc_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Sucursal]
    ADD CONSTRAINT [FK_Sucursal_suc_localidad] FOREIGN KEY ([suc_localidad])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Localidad]([loc_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Factura]
    ADD CONSTRAINT [FK_Factura_fact_cliente] FOREIGN KEY ([fact_cliente])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Cliente]([clie_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Factura]
    ADD CONSTRAINT [FK_Factura_fact_sucursal] FOREIGN KEY ([fact_sucursal])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Sucursal]([suc_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Factura]
    ADD CONSTRAINT [FK_Detalle_Factura_det_fact_factura] FOREIGN KEY ([det_fact_factura])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Factura]([fact_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Factura]
    ADD CONSTRAINT [FK_Detalle_Factura_det_fact_detalle_pedido] FOREIGN KEY ([det_fact_detalle_pedido])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Detalle_Pedido]([det_ped_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Envio]
    ADD CONSTRAINT [FK_Envio_env_factura] FOREIGN KEY ([env_factura])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Factura]([fact_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Pedido]
    ADD CONSTRAINT [FK_Pedido_ped_sucursal] FOREIGN KEY ([ped_sucursal])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Sucursal]([suc_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Pedido]
    ADD CONSTRAINT [FK_Pedido_ped_cliente] FOREIGN KEY ([ped_cliente])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Cliente]([clie_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Pedido]
    ADD CONSTRAINT [FK_Pedido_ped_estado] FOREIGN KEY ([ped_estado])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Pedido_Estado]([ped_est_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Pedido_Cancelacion]
    ADD CONSTRAINT [FK_Pedido_Cancelacion_ped_canc_pedido] FOREIGN KEY ([ped_canc_pedido])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Pedido]([ped_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Pedido]
    ADD CONSTRAINT [FK_Detalle_Pedido_det_ped_pedido] FOREIGN KEY ([det_ped_pedido])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Pedido]([ped_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Pedido]
    ADD CONSTRAINT [FK_Detalle_Pedido_det_ped_sillon] FOREIGN KEY ([det_ped_sillon])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Sillon]([sill_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Compra]
    ADD CONSTRAINT [FK_Compra_comp_sucursal] FOREIGN KEY ([comp_sucursal])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Sucursal]([suc_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Compra]
    ADD CONSTRAINT [FK_Compra_comp_proveedor] FOREIGN KEY ([comp_proveedor])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Proveedor]([prov_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Compra]
    ADD CONSTRAINT [FK_Detalle_Compra_comp_det_compra] FOREIGN KEY ([det_comp_compra])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Compra]([comp_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Detalle_Compra]
    ADD CONSTRAINT [FK_Detalle_Compra_comp_det_material] FOREIGN KEY ([det_comp_material])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Material]([mat_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Proveedor]
    ADD CONSTRAINT [FK_Proveedor_prov_localidad] FOREIGN KEY ([prov_localidad])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Localidad]([loc_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Sillon]
    ADD CONSTRAINT [FK_Sillon_sill_mod_codigo] FOREIGN KEY ([sill_modelo])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Sillon_Modelo]([sill_mod_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Sillon]
    ADD CONSTRAINT [FK_Sillon_sill_medida] FOREIGN KEY ([sill_medida])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Sillon_Medida]([sill_med_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Material_Sillon]
    ADD CONSTRAINT [FK_Material_Sillon_mat_sill_material] FOREIGN KEY ([mat_sill_material])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Material]([mat_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Material_Sillon]
    ADD CONSTRAINT [FK_Material_Sillon_mat_sill_sillon] FOREIGN KEY ([mat_sill_sillon])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Sillon]([sill_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Tela]
    ADD CONSTRAINT [FK_Tela_tela_codigo] FOREIGN KEY ([tela_material])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Material]([mat_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Madera]
    ADD CONSTRAINT [FK_Madera_mad_codigo] FOREIGN KEY ([mad_material])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Material]([mat_id]);

ALTER TABLE [PROGRAMADORES_VIVIENTES].[Relleno]
    ADD CONSTRAINT [FK_Relleno_rell_codigo] FOREIGN KEY ([rell_material])
    REFERENCES [PROGRAMADORES_VIVIENTES].[Material]([mat_id]);

PRINT '--- TABLAS CREADAS CORRECTAMENTE ---';
GO

/* --- MIGRACION DE DATOS ---*/

/* PROVINCIA */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Provincia
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Provincia] (pcia_nombre)
    SELECT DISTINCT Sucursal_Provincia
    FROM gd_esquema.Maestra
    WHERE Sucursal_Provincia IS NOT NULL
	AND Sucursal_Provincia NOT IN (SELECT pcia_nombre FROM [PROGRAMADORES_VIVIENTES].[Provincia])

    INSERT INTO [PROGRAMADORES_VIVIENTES].[Provincia] (pcia_nombre)
    SELECT DISTINCT Cliente_Provincia
    FROM gd_esquema.Maestra
    WHERE Cliente_Provincia IS NOT NULL
	AND Cliente_Provincia NOT IN (SELECT pcia_nombre FROM [PROGRAMADORES_VIVIENTES].[Provincia]);

    INSERT INTO [PROGRAMADORES_VIVIENTES].[Provincia] (pcia_nombre)
    SELECT DISTINCT Proveedor_Provincia
    FROM gd_esquema.Maestra
    WHERE Proveedor_Provincia IS NOT NULL
	AND Proveedor_Provincia NOT IN (SELECT pcia_nombre FROM [PROGRAMADORES_VIVIENTES].[Provincia]);
END
GO

/* PEDIDO_ESTADO */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Pedido_Estado
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Pedido_Estado] (ped_est_estado)
    SELECT DISTINCT Pedido_Estado
    FROM gd_esquema.Maestra
    WHERE Pedido_Estado IS NOT NULL

    INSERT INTO [PROGRAMADORES_VIVIENTES].[Pedido_Estado] (ped_est_estado)
    SELECT 'PENDIENTE'
END
GO

/* MATERIAL */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Material
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Material] (mat_tipo, mat_nombre, mat_descripcion, mat_precio)
	SELECT DISTINCT 
		Material_Tipo, 
		Material_Nombre, 
		Material_Descripcion,
		Material_Precio
	FROM gd_esquema.Maestra
	WHERE Material_Tipo IS NOT NULL
	AND Material_Nombre IS NOT NULL 
	AND	Material_Descripcion IS NOT NULL
	AND Material_Precio IS NOT NULL
END
GO

/* SILLON_MODELO */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Sillon_Modelo
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Sillon_Modelo] (sill_mod_codigo, sill_mod_modelo, sill_mod_descripcion, sill_mod_precio_base)
	SELECT DISTINCT
		Sillon_Modelo_Codigo, 
		Sillon_Modelo, 
		Sillon_Modelo_Descripcion, 
		Sillon_Modelo_Precio
	FROM gd_esquema.Maestra
	WHERE Material_Tipo IS NOT NULL
	AND Sillon_Modelo IS NOT NULL
	AND	Sillon_Modelo_Descripcion IS NOT NULL
	AND	Sillon_Modelo_Precio IS NOT NULL
END
GO

/* SILLON_MEDIDA */
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.Migrar_Sillon_Medida
AS
BEGIN
	INSERT INTO PROGRAMADORES_VIVIENTES.[Sillon_Medida] (sill_med_ancho, sill_med_alto, sill_med_profundidad, sill_med_precio)
	SELECT DISTINCT
		Sillon_Medida_Ancho,
		Sillon_Medida_Alto,
		Sillon_Medida_Profundidad,
		Sillon_Medida_Precio
	FROM gd_esquema.Maestra
	WHERE Sillon_Medida_Ancho IS NOT NULL
	AND	Sillon_Medida_Alto IS NOT NULL
	AND	Sillon_Medida_Profundidad IS NOT NULL
	AND	Sillon_Medida_Precio IS NOT NULL
END
GO

/* LOCALIDAD */
--revisar, no se si esta trayendo la cantidad correcta de la tabla maestra para cliente
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Localidad
AS
BEGIN

INSERT INTO [PROGRAMADORES_VIVIENTES].[Localidad] (loc_nombre, loc_provincia)
    SELECT DISTINCT 
		Maestra.Cliente_Localidad, 
		Provincia.pcia_id
    FROM gd_esquema.Maestra AS Maestra
    LEFT JOIN [PROGRAMADORES_VIVIENTES].[Provincia] AS Provincia ON Maestra.Cliente_Provincia = Provincia.pcia_nombre
	WHERE NOT EXISTS (
		SELECT 1 
		FROM [PROGRAMADORES_VIVIENTES].[Localidad] 
		WHERE [PROGRAMADORES_VIVIENTES].[Localidad].loc_nombre = Maestra.Cliente_Localidad
		AND [PROGRAMADORES_VIVIENTES].[Localidad].loc_provincia = Provincia.pcia_id
	) AND Maestra.Cliente_Localidad IS NOT NULL
	AND Provincia.pcia_id IS NOT NULL

	INSERT INTO [PROGRAMADORES_VIVIENTES].[Localidad] (loc_nombre, loc_provincia)
    SELECT DISTINCT Maestra.Proveedor_Localidad, 
	Provincia.pcia_id
    FROM gd_esquema.Maestra AS Maestra
    LEFT JOIN [PROGRAMADORES_VIVIENTES].[Provincia] AS Provincia ON Maestra.Proveedor_Provincia = Provincia.pcia_nombre
    WHERE NOT EXISTS (
		SELECT 1 
		FROM [PROGRAMADORES_VIVIENTES].[Localidad] 
		WHERE [PROGRAMADORES_VIVIENTES].[Localidad].loc_nombre = Maestra.Proveedor_Localidad
		AND [PROGRAMADORES_VIVIENTES].[Localidad].loc_provincia = Provincia.pcia_id
	) AND Maestra.Proveedor_Localidad IS NOT NULL
	AND Provincia.pcia_id IS NOT NULL

	INSERT INTO [PROGRAMADORES_VIVIENTES].[Localidad] (loc_nombre, loc_provincia)
    SELECT DISTINCT 
		Maestra.Sucursal_Localidad, 
		Provincia.pcia_id
    FROM gd_esquema.Maestra AS Maestra
    LEFT JOIN [PROGRAMADORES_VIVIENTES].[Provincia] AS Provincia ON Maestra.Sucursal_Provincia = Provincia.pcia_nombre
	WHERE NOT EXISTS (
		SELECT 1 
		FROM [PROGRAMADORES_VIVIENTES].[Localidad] 
		WHERE [PROGRAMADORES_VIVIENTES].[Localidad].loc_nombre = Maestra.Sucursal_Localidad
        AND [PROGRAMADORES_VIVIENTES].[Localidad].loc_provincia = Provincia.pcia_id
	) AND Maestra.Sucursal_Localidad IS NOT NULL
	AND Provincia.pcia_id IS NOT NULL

    
END
GO

/* TELA */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Tela
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Tela] (tela_material, tela_color, tela_textura)
	SELECT DISTINCT 
		Material.mat_id, 
		Maestra.Tela_Color, 
		Maestra.Tela_Textura
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Material] AS Material ON Maestra.Material_Tipo = Material.mat_tipo
		AND Maestra.Material_Nombre = Material.mat_nombre
		AND Maestra.Material_Descripcion = Material.mat_descripcion
		AND Maestra.Material_Precio = Material.mat_precio
	WHERE Maestra.Material_Tipo = 'Tela'
	AND Material.mat_id IS NOT NULL 
	AND Maestra.Tela_Color IS NOT NULL
	AND Maestra.Tela_Textura IS NOT NULL
END
GO

/* MADERA */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Madera
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Madera] (mad_material, mad_color, mad_dureza)
	SELECT DISTINCT 
		Material.mat_id, -- Podria haber distinto id y mismas propiedades?
		Maestra.Madera_Color, 
		Maestra.Madera_Dureza
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Material] AS Material ON Maestra.Material_Tipo = Material.mat_tipo
		AND Maestra.Material_Nombre = Material.mat_nombre
		AND Maestra.Material_Descripcion = Material.mat_descripcion
		AND Maestra.Material_Precio = Material.mat_precio
	WHERE Maestra.Material_Tipo = 'Madera'
	AND Material.mat_id IS NOT NULL
	AND Maestra.Madera_Color IS NOT NULL
	AND Maestra.Madera_Dureza IS NOT NULL
END
GO

/* RELLENO */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Relleno
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Relleno] (rell_material, rell_densidad)
	SELECT DISTINCT 
		Material.mat_id, 
		Maestra.Relleno_Densidad
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Material] AS Material ON Maestra.Material_Tipo = Material.mat_tipo
		AND Maestra.Material_Nombre = Material.mat_nombre
		AND Maestra.Material_Descripcion = Material.mat_descripcion
		AND Maestra.Material_Precio = Material.mat_precio
	WHERE Maestra.Material_Tipo = 'Relleno'
	AND Material.mat_id IS NOT NULL
	AND Maestra.Relleno_Densidad IS NOT NULL
END
GO

/* SILLON */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Sillon
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Sillon] (sill_codigo, sill_modelo, sill_medida, sill_precio)
	SELECT 
		Maestra.Sillon_Codigo, 
		Modelo.sill_mod_id, 
		Medida.sill_med_id, 
		Modelo.sill_mod_precio_base + Medida.sill_med_precio + SUM(Maestra.Material_Precio) AS sill_precio
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Sillon_Modelo] AS Modelo ON Maestra.Sillon_Modelo_Codigo = Modelo.sill_mod_codigo
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Sillon_Medida] AS Medida ON Maestra.Sillon_Medida_Ancho = Medida.sill_med_ancho
		AND Maestra.Sillon_Medida_Alto = Medida.sill_med_alto
		AND Maestra.Sillon_Medida_Profundidad = Medida.sill_med_profundidad
		AND Maestra.Sillon_Medida_Precio = Medida.sill_med_precio
	WHERE Maestra.Sillon_Codigo IS NOT NULL
	AND Maestra.Sillon_Modelo_Codigo IS NOT NULL
    AND Maestra.Sillon_Medida_Alto IS NOT NULL
	AND Maestra.Material_Precio IS NOT NULL
	GROUP BY Maestra.Sillon_Codigo, Modelo.sill_mod_id, Medida.sill_med_id, Modelo.sill_mod_precio_base, Medida.sill_med_precio
END
GO

/* MATERIAL_SILLON */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Material_Sillon
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Material_Sillon] (mat_sill_material, mat_sill_sillon)
	SELECT DISTINCT
		Material.mat_id,
		Sillon.sill_id 
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Material] AS Material ON Maestra.Material_Tipo = Material.mat_tipo
		AND Maestra.Material_Nombre = Material.mat_nombre
		AND Maestra.Material_Descripcion = Material.mat_descripcion
		AND Maestra.Material_Precio = Material.mat_precio
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Sillon] AS Sillon ON Maestra.Sillon_Codigo = Sillon.sill_codigo
	WHERE Maestra.Sillon_Codigo IS NOT NULL
		AND Maestra.Material_Tipo IS NOT NULL
		AND Material.mat_id IS NOT NULL
		AND Sillon.sill_id IS NOT NULL
END
GO

/* PROVEEDOR */
/*--------------------------------------------------------------
   PROVEEDOR
--------------------------------------------------------------*/
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.Migrar_Proveedor
AS
BEGIN
    INSERT INTO PROGRAMADORES_VIVIENTES.Proveedor (
        prov_localidad,
        prov_razon_social,
        prov_cuit,
        prov_direccion,
        prov_telefono,
        prov_mail)
    SELECT DISTINCT
        L.loc_id,                        -- ← usa localidad correcta (provincia + nombre)
        M.Proveedor_RazonSocial,
        M.Proveedor_Cuit,
        M.Proveedor_Direccion,
        M.Proveedor_Telefono,
        M.Proveedor_Mail
    FROM gd_esquema.Maestra              AS M
    /* Provincia por nombre */
    LEFT JOIN PROGRAMADORES_VIVIENTES.Provincia  AS P
           ON P.pcia_nombre = M.Proveedor_Provincia
    /* Localidad = nombre + provincia_id */
    LEFT JOIN PROGRAMADORES_VIVIENTES.Localidad  AS L
           ON L.loc_nombre    = M.Proveedor_Localidad
          AND L.loc_provincia = P.pcia_id          -- ← la clave añadida
    WHERE L.loc_id               IS NOT NULL
      AND P.pcia_id              IS NOT NULL
      AND M.Proveedor_RazonSocial IS NOT NULL
      -- evita duplicar CUIT
      AND NOT EXISTS ( SELECT 1
                       FROM PROGRAMADORES_VIVIENTES.Proveedor pr
                       WHERE pr.prov_cuit = M.Proveedor_Cuit );
END;
GO


/* SUCURSAL */
/*--------------------------------------------------------------
   SUCURSAL
--------------------------------------------------------------*/
CREATE PROCEDURE PROGRAMADORES_VIVIENTES.Migrar_Sucursal
AS
BEGIN
    INSERT INTO PROGRAMADORES_VIVIENTES.Sucursal (
        suc_numero,
        suc_localidad,
        suc_direccion,
        suc_telefono,
        suc_mail)
    SELECT DISTINCT
        M.Sucursal_NroSucursal,
        L.loc_id,
        M.Sucursal_Direccion,
        M.Sucursal_Telefono,
        M.Sucursal_Mail
    FROM gd_esquema.Maestra              AS M
    LEFT JOIN PROGRAMADORES_VIVIENTES.Provincia  AS P
           ON P.pcia_nombre = M.Sucursal_Provincia
    LEFT JOIN PROGRAMADORES_VIVIENTES.Localidad  AS L
           ON L.loc_nombre    = M.Sucursal_Localidad
          AND L.loc_provincia = P.pcia_id
    WHERE M.Sucursal_NroSucursal IS NOT NULL
      AND L.loc_id              IS NOT NULL
      AND NOT EXISTS ( SELECT 1
                       FROM PROGRAMADORES_VIVIENTES.Sucursal S
                       WHERE S.suc_numero = M.Sucursal_NroSucursal )
END
GO


/* COMPRA */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Compra
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Compra] (
		comp_numero,
		comp_sucursal,
		comp_proveedor,
		comp_fecha,
		comp_total)
	SELECT DISTINCT
		Maestra.Compra_Numero,
		Sucursal.suc_id,
		Proveedor.prov_id,
		Maestra.Compra_Fecha,
		Maestra.Compra_Total
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Sucursal] AS Sucursal ON Maestra.Sucursal_NroSucursal = Sucursal.suc_numero
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Proveedor] AS Proveedor ON Maestra.Proveedor_Cuit = Proveedor.prov_cuit
	WHERE Maestra.Compra_Numero IS NOT NULL
		AND Sucursal.suc_id IS NOT NULL
		AND Proveedor.prov_id IS NOT NULL
END
GO

/* DETALLE_COMPRA */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Detalle_Compra
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Detalle_Compra] (
		det_comp_compra,
		det_comp_material,
		det_comp_precio,
		det_comp_cantidad,
		det_comp_subtotal)
	SELECT DISTINCT
		Compra.comp_id,
		Material.mat_id,
		Maestra.Detalle_Compra_Precio,
		Maestra.Detalle_Compra_Cantidad,
		Maestra.Detalle_Compra_SubTotal
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Compra] AS Compra ON Maestra.Compra_Numero = Compra.comp_numero
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Material] AS Material ON Maestra.Material_Tipo = Material.mat_tipo
		AND Maestra.Material_Nombre = Material.mat_nombre
		AND Maestra.Material_Descripcion = Material.mat_descripcion
		AND Maestra.Material_Precio = Material.mat_precio
	WHERE Compra.comp_id IS NOT NULL
	AND Material.mat_id IS NOT NULL
	AND Maestra.Detalle_Compra_Precio IS NOT NULL
	AND Maestra.Detalle_Compra_Cantidad IS NOT NULL
	AND Maestra.Detalle_Compra_SubTotal IS NOT NULL
END
GO

/* CLIENTE */
--verificar, no se si me esta trayendo la cantidad correcta de clientes.
/*--------------------------------------------------------------
   CLIENTE
--------------------------------------------------------------*/

CREATE PROCEDURE PROGRAMADORES_VIVIENTES.Migrar_Cliente
AS
BEGIN
    INSERT INTO PROGRAMADORES_VIVIENTES.Cliente (
        clie_localidad,
        clie_dni,
        clie_nombre,
        clie_apellido,
        clie_fecha_nac,
        clie_mail,
        clie_direccion,
        clie_telefono)
    SELECT DISTINCT
        L.loc_id,
        M.Cliente_Dni,
        M.Cliente_Nombre,
        M.Cliente_Apellido,
        M.Cliente_FechaNacimiento,
        M.Cliente_Mail,
        M.Cliente_Direccion,
        M.Cliente_Telefono
    FROM gd_esquema.Maestra              AS M
    LEFT JOIN PROGRAMADORES_VIVIENTES.Provincia  AS P
           ON P.pcia_nombre = M.Cliente_Provincia
    LEFT JOIN PROGRAMADORES_VIVIENTES.Localidad  AS L
           ON L.loc_nombre    = M.Cliente_Localidad
          AND L.loc_provincia = P.pcia_id
    WHERE L.loc_id IS NOT NULL
      AND M.Cliente_Dni IS NOT NULL
      AND NOT EXISTS ( SELECT 1
                       FROM PROGRAMADORES_VIVIENTES.Cliente C
                       WHERE C.clie_dni = M.Cliente_Dni );
END;
GO


/* PEDIDO */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Pedido
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Pedido] (
		ped_numero,
		ped_sucursal,
		ped_cliente,
		ped_fecha,
		ped_estado,
		ped_total)
	SELECT DISTINCT
		Maestra.Pedido_Numero,
		Sucursal.suc_id,
		Cliente.clie_id,
		Maestra.Pedido_Fecha,
		Pedido_Estado.ped_est_id,
		Maestra.Pedido_Total 
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Sucursal] AS Sucursal ON Maestra.Sucursal_NroSucursal = Sucursal.suc_numero
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Cliente] AS Cliente ON Maestra.Cliente_Nombre = Cliente.clie_nombre
		AND Maestra.Cliente_Apellido = Cliente.clie_apellido
		AND Maestra.Cliente_Dni = Cliente.clie_dni
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Pedido_Estado] AS Pedido_Estado ON Maestra.Pedido_Estado = Pedido_Estado.ped_est_estado
	WHERE Maestra.Pedido_Numero IS NOT NULL
	AND Sucursal.suc_id IS NOT NULL
	AND Cliente.clie_id IS NOT NULL
	AND Pedido_Estado.ped_est_id IS NOT NULL
END
GO

/* PEDIDO_CANCELACION */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Pedido_Cancelacion
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Pedido_Cancelacion] (
		ped_canc_pedido,
		ped_canc_fecha,
		ped_canc_motivo)
	SELECT DISTINCT
		Pedido.ped_id,
		Maestra.Pedido_Cancelacion_Fecha,
		Maestra.Pedido_Cancelacion_Motivo 
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Pedido] AS Pedido ON Maestra.Pedido_Numero = Pedido.ped_numero
	WHERE Maestra.Pedido_Cancelacion_Fecha IS NOT NULL
	AND Maestra.Pedido_Cancelacion_Motivo IS NOT NULL
END
GO

/* DETALLE_PEDIDO */ 
--PREGUNTAR!! Hay filas que tienen codigo de pedido y datos de detalle pero no de sillon
--por ahora, se saco de la tabla que este campo no pueda ser nulo y en esta query no se hace ese filtro
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Detalle_Pedido
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Detalle_Pedido] (
		det_ped_pedido,
		det_ped_sillon,
		det_ped_cantidad,
		det_ped_precio_unitario,
		det_ped_subtotal)
	SELECT DISTINCT
		Pedido.ped_id,
		Sillon.sill_id,
		Maestra.Detalle_Pedido_Cantidad,
		Maestra.Detalle_Pedido_Precio,
		Maestra.Detalle_Pedido_SubTotal
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Pedido] AS Pedido ON Maestra.Pedido_Numero = Pedido.ped_numero
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Sillon] AS Sillon ON Maestra.Sillon_Codigo = Sillon.sill_codigo
	WHERE Maestra.Pedido_Numero IS NOT NULL
	AND Maestra.Detalle_Pedido_Cantidad IS NOT NULL
	AND Maestra.Detalle_Pedido_Precio IS NOT NULL
	AND Maestra.Detalle_Pedido_SubTotal IS NOT NULL
END
GO

/* FACTURA */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Factura
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Factura] (
		fact_numero,
		fact_sucursal,
		fact_cliente,
		fact_fecha,
		fact_total)
	SELECT DISTINCT
		Maestra.Factura_Numero,
		Sucursal.suc_id,
		Cliente.clie_id,
		Maestra.Factura_Fecha,
		Maestra.Factura_Total
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Sucursal] AS Sucursal ON Maestra.Sucursal_NroSucursal = Sucursal.suc_numero
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Cliente] AS Cliente ON Maestra.Cliente_Nombre = Cliente.clie_nombre
		AND Maestra.Cliente_Apellido = Cliente.clie_apellido
		AND Maestra.Cliente_Dni = Cliente.clie_dni
	WHERE Maestra.Factura_Numero IS NOT NULL
	AND Sucursal.suc_id IS NOT NULL
	AND Cliente.clie_id IS NOT NULL
END
GO

/* DETALLE_FACTURA */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Detalle_Factura
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Detalle_Factura] (
		det_fact_factura,
		det_fact_detalle_pedido)
	SELECT DISTINCT
		Factura.fact_id,
		Detalle_Pedido.det_ped_id
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Factura] AS Factura ON Maestra.Factura_Numero = Factura.fact_numero
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Pedido] AS Pedido ON Maestra.Pedido_Numero = Pedido.ped_numero
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Detalle_Pedido] AS Detalle_Pedido ON Pedido.ped_id = Detalle_Pedido.det_ped_pedido
	WHERE Maestra.Pedido_Numero IS NOT NULL
	AND Maestra.Detalle_Pedido_Cantidad IS NOT NULL
	AND Pedido.ped_id IS NOT NULL
	AND Detalle_Pedido.det_ped_id IS NOT NULL
	AND Factura.fact_id IS NOT NULL
END
GO


/* ENVIO */
CREATE PROCEDURE [PROGRAMADORES_VIVIENTES].Migrar_Envio
AS
BEGIN
	INSERT INTO [PROGRAMADORES_VIVIENTES].[Envio] (
		env_numero,
		env_factura,
		env_fecha_programada,
		env_fecha_entrega,
		env_traslado,
		env_subida,
		env_total)
	SELECT DISTINCT
		Maestra.Envio_Numero,
		Factura.fact_id,
		Maestra.Envio_Fecha_Programada,
		Maestra.Envio_Fecha,
		Maestra.Envio_ImporteTraslado,
		Maestra.Envio_importeSubida,
		Maestra.Envio_Total
	FROM gd_esquema.Maestra AS Maestra
	LEFT JOIN [PROGRAMADORES_VIVIENTES].[Factura] AS Factura ON Maestra.Factura_Numero = Factura.fact_numero
	WHERE Factura.fact_id IS NOT NULL
	AND Maestra.Envio_Numero IS NOT NULL
END
GO

/* EJECUCIONES */

PRINT '--- COMENZANDO LA MIGRACION DE DATOS ---'

/* Tablas primarias sin FK */
execute PROGRAMADORES_VIVIENTES.[Migrar_Provincia]
execute PROGRAMADORES_VIVIENTES.[Migrar_Pedido_Estado]
execute PROGRAMADORES_VIVIENTES.[Migrar_Material]
execute PROGRAMADORES_VIVIENTES.[Migrar_Sillon_Modelo]
execute PROGRAMADORES_VIVIENTES.[Migrar_Sillon_Medida]


/* Tablas con FK */
execute PROGRAMADORES_VIVIENTES.[Migrar_Localidad]
execute PROGRAMADORES_VIVIENTES.[Migrar_Tela]
execute PROGRAMADORES_VIVIENTES.[Migrar_Madera]
execute PROGRAMADORES_VIVIENTES.[Migrar_Relleno]
execute PROGRAMADORES_VIVIENTES.[Migrar_Sillon]
execute PROGRAMADORES_VIVIENTES.[Migrar_Material_Sillon]
execute PROGRAMADORES_VIVIENTES.[Migrar_Proveedor]
execute PROGRAMADORES_VIVIENTES.[Migrar_Sucursal]
execute PROGRAMADORES_VIVIENTES.[Migrar_Compra]
execute PROGRAMADORES_VIVIENTES.[Migrar_Detalle_Compra]
execute PROGRAMADORES_VIVIENTES.[Migrar_Cliente]
execute PROGRAMADORES_VIVIENTES.[Migrar_Pedido]
execute PROGRAMADORES_VIVIENTES.[Migrar_Pedido_Cancelacion]
execute PROGRAMADORES_VIVIENTES.[Migrar_Detalle_Pedido]
execute PROGRAMADORES_VIVIENTES.[Migrar_Factura]
execute PROGRAMADORES_VIVIENTES.[Migrar_Detalle_Factura]
execute PROGRAMADORES_VIVIENTES.[Migrar_Envio]


PRINT '--- TABLAS MIGRADAS CORRECTAMENTE ---'

/* CREACION DE INDICES */

PRINT '--- CREACION DE INDICES ---'

/* PROVINCIA */
CREATE INDEX IDX_PROVINCIA_ID ON [PROGRAMADORES_VIVIENTES].[Provincia] (pcia_id);

/* LOCALIDAD */
CREATE INDEX IDX_LOCALIDAD_ID ON [PROGRAMADORES_VIVIENTES].[Localidad] (loc_id);

/* CLIENTE */
CREATE INDEX IDX_CLIENTE_ID ON [PROGRAMADORES_VIVIENTES].[Cliente] (clie_id);

/* SUCURSAL */
CREATE INDEX IDX_SUCURSAL_ID ON [PROGRAMADORES_VIVIENTES].[Sucursal] (suc_id);

/* FACTURA */
CREATE INDEX IDX_FACTURA_ID ON [PROGRAMADORES_VIVIENTES].[Factura] (fact_id);

/* DETALLE_FACTURA */
CREATE INDEX IDX_DETALLE_FACTURA_ID ON [PROGRAMADORES_VIVIENTES].[Detalle_Factura] (det_fact_factura, det_fact_detalle_pedido);

/* ENVIO */
CREATE INDEX IDX_ENVIO_ID ON [PROGRAMADORES_VIVIENTES].[Envio] (env_id);

/* PEDIDO */
CREATE INDEX IDX_PEDIDO_ID ON [PROGRAMADORES_VIVIENTES].[Pedido] (ped_id);

/* PEDIDO_ESTADO */
CREATE INDEX IDX_PEDIDO_ESTADO_ID ON [PROGRAMADORES_VIVIENTES].[Pedido_Estado] (ped_est_id);

/* PEDIDO_CANCELACION */
CREATE INDEX IDX_PEDIDO_CANCELACION_ID ON [PROGRAMADORES_VIVIENTES].[Pedido_Cancelacion] (ped_canc_id);

/* DETALLE_PEDIDO */
CREATE INDEX IDX_DETALLE_PEDIDO_ID ON [PROGRAMADORES_VIVIENTES].[Detalle_Pedido] (det_ped_id);

/* COMPRA */
CREATE INDEX IDX_COMPRA_ID ON [PROGRAMADORES_VIVIENTES].[Compra] (comp_numero);

/* DETALLE_COMPRA */
CREATE INDEX IDX_DETALLE_COMPRA_ID ON [PROGRAMADORES_VIVIENTES].[Detalle_Compra] (det_comp_id);

/* PROVEEDOR */
CREATE INDEX IDX_PROVEEDOR_ID ON [PROGRAMADORES_VIVIENTES].[Proveedor] (prov_id);

/* SILLON_MODELO */
CREATE INDEX IDX_SILLON_MODELO_ID ON [PROGRAMADORES_VIVIENTES].[Sillon_Modelo] (sill_mod_id);

/* SILLON */
CREATE INDEX IDX_SILLON_ID ON [PROGRAMADORES_VIVIENTES].[Sillon] (sill_id);

/* SILLON_MEDIDA */
CREATE INDEX IDX_SILLON_MEDIDA_ID ON [PROGRAMADORES_VIVIENTES].[Sillon_Medida] (sill_med_id);

/* MATERIAL_SILLON */
CREATE INDEX IDX_MATERIAL_SILLON_ID ON [PROGRAMADORES_VIVIENTES].[Material_Sillon] (mat_sill_material, mat_sill_sillon);

/* MATERIAL */
CREATE INDEX IDX_MATERIAL_ID ON [PROGRAMADORES_VIVIENTES].[Material] (mat_id);

/* TELA */
CREATE INDEX IDX_TELA_ID ON [PROGRAMADORES_VIVIENTES].[Tela] (tela_material);

/* MADERA */
CREATE INDEX IDX_MADERA_ID ON [PROGRAMADORES_VIVIENTES].[Madera] (mad_material);

/* RELLENO */
CREATE INDEX IDX_RELLENO_ID ON [PROGRAMADORES_VIVIENTES].[Relleno] (rell_material);

PRINT '--- FINALIZACION DE EJECUCION ---'