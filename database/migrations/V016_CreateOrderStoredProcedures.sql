-- V016_CreateOrderStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Create stored procedures for order creation, retrieval, and status management
-- Dependencies: V001-V007

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Order_GetOrderById',         'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrderById;
    IF OBJECT_ID('proc_Order_GetOrderByReference',  'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrderByReference;
    IF OBJECT_ID('proc_Order_GetOrdersByUserId',    'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrdersByUserId;
    IF OBJECT_ID('proc_Order_CreateFromCart',       'P') IS NOT NULL DROP PROCEDURE proc_Order_CreateFromCart;
    IF OBJECT_ID('proc_Order_UpdateStatus',         'P') IS NOT NULL DROP PROCEDURE proc_Order_UpdateStatus;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Order_GetOrderById
-- Returns header + one row per line item
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
            ol.ProductVariantId,
            ol.ProductName,
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
            ol.ProductVariantId,
            ol.ProductName,
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
            ol.ProductVariantId,
            ol.ProductName,
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
-- Copies active cart items into a new order and returns the new OrderId.
-- =========================================================
CREATE PROCEDURE proc_Order_CreateFromCart
    @UserId          INT,
    @DeliverySlotId  INT           = NULL,
    @DeliveryAddress NVARCHAR(1000) = NULL,
    @DeliveryCharge  DECIMAL(10,2) = 0,
    @CreatedBy       INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CartId     INT;
        DECLARE @OrderId    INT;
        DECLARE @SubTotal   DECIMAL(10,2);
        DECLARE @Total      DECIMAL(10,2);
        DECLARE @OrderRef   NVARCHAR(20);

        -- Resolve the active cart
        SELECT @CartId = Id FROM t.tblCart WHERE UserId = @UserId AND IsDeleted = 0;

        IF @CartId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50001, 'No active cart found for this user.', 1;
        END

        -- Calculate subtotal from cart items
        SELECT @SubTotal = SUM(UnitPrice * Quantity)
        FROM t.tblCartItem
        WHERE CartId = @CartId AND IsDeleted = 0;

        IF @SubTotal IS NULL OR @SubTotal = 0
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50002, 'Cart is empty.', 1;
        END

        SET @Total = @SubTotal + @DeliveryCharge;

        -- Generate unique order reference: TC + YYYYMMDD + random 6 chars
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

        -- Copy cart items to order lines
        INSERT INTO t.tblOrderLine (OrderId, ProductVariantId, ProductName, UnitPrice, Quantity, LineTotal, CreatedBy, CreatedOn)
        SELECT @OrderId, ProductVariantId, ProductName, UnitPrice, Quantity,
               CAST(UnitPrice * Quantity AS DECIMAL(10,2)), @CreatedBy, GETUTCDATE()
        FROM t.tblCartItem
        WHERE CartId = @CartId AND IsDeleted = 0;

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

-- =========================================================
-- proc_Order_UpdateStatus
-- =========================================================
CREATE PROCEDURE proc_Order_UpdateStatus
    @OrderId    INT,
    @StatusId   TINYINT,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblOrder
        SET StatusId   = @StatusId,
            ModifiedBy = @ModifiedBy,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @OrderId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblOrder', @OrderId, 'UPDATE',
                CONCAT('{"StatusId":', @StatusId, '}'),
                @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_UpdateStatus', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V016')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V016', 'CreateOrderStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
