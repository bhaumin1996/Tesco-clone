-- V011_CreateContentTables.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create CMS content tables: tblPage, tblBanner, tblRecipe, tblFaq
-- Dependencies: V001-V010

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblPage')
    BEGIN
        CREATE TABLE t.tblPage (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Title          NVARCHAR(500) NOT NULL,
            Slug           NVARCHAR(500) NOT NULL,
            Content        NVARCHAR(MAX) NOT NULL,
            MetaTitle      NVARCHAR(200) NULL,
            MetaDescription NVARCHAR(500) NULL,
            IsPublished    BIT NOT NULL DEFAULT 0,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblPage_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE UNIQUE INDEX IX_tblPage_Slug ON t.tblPage (Slug) WHERE IsDeleted = 0;
        PRINT 'Table [t].[tblPage] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblBanner')
    BEGIN
        CREATE TABLE t.tblBanner (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Title          NVARCHAR(200) NOT NULL,
            ImageUrl       NVARCHAR(500) NOT NULL,
            LinkUrl        NVARCHAR(500) NULL,
            DisplayOrder   INT NOT NULL DEFAULT 0,
            ValidFrom      DATETIME2 NOT NULL,
            ValidTo        DATETIME2 NULL,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblBanner_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        PRINT 'Table [t].[tblBanner] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblFaq')
    BEGIN
        CREATE TABLE t.tblFaq (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Question       NVARCHAR(1000) NOT NULL,
            Answer         NVARCHAR(MAX) NOT NULL,
            DisplayOrder   INT NOT NULL DEFAULT 0,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblFaq_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        PRINT 'Table [t].[tblFaq] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V011')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V011', 'CreateContentTables');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
