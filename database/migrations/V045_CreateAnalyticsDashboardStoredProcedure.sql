-- V045_CreateAnalyticsDashboardStoredProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Create proc_Analytics_GetDashboardStats for admin dashboard KPIs
-- Dependencies: V001-V012

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Analytics_GetDashboardStats', 'P') IS NOT NULL
        DROP PROCEDURE proc_Analytics_GetDashboardStats;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Analytics_GetDashboardStats
-- =========================================================
CREATE PROCEDURE proc_Analytics_GetDashboardStats
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Today DATE = CAST(GETUTCDATE() AS DATE);

        SELECT
            (
                SELECT COUNT(1)
                FROM t.tblOrder
                WHERE IsDeleted = 0
                  AND CAST(CreatedOn AS DATE) = @Today
            ) AS TotalOrdersToday,

            (
                SELECT ISNULL(SUM(Total), 0)
                FROM t.tblOrder
                WHERE IsDeleted = 0
                  AND CAST(CreatedOn AS DATE) = @Today
            ) AS TotalRevenueToday,

            (
                SELECT COUNT(1)
                FROM t.tblUser
                WHERE IsDeleted = 0
                  AND CAST(CreatedOn AS DATE) = @Today
            ) AS NewCustomersToday,

            (
                SELECT COUNT(1)
                FROM t.tblOrder
                WHERE IsDeleted = 0
                  AND StatusId = 1  -- Pending
            ) AS PendingOrders,

            (
                SELECT COUNT(1)
                FROM m.tblProductVariant
                WHERE IsDeleted = 0
                  AND StockQuantity < 10
            ) AS LowStockProducts,

            (
                SELECT COUNT(1)
                FROM t.tblDispute
                WHERE IsDeleted = 0
                  AND StatusId = 1  -- Open
            ) AS OpenDisputes;

    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Analytics_GetDashboardStats', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V045')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V045', 'CreateAnalyticsDashboardStoredProcedure');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
