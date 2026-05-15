-- V043_FixOrderLineStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Add ImageUrl column to t.tblOrderLine (captured at order time like ProductName).
--              Recreate order read SPs to return OrderLineId and ImageUrl.
--              Recreate proc_Order_CreateFromCart to copy ImageUrl from m.tblProductVariant.
-- Dependencies: V007 (CreateOrderTables), V016 (CreateOrderStoredProcedures)

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Add ImageUrl column if it does not already exist
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 't'
          AND TABLE_NAME   = 'tblOrderLine'
          AND COLUMN_NAME  = 'ImageUrl'
    )
    BEGIN
        ALTER TABLE t.tblOrderLine ADD ImageUrl NVARCHAR(500) NULL;
        PRINT 'Column [ImageUrl] added to [t].[tblOrderLine].';
    END

    -- Drop procedures so they can be recreated below
    IF OBJECT_ID('proc_Order_GetOrderById',        'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrderById;
    IF OBJECT_ID('proc_Order_GetOrderByReference', 'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrderByReference;
    IF OBJECT_ID('proc_Order_GetOrdersByUserId',   'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrdersByUserId;
    IF OBJECT_ID('proc_Order_CreateFromCart',      'P') IS NOT NULL DROP PROCEDURE proc_Order_CreateFromCart;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Order_GetOrderById
-- Returns header + one row per line item (includes OrderLineId and ImageUrl)
-- =========================================================
CREATE PROCEDURE proc_Order_GetOrderById
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            o.Id             AS OrderId,
            o.OrderReference,
            o.StatusId,
            o.SubTotal,
            o.DeliveryCharge,
            o.DiscountTotal,
            o.Total,
            o.CreatedOn,
            ol.Id            AS OrderLineId,
            ol.ProductVariantId,
            ol.ProductName,
            ol.ImageUrl,
            ol.UnitPrice,
            ol.Quantity,
            ol.LineTotal
        FROM t.tblOrder o
        INNER JOIN t.tblOrderLine ol ON ol.OrderId = o.Id
        WHERE o.Id = @OrderId
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
-- proc_Order_GetOrderByReference
-- =========================================================
CREATE PROCEDURE proc_Order_GetOrderByReference
    @OrderReference NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            o.Id             AS OrderId,
            o.OrderReference,
            o.StatusId,
            o.SubTotal,
            o.DeliveryCharge,
            o.DiscountTotal,
            o.Total,
            o.CreatedOn,
            ol.Id            AS OrderLineId,
            ol.ProductVariantId,
            ol.ProductName,
            ol.ImageUrl,
            ol.UnitPrice,
            ol.Quantity,
            ol.LineTotal
        FROM t.tblOrder o
        INNER JOIN t.tblOrderLine ol ON ol.OrderId = o.Id
        WHERE o.OrderReference = @OrderReference
          AND o.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_GetOrderByReference', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Order_GetOrdersByUserId
-- Paginated order list with lines; TotalCount on every row (window function)
-- =========================================================
CREATE PROCEDURE proc_Order_GetOrdersByUserId
    @UserId     INT,
    @PageNumber INT = 1,
    @PageSize   INT = 20
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
                COUNT(1) OVER () AS TotalCount,
                ROW_NUMBER() OVER (ORDER BY o.CreatedOn DESC) AS RowNum
            FROM t.tblOrder o
            WHERE o.UserId    = @UserId
              AND o.IsDeleted = 0
        )
        SELECT
            po.Id             AS OrderId,
            po.OrderReference,
            po.StatusId,
            po.SubTotal,
            po.DeliveryCharge,
            po.DiscountTotal,
            po.Total,
            po.CreatedOn,
            po.TotalCount,
            ol.Id             AS OrderLineId,
            ol.ProductVariantId,
            ol.ProductName,
            ol.ImageUrl,
            ol.UnitPrice,
            ol.Quantity,
            ol.LineTotal
        FROM PagedOrders po
        INNER JOIN t.tblOrderLine ol ON ol.OrderId = po.Id
        WHERE po.RowNum > @Offset AND po.RowNum <= @Offset + @PageSize
        ORDER BY po.RowNum, ol.Id;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_GetOrdersByUserId', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Order_CreateFromCart
-- Copies active cart items into a new order; captures ImageUrl from m.tblProductVariant.
-- =========================================================
CREATE PROCEDURE proc_Order_CreateFromCart
    @UserId          INT,
    @DeliverySlotId  INT            = NULL,
    @DeliveryAddress NVARCHAR(1000) = NULL,
    @DeliveryCharge  DECIMAL(10,2)  = 0,
    @CreatedBy       INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CartId   INT;
        DECLARE @OrderId  INT;
        DECLARE @SubTotal DECIMAL(10,2);
        DECLARE @Total    DECIMAL(10,2);
        DECLARE @OrderRef NVARCHAR(20);

        SELECT @CartId = Id FROM t.tblCart WHERE UserId = @UserId AND IsDeleted = 0;

        IF @CartId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50001, 'No active cart found for this user.', 1;
        END

        SELECT @SubTotal = SUM(UnitPrice * Quantity)
        FROM t.tblCartItem
        WHERE CartId = @CartId AND IsDeleted = 0;

        IF @SubTotal IS NULL OR @SubTotal = 0
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50002, 'Cart is empty.', 1;
        END

        SET @Total = @SubTotal + @DeliveryCharge;

        SET @OrderRef = CONCAT('TC', FORMAT(GETUTCDATE(), 'yyyyMMdd'), UPPER(SUBSTRING(CONVERT(NVARCHAR(36), NEWID()), 1, 6)));

        INSERT INTO t.tblOrder (
            UserId, OrderReference, StatusId,
            SubTotal, DeliveryCharge, DiscountTotal, Total,
            DeliverySlotId, DeliveryAddress,
            RecordStatusId, CreatedBy, CreatedOn
        )
        VALUES (
            @UserId, @OrderRef, 1,
            @SubTotal, @DeliveryCharge, 0, @Total,
            @DeliverySlotId, @DeliveryAddress,
            1, @CreatedBy, GETUTCDATE()
        );

        SET @OrderId = SCOPE_IDENTITY();

        -- Copy cart items to order lines; join variant to capture ImageUrl at order time
        INSERT INTO t.tblOrderLine (
            OrderId, ProductVariantId, ProductName, ImageUrl,
            UnitPrice, Quantity, LineTotal, CreatedBy, CreatedOn
        )
        SELECT
            @OrderId,
            ci.ProductVariantId,
            ci.ProductName,
            p.ImageUrl,
            ci.UnitPrice,
            ci.Quantity,
            CAST(ci.UnitPrice * ci.Quantity AS DECIMAL(10,2)),
            @CreatedBy,
            GETUTCDATE()
        FROM t.tblCartItem ci
        LEFT JOIN m.tblProductVariant pv ON pv.Id = ci.ProductVariantId
        LEFT JOIN m.tblProduct p ON p.Id = pv.ProductId
        WHERE ci.CartId = @CartId AND ci.IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblOrder', @OrderId, 'INSERT',
                CONCAT('{"UserId":', @UserId, ',"OrderReference":"', @OrderRef, '","Total":', @Total, '}'),
                @CreatedBy, GETUTCDATE());

        COMMIT TRANSACTION;

        SELECT @OrderId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_CreateFromCart', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO
