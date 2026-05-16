-- V059_FixOrderLineImageUrlInCreation.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: Recreate proc_Order_CreateFromCart to ensure ImageUrl is captured 
--              from tblProduct when creating order lines. This fix was lost 
--              in V058's recreation of the procedure.
-- Dependencies: V058

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF OBJECT_ID('proc_Order_CreateFromCart', 'P') IS NOT NULL 
    DROP PROCEDURE proc_Order_CreateFromCart;
GO

-- =========================================================
-- proc_Order_CreateFromCart (recreated with stock decrement AND ImageUrl capture)
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

        -- Copy cart items to order lines; capture ImageUrl at order time
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
        INNER JOIN m.tblProductVariant pv ON pv.Id = ci.ProductVariantId
        INNER JOIN m.tblProduct p ON p.Id = pv.ProductId
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

-- Fix existing data: Populate missing ImageUrl for existing order lines
UPDATE ol
SET    ol.ImageUrl = p.ImageUrl
FROM   t.tblOrderLine ol
INNER JOIN m.tblProductVariant pv ON pv.Id = ol.ProductVariantId
INNER JOIN m.tblProduct p ON p.Id = pv.ProductId
WHERE  ol.ImageUrl IS NULL;

-- Record migration
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V059')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V059', 'FixOrderLineImageUrlInCreation');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
