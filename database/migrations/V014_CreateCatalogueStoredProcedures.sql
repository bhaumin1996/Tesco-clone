-- V014_CreateCatalogueStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Create stored procedures for the Catalogue module
-- Dependencies: V001-V006

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Catalogue_GetDepartments',      'P') IS NOT NULL DROP PROCEDURE proc_Catalogue_GetDepartments;
    IF OBJECT_ID('proc_Catalogue_GetDepartmentById',   'P') IS NOT NULL DROP PROCEDURE proc_Catalogue_GetDepartmentById;
    IF OBJECT_ID('proc_Catalogue_GetCategories',       'P') IS NOT NULL DROP PROCEDURE proc_Catalogue_GetCategories;
    IF OBJECT_ID('proc_Catalogue_GetCategoryById',     'P') IS NOT NULL DROP PROCEDURE proc_Catalogue_GetCategoryById;
    IF OBJECT_ID('proc_Catalogue_GetProductById',      'P') IS NOT NULL DROP PROCEDURE proc_Catalogue_GetProductById;
    IF OBJECT_ID('proc_Catalogue_GetProductVariants',  'P') IS NOT NULL DROP PROCEDURE proc_Catalogue_GetProductVariants;
    IF OBJECT_ID('proc_Catalogue_SearchProducts',      'P') IS NOT NULL DROP PROCEDURE proc_Catalogue_SearchProducts;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Catalogue_GetDepartments
-- =========================================================
CREATE PROCEDURE proc_Catalogue_GetDepartments
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, Name, Slug, ImageUrl, DisplayOrder
        FROM m.tblDepartment
        WHERE IsDeleted = 0
          AND RecordStatusId = 1
        ORDER BY DisplayOrder, Name;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetDepartments', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Catalogue_GetDepartmentById
-- =========================================================
CREATE PROCEDURE proc_Catalogue_GetDepartmentById
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, Name, Slug, ImageUrl, DisplayOrder
        FROM m.tblDepartment
        WHERE Id = @DepartmentId
          AND IsDeleted = 0
          AND RecordStatusId = 1;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetDepartmentById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Catalogue_GetCategories
-- =========================================================
CREATE PROCEDURE proc_Catalogue_GetCategories
    @DepartmentId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, DepartmentId, ParentCategoryId, Name, Slug, ImageUrl
        FROM m.tblCategory
        WHERE IsDeleted = 0
          AND RecordStatusId = 1
          AND (@DepartmentId IS NULL OR DepartmentId = @DepartmentId)
        ORDER BY DisplayOrder, Name;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetCategories', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Catalogue_GetCategoryById
-- =========================================================
CREATE PROCEDURE proc_Catalogue_GetCategoryById
    @CategoryId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, DepartmentId, ParentCategoryId, Name, Slug, ImageUrl
        FROM m.tblCategory
        WHERE Id = @CategoryId
          AND IsDeleted = 0
          AND RecordStatusId = 1;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetCategoryById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Catalogue_GetProductById
-- =========================================================
CREATE PROCEDURE proc_Catalogue_GetProductById
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            p.Id,
            p.CategoryId,
            c.Name  AS CategoryName,
            p.BrandId,
            b.Name  AS BrandName,
            p.Name,
            p.Slug,
            p.Description,
            p.BasePrice,
            p.ClubcardPrice,
            p.ImageUrl,
            p.IsAvailable
        FROM m.tblProduct p
        INNER JOIN m.tblCategory c ON c.Id = p.CategoryId
        LEFT  JOIN m.tblBrand   b ON b.Id = p.BrandId
        WHERE p.Id = @ProductId
          AND p.IsDeleted = 0
          AND p.RecordStatusId = 1;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetProductById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Catalogue_GetProductVariants
-- =========================================================
CREATE PROCEDURE proc_Catalogue_GetProductVariants
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            v.Id,
            v.Sku,
            v.VariantName,
            v.PriceModifier,
            v.StockQuantity,
            CAST(CASE WHEN v.StockQuantity > 0 THEN 1 ELSE 0 END AS BIT) AS IsInStock
        FROM m.tblProductVariant v
        WHERE v.ProductId = @ProductId
          AND v.IsDeleted = 0
          AND v.RecordStatusId = 1
        ORDER BY v.Id;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetProductVariants', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Catalogue_SearchProducts
-- Full-text style search with filters and pagination
-- =========================================================
CREATE PROCEDURE proc_Catalogue_SearchProducts
    @SearchTerm    NVARCHAR(200) = NULL,
    @CategoryId    INT           = NULL,
    @BrandId       INT           = NULL,
    @MinPrice      DECIMAL(10,2) = NULL,
    @MaxPrice      DECIMAL(10,2) = NULL,
    @InStockOnly   BIT           = NULL,
    @SortBy        NVARCHAR(50)  = 'relevance',
    @SortDirection NVARCHAR(4)   = 'asc',
    @PageNumber    INT           = 1,
    @PageSize      INT           = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            p.Id,
            p.CategoryId,
            c.Name  AS CategoryName,
            p.BrandId,
            b.Name  AS BrandName,
            p.Name,
            p.Slug,
            p.Description,
            p.BasePrice,
            p.ClubcardPrice,
            p.ImageUrl,
            p.IsAvailable,
            COUNT(1) OVER () AS TotalCount
        FROM m.tblProduct p
        INNER JOIN m.tblCategory  c ON c.Id = p.CategoryId
        LEFT  JOIN m.tblBrand     b ON b.Id = p.BrandId
        LEFT  JOIN m.tblProductVariant v ON v.ProductId = p.Id AND v.IsDeleted = 0
        WHERE p.IsDeleted = 0
          AND p.RecordStatusId = 1
          AND p.IsAvailable = 1
          AND (@CategoryId   IS NULL OR p.CategoryId = @CategoryId)
          AND (@BrandId      IS NULL OR p.BrandId    = @BrandId)
          AND (@MinPrice     IS NULL OR p.BasePrice  >= @MinPrice)
          AND (@MaxPrice     IS NULL OR p.BasePrice  <= @MaxPrice)
          AND (@SearchTerm   IS NULL OR p.Name LIKE '%' + @SearchTerm + '%'
                                     OR p.Description LIKE '%' + @SearchTerm + '%')
          AND (@InStockOnly  IS NULL OR @InStockOnly = 0
               OR EXISTS (SELECT 1 FROM m.tblProductVariant sv
                          WHERE sv.ProductId = p.Id AND sv.StockQuantity > 0 AND sv.IsDeleted = 0))
        GROUP BY
            p.Id, p.CategoryId, c.Name, p.BrandId, b.Name,
            p.Name, p.Slug, p.Description, p.BasePrice, p.ClubcardPrice,
            p.ImageUrl, p.IsAvailable
        ORDER BY
            CASE WHEN @SortBy = 'price'  AND @SortDirection = 'asc'  THEN p.BasePrice END ASC,
            CASE WHEN @SortBy = 'price'  AND @SortDirection = 'desc' THEN p.BasePrice END DESC,
            CASE WHEN @SortBy = 'name'   AND @SortDirection = 'asc'  THEN p.Name     END ASC,
            CASE WHEN @SortBy = 'name'   AND @SortDirection = 'desc' THEN p.Name     END DESC,
            p.Name ASC
        OFFSET @Offset ROWS
        FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_SearchProducts', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V014')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V014', 'CreateCatalogueStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
