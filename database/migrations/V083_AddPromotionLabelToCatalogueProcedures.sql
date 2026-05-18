-- V083_AddPromotionLabelToCatalogueProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Re-create catalogue stored procedures to return active product promotion labels.
-- Dependencies: V001-V082

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- 1. Recreate proc_Catalogue_GetProductById
-- =========================================================
IF OBJECT_ID('proc_Catalogue_GetProductById', 'P') IS NOT NULL 
    DROP PROCEDURE proc_Catalogue_GetProductById;
GO

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
            p.IsAvailable,
            CAST(CASE WHEN EXISTS (
                SELECT 1
                FROM   m.tblProductVariant sv
                WHERE  sv.ProductId    = p.Id
                  AND  sv.StockQuantity > 0
                  AND  sv.IsDeleted    = 0
            ) THEN 1 ELSE 0 END AS BIT) AS IsInStock,
            p.AverageRating,
            p.ReviewCount,
            (SELECT MIN(dv.Id)
             FROM   m.tblProductVariant dv
             WHERE  dv.ProductId      = p.Id
               AND  dv.IsDeleted      = 0
               AND  dv.RecordStatusId = 1) AS DefaultVariantId,
            (SELECT TOP 1 dv.VariantName
             FROM   m.tblProductVariant dv
             WHERE  dv.ProductId      = p.Id
               AND  dv.IsDeleted      = 0
               AND  dv.RecordStatusId = 1
             ORDER BY dv.Id) AS UnitPrice,
            (SELECT TOP 1 prm.Name
             FROM m.tblPromotionProduct pp
             INNER JOIN m.tblPromotion prm ON prm.Id = pp.PromotionId
             WHERE pp.ProductId = p.Id
               AND pp.IsDeleted = 0
               AND prm.IsDeleted = 0
               AND prm.IsActive = 1
               AND (prm.ValidFrom IS NULL OR prm.ValidFrom <= GETUTCDATE())
               AND (prm.ValidTo IS NULL OR prm.ValidTo >= GETUTCDATE())
             ORDER BY prm.CreatedOn DESC) AS PromotionLabel
        FROM  m.tblProduct  p
        INNER JOIN m.tblCategory c ON c.Id = p.CategoryId
        LEFT  JOIN m.tblBrand   b ON b.Id = p.BrandId
        WHERE p.Id            = @ProductId
          AND p.IsDeleted      = 0
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
-- 2. Recreate proc_Catalogue_SearchProducts
-- =========================================================
IF OBJECT_ID('proc_Catalogue_SearchProducts', 'P') IS NOT NULL 
    DROP PROCEDURE proc_Catalogue_SearchProducts;
GO

CREATE PROCEDURE proc_Catalogue_SearchProducts
    @SearchTerm    NVARCHAR(200) = NULL,
    @CategoryId    INT           = NULL,
    @BrandId       INT           = NULL,
    @MinPrice      DECIMAL(10,2) = NULL,
    @MaxPrice      DECIMAL(10,2) = NULL,
    @InStockOnly   BIT           = NULL,
    @ClubcardOnly  BIT           = NULL,
    @BrandNames    NVARCHAR(MAX) = NULL,
    @DietaryFlags  NVARCHAR(MAX) = NULL,
    @SortBy        NVARCHAR(50)  = 'relevance',
    @SortDirection NVARCHAR(4)   = 'asc',
    @PageNumber    INT           = 1,
    @PageSize      INT           = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        DECLARE @SelectedBrands TABLE (Name NVARCHAR(200));
        IF @BrandNames IS NOT NULL
            INSERT INTO @SelectedBrands SELECT value FROM STRING_SPLIT(@BrandNames, ',');

        DECLARE @SelectedDietary TABLE (Keyword NVARCHAR(200));
        IF @DietaryFlags IS NOT NULL
            INSERT INTO @SelectedDietary SELECT value FROM STRING_SPLIT(@DietaryFlags, ',');

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
            CAST(CASE WHEN EXISTS (
                SELECT 1
                FROM   m.tblProductVariant sv
                WHERE  sv.ProductId    = p.Id
                  AND  sv.StockQuantity > 0
                  AND  sv.IsDeleted    = 0
            ) THEN 1 ELSE 0 END AS BIT) AS IsInStock,
            p.AverageRating,
            p.ReviewCount,
            (SELECT MIN(dv.Id)
             FROM   m.tblProductVariant dv
             WHERE  dv.ProductId      = p.Id
               AND  dv.IsDeleted      = 0
               AND  dv.RecordStatusId = 1) AS DefaultVariantId,
            (SELECT TOP 1 dv.VariantName
             FROM   m.tblProductVariant dv
             WHERE  dv.ProductId      = p.Id
               AND  dv.IsDeleted      = 0
               AND  dv.RecordStatusId = 1
             ORDER BY dv.Id) AS UnitPrice,
            (SELECT TOP 1 prm.Name
             FROM m.tblPromotionProduct pp
             INNER JOIN m.tblPromotion prm ON prm.Id = pp.PromotionId
             WHERE pp.ProductId = p.Id
               AND pp.IsDeleted = 0
               AND prm.IsDeleted = 0
               AND prm.IsActive = 1
               AND (prm.ValidFrom IS NULL OR prm.ValidFrom <= GETUTCDATE())
               AND (prm.ValidTo IS NULL OR prm.ValidTo >= GETUTCDATE())
             ORDER BY prm.CreatedOn DESC) AS PromotionLabel,
            COUNT(1) OVER () AS TotalCount
        FROM m.tblProduct p
        INNER JOIN m.tblCategory  c ON c.Id = p.CategoryId
        LEFT  JOIN m.tblBrand     b ON b.Id = p.BrandId
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
          AND (@ClubcardOnly IS NULL OR @ClubcardOnly = 0 OR p.ClubcardPrice IS NOT NULL)
          AND (@BrandNames   IS NULL OR b.Name IN (SELECT Name FROM @SelectedBrands))
          AND (@DietaryFlags IS NULL OR EXISTS (
              SELECT 1 FROM @SelectedDietary d
              WHERE p.Description LIKE '%' + d.Keyword + '%'
                 OR p.Name LIKE '%' + d.Keyword + '%'
          ))
        GROUP BY
            p.Id, p.CategoryId, c.Name, p.BrandId, b.Name,
            p.Name, p.Slug, p.Description, p.BasePrice, p.ClubcardPrice,
            p.ImageUrl, p.IsAvailable, p.AverageRating, p.ReviewCount
        ORDER BY
            CASE WHEN @SortBy = 'price'  AND @SortDirection = 'asc'  THEN p.BasePrice     END ASC,
            CASE WHEN @SortBy = 'price'  AND @SortDirection = 'desc' THEN p.BasePrice     END DESC,
            CASE WHEN @SortBy = 'rating' AND @SortDirection = 'asc'  THEN p.AverageRating END ASC,
            CASE WHEN @SortBy = 'rating' AND @SortDirection = 'desc' THEN p.AverageRating END DESC,
            CASE WHEN @SortBy = 'name'   AND @SortDirection = 'asc'  THEN p.Name          END ASC,
            CASE WHEN @SortBy = 'name'   AND @SortDirection = 'desc' THEN p.Name          END DESC,
            CASE WHEN @SortBy = 'relevance' OR @SortBy IS NULL THEN p.Id END DESC,
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
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V083')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V083', 'AddPromotionLabelToCatalogueProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
