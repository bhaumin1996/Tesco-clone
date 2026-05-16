-- V061_AddCreatedOnToCategoriesAndDynamicSortToProducts.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: (1) Add CreatedOn to proc_Admin_GetCategories result set and order newest first.
--              (2) Add @SortBy / @SortDirection parameters to proc_Admin_GetProducts so the
--                  admin UI can sort any column; defaults to createdOn DESC.
-- Dependencies: V030, V034

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- Drop existing procedures
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('proc_Admin_GetCategories', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetCategories;
    IF OBJECT_ID('proc_Admin_GetProducts',   'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetProducts;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetCategories
-- Returns all non-deleted categories with product count,
-- department name, image URL, and CreatedOn.
-- Ordered newest first.
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
            c.ImageUrl,
            c.DepartmentId,
            d.Name          AS DepartmentName,
            COUNT(p.Id)     AS ProductCount,
            CAST(CASE WHEN c.RecordStatusId = 1 THEN 1 ELSE 0 END AS BIT) AS IsActive,
            c.CreatedOn
        FROM m.tblCategory c
        INNER JOIN m.tblDepartment d ON d.Id = c.DepartmentId AND d.IsDeleted = 0
        LEFT  JOIN m.tblProduct   p ON p.CategoryId = c.Id AND p.IsDeleted = 0
        WHERE c.IsDeleted = 0
        GROUP BY c.Id, c.Name, c.Slug, c.ImageUrl, c.DepartmentId, d.Name, c.RecordStatusId, c.CreatedOn
        ORDER BY c.CreatedOn DESC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetCategories', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetProducts
-- Paginated admin product list with dynamic column sorting.
-- @SortBy accepts: createdOn, name, categoryName, brandName,
--                  basePrice, stockQuantity, isAvailable
-- @SortDirection accepts: asc, desc
-- =========================================================
CREATE PROCEDURE proc_Admin_GetProducts
    @Search         NVARCHAR(256) = NULL,
    @CategoryId     INT           = NULL,
    @DepartmentId   INT           = NULL,
    @PageNumber     INT           = 1,
    @PageSize       INT           = 20,
    @SortBy         NVARCHAR(50)  = 'createdOn',
    @SortDirection  NVARCHAR(4)   = 'desc'
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
        INNER JOIN m.tblCategory   c  ON c.Id  = p.CategoryId   AND c.IsDeleted = 0
        INNER JOIN m.tblDepartment d  ON d.Id  = c.DepartmentId AND d.IsDeleted = 0
        LEFT  JOIN m.tblBrand      b  ON b.Id  = p.BrandId      AND b.IsDeleted = 0
        LEFT  JOIN (
            SELECT ProductId, SUM(StockQuantity) AS TotalStock
            FROM m.tblProductVariant
            WHERE IsDeleted = 0
            GROUP BY ProductId
        ) pv ON pv.ProductId = p.Id
        WHERE p.IsDeleted = 0
          AND (@Search       IS NULL OR p.Name LIKE '%' + @Search + '%' OR p.Slug LIKE '%' + @Search + '%')
          AND (@CategoryId   IS NULL OR p.CategoryId   = @CategoryId)
          AND (@DepartmentId IS NULL OR c.DepartmentId = @DepartmentId)
        ORDER BY
            -- name
            CASE WHEN @SortBy = 'name'          AND @SortDirection = 'asc'  THEN p.Name     END ASC,
            CASE WHEN @SortBy = 'name'          AND @SortDirection = 'desc' THEN p.Name     END DESC,
            -- categoryName
            CASE WHEN @SortBy = 'categoryName'  AND @SortDirection = 'asc'  THEN c.Name     END ASC,
            CASE WHEN @SortBy = 'categoryName'  AND @SortDirection = 'desc' THEN c.Name     END DESC,
            -- brandName
            CASE WHEN @SortBy = 'brandName'     AND @SortDirection = 'asc'  THEN b.Name     END ASC,
            CASE WHEN @SortBy = 'brandName'     AND @SortDirection = 'desc' THEN b.Name     END DESC,
            -- basePrice
            CASE WHEN @SortBy = 'basePrice'     AND @SortDirection = 'asc'  THEN p.BasePrice  END ASC,
            CASE WHEN @SortBy = 'basePrice'     AND @SortDirection = 'desc' THEN p.BasePrice  END DESC,
            -- isAvailable
            CASE WHEN @SortBy = 'isAvailable'   AND @SortDirection = 'asc'  THEN CAST(p.IsAvailable AS TINYINT) END ASC,
            CASE WHEN @SortBy = 'isAvailable'   AND @SortDirection = 'desc' THEN CAST(p.IsAvailable AS TINYINT) END DESC,
            -- stockQuantity
            CASE WHEN @SortBy = 'stockQuantity' AND @SortDirection = 'asc'  THEN ISNULL(pv.TotalStock, 0) END ASC,
            CASE WHEN @SortBy = 'stockQuantity' AND @SortDirection = 'desc' THEN ISNULL(pv.TotalStock, 0) END DESC,
            -- createdOn (default)
            CASE WHEN @SortBy = 'createdOn'     AND @SortDirection = 'asc'  THEN p.CreatedOn  END ASC,
            CASE WHEN @SortBy = 'createdOn'     AND @SortDirection = 'desc' THEN p.CreatedOn  END DESC,
            -- tiebreaker when sort column is not createdOn
            CASE WHEN @SortBy <> 'createdOn' THEN p.CreatedOn END DESC
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
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V061')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V061', 'AddCreatedOnToCategoriesAndDynamicSortToProducts');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
