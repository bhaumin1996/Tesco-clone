-- V065_FixBannerTableLegacyColumns.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: Make legacy ValidFrom column in t.tblBanner nullable to fix INSERT failures
--              when creating banners via admin panel.
-- Dependencies: V011, V028

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Make ValidFrom nullable in t.tblBanner
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblBanner' 
               AND COLUMN_NAME = 'ValidFrom' AND IS_NULLABLE = 'NO')
    BEGIN
        ALTER TABLE t.tblBanner ALTER COLUMN ValidFrom DATETIME2 NULL;
        PRINT 'Column [t].[tblBanner].[ValidFrom] altered to allow NULLs.';
    END

    -- Also update proc_Admin_CreateBanner to sync legacy columns just in case
    IF OBJECT_ID('proc_Admin_CreateBanner', 'P') IS NOT NULL
    BEGIN
        EXEC('
        ALTER PROCEDURE proc_Admin_CreateBanner
            @Title        NVARCHAR(200),
            @SubTitle     NVARCHAR(300) = NULL,
            @ImageUrl     NVARCHAR(500) = NULL,
            @LinkUrl      NVARCHAR(500) = NULL,
            @DisplayOrder INT = 0,
            @IsActive     BIT = 1,
            @StartsAt     DATETIME2 = NULL,
            @EndsAt       DATETIME2 = NULL,
            @AdminId      INT
        AS
        BEGIN
            SET NOCOUNT ON;
            BEGIN TRY
                BEGIN TRANSACTION;

                DECLARE @BannerId INT;

                INSERT INTO t.tblBanner
                    (Title, SubTitle, ImageUrl, LinkUrl, DisplayOrder, IsActive,
                     StartsAt, EndsAt, ValidFrom, ValidTo, RecordStatusId, CreatedBy, CreatedOn)
                VALUES
                    (@Title, @SubTitle, @ImageUrl, @LinkUrl, @DisplayOrder, @IsActive,
                     @StartsAt, @EndsAt, @StartsAt, @EndsAt, 1, @AdminId, GETUTCDATE());

                SET @BannerId = SCOPE_IDENTITY();

                INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
                VALUES (''tblBanner'', @BannerId, ''INSERT'', CONCAT(''{"Title":"'', @Title, ''"}''), @AdminId, GETUTCDATE());

                COMMIT TRANSACTION;
                SELECT @BannerId;
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
                VALUES (''Error'', ''proc_Admin_CreateBanner'', ERROR_MESSAGE(), GETUTCDATE());
                THROW;
            END CATCH
        END
        ');
        PRINT 'Procedure [proc_Admin_CreateBanner] updated to sync legacy columns.';
    END

    -- Sync legacy columns in proc_Admin_UpdateBanner as well
    IF OBJECT_ID('proc_Admin_UpdateBanner', 'P') IS NOT NULL
    BEGIN
        EXEC('
        ALTER PROCEDURE proc_Admin_UpdateBanner
            @BannerId     INT,
            @Title        NVARCHAR(200),
            @SubTitle     NVARCHAR(300) = NULL,
            @ImageUrl     NVARCHAR(500) = NULL,
            @LinkUrl      NVARCHAR(500) = NULL,
            @DisplayOrder INT,
            @IsActive     BIT,
            @StartsAt     DATETIME2 = NULL,
            @EndsAt       DATETIME2 = NULL,
            @AdminId      INT
        AS
        BEGIN
            SET NOCOUNT ON;
            BEGIN TRY
                BEGIN TRANSACTION;

                UPDATE t.tblBanner
                SET Title        = @Title,
                    SubTitle     = @SubTitle,
                    ImageUrl     = @ImageUrl,
                    LinkUrl      = @LinkUrl,
                    DisplayOrder = @DisplayOrder,
                    IsActive     = @IsActive,
                    StartsAt     = @StartsAt,
                    EndsAt       = @EndsAt,
                    ValidFrom    = @StartsAt,
                    ValidTo      = @EndsAt,
                    ModifiedBy   = @AdminId,
                    ModifiedOn   = GETUTCDATE()
                WHERE Id = @BannerId AND IsDeleted = 0;

                INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
                VALUES (''tblBanner'', @BannerId, ''UPDATE'', CONCAT(''{"Title":"'', @Title, ''"}''), @AdminId, GETUTCDATE());

                COMMIT TRANSACTION;
            END TRY
            BEGIN CATCH
                IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
                INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
                VALUES (''Error'', ''proc_Admin_UpdateBanner'', ERROR_MESSAGE(), GETUTCDATE());
                THROW;
            END CATCH
        END
        ');
        PRINT 'Procedure [proc_Admin_UpdateBanner] updated to sync legacy columns.';
    END

    -- Record migration
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V065')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V065', 'FixBannerTableLegacyColumns');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
GO
