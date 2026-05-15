-- V049_FixAnalyticsGetTopProductsProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Fix proc_Analytics_GetTopProducts — correct join path through tblProductVariant,
--              use Id (not ProductId) as tblProduct/tblOrder PK, remove IsDeleted from tblOrderLine
-- Dependencies: V048

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;
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
-- proc_Analytics_GetTopProducts
-- tblOrderLine has no IsDeleted; join to tblProduct goes
-- through tblProductVariant (tblOrderLine.ProductVariantId)
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
            p.Id                                       AS ProductId,
            p.Name                                     AS ProductName,
            p.ImageUrl,
            SUM(ol.Quantity)                           AS TotalUnitsSold,
            ISNULL(SUM(ol.Quantity * ol.UnitPrice), 0) AS TotalRevenue
        FROM t.tblOrderLine ol
        INNER JOIN t.tblOrder o
            ON o.Id = ol.OrderId
           AND o.IsDeleted = 0
           AND o.CreatedOn >= @From
           AND o.CreatedOn <= @To
        INNER JOIN m.tblProductVariant pv
            ON pv.Id = ol.ProductVariantId
           AND pv.IsDeleted = 0
        INNER JOIN m.tblProduct p
            ON p.Id = pv.ProductId
           AND p.IsDeleted = 0
        GROUP BY p.Id, p.Name, p.ImageUrl
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
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V049')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V049', 'FixAnalyticsGetTopProductsProcedure');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
