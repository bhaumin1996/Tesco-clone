-- V004_CreateReferenceData.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create reference/master lookup tables (RecordStatus, Role)
-- Dependencies: V001, V002, V003

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblRecordStatus')
    BEGIN
        CREATE TABLE m.tblRecordStatus (
            Id   TINYINT NOT NULL PRIMARY KEY,
            Name NVARCHAR(50) NOT NULL
        );
        INSERT INTO m.tblRecordStatus (Id, Name) VALUES
            (1, 'Active'),
            (2, 'Inactive'),
            (3, 'Deleted');
        PRINT 'Table [m].[tblRecordStatus] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblRole')
    BEGIN
        CREATE TABLE m.tblRole (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Name           NVARCHAR(100) NOT NULL,
            Description    NVARCHAR(500) NULL,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL DEFAULT 1,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblRole_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE UNIQUE INDEX IX_tblRole_Name ON m.tblRole (Name) WHERE IsDeleted = 0;
        INSERT INTO m.tblRole (Name, Description, CreatedBy) VALUES
            ('Admin', 'Full system administrator', 1),
            ('Customer', 'Standard customer account', 1),
            ('Seller', 'Marketplace seller', 1);
        PRINT 'Table [m].[tblRole] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V004')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V004', 'CreateReferenceData');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
