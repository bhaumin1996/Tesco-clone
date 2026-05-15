-- V048_AddAnalyticsSalesAndTopProductsProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Add proc_Analytics_GetSalesAnalytics and proc_Analytics_GetTopProducts
-- Dependencies: V045 (Analytics dashboard proc)

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Analytics_GetSalesAnalytics', 'P') IS NOT NULL
        DROP PROCEDURE proc_Analytics_GetSalesAnalytics;

    IF OBJECT_ID('proc_Analytics_GetTopProducts', 'P') IS NOT NULL
        DROP PROCEDURE proc_Analytics_GetTopProducts;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Analytics_GetSalesAnalytics
-- Returns summary row + daily breakdown for a date range
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
            ISNULL(SUM(Total), 0)   AS TotalRevenue,
            COUNT(1)                AS TotalOrders
        FROM t.tblOrder
        WHERE IsDeleted = 0
          AND CreatedOn >= @From
          AND CreatedOn <= @To;

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
-- proc_Analytics_GetTopProducts
-- Returns top N products by units sold in a date range
-- =========================================================
CREATE PROCEDURE proc_Analytics_GetTopProducts
    @From  DATETIME2,
    @To    DATETIME2,
    @Top   INT = 10
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT TOP (@Top)
            p.ProductId,
            p.Name                           AS ProductName,
            p.ImageUrl,
            SUM(ol.Quantity)                 AS TotalUnitsSold,
            ISNULL(SUM(ol.Quantity * ol.UnitPrice), 0) AS TotalRevenue
        FROM t.tblOrderLine ol
        INNER JOIN t.tblOrder o
            ON o.OrderId = ol.OrderId
           AND o.IsDeleted = 0
           AND o.CreatedOn >= @From
           AND o.CreatedOn <= @To
        INNER JOIN m.tblProduct p
            ON p.ProductId = ol.ProductId
           AND p.IsDeleted = 0
        WHERE ol.IsDeleted = 0
        GROUP BY p.ProductId, p.Name, p.ImageUrl
        ORDER BY TotalUnitsSold DESC;

    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Analytics_GetTopProducts', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V048')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V048', 'AddAnalyticsSalesAndTopProductsProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
