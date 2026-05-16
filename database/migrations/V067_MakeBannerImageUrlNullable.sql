-- V067_MakeBannerImageUrlNullable.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: Make ImageUrl column in t.tblBanner nullable to prevent UPDATE/INSERT failures.
-- Dependencies: V011, V028

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Make ImageUrl nullable in t.tblBanner
    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblBanner' 
               AND COLUMN_NAME = 'ImageUrl' AND IS_NULLABLE = 'NO')
    BEGIN
        ALTER TABLE t.tblBanner ALTER COLUMN ImageUrl NVARCHAR(500) NULL;
        PRINT 'Column [t].[tblBanner].[ImageUrl] altered to allow NULLs.';
    END

    -- Record migration
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V067')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V067', 'MakeBannerImageUrlNullable');

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
