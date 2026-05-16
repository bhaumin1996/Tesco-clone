-- V066_AddAdminGetBannerByIdProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: Add missing proc_Admin_GetBannerById stored procedure.
-- Dependencies: V011, V028

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- 1. Drop existing procedure
IF OBJECT_ID('proc_Admin_GetBannerById', 'P') IS NOT NULL 
    DROP PROCEDURE proc_Admin_GetBannerById;
GO

-- 2. Create the procedure
CREATE PROCEDURE proc_Admin_GetBannerById
    @BannerId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, Title, SubTitle, ImageUrl, LinkUrl, DisplayOrder, IsActive, StartsAt, EndsAt, CreatedOn, ModifiedOn
        FROM t.tblBanner
        WHERE Id = @BannerId AND IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetBannerById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- 3. Record migration
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V066')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V066', 'AddAdminGetBannerByIdProcedure');
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
