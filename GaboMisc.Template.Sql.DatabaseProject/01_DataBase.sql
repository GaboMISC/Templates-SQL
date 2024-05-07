/* ********** Creacion de la BD ********** */
-- ======================================================
-- Base de Datos
-- ======================================================
SET NOCOUNT ON; -- Desactiva los Mensajes
USE master;
GO -- Base de Datos
IF EXISTS(SELECT * FROM SYS.DATABASES WHERE NAME='InsurancePolicy') -- Base de Datos
	BEGIN
		-- Si Existe

		-- Configura la base de datos en modo de usuario único
		--ALTER DATABASE InsurancePolicy SET SINGLE_USER WITH ROLLBACK IMMEDIATE; -- Cierra todas las conexiones

		DROP DATABASE InsurancePolicy;
		CREATE DATABASE InsurancePolicy;

		-- Vuelve a configurar la base de datos en modo multiusuario
		--ALTER DATABASE InsurancePolicy SET MULTI_USER;
		PRINT 'Se elimino y creo la base de datos';
	END
ELSE
	BEGIN
		-- No Existe
		CREATE DATABASE InsurancePolicy;
		PRINT 'Se creo la base de datos';
	END
GO
-- ======================================================
-- Esquemas
-- ======================================================
-- Cambio de Base de Datos
USE InsurancePolicy;
GO -- Esquema de Tablas
IF EXISTS(SELECT * FROM sys.schemas WITH(NOLOCK) WHERE name = 'ope')
	BEGIN
		-- Si Existe
		DROP SCHEMA ope;
		PRINT 'Se elimino el esquema';
	END
GO
	CREATE SCHEMA ope;
	GO
	PRINT 'Se creo el esquema';
GO
IF EXISTS(SELECT * FROM sys.schemas WITH(NOLOCK) WHERE name = 'adm')
	BEGIN
		-- Si Existe
		DROP SCHEMA adm;
		PRINT 'Se elimino el esquema';
	END
GO
	CREATE SCHEMA adm;
	GO
	PRINT 'Se creo el esquema';