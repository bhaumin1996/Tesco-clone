-- InsertTescoProducts.sql
-- Scraped from Tesco.com

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;

DECLARE @AdminId INT = 1;
DECLARE @DepartmentId INT;
DECLARE @CategoryId INT;

-- 1. Ensure Department exists
IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'fresh-food')
BEGIN
    INSERT INTO m.tblDepartment (Name, Slug, DisplayOrder, RecordStatusId, CreatedBy)
    VALUES ('Fresh Food', 'fresh-food', 1, 1, @AdminId);
END
SELECT @DepartmentId = Id FROM m.tblDepartment WHERE Slug = 'fresh-food';

-- 2. Ensure Category exists
IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'fresh-food-all')
BEGIN
    INSERT INTO m.tblCategory (DepartmentId, Name, Slug, DisplayOrder, RecordStatusId, CreatedBy)
    VALUES (@DepartmentId, 'Fresh Food All', 'fresh-food-all', 1, 1, @AdminId);
END
SELECT @CategoryId = Id FROM m.tblCategory WHERE Slug = 'fresh-food-all';

-- 3. Function-like logic for Brand and Product insertion
-- We will use a temporary table to hold the scraped data for cleaner insertion
CREATE TABLE #ScrapedProducts (
    ProductName NVARCHAR(500),
    BrandName NVARCHAR(200),
    BasePrice DECIMAL(10, 2),
    ClubcardPrice DECIMAL(10, 2),
    Description NVARCHAR(MAX),
    ImageUrl NVARCHAR(500)
);

INSERT INTO #ScrapedProducts (ProductName, BrandName, BasePrice, ClubcardPrice, Description, ImageUrl)
VALUES 
('Tesco Finest Tuscan Sausage Orecchiette 750g', 'Tesco Finest', 8.00, 6.50, 'Cooked orecchiette pasta with a pork sausage meat crumb in a spicy red wine sauce, topped with a Parmigiano Reggiano cheese sachet and fresh parsley.', 'https://www.tesco.com/shop/en-GB/products/323504227'),
('Tesco Chicken Alfredo with tagliatelle 400g', 'Tesco', 3.75, NULL, 'Tagliatelle with chicken breast pieces in a creamy cheese sauce.', 'https://www.tesco.com/shop/en-GB/products/323315727'),
('Muller Corner Vanilla & Banana Yogurts with Chocolate Balls & Flakes 6 x 124g', 'Muller Corner', 4.00, NULL, 'Vanilla flavour yogurt with milk & white chocolate coated puffed rice balls (8%) on the side x3. Banana yogurt with milk chocolate coated cornflakes (8%) on the side x3.', 'https://www.tesco.com/shop/en-GB/products/311937292'),
('Tesco British Salted Block Butter 250G', 'Tesco', 1.99, NULL, '100% British milk salted butter. Suitable for vegetarians.', 'https://www.tesco.com/shop/en-GB/products/290920510'),
('Tesco British Unsalted Butter 250G', 'Tesco', 1.99, NULL, '100% British milk unsalted butter. Suitable for vegetarians.', 'https://www.tesco.com/shop/en-GB/products/290921181');

-- Iterate and Insert
DECLARE @PName NVARCHAR(500), @BName NVARCHAR(200), @BPrice DECIMAL(10, 2), @CPrice DECIMAL(10, 2), @Desc NVARCHAR(MAX), @Img NVARCHAR(500);
DECLARE @BrandId INT;
DECLARE @ProductId INT;
DECLARE @Slug NVARCHAR(500);

DECLARE prod_cursor CURSOR FOR 
SELECT ProductName, BrandName, BasePrice, ClubcardPrice, Description, ImageUrl FROM #ScrapedProducts;

OPEN prod_cursor;
FETCH NEXT FROM prod_cursor INTO @PName, @BName, @BPrice, @CPrice, @Desc, @Img;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Ensure Brand exists
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Name = @BName)
    BEGIN
        SET @Slug = LOWER(REPLACE(REPLACE(REPLACE(@BName, ' ', '-'), '&', 'and'), '.', ''));
        INSERT INTO m.tblBrand (Name, Slug, RecordStatusId, CreatedBy)
        VALUES (@BName, @Slug, 1, @AdminId);
    END
    SELECT @BrandId = Id FROM m.tblBrand WHERE Name = @BName;

    -- Generate Product Slug
    SET @Slug = LOWER(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@PName, ' ', '-'), '&', 'and'), '.', ''), '(', ''), ')', ''));
    
    -- Insert Product if not exists
    IF NOT EXISTS (SELECT 1 FROM m.tblProduct WHERE Slug = @Slug)
    BEGIN
        INSERT INTO m.tblProduct (CategoryId, BrandId, Name, Slug, Description, BasePrice, ClubcardPrice, ImageUrl, IsAvailable, RecordStatusId, CreatedBy)
        VALUES (@CategoryId, @BrandId, @PName, @Slug, @Desc, @BPrice, @CPrice, @Img, 1, 1, @AdminId);
        
        SET @ProductId = SCOPE_IDENTITY();
        PRINT 'Inserted product: ' + @PName;

        -- Insert default variant
        DECLARE @Sku NVARCHAR(100) = 'SKU-' + CAST(@ProductId AS NVARCHAR(10)) + '-' + LEFT(REPLACE(NEWID(), '-', ''), 8);
        INSERT INTO m.tblProductVariant (ProductId, Sku, VariantName, PriceModifier, StockQuantity, RecordStatusId, CreatedBy)
        VALUES (@ProductId, @Sku, 'Standard', 0, 100, 1, @AdminId);
        PRINT 'Inserted variant for: ' + @PName;
    END
    ELSE
    BEGIN
        PRINT 'Product already exists: ' + @PName;
    END

    FETCH NEXT FROM prod_cursor INTO @PName, @BName, @BPrice, @CPrice, @Desc, @Img;
END

CLOSE prod_cursor;
DEALLOCATE prod_cursor;

DROP TABLE #ScrapedProducts;
GO
