-- V074_AddRemainingStockToAdminProductsAndInventory.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: Rebuild proc_Admin_GetProducts and proc_Admin_GetInventory to include
--              RemainingStock = StockQuantity - SUM(committed active order quantities).
--              Active orders: StatusId IN (1=Placed, 2=Confirmed).
-- Dependencies: V073

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- Drop and recreate proc_Admin_GetProducts
-- =========================================================
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

CREATE PROCEDURE proc_Admin_GetProducts
    @Search        NVARCHAR(256) = NULL,
    @CategoryId    INT           = NULL,
    @DepartmentId  INT           = NULL,
    @PageNumber    INT           = 1,
    @PageSize      INT           = 20,
    @SortBy        NVARCHAR(50)  = 'createdOn',
    @SortDirection NVARCHAR(4)   = 'desc'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            p.Id,
            p.CategoryId,
            c.Name                                                                      AS CategoryName,
            p.BrandId,
            b.Name                                                                      AS BrandName,
            p.Name,
            p.Slug,
            p.Description,
            p.BasePrice,
            p.ClubcardPrice,
            p.ImageUrl,
            p.IsAvailable,
            ISNULL(pv.TotalStock, 0)                                                   AS StockQuantity,
            p.CreatedOn,
            p.ModifiedOn,
            ISNULL(oc.PlacedAndConfirmedCount, 0)                                      AS PlacedAndConfirmedCount,
            ISNULL(oc.PendingOrderCount, 0)                                            AS PendingOrderCount,
            ISNULL(pv.TotalStock, 0) - ISNULL(oc.CommittedQuantity, 0)                AS RemainingStock,
            COUNT(1) OVER ()                                                            AS TotalCount
        FROM m.tblProduct p
        INNER JOIN m.tblCategory   c  ON c.Id  = p.CategoryId   AND c.IsDeleted = 0
        INNER JOIN m.tblDepartment d  ON d.Id  = c.DepartmentId AND d.IsDeleted = 0
        LEFT  JOIN m.tblBrand      b  ON b.Id  = p.BrandId      AND b.IsDeleted = 0
        LEFT  JOIN (
            SELECT ProductId, SUM(StockQuantity) AS TotalStock
            FROM   m.tblProductVariant
            WHERE  IsDeleted = 0
            GROUP  BY ProductId
        ) pv ON pv.ProductId = p.Id
        LEFT  JOIN (
            SELECT
                pv2.ProductId,
                COUNT(DISTINCT CASE WHEN o.StatusId IN (1, 2) THEN o.Id END)  AS PlacedAndConfirmedCount,
                COUNT(DISTINCT CASE WHEN o.StatusId = 1        THEN o.Id END)  AS PendingOrderCount,
                SUM(CASE WHEN o.StatusId IN (1, 2) THEN ol.Quantity ELSE 0 END) AS CommittedQuantity
            FROM   m.tblProductVariant pv2
            INNER  JOIN t.tblOrderLine ol ON ol.ProductVariantId = pv2.Id
            INNER  JOIN t.tblOrder     o  ON o.Id = ol.OrderId   AND o.IsDeleted = 0
            WHERE  pv2.IsDeleted = 0
            GROUP  BY pv2.ProductId
        ) oc ON oc.ProductId = p.Id
        WHERE p.IsDeleted = 0
          AND (@Search       IS NULL OR p.Name LIKE '%' + @Search + '%' OR p.Slug LIKE '%' + @Search + '%')
          AND (@CategoryId   IS NULL OR p.CategoryId   = @CategoryId)
          AND (@DepartmentId IS NULL OR c.DepartmentId = @DepartmentId)
        ORDER BY
            CASE WHEN @SortBy = 'name'          AND @SortDirection = 'asc'  THEN p.Name          END ASC,
            CASE WHEN @SortBy = 'name'          AND @SortDirection = 'desc' THEN p.Name          END DESC,
            CASE WHEN @SortBy = 'basePrice'     AND @SortDirection = 'asc'  THEN p.BasePrice     END ASC,
            CASE WHEN @SortBy = 'basePrice'     AND @SortDirection = 'desc' THEN p.BasePrice     END DESC,
            CASE WHEN @SortBy = 'stockQuantity' AND @SortDirection = 'asc'  THEN pv.TotalStock   END ASC,
            CASE WHEN @SortBy = 'stockQuantity' AND @SortDirection = 'desc' THEN pv.TotalStock   END DESC,
            CASE WHEN @SortBy = 'isAvailable'   AND @SortDirection = 'asc'  THEN CAST(p.IsAvailable AS TINYINT) END ASC,
            CASE WHEN @SortBy = 'isAvailable'   AND @SortDirection = 'desc' THEN CAST(p.IsAvailable AS TINYINT) END DESC,
            CASE WHEN @SortDirection = 'asc'  THEN p.CreatedOn END ASC,
            CASE WHEN @SortDirection = 'desc' THEN p.CreatedOn END DESC
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
-- Drop and recreate proc_Admin_GetInventory
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('proc_Admin_GetInventory', 'P') IS NOT NULL
        DROP PROCEDURE proc_Admin_GetInventory;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

CREATE PROCEDURE proc_Admin_GetInventory
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            pv.Id                                                                              AS ProductVariantId,
            p.Id                                                                               AS ProductId,
            p.Name                                                                             AS ProductName,
            pv.Sku,
            pv.StockQuantity,
            pv.LowStockThreshold,
            CAST(CASE WHEN pv.StockQuantity <= pv.LowStockThreshold THEN 1 ELSE 0 END AS BIT) AS IsLowStock,
            ISNULL(oc.PlacedAndConfirmedCount, 0)                                             AS PlacedAndConfirmedCount,
            ISNULL(oc.PendingOrderCount, 0)                                                   AS PendingOrderCount,
            pv.StockQuantity - ISNULL(oc.CommittedQuantity, 0)                               AS RemainingStock
        FROM m.tblProductVariant pv
        INNER JOIN m.tblProduct p ON p.Id = pv.ProductId AND p.IsDeleted = 0
        LEFT  JOIN (
            SELECT
                ol.ProductVariantId,
                COUNT(DISTINCT CASE WHEN o.StatusId IN (1, 2) THEN o.Id END)  AS PlacedAndConfirmedCount,
                COUNT(DISTINCT CASE WHEN o.StatusId = 1        THEN o.Id END)  AS PendingOrderCount,
                SUM(CASE WHEN o.StatusId IN (1, 2) THEN ol.Quantity ELSE 0 END) AS CommittedQuantity
            FROM   t.tblOrderLine ol
            INNER  JOIN t.tblOrder o ON o.Id = ol.OrderId AND o.IsDeleted = 0
            GROUP  BY ol.ProductVariantId
        ) oc ON oc.ProductVariantId = pv.Id
        WHERE pv.IsDeleted = 0
        ORDER BY pv.StockQuantity ASC, p.Name ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetInventory', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V074')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V074', 'AddRemainingStockToAdminProductsAndInventory');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
