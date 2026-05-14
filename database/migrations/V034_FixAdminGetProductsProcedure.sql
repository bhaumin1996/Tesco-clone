-- V034_FixAdminGetProductsProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-14
-- Description: Recreate proc_Admin_GetProducts with the correct @Search parameter name
--              (V031 renamed it to @SearchTerm, breaking the repository) and restore
--              all columns required by the AdminCatalogueRepository mapper:
--              CategoryId, BrandId, StockQuantity, CreatedOn, ModifiedOn.
-- Dependencies: V020, V031

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('proc_Admin_GetProducts', 'P') IS NOT NULL
        DROP PROCEDURE proc_Admin_GetProducts;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetProducts
-- =========================================================
CREATE PROCEDURE proc_Admin_GetProducts
    @Search       NVARCHAR(256) = NULL,
    @CategoryId   INT           = NULL,
    @DepartmentId INT           = NULL,
    @PageNumber   INT           = 1,
    @PageSize     INT           = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            p.Id,
            p.CategoryId,
            c.Name                                              AS CategoryName,
            p.BrandId,
            b.Name                                              AS BrandName,
            p.Name,
            p.Slug,
            p.Description,
            p.BasePrice,
            p.ClubcardPrice,
            p.ImageUrl,
            p.IsAvailable,
            ISNULL(pv.TotalStock, 0)                           AS StockQuantity,
            p.CreatedOn,
            p.ModifiedOn,
            COUNT(1) OVER ()                                   AS TotalCount
        FROM m.tblProduct p
        INNER JOIN m.tblCategory   c  ON c.Id  = p.CategoryId    AND c.IsDeleted = 0
        INNER JOIN m.tblDepartment d  ON d.Id  = c.DepartmentId  AND d.IsDeleted = 0
        LEFT  JOIN m.tblBrand      b  ON b.Id  = p.BrandId       AND b.IsDeleted = 0
        LEFT  JOIN (
            SELECT ProductId, SUM(StockQuantity) AS TotalStock
            FROM m.tblProductVariant
            WHERE IsDeleted = 0
            GROUP BY ProductId
        ) pv ON pv.ProductId = p.Id
        WHERE p.IsDeleted = 0
          AND (@Search       IS NULL OR p.Name LIKE '%' + @Search + '%' OR p.Slug LIKE '%' + @Search + '%')
          AND (@CategoryId   IS NULL OR p.CategoryId    = @CategoryId)
          AND (@DepartmentId IS NULL OR c.DepartmentId  = @DepartmentId)
        ORDER BY p.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetProducts', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V034')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V034', 'FixAdminGetProductsProcedure');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
