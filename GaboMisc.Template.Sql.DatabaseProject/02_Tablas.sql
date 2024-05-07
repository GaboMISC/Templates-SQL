-- ======================================================
-- Tablas
-- ======================================================
USE [InsurancePolicy];
GO
-------------------------------------------------- Tabla --------------------------------------------------
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.TABLES WITH(NOLOCK) WHERE TABLE_NAME = 'Ramo' AND TABLE_SCHEMA = 'adm')
	BEGIN
		DROP TABLE [InsurancePolicy].[adm].[Ramo];
		PRINT 'Se elimino la tabla';
	END
GO
	CREATE TABLE [adm].[Ramo]
	(
		RamoId INT NOT NULL,
		Nombre VARCHAR(50) NULL,
		Abreviatura VARCHAR(50) NULL,
		Departamento INT NOT NULL
	);
	PRINT 'Se crea la tabla';
GO -- Contraints Tabla
	ALTER TABLE [adm].[Ramo]
		ADD CONSTRAINT PK_Ramo_RamoId PRIMARY KEY CLUSTERED (RamoId ASC);
	ALTER TABLE [adm].[Ramo]
		ADD CONSTRAINT FK_Departamento_Ramo_Departamento FOREIGN KEY (Departamento) REFERENCES [InsurancePolicy].[adm].[Departamento] (DepartamentoId);
	PRINT 'Se crean los contraints de la tabla';
GO -- Indices Tabla
	CREATE NONCLUSTERED INDEX IXNC_Ramo_Abreviatura ON [InsurancePolicy].[adm].[Ramo] (Abreviatura ASC);
	CREATE NONCLUSTERED INDEX IXNC_Ramo_Departamento ON [InsurancePolicy].[adm].[Ramo] (Departamento ASC);
	PRINT 'Se crean los indices de la tabla';