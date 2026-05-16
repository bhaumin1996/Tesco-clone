-- V075_AddInvoicePathToOrders.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: Add InvoicePath to tblOrder and update related stored procedures
-- Dependencies: V007, V016, V059, V047

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Add InvoicePath column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblOrder' AND COLUMN_NAME = 'InvoicePath')
    BEGIN
        ALTER TABLE t.tblOrder ADD InvoicePath NVARCHAR(500) NULL;
        PRINT 'Column InvoicePath added to t.tblOrder.';
    END

    -- 2. Update proc_Order_GetOrderById
    IF OBJECT_ID('proc_Order_GetOrderById', 'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrderById;
    EXEC('
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
                o.InvoicePath,
                ISNULL(u.FirstName + '' '' + u.LastName, ''Unknown'') AS CustomerName,
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
            VALUES (''Error'', ''proc_Order_GetOrderById'', ERROR_MESSAGE(), GETUTCDATE());
            THROW;
        END CATCH
    END');

    -- 3. Update proc_Order_GetOrderByReference
    IF OBJECT_ID('proc_Order_GetOrderByReference', 'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrderByReference;
    EXEC('
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
                o.InvoicePath,
                ISNULL(u.FirstName + '' '' + u.LastName, ''Unknown'') AS CustomerName,
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
            VALUES (''Error'', ''proc_Order_GetOrderByReference'', ERROR_MESSAGE(), GETUTCDATE());
            THROW;
        END CATCH
    END');

    -- 4. Update proc_Order_GetOrdersByUserId
    IF OBJECT_ID('proc_Order_GetOrdersByUserId', 'P') IS NOT NULL DROP PROCEDURE proc_Order_GetOrdersByUserId;
    EXEC('
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
                    o.InvoicePath,
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
                po.InvoicePath,
                po.TotalCount,
                ISNULL(u.FirstName + '' '' + u.LastName, ''Unknown'') AS CustomerName,
                ol.Id            AS OrderLineId,
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
            VALUES (''Error'', ''proc_Order_GetOrdersByUserId'', ERROR_MESSAGE(), GETUTCDATE());
            THROW;
        END CATCH
    END');

    -- 5. Add proc_Order_UpdateInvoicePath
    IF OBJECT_ID('proc_Order_UpdateInvoicePath', 'P') IS NOT NULL DROP PROCEDURE proc_Order_UpdateInvoicePath;
    EXEC('
    CREATE PROCEDURE proc_Order_UpdateInvoicePath
        @OrderId     INT,
        @InvoicePath NVARCHAR(500),
        @ModifiedBy  INT
    AS
    BEGIN
        SET NOCOUNT ON;
        BEGIN TRY
            BEGIN TRANSACTION;

            UPDATE t.tblOrder
            SET InvoicePath = @InvoicePath,
                ModifiedBy  = @ModifiedBy,
                ModifiedOn  = GETUTCDATE()
            WHERE Id = @OrderId AND IsDeleted = 0;

            INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
            VALUES (''tblOrder'', @OrderId, ''UPDATE'',
                    CONCAT(''{"InvoicePath":"'', @InvoicePath, ''"}''),
                    @ModifiedBy, GETUTCDATE());

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
            VALUES (''Error'', ''proc_Order_UpdateInvoicePath'', ERROR_MESSAGE(), GETUTCDATE());
            THROW;
        END CATCH
    END');

    -- 6. Record migration
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V075')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V075', 'AddInvoicePathToOrders');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
