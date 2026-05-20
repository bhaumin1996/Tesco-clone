-- V106_FixAdminGetSellerApplicationsProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Fix proc_Admin_GetSellerApplications to include RegistrationNumber, VatNumber, Description, BankDetailsRef, CategoryIds, and Website.
-- Dependencies: V105

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetSellerApplications', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellerApplications;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V106_DropProcedure', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- ─────────────────────────────────────────────────────────
-- Recreate: proc_Admin_GetSellerApplications
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Admin_GetSellerApplications
    @StatusFilter NVARCHAR(50) = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            a.Id,
            a.UserId,
            a.BusinessName,
            a.BusinessEmail,
            a.Phone,
            ast.Name AS StatusName,
            a.TsAndCsAccepted,
            a.ReviewNotes,
            a.ReviewedOn,
            a.CreatedOn,
            a.ModifiedOn,
            a.Website,
            a.RegistrationNumber,
            a.VatNumber,
            a.Description,
            a.BankDetailsRef,
            a.CategoryIds,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblSellerApplication a
        INNER JOIN m.tblApplicationStatus ast ON ast.Id = a.StatusId
        WHERE a.IsDeleted = 0
          AND (@StatusFilter IS NULL OR ast.Name = @StatusFilter)
        ORDER BY a.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetSellerApplications', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────────
-- Record migration in t.tblMigration
-- ─────────────────────────────────────────────────────────
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V106')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V106', 'FixAdminGetSellerApplicationsProcedure');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
