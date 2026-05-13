-- V003_CreateAuditAndLogTables.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create tblAuditLog and tblLog tables used by all stored procedures
-- Dependencies: V001, V002

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblAuditLog')
    BEGIN
        CREATE TABLE t.tblAuditLog (
            Id           BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            TableName    NVARCHAR(128) NOT NULL,
            RecordId     INT NOT NULL,
            Action       NVARCHAR(20) NOT NULL,    -- INSERT, UPDATE, SOFT_DELETE
            OldValues    NVARCHAR(MAX) NULL,
            NewValues    NVARCHAR(MAX) NULL,
            ChangedBy    INT NOT NULL,
            ChangedOn    DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            CorrelationId NVARCHAR(64) NULL
        );
        CREATE INDEX IX_tblAuditLog_TableName_RecordId ON t.tblAuditLog (TableName, RecordId);
        CREATE INDEX IX_tblAuditLog_ChangedOn ON t.tblAuditLog (ChangedOn);
        PRINT 'Table [t].[tblAuditLog] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblLog')
    BEGIN
        CREATE TABLE t.tblLog (
            Id          BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Level       NVARCHAR(20) NOT NULL,     -- Information, Warning, Error, Critical
            Source      NVARCHAR(256) NOT NULL,
            Message     NVARCHAR(MAX) NOT NULL,
            Exception   NVARCHAR(MAX) NULL,
            UserId      INT NULL,
            LoggedOn    DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            CorrelationId NVARCHAR(64) NULL
        );
        CREATE INDEX IX_tblLog_Level_LoggedOn ON t.tblLog (Level, LoggedOn);
        PRINT 'Table [t].[tblLog] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V003')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V003', 'CreateAuditAndLogTables');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
