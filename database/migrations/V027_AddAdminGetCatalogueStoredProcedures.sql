-- V027_AddAdminGetCatalogueStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-14
-- Description: Add proc_Admin_GetCategories and proc_Admin_GetDepartments for admin catalogue API
-- Dependencies: V001-V020

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('proc_Admin_GetCategories',  'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetCategories;
    IF OBJECT_ID('proc_Admin_GetDepartments', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetDepartments;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetCategories
-- Returns all non-deleted categories with department name
-- and a product count for admin management.
-- =========================================================
CREATE PROCEDURE proc_Admin_GetCategories
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            c.Id            AS CategoryId,
            c.Name,
            c.Slug,
            d.Name          AS DepartmentName,
            COUNT(p.Id)     AS ProductCount,
            CAST(CASE WHEN c.RecordStatusId = 1 THEN 1 ELSE 0 END AS BIT) AS IsActive
        FROM m.tblCategory c
        INNER JOIN m.tblDepartment d ON d.Id = c.DepartmentId AND d.IsDeleted = 0
        LEFT  JOIN m.tblProduct   p ON p.CategoryId = c.Id AND p.IsDeleted = 0
        WHERE c.IsDeleted = 0
        GROUP BY c.Id, c.Name, c.Slug, d.Name, c.RecordStatusId
        ORDER BY d.Name, c.Name;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetCategories', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetDepartments
-- Returns all non-deleted departments for admin dropdowns
-- and management views.
-- =========================================================
CREATE PROCEDURE proc_Admin_GetDepartments
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            d.Id   AS DepartmentId,
            d.Name
        FROM m.tblDepartment d
        WHERE d.IsDeleted = 0
        ORDER BY d.DisplayOrder, d.Name;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetDepartments', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V027')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V027', 'AddAdminGetCatalogueStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
