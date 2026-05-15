-- V046_FixAdminGetAllOrdersAddCustomerName.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Rebuild proc_Admin_GetAllOrders to JOIN tblUser and return CustomerName
-- Dependencies: V001-V022

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetAllOrders', 'P') IS NOT NULL
        DROP PROCEDURE proc_Admin_GetAllOrders;

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
            ISNULL(u.FirstName + ' ' + u.LastName, 'Unknown') AS CustomerName,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblOrder o
        LEFT JOIN t.tblUser u ON u.Id = o.UserId AND u.IsDeleted = 0
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
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V046')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V046', 'FixAdminGetAllOrdersAddCustomerName');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
