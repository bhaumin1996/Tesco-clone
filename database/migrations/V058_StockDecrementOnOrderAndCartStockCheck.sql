-- V058_StockDecrementOnOrderAndCartStockCheck.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: (1) Recreate proc_Order_UpsertCartItem to validate quantity against available stock.
--              (2) Recreate proc_Order_CreateFromCart to decrement StockQuantity on order placement
--                  with UPDLOCK concurrency guard to prevent oversell.
--              (3) Recreate proc_Order_UpdateStatus to restore StockQuantity when an order is
--                  cancelled (StatusId = 6) or refunded (StatusId = 7).
--              (4) Create proc_Order_GetVariantStock for application-layer pre-checks.
-- Dependencies: V015, V016, V057

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF OBJECT_ID('proc_Order_UpsertCartItem',  'P') IS NOT NULL DROP PROCEDURE proc_Order_UpsertCartItem;
IF OBJECT_ID('proc_Order_CreateFromCart',  'P') IS NOT NULL DROP PROCEDURE proc_Order_CreateFromCart;
IF OBJECT_ID('proc_Order_UpdateStatus',    'P') IS NOT NULL DROP PROCEDURE proc_Order_UpdateStatus;
IF OBJECT_ID('proc_Order_GetVariantStock', 'P') IS NOT NULL DROP PROCEDURE proc_Order_GetVariantStock;
GO

-- =========================================================
-- proc_Order_GetVariantStock
-- Returns current StockQuantity for a single variant.
-- =========================================================
CREATE PROCEDURE proc_Order_GetVariantStock
    @ProductVariantId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT StockQuantity
        FROM   m.tblProductVariant
        WHERE  Id        = @ProductVariantId
          AND  IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_GetVariantStock', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Order_UpsertCartItem  (recreated with stock check)
-- Raises error 50011 if @Quantity exceeds available StockQuantity.
-- =========================================================
CREATE PROCEDURE proc_Order_UpsertCartItem
    @UserId           INT,
    @ProductVariantId INT,
    @ProductName      NVARCHAR(500),
    @UnitPrice        DECIMAL(10,2),
    @Quantity         INT,
    @ModifiedBy       INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Available INT;
        SELECT @Available = StockQuantity
        FROM   m.tblProductVariant WITH (UPDLOCK, ROWLOCK)
        WHERE  Id        = @ProductVariantId
          AND  IsDeleted = 0;

        IF @Available IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50010, 'Product variant not found.', 1;
        END

        IF @Quantity > @Available
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50011, 'Requested quantity exceeds available stock.', 1;
        END

        DECLARE @CartId INT;
        SELECT @CartId = Id FROM t.tblCart WHERE UserId = @UserId AND IsDeleted = 0;

        IF @CartId IS NULL
        BEGIN
            INSERT INTO t.tblCart (UserId, RecordStatusId, CreatedBy, CreatedOn)
            VALUES (@UserId, 1, @ModifiedBy, GETUTCDATE());
            SET @CartId = SCOPE_IDENTITY();
        END

        IF EXISTS (
            SELECT 1 FROM t.tblCartItem
            WHERE CartId = @CartId AND ProductVariantId = @ProductVariantId AND IsDeleted = 0
        )
        BEGIN
            UPDATE t.tblCartItem
            SET Quantity   = @Quantity,
                UnitPrice  = @UnitPrice,
                ModifiedBy = @ModifiedBy,
                ModifiedOn = GETUTCDATE()
            WHERE CartId = @CartId AND ProductVariantId = @ProductVariantId AND IsDeleted = 0;
        END
        ELSE
        BEGIN
            INSERT INTO t.tblCartItem (CartId, ProductVariantId, ProductName, UnitPrice, Quantity, CreatedBy, CreatedOn)
            VALUES (@CartId, @ProductVariantId, @ProductName, @UnitPrice, @Quantity, @ModifiedBy, GETUTCDATE());
        END

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCartItem', @CartId, 'UPSERT',
                CONCAT('{"ProductVariantId":', @ProductVariantId, ',"Quantity":', @Quantity, '}'),
                @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_UpsertCartItem', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Order_CreateFromCart  (recreated with stock decrement)
-- UPDLOCK on all variant rows before inserting order lines
-- prevents concurrent orders from overselling the same stock.
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

        -- Lock all affected variant rows and verify stock in a single pass.
        -- If any item exceeds available stock the order is rejected atomically.
        DECLARE @InsufficientVariantId INT;

        SELECT TOP 1 @InsufficientVariantId = ci.ProductVariantId
        FROM t.tblCartItem ci
        INNER JOIN m.tblProductVariant pv WITH (UPDLOCK, ROWLOCK)
            ON pv.Id = ci.ProductVariantId AND pv.IsDeleted = 0
        WHERE ci.CartId    = @CartId
          AND ci.IsDeleted = 0
          AND ci.Quantity  > pv.StockQuantity;

        IF @InsufficientVariantId IS NOT NULL
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50003, 'One or more items in your cart have insufficient stock.', 1;
        END

        SET @Total    = @SubTotal + @DeliveryCharge;
        SET @OrderRef = CONCAT('TC', FORMAT(GETUTCDATE(), 'yyyyMMdd'),
                               UPPER(SUBSTRING(CONVERT(NVARCHAR(36), NEWID()), 1, 6)));

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

        INSERT INTO t.tblOrderLine (OrderId, ProductVariantId, ProductName, UnitPrice, Quantity, LineTotal, CreatedBy, CreatedOn)
        SELECT @OrderId, ci.ProductVariantId, ci.ProductName, ci.UnitPrice, ci.Quantity,
               CAST(ci.UnitPrice * ci.Quantity AS DECIMAL(10,2)), @CreatedBy, GETUTCDATE()
        FROM t.tblCartItem ci
        WHERE ci.CartId    = @CartId
          AND ci.IsDeleted = 0;

        -- Decrement stock atomically within the same transaction.
        UPDATE pv
        SET    pv.StockQuantity = pv.StockQuantity - ci.Quantity,
               pv.ModifiedBy   = @CreatedBy,
               pv.ModifiedOn   = GETUTCDATE()
        FROM   m.tblProductVariant pv
        INNER JOIN t.tblCartItem ci
            ON  ci.ProductVariantId = pv.Id
            AND ci.CartId           = @CartId
            AND ci.IsDeleted        = 0;

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
-- proc_Order_UpdateStatus  (recreated with stock restore)
-- Restores StockQuantity when transitioning to Cancelled (6)
-- or Refunded (7), but only from a status that had consumed stock.
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

        DECLARE @PreviousStatusId TINYINT;
        SELECT @PreviousStatusId = StatusId
        FROM   t.tblOrder
        WHERE  Id = @OrderId AND IsDeleted = 0;

        IF @PreviousStatusId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50004, 'Order not found.', 1;
        END

        UPDATE t.tblOrder
        SET StatusId   = @StatusId,
            ModifiedBy = @ModifiedBy,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @OrderId AND IsDeleted = 0;

        -- Restore stock only when first transitioning to Cancelled or Refunded.
        -- Guard against double-restore if somehow called twice.
        IF @StatusId IN (6, 7) AND @PreviousStatusId NOT IN (6, 7)
        BEGIN
            UPDATE pv
            SET    pv.StockQuantity = pv.StockQuantity + ol.Quantity,
                   pv.ModifiedBy   = @ModifiedBy,
                   pv.ModifiedOn   = GETUTCDATE()
            FROM   m.tblProductVariant pv
            INNER JOIN t.tblOrderLine ol ON ol.ProductVariantId = pv.Id
            WHERE  ol.OrderId = @OrderId;
        END

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

BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V058')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V058', 'StockDecrementOnOrderAndCartStockCheck');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
