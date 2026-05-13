-- V002_CreateMigrationTable.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create migration tracking table
-- Dependencies: V001

BEGIN TRY
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblMigration')
    BEGIN
        CREATE TABLE t.tblMigration (
            Id          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Version     VARCHAR(20) NOT NULL,
            Description NVARCHAR(500) NOT NULL,
            AppliedOn   DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            AppliedBy   NVARCHAR(128) NOT NULL DEFAULT SYSTEM_USER
        );
        CREATE UNIQUE INDEX IX_tblMigration_Version ON t.tblMigration (Version);
        PRINT 'Table [t].[tblMigration] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V001')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V001', 'CreateSchemas');

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V002')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V002', 'CreateMigrationTable');
END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
