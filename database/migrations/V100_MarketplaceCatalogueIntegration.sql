-- V100_MarketplaceCatalogueIntegration.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Phase 11 — marketplace catalogue integration.
--              Updates proc_Catalogue_SearchProducts to accept @IncludeMarketplace
--              and UNION approved+published seller listings alongside Tesco-own products.
--              Both result branches return IsMarketplace, SellerId, SellerName columns
--              so the customer storefront can render the "Sold by" badge.
-- Dependencies: V001-V099

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- Recreate proc_Catalogue_SearchProducts
-- =========================================================
IF OBJECT_ID('proc_Catalogue_SearchProducts', 'P') IS NOT NULL
    DROP PROCEDURE proc_Catalogue_SearchProducts;
GO

CREATE PROCEDURE proc_Catalogue_SearchProducts
    @SearchTerm        NVARCHAR(200) = NULL,
    @CategoryId        INT           = NULL,
    @BrandId           INT           = NULL,
    @MinPrice          DECIMAL(10,2) = NULL,
    @MaxPrice          DECIMAL(10,2) = NULL,
    @InStockOnly       BIT           = NULL,
    @ClubcardOnly      BIT           = NULL,
    @BrandNames        NVARCHAR(MAX) = NULL,
    @DietaryFlags      NVARCHAR(MAX) = NULL,
    @SortBy            NVARCHAR(50)  = 'relevance',
    @SortDirection     NVARCHAR(4)   = 'asc',
    @PageNumber        INT           = 1,
    @PageSize          INT           = 20,
    @IncludeMarketplace BIT          = 0,
    @SellerId          INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        DECLARE @SelectedBrands  TABLE (Name NVARCHAR(200));
        DECLARE @SelectedDietary TABLE (Keyword NVARCHAR(200));

        IF @BrandNames IS NOT NULL
            INSERT INTO @SelectedBrands SELECT value FROM STRING_SPLIT(@BrandNames, ',');
        IF @DietaryFlags IS NOT NULL
            INSERT INTO @SelectedDietary SELECT value FROM STRING_SPLIT(@DietaryFlags, ',');

        -- CTE combines Tesco products and (optionally) published marketplace listings
        ;WITH CombinedResults AS
        (
            -- ── Tesco-own products ─────────────────────────────────────────────────
            SELECT
                p.Id,
                p.CategoryId,
                c.Name             AS CategoryName,
                p.BrandId,
                b.Name             AS BrandName,
                p.Name,
                p.Slug,
                p.Description,
                p.BasePrice,
                p.ClubcardPrice,
                p.ImageUrl,
                p.IsAvailable,
                CAST(CASE WHEN EXISTS (
                    SELECT 1 FROM m.tblProductVariant sv
                    WHERE sv.ProductId = p.Id AND sv.StockQuantity > 0 AND sv.IsDeleted = 0
                ) THEN 1 ELSE 0 END AS BIT)                             AS IsInStock,
                p.AverageRating,
                p.ReviewCount,
                (SELECT MIN(dv.Id)
                 FROM m.tblProductVariant dv
                 WHERE dv.ProductId = p.Id AND dv.IsDeleted = 0 AND dv.RecordStatusId = 1)
                                                                         AS DefaultVariantId,
                (SELECT TOP 1 dv.VariantName
                 FROM m.tblProductVariant dv
                 WHERE dv.ProductId = p.Id AND dv.IsDeleted = 0 AND dv.RecordStatusId = 1
                 ORDER BY dv.Id)                                         AS UnitPrice,
                (SELECT TOP 1 prm.Name
                 FROM m.tblPromotionProduct pp
                 INNER JOIN m.tblPromotion prm ON prm.Id = pp.PromotionId
                 WHERE pp.ProductId = p.Id
                   AND pp.IsDeleted = 0 AND prm.IsDeleted = 0 AND prm.IsActive = 1
                   AND (prm.ValidFrom IS NULL OR prm.ValidFrom <= GETUTCDATE())
                   AND (prm.ValidTo   IS NULL OR prm.ValidTo   >= GETUTCDATE())
                 ORDER BY prm.CreatedOn DESC)                            AS PromotionLabel,
                CAST(0 AS BIT)              AS IsMarketplace,
                CAST(NULL AS INT)           AS ListingSellerId,
                CAST(NULL AS NVARCHAR(300)) AS SellerName
            FROM m.tblProduct p
            INNER JOIN m.tblCategory c ON c.Id = p.CategoryId
            LEFT  JOIN m.tblBrand   b ON b.Id = p.BrandId
            WHERE p.IsDeleted = 0
              AND p.RecordStatusId = 1
              AND p.IsAvailable = 1
              AND (@CategoryId   IS NULL OR p.CategoryId = @CategoryId)
              AND (@BrandId      IS NULL OR p.BrandId    = @BrandId)
              AND (@MinPrice     IS NULL OR p.BasePrice  >= @MinPrice)
              AND (@MaxPrice     IS NULL OR p.BasePrice  <= @MaxPrice)
              AND (@SearchTerm   IS NULL
                   OR p.Name        LIKE '%' + @SearchTerm + '%'
                   OR p.Description LIKE '%' + @SearchTerm + '%')
              AND (@InStockOnly   IS NULL OR @InStockOnly = 0
                   OR EXISTS (SELECT 1 FROM m.tblProductVariant sv
                              WHERE sv.ProductId = p.Id AND sv.StockQuantity > 0 AND sv.IsDeleted = 0))
              AND (@ClubcardOnly  IS NULL OR @ClubcardOnly = 0 OR p.ClubcardPrice IS NOT NULL)
              AND (@BrandNames    IS NULL OR b.Name IN (SELECT Name FROM @SelectedBrands))
              AND (@DietaryFlags  IS NULL OR EXISTS (
                  SELECT 1 FROM @SelectedDietary d
                  WHERE p.Description LIKE '%' + d.Keyword + '%'
                     OR p.Name        LIKE '%' + d.Keyword + '%'))

            UNION ALL

            -- ── Approved marketplace listings ──────────────────────────────────────
            SELECT
                l.Id,
                ISNULL(l.CategoryId, 0)    AS CategoryId,
                ISNULL(cat.Name, '')       AS CategoryName,
                CAST(NULL AS INT)           AS BrandId,
                CAST(NULL AS NVARCHAR(200)) AS BrandName,
                l.Title                    AS Name,
                ISNULL(l.Slug, '')         AS Slug,
                l.Description,
                l.Price                    AS BasePrice,
                CAST(NULL AS DECIMAL(18,4)) AS ClubcardPrice,
                l.ImageUrl,
                CAST(1 AS BIT)             AS IsAvailable,
                CAST(CASE WHEN l.StockQuantity > 0 THEN 1 ELSE 0 END AS BIT) AS IsInStock,
                CAST(0.0 AS DECIMAL(3,2))  AS AverageRating,
                0                          AS ReviewCount,
                CAST(NULL AS INT)           AS DefaultVariantId,
                CAST(NULL AS NVARCHAR(200)) AS UnitPrice,
                CAST(NULL AS NVARCHAR(200)) AS PromotionLabel,
                CAST(1 AS BIT)             AS IsMarketplace,
                l.SellerId                 AS ListingSellerId,
                s.BusinessName             AS SellerName
            FROM t.tblListing l
            INNER JOIN t.tblSeller s   ON s.Id = l.SellerId
            LEFT  JOIN m.tblCategory cat ON cat.Id = l.CategoryId
            WHERE @IncludeMarketplace = 1
              AND l.IsDeleted = 0
              AND l.RecordStatusId = 1
              AND l.StatusId = 2                -- Published
              AND s.IsDeleted = 0
              AND s.StatusId = 2                -- Approved
              AND (@SellerId     IS NULL OR l.SellerId = @SellerId)
              AND (@CategoryId   IS NULL OR l.CategoryId = @CategoryId)
              AND (@MinPrice     IS NULL OR l.Price >= @MinPrice)
              AND (@MaxPrice     IS NULL OR l.Price <= @MaxPrice)
              AND (@InStockOnly  IS NULL OR @InStockOnly = 0 OR l.StockQuantity > 0)
              AND (@SearchTerm   IS NULL
                   OR l.Title       LIKE '%' + @SearchTerm + '%'
                   OR l.Description LIKE '%' + @SearchTerm + '%')
        )
        SELECT
            cr.Id,
            cr.CategoryId,
            cr.CategoryName,
            cr.BrandId,
            cr.BrandName,
            cr.Name,
            cr.Slug,
            cr.Description,
            cr.BasePrice,
            cr.ClubcardPrice,
            cr.ImageUrl,
            cr.IsAvailable,
            cr.IsInStock,
            cr.AverageRating,
            cr.ReviewCount,
            cr.DefaultVariantId,
            cr.UnitPrice,
            cr.PromotionLabel,
            cr.IsMarketplace,
            cr.ListingSellerId AS SellerId,
            cr.SellerName,
            COUNT(1) OVER () AS TotalCount
        FROM CombinedResults cr
        ORDER BY
            CASE WHEN @SortBy = 'price'   AND @SortDirection = 'asc'  THEN cr.BasePrice     END ASC,
            CASE WHEN @SortBy = 'price'   AND @SortDirection = 'desc' THEN cr.BasePrice     END DESC,
            CASE WHEN @SortBy = 'rating'  AND @SortDirection = 'asc'  THEN cr.AverageRating END ASC,
            CASE WHEN @SortBy = 'rating'  AND @SortDirection = 'desc' THEN cr.AverageRating END DESC,
            CASE WHEN @SortBy = 'name'    AND @SortDirection = 'asc'  THEN cr.Name          END ASC,
            CASE WHEN @SortBy = 'name'    AND @SortDirection = 'desc' THEN cr.Name          END DESC,
            -- Marketplace listings last unless explicitly sorted
            cr.IsMarketplace ASC,
            CASE WHEN @SortBy = 'relevance' OR @SortBy IS NULL THEN cr.Id END DESC,
            cr.Name ASC
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
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V100')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V100', 'MarketplaceCatalogueIntegration');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
