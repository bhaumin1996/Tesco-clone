-- V047_AddCustomerNameToOrderDetails.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Update proc_Order_GetOrderById and proc_Order_GetOrderByReference 
--              to return CustomerName by joining with tblUser.
-- Dependencies: V044

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- Batch 1: Drop procedures if they exist
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Order_GetOrderById', 'P') IS NOT NULL
        DROP PROCEDURE proc_Order_GetOrderById;
    
    IF OBJECT_ID('proc_Order_GetOrderByReference', 'P') IS NOT NULL
        DROP PROCEDURE proc_Order_GetOrderByReference;

    IF OBJECT_ID('proc_Order_GetOrdersByUserId', 'P') IS NOT NULL
        DROP PROCEDURE proc_Order_GetOrdersByUserId;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- Batch 2: Recreate proc_Order_GetOrderById
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
            ISNULL(u.FirstName + ' ' + u.LastName, 'Unknown') AS CustomerName,
            ol.Id            AS OrderLineId,
            ol.ProductVariantId,
            ol.ProductName,
            ol.ImageUrl,
            ol.UnitPrice,
            ol.Quantity,
            ol.LineTotal
        FROM t.tblOrder o
        INNER JOIN t.tblOrderLine ol ON ol.OrderId = o.Id
        LEFT JOIN t.tblUser u ON u.Id = o.UserId AND u.IsDeleted = 0
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

-- Batch 3: Recreate proc_Order_GetOrderByReference
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
            ISNULL(u.FirstName + ' ' + u.LastName, 'Unknown') AS CustomerName,
            ol.Id            AS OrderLineId,
            ol.ProductVariantId,
            ol.ProductName,
            ol.ImageUrl,
            ol.UnitPrice,
            ol.Quantity,
            ol.LineTotal
        FROM t.tblOrder o
        INNER JOIN t.tblOrderLine ol ON ol.OrderId = o.Id
        LEFT JOIN t.tblUser u ON u.Id = o.UserId AND u.IsDeleted = 0
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

-- Batch 4: Recreate proc_Order_GetOrdersByUserId
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
            ISNULL(u.FirstName + ' ' + u.LastName, 'Unknown') AS CustomerName,
            ol.Id             AS OrderLineId,
            ol.ProductVariantId,
            ol.ProductName,
            ol.ImageUrl,
            ol.UnitPrice,
            ol.Quantity,
            ol.LineTotal
        FROM PagedOrders po
        INNER JOIN t.tblOrderLine ol ON ol.OrderId = po.Id
        LEFT JOIN t.tblUser u ON u.Id = @UserId AND u.IsDeleted = 0
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

-- Batch 5: Record migration
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V047')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V047', 'AddCustomerNameToOrderDetails');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
