-- V056_SeedProductVariants.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Insert 10 additional product variants (size / pack alternatives) across
--              10 seed products from V026. Each product already has a default Standard
--              variant from V026/V042; these add a second size or pack-size option.
-- Dependencies: V006 (CreateCatalogueTables), V026 (seed_test_products), V042 (default variants)

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Admin INT = 1;

    -- Product ID lookups by slug
    DECLARE @IdMilk          INT = (SELECT Id FROM m.tblProduct WHERE Slug = 'tesco-whole-milk-2-pints'          AND IsDeleted = 0);
    DECLARE @IdCoke          INT = (SELECT Id FROM m.tblProduct WHERE Slug = 'coca-cola-original-12-pack'        AND IsDeleted = 0);
    DECLARE @IdDairyMilk     INT = (SELECT Id FROM m.tblProduct WHERE Slug = 'cadbury-dairy-milk-200g'           AND IsDeleted = 0);
    DECLARE @IdWalkers       INT = (SELECT Id FROM m.tblProduct WHERE Slug = 'walkers-ready-salted-6-pack'       AND IsDeleted = 0);
    DECLARE @IdBeans         INT = (SELECT Id FROM m.tblProduct WHERE Slug = 'heinz-baked-beans-415g'            AND IsDeleted = 0);
    DECLARE @IdCornFlakes    INT = (SELECT Id FROM m.tblProduct WHERE Slug = 'kelloggs-corn-flakes-500g'         AND IsDeleted = 0);
    DECLARE @IdAriel         INT = (SELECT Id FROM m.tblProduct WHERE Slug = 'ariel-all-in-1-pods-30'            AND IsDeleted = 0);
    DECLARE @IdPedigree      INT = (SELECT Id FROM m.tblProduct WHERE Slug = 'pedigree-adult-dry-chicken-3kg'    AND IsDeleted = 0);
    DECLARE @IdLurpak        INT = (SELECT Id FROM m.tblProduct WHERE Slug = 'lurpak-slightly-salted-butter-250g' AND IsDeleted = 0);
    DECLARE @IdSpaghetti     INT = (SELECT Id FROM m.tblProduct WHERE Slug = 'tesco-spaghetti-500g'              AND IsDeleted = 0);

    -- ── 1. Tesco Whole Milk — 4 Pints ────────────────────────────────────────
    IF @IdMilk IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE Sku = 'SKU-MILK-4PT' AND IsDeleted = 0)
        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, PriceModifier, StockQuantity, Barcode, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@IdMilk, 'SKU-MILK-4PT', '4 Pints (2.272L)', 0.90, 80, '5000436340728', 1, @Admin, GETUTCDATE());

    -- ── 2. Coca-Cola Original — 24-Pack ──────────────────────────────────────
    IF @IdCoke IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE Sku = 'SKU-COKE-24PK' AND IsDeleted = 0)
        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, PriceModifier, StockQuantity, Barcode, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@IdCoke, 'SKU-COKE-24PK', '24 x 330ml', 6.50, 50, '5449000214911', 1, @Admin, GETUTCDATE());

    -- ── 3. Cadbury Dairy Milk — 360g ─────────────────────────────────────────
    IF @IdDairyMilk IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE Sku = 'SKU-CDM-360G' AND IsDeleted = 0)
        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, PriceModifier, StockQuantity, Barcode, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@IdDairyMilk, 'SKU-CDM-360G', '360g', 1.80, 60, '7622210952196', 1, @Admin, GETUTCDATE());

    -- ── 4. Walkers Ready Salted — 12-Pack ────────────────────────────────────
    IF @IdWalkers IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE Sku = 'SKU-WLK-RS-12PK' AND IsDeleted = 0)
        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, PriceModifier, StockQuantity, Barcode, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@IdWalkers, 'SKU-WLK-RS-12PK', '12 x 25g', 2.25, 40, '5000328530008', 1, @Admin, GETUTCDATE());

    -- ── 5. Heinz Baked Beans — 200g (Small) ──────────────────────────────────
    IF @IdBeans IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE Sku = 'SKU-HNZ-BB-200G' AND IsDeleted = 0)
        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, PriceModifier, StockQuantity, Barcode, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@IdBeans, 'SKU-HNZ-BB-200G', '200g', -0.35, 90, '5000157024793', 1, @Admin, GETUTCDATE());

    -- ── 6. Kelloggs Corn Flakes — 1kg ────────────────────────────────────────
    IF @IdCornFlakes IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE Sku = 'SKU-KLG-CF-1KG' AND IsDeleted = 0)
        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, PriceModifier, StockQuantity, Barcode, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@IdCornFlakes, 'SKU-KLG-CF-1KG', '1kg', 1.50, 55, '5010028614891', 1, @Admin, GETUTCDATE());

    -- ── 7. Ariel All-in-1 Pods — 60 Washes ──────────────────────────────────
    IF @IdAriel IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE Sku = 'SKU-ARL-60W' AND IsDeleted = 0)
        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, PriceModifier, StockQuantity, Barcode, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@IdAriel, 'SKU-ARL-60W', '60 Washes', 6.50, 35, '8001090791009', 1, @Admin, GETUTCDATE());

    -- ── 8. Pedigree Adult Dry — 7.5kg ────────────────────────────────────────
    IF @IdPedigree IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE Sku = 'SKU-PDG-7KG5' AND IsDeleted = 0)
        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, PriceModifier, StockQuantity, Barcode, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@IdPedigree, 'SKU-PDG-7KG5', '7.5kg', 11.50, 25, '3065890133994', 1, @Admin, GETUTCDATE());

    -- ── 9. Lurpak Slightly Salted Butter — 500g ───────────────────────────────
    IF @IdLurpak IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE Sku = 'SKU-LPK-500G' AND IsDeleted = 0)
        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, PriceModifier, StockQuantity, Barcode, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@IdLurpak, 'SKU-LPK-500G', '500g', 3.25, 45, '5740900560118', 1, @Admin, GETUTCDATE());

    -- ── 10. Tesco Spaghetti — 1kg ─────────────────────────────────────────────
    IF @IdSpaghetti IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE Sku = 'SKU-TSC-SPG-1KG' AND IsDeleted = 0)
        INSERT INTO m.tblProductVariant
            (ProductId, Sku, VariantName, PriceModifier, StockQuantity, Barcode, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@IdSpaghetti, 'SKU-TSC-SPG-1KG', '1kg', 0.55, 70, '5051790000674', 1, @Admin, GETUTCDATE());

    -- ── Audit log ─────────────────────────────────────────────────────────────
    INSERT INTO t.tblAuditLog (TableName, RecordId, Action, OldValues, NewValues, ChangedBy, ChangedOn)
    VALUES (
        'm.tblProductVariant',
        0,
        'INSERT',
        NULL,
        N'{"operation":"V056_SeedProductVariants","description":"10 additional size/pack variants across 10 seed products"}',
        @Admin,
        GETUTCDATE()
    );

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V056')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V056', 'SeedProductVariants');

    COMMIT TRANSACTION;
    PRINT 'V056_SeedProductVariants.sql completed. Up to 10 variants inserted.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V056_SeedProductVariants', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO
