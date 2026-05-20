-- V097_MarketplaceCommissionEngine.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Commission engine for the marketplace.
--              Adds m.tblCommissionTier (category-level commission rates),
--              fn_Marketplace_CalculateCommission (computes commission amount),
--              proc_Marketplace_RecordCommission (writes t.tblCommission on order placement),
--              proc_Marketplace_GetSellerCommissionSummary (seller earnings summary).
-- Dependencies: V001-V012, V028, V096

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- PART 1: m.tblCommissionTier reference table
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblCommissionTier')
    BEGIN
        CREATE TABLE m.tblCommissionTier (
            Id          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Name        NVARCHAR(100) NOT NULL,
            CategoryId  INT NULL,           -- NULL = global default tier
            Rate        DECIMAL(5,2) NOT NULL,  -- e.g. 12.50 for 12.5%
            IsDefault   BIT NOT NULL DEFAULT 0,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy   INT NOT NULL DEFAULT 1,
            CreatedOn   DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy  INT NULL,
            ModifiedOn  DATETIME2 NULL,
            IsDeleted   BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblCommissionTier_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblCommissionTier_CategoryId ON m.tblCommissionTier (CategoryId);

        -- Seed a global default tier at 10%
        INSERT INTO m.tblCommissionTier (Name, CategoryId, Rate, IsDefault, CreatedBy)
        VALUES ('Default 10%', NULL, 10.00, 1, 1);
    END

    -- Add CommissionTierId FK column to t.tblSeller if not present
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='CommissionTierId')
        ALTER TABLE t.tblSeller ADD CommissionTierId INT NULL;

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V097_Part1')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V097_Part1', 'CommissionEngine_TierTable');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V097_Part1', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 2: Drop/create function and stored procedures
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('fn_Marketplace_CalculateCommission',        'FN') IS NOT NULL DROP FUNCTION fn_Marketplace_CalculateCommission;
    IF OBJECT_ID('proc_Marketplace_RecordCommission',         'P')  IS NOT NULL DROP PROCEDURE proc_Marketplace_RecordCommission;
    IF OBJECT_ID('proc_Marketplace_GetSellerCommissionSummary','P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerCommissionSummary;
    IF OBJECT_ID('proc_Marketplace_GetCommissionTiers',       'P')  IS NOT NULL DROP PROCEDURE proc_Marketplace_GetCommissionTiers;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- fn_Marketplace_CalculateCommission
-- Returns commission amount for a given sale amount and seller.
-- Resolves tier: seller-specific tier → category-level tier → global default.
-- =========================================================
CREATE FUNCTION fn_Marketplace_CalculateCommission
(
    @SaleAmount DECIMAL(10,2),
    @SellerId   INT,
    @CategoryId INT = NULL
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Rate DECIMAL(5,2);

    -- 1. Seller-specific tier
    SELECT TOP 1 @Rate = ct.Rate
    FROM t.tblSeller s
    INNER JOIN m.tblCommissionTier ct ON ct.Id = s.CommissionTierId
    WHERE s.Id = @SellerId AND s.IsDeleted = 0 AND ct.IsDeleted = 0;

    -- 2. Category-level tier (if no seller-specific tier and CategoryId provided)
    IF @Rate IS NULL AND @CategoryId IS NOT NULL
    BEGIN
        SELECT TOP 1 @Rate = Rate
        FROM m.tblCommissionTier
        WHERE CategoryId = @CategoryId AND IsDeleted = 0
        ORDER BY Id;
    END

    -- 3. Global default tier
    IF @Rate IS NULL
    BEGIN
        SELECT TOP 1 @Rate = Rate
        FROM m.tblCommissionTier
        WHERE IsDefault = 1 AND IsDeleted = 0;
    END

    -- Fallback to 10% if no tier found
    IF @Rate IS NULL SET @Rate = 10.00;

    RETURN ROUND(@SaleAmount * @Rate / 100.0, 2);
END
GO

-- =========================================================
-- proc_Marketplace_RecordCommission
-- Called after order placement for each marketplace order line.
-- =========================================================
CREATE PROCEDURE proc_Marketplace_RecordCommission
    @SellerId    INT,
    @OrderLineId INT,
    @SaleAmount  DECIMAL(10,2),
    @CategoryId  INT = NULL,
    @CreatedBy   INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CommissionAmount DECIMAL(10,2) =
            dbo.fn_Marketplace_CalculateCommission(@SaleAmount, @SellerId, @CategoryId);

        INSERT INTO t.tblCommission
            (SellerId, OrderLineId, SaleAmount, CommissionAmount, RecordStatusId, CreatedBy, CreatedOn, IsDeleted)
        VALUES
            (@SellerId, @OrderLineId, @SaleAmount, @CommissionAmount, 1, @CreatedBy, GETUTCDATE(), 0);

        DECLARE @CommissionId BIGINT = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCommission', CAST(@CommissionId AS INT), 'CREATE',
                CONCAT('{"SellerId":', @SellerId, ',"SaleAmount":', @SaleAmount,
                       ',"CommissionAmount":', @CommissionAmount, '}'),
                @CreatedBy, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @CommissionId AS CommissionId, @CommissionAmount AS CommissionAmount;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_RecordCommission', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Marketplace_GetSellerCommissionSummary
-- Returns aggregated commission stats for a seller (for the finance page).
-- =========================================================
CREATE PROCEDURE proc_Marketplace_GetSellerCommissionSummary
    @SellerId   INT,
    @FromDate   DATETIME2 = NULL,
    @ToDate     DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            SUM(c.SaleAmount)        AS TotalSales,
            SUM(c.CommissionAmount)  AS TotalCommission,
            SUM(c.SaleAmount - c.CommissionAmount) AS NetEarnings,
            COUNT(*)                 AS TransactionCount
        FROM t.tblCommission c
        WHERE c.SellerId = @SellerId
          AND c.IsDeleted = 0
          AND (@FromDate IS NULL OR c.CreatedOn >= @FromDate)
          AND (@ToDate   IS NULL OR c.CreatedOn <= @ToDate);
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_GetSellerCommissionSummary', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Marketplace_GetCommissionTiers
-- Returns all active commission tiers (for admin management).
-- =========================================================
CREATE PROCEDURE proc_Marketplace_GetCommissionTiers
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            ct.Id,
            ct.Name,
            ct.CategoryId,
            c.Name AS CategoryName,
            ct.Rate,
            ct.IsDefault,
            ct.CreatedOn,
            ct.ModifiedOn
        FROM m.tblCommissionTier ct
        LEFT JOIN m.tblCategory c ON c.Id = ct.CategoryId AND c.IsDeleted = 0
        WHERE ct.IsDeleted = 0
        ORDER BY ct.IsDefault DESC, ct.Rate;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_GetCommissionTiers', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V097')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V097', 'MarketplaceCommissionEngine');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
