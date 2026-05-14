-- V030_UpdateGetCategoriesAddImageUrl.sql
-- Author: Tesco Clone
-- Date: 2026-05-14
-- Description: Add ImageUrl to proc_Admin_GetCategories result set
-- Dependencies: V027, V029

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('proc_Admin_GetCategories', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetCategories;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

CREATE PROCEDURE proc_Admin_GetCategories
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            c.Id            AS CategoryId,
            c.Name,
            c.Slug,
            c.ImageUrl,
            c.DepartmentId,
            d.Name          AS DepartmentName,
            COUNT(p.Id)     AS ProductCount,
            CAST(CASE WHEN c.RecordStatusId = 1 THEN 1 ELSE 0 END AS BIT) AS IsActive
        FROM m.tblCategory c
        INNER JOIN m.tblDepartment d ON d.Id = c.DepartmentId AND d.IsDeleted = 0
        LEFT  JOIN m.tblProduct   p ON p.CategoryId = c.Id AND p.IsDeleted = 0
        WHERE c.IsDeleted = 0
        GROUP BY c.Id, c.Name, c.Slug, c.ImageUrl, c.DepartmentId, d.Name, c.RecordStatusId
        ORDER BY d.Name, c.Name;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetCategories', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO
