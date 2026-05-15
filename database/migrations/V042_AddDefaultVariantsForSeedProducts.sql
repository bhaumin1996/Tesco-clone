-- V042_AddDefaultVariantsForSeedProducts.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Add a default Standard variant (StockQuantity=100) for every product in
--              m.tblProduct that has no active entry in m.tblProductVariant.
--              Fixes the empty-cart bug caused by V026 seed inserting products without variants.
-- Dependencies: V006 (CreateCatalogueTables), V026 (seed products)

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Admin INT = 1;

    INSERT INTO m.tblProductVariant
        (ProductId, Sku, VariantName, PriceModifier, StockQuantity, RecordStatusId, CreatedBy, CreatedOn)
    SELECT
        p.Id,
        'SKU-' + CAST(p.Id AS NVARCHAR(10)) + '-DEFAULT',
        'Standard',
        0,
        100,
        1,
        @Admin,
        GETUTCDATE()
    FROM m.tblProduct p
    WHERE p.IsDeleted = 0
      AND NOT EXISTS (
          SELECT 1
          FROM   m.tblProductVariant pv
          WHERE  pv.ProductId      = p.Id
            AND  pv.IsDeleted      = 0
            AND  pv.RecordStatusId = 1
      );

    DECLARE @Inserted INT = @@ROWCOUNT;

    INSERT INTO t.tblAuditLog (TableName, RecordId, Action, OldValues, NewValues, ChangedBy, ChangedOn)
    VALUES (
        'm.tblProductVariant',
        0,
        'INSERT',
        NULL,
        N'{"operation":"V042_AddDefaultVariantsForSeedProducts","rowsInserted":' + CAST(@Inserted AS NVARCHAR(10)) + N'}',
        @Admin,
        GETUTCDATE()
    );

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V042')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V042', 'AddDefaultVariantsForSeedProducts');

    COMMIT TRANSACTION;
    PRINT CAST(@Inserted AS NVARCHAR(10)) + ' default variants inserted.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V042_AddDefaultVariantsForSeedProducts', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO
