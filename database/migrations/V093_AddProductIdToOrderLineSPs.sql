-- V093_AddProductIdToOrderLineSPs.sql
-- Author: Tesco Clone
-- Date: 2026-05-19
-- Description: Join m.tblProductVariant in proc_Order_GetOrderById,
--              proc_Order_GetOrderByReference, and proc_Order_GetOrdersByUserId
--              to return pv.ProductId alongside ProductVariantId.
--              Required so the storefront can load per-product rating status
--              from order line items (item.productId was previously undefined
--              because only ProductVariantId was returned).
-- Dependencies: V075, V092

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- 1. proc_Order_GetOrderById
-- =========================================================
IF OBJECT_ID('proc_Order_GetOrderById', 'P') IS NOT NULL
    DROP PROCEDURE proc_Order_GetOrderById;
GO

CREATE PROCEDURE proc_Order_GetOrderById
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            o.Id                AS OrderId,
            o.OrderReference,
            o.StatusId,
            o.SubTotal,
            o.DeliveryCharge,
            o.DiscountTotal,
            o.Total,
            o.DeliveryAddress,
            o.CreatedOn,
            o.InvoicePath,
            ISNULL(u.FirstName + ' ' + u.LastName, 'Unknown') AS CustomerName,
            ol.Id               AS OrderLineId,
            ol.ProductVariantId,
            pv.ProductId,
            ol.ProductName,
            ol.ImageUrl,
            ol.UnitPrice,
            ol.Quantity,
            ol.LineTotal
        FROM t.tblOrder o
        INNER JOIN t.tblOrderLine      ol ON ol.OrderId          = o.Id
        INNER JOIN m.tblProductVariant  pv ON pv.Id               = ol.ProductVariantId
        LEFT  JOIN t.tblUser            u  ON u.Id                = o.UserId AND u.IsDeleted = 0
        WHERE o.Id        = @OrderId
          AND o.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_GetOrderById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- 2. proc_Order_GetOrderByReference
-- =========================================================
IF OBJECT_ID('proc_Order_GetOrderByReference', 'P') IS NOT NULL
    DROP PROCEDURE proc_Order_GetOrderByReference;
GO

CREATE PROCEDURE proc_Order_GetOrderByReference
    @OrderReference NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            o.Id                AS OrderId,
            o.OrderReference,
            o.StatusId,
            o.SubTotal,
            o.DeliveryCharge,
            o.DiscountTotal,
            o.Total,
            o.DeliveryAddress,
            o.CreatedOn,
            o.InvoicePath,
            ISNULL(u.FirstName + ' ' + u.LastName, 'Unknown') AS CustomerName,
            ol.Id               AS OrderLineId,
            ol.ProductVariantId,
            pv.ProductId,
            ol.ProductName,
            ol.ImageUrl,
            ol.UnitPrice,
            ol.Quantity,
            ol.LineTotal
        FROM t.tblOrder o
        INNER JOIN t.tblOrderLine      ol ON ol.OrderId          = o.Id
        INNER JOIN m.tblProductVariant  pv ON pv.Id               = ol.ProductVariantId
        LEFT  JOIN t.tblUser            u  ON u.Id                = o.UserId AND u.IsDeleted = 0
        WHERE o.OrderReference = @OrderReference
          AND o.IsDeleted      = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_GetOrderByReference', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- 3. proc_Order_GetOrdersByUserId  (for order list page)
-- =========================================================
IF OBJECT_ID('proc_Order_GetOrdersByUserId', 'P') IS NOT NULL
    DROP PROCEDURE proc_Order_GetOrdersByUserId;
GO

CREATE PROCEDURE proc_Order_GetOrdersByUserId
    @UserId     INT,
    @PageNumber INT = 1,
    @PageSize   INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        WITH PagedOrders AS (
            SELECT
                o.Id,
                o.OrderReference,
                o.StatusId,
                o.SubTotal,
                o.DeliveryCharge,
                o.DiscountTotal,
                o.Total,
                o.CreatedOn,
                o.InvoicePath,
                ISNULL(u.FirstName + ' ' + u.LastName, 'Unknown') AS CustomerName,
                COUNT(1) OVER () AS TotalCount
            FROM t.tblOrder o
            LEFT JOIN t.tblUser u ON u.Id = o.UserId AND u.IsDeleted = 0
            WHERE o.UserId    = @UserId
              AND o.IsDeleted = 0
            ORDER BY o.CreatedOn DESC
            OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY
        )
        SELECT
            po.Id               AS OrderId,
            po.OrderReference,
            po.StatusId,
            po.SubTotal,
            po.DeliveryCharge,
            po.DiscountTotal,
            po.Total,
            po.CreatedOn,
            po.InvoicePath,
            po.CustomerName,
            po.TotalCount,
            ol.Id               AS OrderLineId,
            ol.ProductVariantId,
            pv.ProductId,
            ol.ProductName,
            ol.ImageUrl,
            ol.UnitPrice,
            ol.Quantity,
            ol.LineTotal
        FROM PagedOrders po
        INNER JOIN t.tblOrderLine      ol ON ol.OrderId = po.Id
        INNER JOIN m.tblProductVariant  pv ON pv.Id     = ol.ProductVariantId
        ORDER BY po.CreatedOn DESC, ol.Id ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_GetOrdersByUserId', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V093')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V093', 'AddProductIdToOrderLineSPs');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
