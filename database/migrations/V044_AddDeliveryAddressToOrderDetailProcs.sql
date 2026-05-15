-- V044_AddDeliveryAddressToOrderDetailProcs.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Recreate proc_Order_GetOrderById and proc_Order_GetOrderByReference
--              to include DeliveryAddress in the result set so the API can return it.
-- Dependencies: V043 (FixOrderLineStoredProcedures)

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Order_GetOrderById',        'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrderById;
    IF OBJECT_ID('proc_Order_GetOrderByReference', 'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrderByReference;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Order_GetOrderById
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
            o.DeliveryAddress,
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
            o.DeliveryAddress,
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
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V044')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V044', 'AddDeliveryAddressToOrderDetailProcs');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
