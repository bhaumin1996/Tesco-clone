-- V057_AddLowStockThresholdAndCreateProductVariant.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Add LowStockThreshold column to m.tblProductVariant,
--              update proc_Admin_GetInventory to use the real column,
--              and add proc_Admin_CreateProductVariant for first-time stock entry.
-- Dependencies: V001-V056

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- PART 1 – Add LowStockThreshold column
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblProductVariant'
          AND COLUMN_NAME = 'LowStockThreshold'
    )
    BEGIN
        ALTER TABLE m.tblProductVariant
            ADD LowStockThreshold INT NOT NULL DEFAULT 10;

        PRINT 'Column [LowStockThreshold] added to [m].[tblProductVariant].';
    END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V057_Part1', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 2 – Drop procedures before recreating
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetInventory',         'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetInventory;
    IF OBJECT_ID('proc_Admin_CreateProductVariant', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreateProductVariant;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetInventory  (updated: use real LowStockThreshold column)
-- =========================================================
CREATE PROCEDURE proc_Admin_GetInventory
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            pv.Id                                                                          AS ProductVariantId,
            p.Id                                                                           AS ProductId,
            p.Name                                                                         AS ProductName,
            pv.Sku,
            pv.StockQuantity,
            pv.LowStockThreshold,
            CAST(CASE WHEN pv.StockQuantity <= pv.LowStockThreshold THEN 1 ELSE 0 END AS BIT) AS IsLowStock
        FROM m.tblProductVariant pv
        INNER JOIN m.tblProduct p ON p.Id = pv.ProductId AND p.IsDeleted = 0
        WHERE pv.IsDeleted = 0
        ORDER BY pv.StockQuantity ASC, p.Name ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetInventory', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreateProductVariant
-- Creates a new product variant with initial stock for first-time inventory entry.
-- Raises an error if the SKU already exists or the product does not exist.
-- =========================================================
CREATE PROCEDURE proc_Admin_CreateProductVariant
    @ProductId          INT,
    @Sku                NVARCHAR(100),
    @VariantName        NVARCHAR(200) = NULL,
    @Barcode            NVARCHAR(50)  = NULL,
    @InitialQuantity    INT           = 0,
    @LowStockThreshold  INT           = 10,
    @AdminId            INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate product exists
        IF NOT EXISTS (
            SELECT 1 FROM m.tblProduct WHERE Id = @ProductId AND IsDeleted = 0
        )
        BEGIN
            RAISERROR('Product not found.', 16, 1);
        END

        -- Validate SKU uniqueness
        IF EXISTS (
            SELECT 1 FROM m.tblProductVariant WHERE Sku = @Sku AND IsDeleted = 0
        )
        BEGIN
            RAISERROR('A variant with this SKU already exists.', 16, 1);
        END

        DECLARE @VariantId INT;

        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, Barcode, StockQuantity, LowStockThreshold,
             RecordStatusId, CreatedBy, CreatedOn, IsDeleted)
        VALUES
            (@ProductId, @Sku, @VariantName, @Barcode, @InitialQuantity, @LowStockThreshold,
             1, @AdminId, GETUTCDATE(), 0);

        SET @VariantId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES (
            'tblProductVariant',
            @VariantId,
            'INSERT',
            CONCAT(
                '{"ProductId":', @ProductId,
                ',"Sku":"', @Sku,
                '","InitialQuantity":', @InitialQuantity,
                ',"LowStockThreshold":', @LowStockThreshold, '}'
            ),
            @AdminId,
            GETUTCDATE()
        );

        COMMIT TRANSACTION;

        SELECT @VariantId AS VariantId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreateProductVariant', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V057')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V057', 'AddLowStockThresholdAndCreateProductVariant');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
