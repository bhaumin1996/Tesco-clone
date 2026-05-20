-- V101_SellerOrderFulfillmentWorkflow.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Phase 11 — seller order fulfillment workflow.
--              Adds IsMarketplace / SellerId / ListingId columns to t.tblOrderLine.
--              Creates m.tblSellerOrderStatus reference table.
--              Creates t.tblSellerOrder (one record per seller per customer order).
--              Creates stored procedures for seller order management:
--                proc_Marketplace_CreateSellerOrdersForOrder
--                proc_Marketplace_GetSellerOrders
--                proc_Marketplace_GetSellerOrderById
--                proc_Marketplace_ConfirmSellerOrder
--                proc_Marketplace_DispatchSellerOrder
-- Dependencies: V001-V100

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- PART 1: Add marketplace columns to t.tblOrderLine
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblOrderLine' AND COLUMN_NAME='IsMarketplace')
        ALTER TABLE t.tblOrderLine ADD IsMarketplace BIT NOT NULL DEFAULT 0;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblOrderLine' AND COLUMN_NAME='SellerId')
        ALTER TABLE t.tblOrderLine ADD SellerId INT NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblOrderLine' AND COLUMN_NAME='ListingId')
        ALTER TABLE t.tblOrderLine ADD ListingId INT NULL;

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V101_Part1')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V101_Part1', 'SellerOrderFulfillment_OrderLineColumns');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V101_Part1', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 2: m.tblSellerOrderStatus reference table
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblSellerOrderStatus')
    BEGIN
        CREATE TABLE m.tblSellerOrderStatus (
            Id   TINYINT      NOT NULL PRIMARY KEY,
            Name NVARCHAR(50) NOT NULL
        );
        INSERT INTO m.tblSellerOrderStatus (Id, Name)
        VALUES (1,'Pending'), (2,'Confirmed'), (3,'Dispatched'), (4,'Cancelled');
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V101_Part2')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V101_Part2', 'SellerOrderFulfillment_StatusTable');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V101_Part2', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 3: t.tblSellerOrder table
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSellerOrder')
    BEGIN
        CREATE TABLE t.tblSellerOrder (
            Id              INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
            SellerId        INT          NOT NULL,
            OrderId         INT          NOT NULL,
            StatusId        TINYINT      NOT NULL DEFAULT 1,
            CarrierName     NVARCHAR(100) NULL,
            TrackingNumber  NVARCHAR(100) NULL,
            ConfirmedOn     DATETIME2    NULL,
            DispatchedOn    DATETIME2    NULL,
            RecordStatusId  TINYINT      NOT NULL DEFAULT 1,
            CreatedBy       INT          NOT NULL,
            CreatedOn       DATETIME2    NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy      INT          NULL,
            ModifiedOn      DATETIME2    NULL,
            IsDeleted       BIT          NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSellerOrder_tblSeller  FOREIGN KEY (SellerId)  REFERENCES t.tblSeller  (Id),
            CONSTRAINT FK_tblSellerOrder_tblOrder   FOREIGN KEY (OrderId)   REFERENCES t.tblOrder   (Id),
            CONSTRAINT FK_tblSellerOrder_tblSellerOrderStatus FOREIGN KEY (StatusId) REFERENCES m.tblSellerOrderStatus (Id),
            CONSTRAINT UQ_tblSellerOrder_SellerOrder UNIQUE (SellerId, OrderId)
        );

        CREATE INDEX IX_tblSellerOrder_SellerId ON t.tblSellerOrder (SellerId) WHERE IsDeleted = 0;
        CREATE INDEX IX_tblSellerOrder_OrderId  ON t.tblSellerOrder (OrderId)  WHERE IsDeleted = 0;
        CREATE INDEX IX_tblSellerOrder_StatusId ON t.tblSellerOrder (StatusId) WHERE IsDeleted = 0;
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V101_Part3')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V101_Part3', 'SellerOrderFulfillment_SellerOrderTable');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V101_Part3', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 4: Stored procedures
-- =========================================================
IF OBJECT_ID('proc_Marketplace_CreateSellerOrdersForOrder', 'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_CreateSellerOrdersForOrder;
IF OBJECT_ID('proc_Marketplace_GetSellerOrders',            'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerOrders;
IF OBJECT_ID('proc_Marketplace_GetSellerOrderById',         'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerOrderById;
IF OBJECT_ID('proc_Marketplace_ConfirmSellerOrder',         'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_ConfirmSellerOrder;
IF OBJECT_ID('proc_Marketplace_DispatchSellerOrder',        'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_DispatchSellerOrder;
GO

-- Creates one t.tblSellerOrder row per distinct seller for any marketplace lines on the given order.
-- Called immediately after proc_Order_PlaceOrder succeeds.
CREATE PROCEDURE proc_Marketplace_CreateSellerOrdersForOrder
    @OrderId   INT,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @SellerIds TABLE (SellerId INT);
        INSERT INTO @SellerIds (SellerId)
        SELECT DISTINCT ol.SellerId
        FROM t.tblOrderLine ol
        WHERE ol.OrderId      = @OrderId
          AND ol.IsMarketplace = 1
          AND ol.SellerId IS NOT NULL;

        INSERT INTO t.tblSellerOrder (SellerId, OrderId, StatusId, CreatedBy, CreatedOn)
        SELECT s.SellerId, @OrderId, 1, @CreatedBy, GETUTCDATE()
        FROM @SellerIds s
        WHERE NOT EXISTS (
            SELECT 1 FROM t.tblSellerOrder so
            WHERE so.SellerId = s.SellerId AND so.OrderId = @OrderId AND so.IsDeleted = 0
        );

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        SELECT 'tblSellerOrder', so.Id, 'CREATE',
               CONCAT('{"OrderId":', @OrderId, ',"SellerId":', so.SellerId, '}'),
               @CreatedBy, GETUTCDATE()
        FROM t.tblSellerOrder so
        WHERE so.OrderId = @OrderId AND so.IsDeleted = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_CreateSellerOrdersForOrder', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_GetSellerOrders
    @SellerId    INT,
    @StatusFilter NVARCHAR(50) = NULL,
    @PageNumber  INT = 1,
    @PageSize    INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            so.Id,
            so.OrderId,
            o.OrderReference,
            ss.Name                                     AS StatusName,
            so.CarrierName,
            so.TrackingNumber,
            so.ConfirmedOn,
            so.DispatchedOn,
            (SELECT COUNT(1) FROM t.tblOrderLine ol
             WHERE ol.OrderId = o.Id AND ol.SellerId = @SellerId AND ol.IsMarketplace = 1)
                                                        AS LineCount,
            (SELECT ISNULL(SUM(ol.UnitPrice * ol.Quantity), 0) FROM t.tblOrderLine ol
             WHERE ol.OrderId = o.Id AND ol.SellerId = @SellerId AND ol.IsMarketplace = 1)
                                                        AS SellerTotal,
            o.CreatedOn                                 AS OrderPlacedOn,
            COUNT(1) OVER ()                            AS TotalCount
        FROM t.tblSellerOrder so
        INNER JOIN t.tblOrder            o  ON o.Id  = so.OrderId
        INNER JOIN m.tblSellerOrderStatus ss ON ss.Id = so.StatusId
        WHERE so.SellerId  = @SellerId
          AND so.IsDeleted = 0
          AND (@StatusFilter IS NULL OR ss.Name = @StatusFilter)
        ORDER BY so.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_GetSellerOrders', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_GetSellerOrderById
    @SellerOrderId INT,
    @SellerId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Header
        SELECT
            so.Id,
            so.OrderId,
            o.OrderReference,
            ss.Name       AS StatusName,
            so.CarrierName,
            so.TrackingNumber,
            so.ConfirmedOn,
            so.DispatchedOn,
            o.CreatedOn   AS OrderPlacedOn,
            o.DeliveryAddress
        FROM t.tblSellerOrder so
        INNER JOIN t.tblOrder            o  ON o.Id  = so.OrderId
        INNER JOIN m.tblSellerOrderStatus ss ON ss.Id = so.StatusId
        WHERE so.Id       = @SellerOrderId
          AND so.SellerId = @SellerId
          AND so.IsDeleted = 0;

        -- Lines belonging to this seller on this order
        -- ProductId is on m.tblProductVariant; t.tblOrderLine stores ProductVariantId
        SELECT
            ol.Id,
            pv.ProductId,
            ol.ProductName,
            ol.ImageUrl,
            ol.UnitPrice,
            ol.Quantity,
            ol.LineTotal,
            ol.ListingId,
            ol.SellerId
        FROM t.tblOrderLine ol
        INNER JOIN m.tblProductVariant pv ON pv.Id = ol.ProductVariantId
        WHERE ol.OrderId      = (SELECT OrderId FROM t.tblSellerOrder
                                  WHERE Id = @SellerOrderId AND SellerId = @SellerId AND IsDeleted = 0)
          AND ol.SellerId     = @SellerId
          AND ol.IsMarketplace = 1;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_GetSellerOrderById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_ConfirmSellerOrder
    @SellerOrderId INT,
    @SellerId      INT,
    @ModifiedBy    INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM t.tblSellerOrder
            WHERE Id = @SellerOrderId AND SellerId = @SellerId AND StatusId = 1 AND IsDeleted = 0)
        BEGIN
            RAISERROR ('SellerOrder not found or not in Pending status.', 16, 1);
        END

        UPDATE t.tblSellerOrder
        SET StatusId    = 2,
            ConfirmedOn = GETUTCDATE(),
            ModifiedBy  = @ModifiedBy,
            ModifiedOn  = GETUTCDATE()
        WHERE Id = @SellerOrderId AND SellerId = @SellerId;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSellerOrder', @SellerOrderId, 'UPDATE',
                '{"StatusId":2,"Action":"Confirmed"}', @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_ConfirmSellerOrder', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_DispatchSellerOrder
    @SellerOrderId  INT,
    @SellerId       INT,
    @CarrierName    NVARCHAR(100),
    @TrackingNumber NVARCHAR(100),
    @ModifiedBy     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM t.tblSellerOrder
            WHERE Id = @SellerOrderId AND SellerId = @SellerId AND StatusId IN (1,2) AND IsDeleted = 0)
        BEGIN
            RAISERROR ('SellerOrder not found or already dispatched/cancelled.', 16, 1);
        END

        UPDATE t.tblSellerOrder
        SET StatusId       = 3,
            CarrierName    = @CarrierName,
            TrackingNumber = @TrackingNumber,
            DispatchedOn   = GETUTCDATE(),
            ModifiedBy     = @ModifiedBy,
            ModifiedOn     = GETUTCDATE()
        WHERE Id = @SellerOrderId AND SellerId = @SellerId;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSellerOrder', @SellerOrderId, 'UPDATE',
                CONCAT('{"StatusId":3,"CarrierName":"', @CarrierName,
                       '","TrackingNumber":"', @TrackingNumber, '"}'),
                @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_DispatchSellerOrder', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V101')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V101', 'SellerOrderFulfillmentWorkflow');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
