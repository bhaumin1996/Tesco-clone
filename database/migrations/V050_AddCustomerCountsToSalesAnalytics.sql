-- V050_AddCustomerCountsToSalesAnalytics.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Extend proc_Analytics_GetSalesAnalytics to return NewCustomers and ReturningCustomers
-- Dependencies: V048

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('proc_Analytics_GetSalesAnalytics', 'P') IS NOT NULL
        DROP PROCEDURE proc_Analytics_GetSalesAnalytics;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Analytics_GetSalesAnalytics
-- Result set 1: totals including new/returning customer counts
-- Result set 2: daily breakdown
-- =========================================================
CREATE PROCEDURE proc_Analytics_GetSalesAnalytics
    @From  DATETIME2,
    @To    DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Result set 1: totals
        SELECT
            ISNULL(SUM(o.Total), 0)  AS TotalRevenue,
            COUNT(o.Id)              AS TotalOrders,

            -- customers whose very first order falls within the range
            (
                SELECT COUNT(DISTINCT o2.UserId)
                FROM t.tblOrder o2
                WHERE o2.IsDeleted = 0
                  AND o2.CreatedOn >= @From
                  AND o2.CreatedOn <= @To
                  AND NOT EXISTS (
                      SELECT 1 FROM t.tblOrder o3
                      WHERE o3.UserId = o2.UserId
                        AND o3.IsDeleted = 0
                        AND o3.CreatedOn < @From
                  )
            ) AS NewCustomers,

            -- customers who ordered before the range AND also within it
            (
                SELECT COUNT(DISTINCT o2.UserId)
                FROM t.tblOrder o2
                WHERE o2.IsDeleted = 0
                  AND o2.CreatedOn >= @From
                  AND o2.CreatedOn <= @To
                  AND EXISTS (
                      SELECT 1 FROM t.tblOrder o3
                      WHERE o3.UserId = o2.UserId
                        AND o3.IsDeleted = 0
                        AND o3.CreatedOn < @From
                  )
            ) AS ReturningCustomers

        FROM t.tblOrder o
        WHERE o.IsDeleted = 0
          AND o.CreatedOn >= @From
          AND o.CreatedOn <= @To;

        -- Result set 2: daily breakdown
        SELECT
            CAST(CreatedOn AS DATE)  AS Date,
            COUNT(1)                 AS Orders,
            ISNULL(SUM(Total), 0)   AS Revenue
        FROM t.tblOrder
        WHERE IsDeleted = 0
          AND CreatedOn >= @From
          AND CreatedOn <= @To
        GROUP BY CAST(CreatedOn AS DATE)
        ORDER BY CAST(CreatedOn AS DATE);

    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Analytics_GetSalesAnalytics', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V050')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V050', 'AddCustomerCountsToSalesAnalytics');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
