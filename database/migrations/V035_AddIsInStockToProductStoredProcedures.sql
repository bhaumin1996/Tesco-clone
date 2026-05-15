-- =========================================================
-- V035_AddIsInStockToProductStoredProcedures.sql
-- Author : Bhaumin Patel
-- Date   : 2026-05-15
-- Reason : ProductDto returned IsAvailable (always 1 in results) but the
--          Angular frontend expects isInStock based on actual variant stock.
--          Adds IsInStock (EXISTS check on StockQuantity > 0) to both
--          proc_Catalogue_GetProductById and proc_Catalogue_SearchProducts.
-- Depends: V014_CreateCatalogueStoredProcedures.sql
-- =========================================================

CREATE OR ALTER PROCEDURE proc_Catalogue_GetProductById
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
            ) THEN 1 ELSE 0 END AS BIT) AS IsInStock
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

CREATE OR ALTER PROCEDURE proc_Catalogue_SearchProducts
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
            CAST(CASE WHEN EXISTS (
                SELECT 1
                FROM   m.tblProductVariant sv
                WHERE  sv.ProductId    = p.Id
                  AND  sv.StockQuantity > 0
                  AND  sv.IsDeleted    = 0
            ) THEN 1 ELSE 0 END AS BIT) AS IsInStock,
            COUNT(1) OVER () AS TotalCount
        FROM  m.tblProduct p
        INNER JOIN m.tblCategory  c ON c.Id = p.CategoryId
        LEFT  JOIN m.tblBrand     b ON b.Id = p.BrandId
        LEFT  JOIN m.tblProductVariant v ON v.ProductId = p.Id AND v.IsDeleted = 0
        WHERE p.IsDeleted      = 0
          AND p.RecordStatusId = 1
          AND p.IsAvailable    = 1
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
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_SearchProducts', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO
