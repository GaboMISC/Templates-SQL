USE [InsurancePolicy];
GO
-- ======================================================
-- Descripción: Administración de Pólizas.
-- 2024-02-22 GMartinez: Creación del Stored Procedure.
-- 2024-04-11 GMartinez: Generación de las consultas para las opciones 2, 3, 4, 5, 6 y 7.
-- ======================================================
CREATE OR ALTER PROCEDURE [ope].[pInsuranceManagement]
(
    @Opcion INT,
    @LineaNegocio VARCHAR(100) = NULL,
    @IdPolizas VARCHAR(100) = NULL,
    @IdStatus INT = NULL,
    @IdGrupo INT = NULL,
    @IdPoliza INT = NULL,
    @NumPoliza VARCHAR(100) = NULL,
    @Contratante VARCHAR(100) = NULL,
    @EstatusPol INT = NULL,
    @IdAseguradora INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CodigoError INT = 0;
    DECLARE @MensajeError VARCHAR(2048) = '';

    BEGIN TRY
        SET @CodigoError = 0;
        SET @MensajeError = '';

        IF (@Opcion = 1) -- ObtenerPolizasEmpleado
        BEGIN
            SELECT S.IDDocto AS IdDocto,
                   S.Documento,
                   S.Contratante,
                   S.PrimaNeta,
                   M.Sufijo,
                   R.RamoId AS IdRamo,
                   R.Nombre AS NombreRamo,
                   S.[Status],
                   S.StatusDescripcion
            FROM
            (
                SELECT S.PolicyInfoId,
                       S.IDDocto AS IdDocto,
                       S.Documento,
                       S.NombreCompleto AS Contratante,
                       S.PrimaNeta,
                       S.Moneda,
                       S.RamosNombre,
                       S.DeptosNombre,
                       S.[Status],
                       S.Status_TXT AS StatusDescripcion
                FROM [InsurancePolicy].[ope].[PolicyInfo] AS S WITH (NOLOCK)
                WHERE S.LBussinesNombre = @LineaNegocio
                      AND S.IDDocto IN (
                                           SELECT value FROM STRING_SPLIT(@IdPolizas, ',')
                                       )
                      AND (
                              @IdStatus IS NULL
                              OR S.[Status] = @IdStatus
                          ) -- Opcional
            ) AS S
                INNER JOIN [InsurancePolicy].[adm].[Ramo] AS R WITH (NOLOCK)
                    ON R.Nombre = S.RamosNombre
                INNER JOIN [InsurancePolicy].[adm].[Moneda] AS M WITH (NOLOCK)
                    ON M.Moneda = S.Moneda
                INNER JOIN [InsurancePolicy].[adm].[Departamento] AS DP WITH (NOLOCK)
                    ON DP.Nombre = S.DeptosNombre
            WHERE R.Nombre = S.RamosNombre
                  AND R.Departamento = DP.DepartamentoId;
        END;

        IF (@Opcion = 2) -- AseguradosPol
        BEGIN
            SELECT S.IDDocto AS IdDocto,
                   S.Documento,
                   A.IDCont AS IdAseguradora,
                   A.CiaAbreviacion AS Aseguradora,
                   S.IdContratante,
                   S.Contratante,
                   S.IDGrupo AS IdSubGrupo,
                   S.Grupo AS SubGrupo,
                   R.RamoId AS IdRamo,
                   R.Nombre AS NombreRamo,
                   S.[Status],
                   S.StatusDescripcion,
                   M.MonedaId AS IdMoneda,
                   M.Prefijo
            FROM
            (
                SELECT S.PolicyInfoId,
                       S.IDDocto AS IdDocto,
                       S.Documento,
                       S.CiaAbreviacion,
                       S.IDCli AS IdContratante,
                       S.NombreCompleto AS Contratante,
                       G.IDGrupo,
                       G.Grupo,
                       S.RamosNombre,
                       S.DeptosNombre,
                       S.[Status],
                       S.Status_TXT AS StatusDescripcion,
                       S.Moneda
                FROM [InsurancePolicy].[ope].[PolicyInfo] AS S WITH (NOLOCK)
                    INNER JOIN [InsurancePolicy].[adm].[Grupo] AS G WITH (NOLOCK)
                        ON IDGrupo = @IdGrupo
                WHERE S.LBussinesNombre = @LineaNegocio
                      AND (
                              @IdPoliza IS NULL
                              OR S.IDDocto = @IdPoliza
                          ) -- Opcional
            ) AS S
                INNER JOIN [InsurancePolicy].[adm].[Ramo] AS R WITH (NOLOCK)
                    ON R.Nombre = S.RamosNombre
                INNER JOIN [InsurancePolicy].[adm].[Moneda] AS M WITH (NOLOCK)
                    ON M.Moneda = S.Moneda
                INNER JOIN [InsurancePolicy].[adm].[Departamento] AS DP WITH (NOLOCK)
                    ON DP.Nombre = S.DeptosNombre
                INNER JOIN [InsurancePolicy].[adm].[Aseguradora] AS A WITH (NOLOCK)
                    ON A.CiaAbreviacion = S.CiaAbreviacion
            WHERE R.Nombre = S.RamosNombre
                  AND R.Departamento = DP.DepartamentoId;
        END;

        IF (@Opcion = 3) -- Solicitudes
        BEGIN
            SELECT S.IDDocto AS IdPoliza,
                   S.IDCli AS IdContratante,
                   S.NombreCompleto AS Contratante
            FROM [InsurancePolicy].[ope].[PolicyInfo] AS S WITH (NOLOCK)
                INNER JOIN [InsurancePolicy].[adm].[Grupo] AS G WITH (NOLOCK)
                    ON G.IDGrupo = @IdGrupo
            WHERE S.LBussinesNombre = @LineaNegocio;
        END;

        IF (@Opcion = 4) -- SolicBajaAseg_ValidarAsegCore
        BEGIN
            SELECT S.IDDocto AS IdPoliza,
                   s.FDesde,
                   s.FHasta
            FROM [InsurancePolicy].[ope].[PolicyInfo] AS S WITH (NOLOCK)
            WHERE S.IDDocto = @IdPoliza;
        END;

        IF (@Opcion = 5) -- SolEndoso_CalcularPrimas
        BEGIN
            SELECT S.IDDocto AS IdPoliza,
                   s.PrimaNeta
            FROM [InsurancePolicy].[ope].[PolicyInfo] AS S WITH (NOLOCK)
            WHERE S.IDDocto = @IdPoliza;
        END;

        IF (@Opcion = 6) -- SelectorPolPolizas
        BEGIN
            SELECT S.IDDocto AS IdDocto,
                   S.Documento,
                   S.FDesde,
                   S.FHasta,
                   A.IDCont AS IdAseguradora,
                   A.CiaAbreviacion AS Aseguradora,
                   S.IDCli AS IdContratante,
                   S.NombreCompleto AS Contratante,
                   G.IDGrupo AS IdSubGrupo,
                   G.Grupo AS SubGrupo,
                   R.RamoId AS IdRamo,
                   R.Nombre AS NombreRamo,
                   S.[Status],
                   S.Status_TXT AS StatusDescripcion,
                   FP.IDFPago AS IdFPago,
                   FP.FPago AS DescFPago
            FROM [InsurancePolicy].[ope].[PolicyInfo] AS S WITH (NOLOCK)
                INNER JOIN [InsurancePolicy].[adm].[Grupo] AS G WITH (NOLOCK)
                    ON G.GrupoSinComas = S.GrupoSinComas
                INNER JOIN [InsurancePolicy].[adm].[Ramo] AS R WITH (NOLOCK)
                    ON R.Nombre = S.RamosNombre
                INNER JOIN [InsurancePolicy].[adm].[Departamento] AS DP WITH (NOLOCK)
                    ON DP.Nombre = S.DeptosNombre
                INNER JOIN [InsurancePolicy].[adm].[Aseguradora] AS A WITH (NOLOCK)
                    ON A.CiaAbreviacion = S.CiaAbreviacion
                INNER JOIN [InsurancePolicy].[adm].[FormaDePago] AS FP WITH (NOLOCK)
                    ON FP.FPago = S.FPago
            WHERE S.LBussinesNombre = @LineaNegocio
                  AND (
                          @IdPoliza IS NULL
                          OR S.IDDocto = @IdPoliza
                      ) -- Opcional
                  AND (
                          @NumPoliza IS NULL
                          OR S.Documento = @NumPoliza
                      ) -- Opcional
                  AND (
                          @Contratante IS NULL
                          OR S.NombreCompleto LIKE '%' + @Contratante + '%'
                      ) -- Opcional
                  AND (
                          @EstatusPol IS NULL
                          OR S.[Status] = @EstatusPol
                      ) -- Opcional
                  AND (
                          @IdAseguradora IS NULL
                          OR A.IDCont = @IdAseguradora
                      ) -- Opcional
                  AND R.Nombre = S.RamosNombre
                  AND R.Departamento = DP.DepartamentoId;
        END;

        IF (@Opcion = 7) -- RecuperarMovtoPolizasSelector
        BEGIN
            SELECT S.IDDocto AS IdDocto,
                   S.Documento,
                   S.Contratante,
                   S.PrimaNeta,
                   M.Sufijo,
                   R.RamoId AS IdRamo,
                   S.[Status],
                   S.StatusDescripcion
            FROM
            (
                SELECT S.PolicyInfoId,
                       S.IDDocto AS IdDocto,
                       S.Documento,
                       S.NombreCompleto AS Contratante,
                       S.PrimaNeta,
                       S.Moneda,
                       S.RamosNombre,
                       S.DeptosNombre,
                       S.[Status],
                       S.Status_TXT AS StatusDescripcion
                FROM [InsurancePolicy].[ope].[PolicyInfo] AS S WITH (NOLOCK)
                WHERE S.LBussinesNombre = @LineaNegocio
                      AND S.IDDocto IN (
                                           SELECT value FROM STRING_SPLIT(@IdPolizas, ',')
                                       )
            ) AS S
                INNER JOIN [InsurancePolicy].[adm].[Ramo] AS R WITH (NOLOCK)
                    ON R.Nombre = S.RamosNombre
                INNER JOIN [InsurancePolicy].[adm].[Moneda] AS M WITH (NOLOCK)
                    ON M.Moneda = S.Moneda
                INNER JOIN [InsurancePolicy].[adm].[Departamento] AS DP WITH (NOLOCK)
                    ON DP.Nombre = S.DeptosNombre
            WHERE R.Nombre = S.RamosNombre
                  AND R.Departamento = DP.DepartamentoId;
        END;
    END TRY
    BEGIN CATCH
        -- Obtiene el error
        SET @CodigoError = ERROR_NUMBER();
        SET @MensajeError = ERROR_MESSAGE();

        SELECT @CodigoError AS CodigoError,
               @MensajeError AS MensajeError;
    END CATCH;
END;