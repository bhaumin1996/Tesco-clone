-- V107_AddMarketplaceAnalyticsProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Create proc_Analytics_GetMarketplaceAnalytics for marketplace KPI and top seller analytics.
-- Dependencies: V102

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Analytics_GetMarketplaceAnalytics', 'P') IS NOT NULL
        DROP PROCEDURE proc_Analytics_GetMarketplaceAnalytics;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Analytics_GetMarketplaceAnalytics
-- Result set 1: Marketplace KPIs
-- Result set 2: Top 10 Marketplace Sellers by Revenue
-- =========================================================
CREATE PROCEDURE proc_Analytics_GetMarketplaceAnalytics
    @From  DATETIME2,
    @To    DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- 1. Calculate GMV and Total Orders
        DECLARE @GMV DECIMAL(18,2) = 0.00;
        DECLARE @TotalOrders INT = 0;

        SELECT 
            @GMV = ISNULL(SUM(ol.LineTotal), 0.00),
            @TotalOrders = COUNT(DISTINCT ol.OrderId)
        FROM t.tblOrderLine ol
        INNER JOIN t.tblOrder o ON o.Id = ol.OrderId
        WHERE ol.IsMarketplace = 1
          AND o.IsDeleted = 0
          AND o.CreatedOn >= @From
          AND o.CreatedOn <= @To;

        -- 2. Average Order Value
        DECLARE @AverageOrderValue DECIMAL(18,2) = 0.00;
        IF @TotalOrders > 0
            SET @AverageOrderValue = @GMV / @TotalOrders;

        -- 3. Dispute Rate
        DECLARE @DisputeCount INT = 0;
        SELECT @DisputeCount = COUNT(1)
        FROM t.tblDispute
        WHERE IsDeleted = 0
          AND CreatedOn >= @From
          AND CreatedOn <= @To;

        DECLARE @DisputeRate DECIMAL(5,2) = 0.00;
        IF @TotalOrders > 0
            SET @DisputeRate = CAST((@DisputeCount * 100.0) / @TotalOrders AS DECIMAL(5,2));

        -- 4. Return Rate
        DECLARE @ReturnCount INT = 0;
        SELECT @ReturnCount = COUNT(1)
        FROM t.tblMarketplaceReturn
        WHERE IsDeleted = 0
          AND CreatedOn >= @From
          AND CreatedOn <= @To;

        DECLARE @ReturnRate DECIMAL(5,2) = 0.00;
        IF @TotalOrders > 0
            SET @ReturnRate = CAST((@ReturnCount * 100.0) / @TotalOrders AS DECIMAL(5,2));

        -- 5. New Applications Count
        DECLARE @NewApplications INT = 0;
        SELECT @NewApplications = COUNT(1)
        FROM t.tblSellerApplication
        WHERE IsDeleted = 0
          AND CreatedOn >= @From
          AND CreatedOn <= @To;

        -- Result Set 1: Marketplace KPIs
        SELECT 
            @GMV AS Gmv,
            @TotalOrders AS TotalOrders,
            @AverageOrderValue AS AverageOrderValue,
            @DisputeRate AS DisputeRate,
            @ReturnRate AS ReturnRate,
            @NewApplications AS NewApplicationsCount;

        -- Result Set 2: Top Sellers
        SELECT TOP (10)
            s.Id AS SellerId,
            s.BusinessName,
            ISNULL(SUM(ol.LineTotal), 0.00) AS Revenue,
            COUNT(DISTINCT ol.OrderId) AS OrderCount
        FROM t.tblSeller s
        INNER JOIN t.tblOrderLine ol ON ol.SellerId = s.Id
        INNER JOIN t.tblOrder o ON o.Id = ol.OrderId
        WHERE s.IsDeleted = 0
          AND ol.IsMarketplace = 1
          AND o.IsDeleted = 0
          AND o.CreatedOn >= @From
          AND o.CreatedOn <= @To
        GROUP BY s.Id, s.BusinessName
        ORDER BY Revenue DESC;

    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Analytics_GetMarketplaceAnalytics', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V107')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V107', 'AddMarketplaceAnalyticsProcedure');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
