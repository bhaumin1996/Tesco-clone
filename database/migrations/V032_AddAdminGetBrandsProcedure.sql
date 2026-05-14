-- V032_AddAdminGetBrandsProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-14
-- Description: Add proc_Admin_GetBrands for brand dropdown in admin product form
-- Dependencies: V006 (m.tblBrand)

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetBrands', 'P') IS NOT NULL
        DROP PROCEDURE proc_Admin_GetBrands;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetBrands
-- =========================================================
CREATE PROCEDURE proc_Admin_GetBrands
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            Id   AS BrandId,
            Name
        FROM m.tblBrand
        WHERE IsDeleted = 0
        ORDER BY Name ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetBrands', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V032')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V032', 'AddAdminGetBrandsProcedure');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
