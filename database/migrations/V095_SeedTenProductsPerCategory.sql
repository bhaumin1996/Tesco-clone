-- V095_SeedTenProductsPerCategory.sql
-- Author: Tesco Clone
-- Date: 2026-05-19
-- Description: Add 10 products to every single category with unique images.

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Admin INT = 1;
    DECLARE @DefaultBrandId INT;

    -- Ensure a default brand exists
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'tesco' AND IsDeleted = 0)
    BEGIN
        INSERT INTO m.tblBrand (Name, Slug, RecordStatusId, CreatedBy) VALUES ('Tesco', 'tesco', 1, @Admin);
    END
    SELECT TOP 1 @DefaultBrandId = Id FROM m.tblBrand WHERE Slug = 'tesco' AND IsDeleted = 0;

    DECLARE @CatId INT, @CatName NVARCHAR(200), @CatSlug NVARCHAR(200);
    DECLARE @i INT, @ProdName NVARCHAR(500), @ProdSlug NVARCHAR(500), @ProdImageUrl NVARCHAR(500), @GuidStr NVARCHAR(36);
    DECLARE @NewProdId INT;

    DECLARE cat_cur CURSOR LOCAL FOR
    SELECT Id, Name, Slug
    FROM m.tblCategory
    WHERE IsDeleted = 0;

    OPEN cat_cur;
    FETCH NEXT FROM cat_cur INTO @CatId, @CatName, @CatSlug;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @i = 1;

        -- Insert exactly 10 products for each category
        WHILE @i <= 10
        BEGIN
            SET @GuidStr = CAST(NEWID() AS NVARCHAR(36));
            SET @ProdName = @CatName + ' Item ' + CAST(@i AS NVARCHAR(10)) + ' ' + SUBSTRING(@GuidStr, 1, 4);
            SET @ProdSlug = @CatSlug + '-item-' + CAST(@i AS NVARCHAR(10)) + '-' + SUBSTRING(@GuidStr, 1, 8);
            
            -- Unique image for each product using picsum
            SET @ProdImageUrl = 'https://picsum.photos/seed/' + @GuidStr + '/300/300';

            INSERT INTO m.tblProduct (CategoryId, BrandId, Name, Slug, Description, BasePrice, ClubcardPrice, ImageUrl, IsAvailable, RecordStatusId, CreatedBy)
            VALUES (@CatId, @DefaultBrandId, @ProdName, @ProdSlug, 'A dynamically seeded product for ' + @CatName + ' category.',
                    ROUND((RAND() * 5) + 1.00, 2), NULL, @ProdImageUrl, 1, 1, @Admin);

            SET @NewProdId = SCOPE_IDENTITY();

            -- Variant
            INSERT INTO m.tblProductVariant (ProductId, Sku, VariantName, PriceModifier, StockQuantity, RecordStatusId, CreatedBy)
            VALUES (@NewProdId, 'SKU-' + CAST(@NewProdId AS NVARCHAR(20)), 'Default', 0, 100, 1, @Admin);

            -- Inventory
            IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblInventory')
            BEGIN
                INSERT INTO t.tblInventory (ProductId, QuantityOnHand, ReorderLevel, RecordStatusId, CreatedBy)
                VALUES (@NewProdId, 100, 10, 1, @Admin);
            END

            SET @i = @i + 1;
        END

        FETCH NEXT FROM cat_cur INTO @CatId, @CatName, @CatSlug;
    END

    CLOSE cat_cur; DEALLOCATE cat_cur;

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V095')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V095', 'SeedTenProductsPerCategory');

    COMMIT TRANSACTION;
    PRINT 'V095 completed successfully. Added 10 products to each category.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V095_SeedTenProductsPerCategory.sql', ERROR_MESSAGE(), GETUTCDATE());
    
    THROW;
END CATCH
