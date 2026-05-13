-- V022_CreateAdminOrderStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Admin stored procedures for order status and refund management
-- Dependencies: V001-V007

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetAllOrders',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetAllOrders;
    IF OBJECT_ID('proc_Admin_UpdateOrderStatus', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdateOrderStatus;
    IF OBJECT_ID('proc_Admin_ProcessRefund',     'P') IS NOT NULL DROP PROCEDURE proc_Admin_ProcessRefund;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetAllOrders
-- =========================================================
CREATE PROCEDURE proc_Admin_GetAllOrders
    @Status     TINYINT = NULL,
    @PageNumber INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            o.Id,
            o.OrderReference,
            o.StatusId,
            o.SubTotal,
            o.DeliveryCharge,
            o.DiscountTotal,
            o.Total,
            o.CreatedOn,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblOrder o
        WHERE o.IsDeleted = 0
          AND (@Status IS NULL OR o.StatusId = @Status)
        ORDER BY o.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetAllOrders', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UpdateOrderStatus
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdateOrderStatus
    @OrderId INT,
    @Status  TINYINT,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblOrder
        SET StatusId   = @Status,
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @OrderId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblOrder', @OrderId, 'UPDATE',
                CONCAT('{"StatusId":', @Status, '}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdateOrderStatus', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_ProcessRefund
-- =========================================================
CREATE PROCEDURE proc_Admin_ProcessRefund
    @OrderId      INT,
    @RefundAmount DECIMAL(10,2),
    @Reason       NVARCHAR(500),
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Mark order as Refunded (StatusId = 7)
        UPDATE t.tblOrder
        SET StatusId   = 7,
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @OrderId
          AND IsDeleted = 0;

        -- Record refund transaction
        INSERT INTO t.tblPayment
            (OrderId, Amount, StatusId, PaymentMethod, Notes, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@OrderId, -@RefundAmount, 3, 'Refund', @Reason, 1, @AdminId, GETUTCDATE());

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblOrder', @OrderId, 'UPDATE',
                CONCAT('{"StatusId":7,"RefundAmount":', @RefundAmount, ',"Reason":"', @Reason, '"}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_ProcessRefund', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V022')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V022', 'CreateAdminOrderStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
