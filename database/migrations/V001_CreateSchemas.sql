-- V001_CreateSchemas.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create m (master/reference) and t (transactional/audit) schemas
-- Dependencies: none

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'm')
    BEGIN
        EXEC('CREATE SCHEMA m');
        PRINT 'Schema [m] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 't')
    BEGIN
        EXEC('CREATE SCHEMA t');
        PRINT 'Schema [t] created.';
    END
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
