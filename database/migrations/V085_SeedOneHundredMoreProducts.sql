-- V085_SeedOneHundredMoreProducts.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Seed exactly 100 more realistic Tesco-style products across departments,
--              complete with variants (size/unit labels), stock/inventory levels,
--              and auto-link them to existing promotions.
-- Dependencies: V001-V084

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Admin INT = 1;

    -- ================================================================
    -- 1. ENSURE BRANDS EXIST
    -- ================================================================
    DECLARE @Brands TABLE (Name NVARCHAR(200), Slug NVARCHAR(200));
    INSERT INTO @Brands VALUES
        ('Stella Artois',   'stella-artois'),
        ('Guinness',        'guinness'),
        ('Hardys',          'hardys'),
        ('Oyster Bay',      'oyster-bay'),
        ('Smirnoff',        'smirnoff'),
        ('Gordons',         'gordons'),
        ('Moet & Chandon',  'moet-chandon'),
        ('Ellas Kitchen',   'ellas-kitchen'),
        ('Aptamil',         'aptamil'),
        ('Huggies',         'huggies'),
        ('Aveeno',          'aveeno'),
        ('Carex',           'carex'),
        ('Head & Shoulders','head-shoulders'),
        ('Oral-B',          'oral-b'),
        ('Vaseline',        'vaseline'),
        ('Lynx',            'lynx'),
        ('Flash',           'flash'),
        ('Comfort',         'comfort'),
        ('Finish',          'finish'),
        ('Kleenex',         'kleenex'),
        ('Bakers',          'bakers'),
        ('Dreamies',        'dreamies'),
        ('Philadelphia',    'philadelphia'),
        ('Hovis',           'hovis'),
        ('Warburtons',      'warburtons'),
        ('Muller',          'muller'),
        ('Alpro',           'alpro'),
        ('Oreo',            'oreo'),
        ('Birds Eye',       'birds-eye'),
        ('McCain',          'mccain'),
        ('Aunt Bessies',    'aunt-bessies'),
        ('Haagen-Dazs',     'haagen-dazs'),
        ('Magnum',          'magnum'),
        ('Chicago Town',    'chicago-town'),
        ('Heinz',           'heinz'),
        ('John West',       'john-west'),
        ('Sarsons',         'sarsons'),
        ('Kelloggs',        'kelloggs'),
        ('Quaker',          'quaker'),
        ('PG Tips',         'pg-tips'),
        ('Kenco',           'kenco'),
        ('Hellmanns',       'hellmanns'),
        ('Coca-Cola',       'coca-cola'),
        ('Pepsi',           'pepsi'),
        ('Fanta',           'fanta'),
        ('Innocent',        'innocent'),
        ('Volvic',          'volvic'),
        ('Buxton',          'buxton'),
        ('Fairy',           'fairy'),
        ('Andrex',          'andrex'),
        ('Pedigree',        'pedigree'),
        ('Whiskas',         'whiskas'),
        ('Tesco',           'tesco'),
        ('Tesco Finest',    'tesco-finest'),
        ('Tesco Organic',   'tesco-organic');

    DECLARE @BrandName NVARCHAR(200), @BrandSlug NVARCHAR(200);
    DECLARE brand_cur CURSOR LOCAL FOR SELECT Name, Slug FROM @Brands;
    OPEN brand_cur;
    FETCH NEXT FROM brand_cur INTO @BrandName, @BrandSlug;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = @BrandSlug AND IsDeleted = 0)
            INSERT INTO m.tblBrand (Name, Slug, RecordStatusId, CreatedBy)
            VALUES (@BrandName, @BrandSlug, 1, @Admin);
        FETCH NEXT FROM brand_cur INTO @BrandName, @BrandSlug;
    END
    CLOSE brand_cur; DEALLOCATE brand_cur;

    -- ================================================================
    -- 2. CATEGORY ID LOOKUPS
    -- ================================================================
    DECLARE @CatFruitVeg        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'fruit-vegetables'     AND IsDeleted = 0);
    DECLARE @CatMeatFish        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'meat-fish'            AND IsDeleted = 0);
    DECLARE @CatDairy           INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'dairy-eggs-chilled'   AND IsDeleted = 0);
    DECLARE @CatReadyMeals      INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'ready-meals'          AND IsDeleted = 0);
    DECLARE @CatDeli            INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'deli'                 AND IsDeleted = 0);
    DECLARE @CatBread           INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'bread'                AND IsDeleted = 0);
    DECLARE @CatCakes           INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'cakes-biscuits'       AND IsDeleted = 0);
    DECLARE @CatFrozenMeals     INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-ready-meals'   AND IsDeleted = 0);
    DECLARE @CatFrozenPizza     INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-pizza'         AND IsDeleted = 0);
    DECLARE @CatFrozenSides     INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-chips-sides'   AND IsDeleted = 0);
    DECLARE @CatFrozenVeg       INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-vegetables'    AND IsDeleted = 0);
    DECLARE @CatIceCream        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'ice-cream-lollies'    AND IsDeleted = 0);
    DECLARE @CatPasta           INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'pasta-rice-grains'    AND IsDeleted = 0);
    DECLARE @CatTins            INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'tins-cans'            AND IsDeleted = 0);
    DECLARE @CatSnacks          INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'snacks-confectionery' AND IsDeleted = 0);
    DECLARE @CatCereals         INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'cereals-porridge'     AND IsDeleted = 0);
    DECLARE @CatSoftDrinks      INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'soft-drinks'          AND IsDeleted = 0);
    DECLARE @CatJuice           INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'fruit-juice-squash'   AND IsDeleted = 0);
    DECLARE @CatBeer            INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'beer-cider'           AND IsDeleted = 0);
    DECLARE @CatWine            INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'wine'                 AND IsDeleted = 0);
    DECLARE @CatSpirits         INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'spirits'              AND IsDeleted = 0);
    DECLARE @CatSparkling       INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'champagne-sparkling-wine' AND IsDeleted = 0);
    DECLARE @CatBabyFood        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'baby-food-milk'       AND IsDeleted = 0);
    DECLARE @CatBabyWipes       INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'nappies-wipes'        AND IsDeleted = 0);
    DECLARE @CatBabyToiletries  INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'baby-health-toiletries' AND IsDeleted = 0);
    DECLARE @CatDental          INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'dental'               AND IsDeleted = 0);
    DECLARE @CatBathShower      INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'bath-shower'          AND IsDeleted = 0);
    DECLARE @CatHairCare        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'hair-care'            AND IsDeleted = 0);
    DECLARE @CatSkinCare        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'skin-care'            AND IsDeleted = 0);
    DECLARE @CatGrooming        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'mens-grooming'        AND IsDeleted = 0);
    DECLARE @CatCleaning        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'cleaning'             AND IsDeleted = 0);
    DECLARE @CatLaundry         INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'laundry'              AND IsDeleted = 0);
    DECLARE @CatToiletPaper     INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'bathroom-toilet'      AND IsDeleted = 0);
    DECLARE @CatDogFood         INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'dog-food-accessories' AND IsDeleted = 0);
    DECLARE @CatCatFood         INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'cat-food-accessories' AND IsDeleted = 0);
    DECLARE @CatHotDrinks       INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'tea-coffee-hot-drinks' AND IsDeleted = 0);
    DECLARE @CatWorldFoods      INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'world-foods'          AND IsDeleted = 0);
    DECLARE @CatSauces          INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'condiments-sauces'     AND IsDeleted = 0);
    DECLARE @CatSoups           INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'soups-stocks-gravy'    AND IsDeleted = 0);
    DECLARE @CatBaking          INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'baking'               AND IsDeleted = 0);
    DECLARE @CatWater           INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'water'                AND IsDeleted = 0);

    -- Fallback default categories if any of the above are NULL
    SET @CatFruitVeg = ISNULL(@CatFruitVeg, 1);
    SET @CatMeatFish = ISNULL(@CatMeatFish, 2);
    SET @CatDairy = ISNULL(@CatDairy, 3);
    SET @CatBread = ISNULL(@CatBread, 4);
    SET @CatCakes = ISNULL(@CatCakes, 5);
    SET @CatFrozenMeals = ISNULL(@CatFrozenMeals, 6);
    SET @CatFrozenPizza = ISNULL(@CatFrozenPizza, 7);
    SET @CatIceCream = ISNULL(@CatIceCream, 8);
    SET @CatPasta = ISNULL(@CatPasta, 9);
    SET @CatTins = ISNULL(@CatTins, 10);
    SET @CatSnacks = ISNULL(@CatSnacks, 11);
    SET @CatCereals = ISNULL(@CatCereals, 12);
    SET @CatSoftDrinks = ISNULL(@CatSoftDrinks, 13);
    SET @CatJuice = ISNULL(@CatJuice, 14);
    SET @CatBeer = ISNULL(@CatBeer, 15);
    SET @CatWine = ISNULL(@CatWine, 16);
    SET @CatSpirits = ISNULL(@CatSpirits, 17);
    SET @CatSparkling = ISNULL(@CatSparkling, 18);
    SET @CatBabyFood = ISNULL(@CatBabyFood, 19);
    SET @CatBabyWipes = ISNULL(@CatBabyWipes, 20);
    SET @CatBabyToiletries = ISNULL(@CatBabyToiletries, 21);
    SET @CatDental = ISNULL(@CatDental, 22);
    SET @CatBathShower = ISNULL(@CatBathShower, 23);
    SET @CatHairCare = ISNULL(@CatHairCare, 24);
    SET @CatSkinCare = ISNULL(@CatSkinCare, 25);
    SET @CatGrooming = ISNULL(@CatGrooming, 26);
    SET @CatCleaning = ISNULL(@CatCleaning, 27);
    SET @CatLaundry = ISNULL(@CatLaundry, 28);
    SET @CatToiletPaper = ISNULL(@CatToiletPaper, 29);
    SET @CatDogFood = ISNULL(@CatDogFood, 30);
    SET @CatCatFood = ISNULL(@CatCatFood, 31);
    SET @CatHotDrinks = ISNULL(@CatHotDrinks, 32);
    SET @CatWorldFoods = ISNULL(@CatWorldFoods, 33);
    SET @CatSauces = ISNULL(@CatSauces, 34);
    SET @CatSoups = ISNULL(@CatSoups, 35);
    SET @CatBaking = ISNULL(@CatBaking, 36);
    SET @CatWater = ISNULL(@CatWater, 37);

    -- ================================================================
    -- 3. PRODUCT DATA LIST (100 ITEMS)
    -- ================================================================
    DECLARE @Products TABLE (
        CategoryId    INT,
        BrandSlug     NVARCHAR(200),
        Name          NVARCHAR(500),
        Slug          NVARCHAR(500),
        Description   NVARCHAR(MAX),
        BasePrice     DECIMAL(10,2),
        ClubcardPrice DECIMAL(10,2) NULL,
        ImageUrl      NVARCHAR(500),
        IsAvailable   BIT,
        VariantName   NVARCHAR(200),
        StockQuantity INT
    );

    INSERT INTO @Products VALUES
    -- ── 1. Fruit & Veg (11 Items) ──────────────────────────────────
    (@CatFruitVeg, 'tesco', 'Tesco Bananas 5 Pack', 'tesco-bananas-5-pack', 'Delicious sweet and ripe yellow bananas, pre-packed for convenience.', 0.90, 0.75, '/assets/images/categories/fruit-vegetables.jpg', 1, '5 Pack', 150),
    (@CatFruitVeg, 'tesco', 'Tesco Iceberg Lettuce Each', 'tesco-iceberg-lettuce-each', 'Crisp and refreshing iceberg lettuce, perfect for salads and wraps.', 0.75, NULL, '/assets/images/categories/fruit-vegetables.jpg', 1, 'Each', 100),
    (@CatFruitVeg, 'tesco', 'Tesco Cherry Tomatoes 250g', 'tesco-cherry-tomatoes-250g', 'Sweet and juicy cherry tomatoes, great for salads or roasting.', 1.00, 0.80, '/assets/images/categories/fruit-vegetables.jpg', 1, '250g', 130),
    (@CatFruitVeg, 'tesco', 'Tesco Baking Potatoes 4 Pack', 'tesco-baking-potatoes-4-pack', 'Fluffy and perfect for baking, mashing, or making homemade jacket potatoes.', 0.85, NULL, '/assets/images/categories/fruit-vegetables.jpg', 1, '4 Pack', 140),
    (@CatFruitVeg, 'tesco', 'Tesco Red Onions 1kg', 'tesco-red-onions-1kg', 'Sweet, mild red onions, great for eating raw in salads or cooking.', 1.10, 0.90, '/assets/images/categories/fruit-vegetables.jpg', 1, '1kg', 160),
    (@CatFruitVeg, 'tesco', 'Tesco Easy Peeler Satsumas 600g', 'tesco-easy-peeler-satsumas-600g', 'Sweet easy-to-peel satsumas, packed full of natural Vitamin C.', 1.50, NULL, '/assets/images/categories/fruit-vegetables.jpg', 1, '600g', 120),
    (@CatFruitVeg, 'tesco', 'Tesco Cucumber Each', 'tesco-cucumber-each', 'Cool and hydrating fresh English cucumber, perfect for snacking.', 0.70, NULL, '/assets/images/categories/fruit-vegetables.jpg', 1, 'Each', 110),
    (@CatFruitVeg, 'tesco', 'Tesco Hass Avocados 2 Pack', 'tesco-hass-avocados-2-pack', 'Rich and creamy Hass avocados, ready to eat and full of good fats.', 1.80, 1.40, '/assets/images/categories/fruit-vegetables.jpg', 1, '2 Pack', 90),
    (@CatFruitVeg, 'tesco-organic', 'Tesco Organic Baby Spinach 250g', 'tesco-organic-baby-spinach-250g', 'Fresh and healthy organic baby spinach, thoroughly washed and ready.', 1.50, 1.20, '/assets/images/categories/fruit-vegetables.jpg', 1, '250g', 80),
    (@CatFruitVeg, 'tesco', 'Tesco Lemon Loose', 'tesco-lemon-loose', 'Zesty fresh loose yellow lemon, great for adding flavor to food and drinks.', 0.30, NULL, '/assets/images/categories/fruit-vegetables.jpg', 1, 'Each', 200),
    (@CatFruitVeg, 'tesco', 'Tesco Gala Apples Loose', 'tesco-gala-apples-loose', 'Sweet and crunchy loose Gala apple, grown by quality orchards.', 0.20, NULL, '/assets/images/categories/fruit-vegetables.jpg', 1, 'Each', 250),

    -- ── 2. Meat & Fish (9 Items) ────────────────────────────────────
    (@CatMeatFish, 'tesco', 'Tesco Chicken Breast Portions 650g', 'tesco-chicken-breast-portions-650g', 'Fresh British skinless and boneless chicken breast portions.', 4.80, 4.00, '/assets/images/categories/meat-fish.jpg', 1, '650g', 70),
    (@CatMeatFish, 'tesco', 'Tesco British Beef Mince 5% Fat 500g', 'tesco-beef-mince-5pct-500g', 'Lean and high-quality 5% fat British beef mince, ideal for spaghetti.', 3.50, 3.00, '/assets/images/categories/meat-fish.jpg', 1, '500g', 95),
    (@CatMeatFish, 'tesco', 'Tesco Pork Sausages 8 Pack 454g', 'tesco-pork-sausages-8pk-454g', '8 pork sausages seasoned with herbs. Perfect for a cooked breakfast.', 2.20, 1.80, '/assets/images/categories/meat-fish.jpg', 1, '454g', 110),
    (@CatMeatFish, 'tesco', 'Tesco Salmon Fillets 2 Pack 260g', 'tesco-salmon-fillets-2pk-260g', '2 boneless Atlantic salmon fillets with skin, rich in Omega 3.', 4.50, 3.80, '/assets/images/categories/meat-fish.jpg', 1, '260g', 50),
    (@CatMeatFish, 'tesco', 'Tesco Whole Chicken Medium 1.5kg', 'tesco-whole-chicken-medium-1.5kg', 'Fresh Class A British medium whole chicken with giblets.', 4.20, NULL, '/assets/images/categories/meat-fish.jpg', 1, '1.5kg', 60),
    (@CatMeatFish, 'tesco', 'Tesco British Lamb Chops 400g', 'tesco-british-lamb-chops-400g', 'Tender and juicy British lamb loin chops, ready for grilling.', 5.50, 4.80, '/assets/images/categories/meat-fish.jpg', 1, '400g', 40),
    (@CatMeatFish, 'tesco', 'Tesco Cod Fillets 2 Pack 250g', 'tesco-cod-fillets-2pk-250g', '2 skinless, boneless Atlantic cod fillets. Firm and flaky.', 4.00, NULL, '/assets/images/categories/meat-fish.jpg', 1, '250g', 45),
    (@CatMeatFish, 'tesco-finest', 'Tesco Finest Dressed Crabs 140g', 'tesco-finest-dressed-crabs-140g', 'Prepared crab shell filled with delicious brown and white crab meat.', 3.80, NULL, '/assets/images/categories/meat-fish.jpg', 1, '140g', 30),
    (@CatMeatFish, 'tesco-finest', 'Tesco Finest Beef Sirloin Steak 227g', 'tesco-finest-sirloin-steak-227g', 'Finest dry-aged British beef sirloin steak, exceptionally tender.', 6.00, 5.00, '/assets/images/categories/meat-fish.jpg', 1, '227g', 50),

    -- ── 3. Dairy, Eggs & Alternatives (9 Items) ────────────────────
    (@CatDairy, 'tesco', 'Tesco Whole Milk 4 Pints 2.27L', 'tesco-whole-milk-4-pints-2.27l', 'Fresh pasteurized whole homogenized milk. Sourced from British farms.', 1.65, NULL, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '2.27L', 180),
    (@CatDairy, 'tesco', 'Tesco Semi Skimmed Milk 2 Pints 1.13L', 'tesco-semi-skimmed-milk-2-pints-1.13l', 'Fresh pasteurized semi-skimmed milk. The classic daily essential.', 1.25, NULL, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '1.13L', 150),
    (@CatDairy, 'tesco', 'Tesco British Extra Large Eggs 6 Pack', 'tesco-extra-large-eggs-6pk', '6 large, free-range British eggs from quality audited farms.', 1.95, 1.60, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '6 Pack', 130),
    (@CatDairy, 'tesco', 'Tesco Mature White Cheddar Cheese 400g', 'tesco-mature-white-cheddar-400g', 'Rich, creamy and full of flavor white cheddar cheese.', 3.00, 2.50, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '400g', 125),
    (@CatDairy, 'tesco-finest', 'Tesco Finest French Brie 200g', 'tesco-finest-french-brie-200g', 'Soft and creamy double cream brie, made in the north of France.', 2.20, NULL, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '200g', 90),
    (@CatDairy, 'philadelphia', 'Philadelphia Original Cream Cheese 200g', 'philadelphia-original-cream-cheese-200g', 'Classic cool, creamy and spreadable original Philadelphia cream cheese.', 2.00, 1.50, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '200g', 110),
    (@CatDairy, 'tesco', 'Tesco Fresh Double Cream 300ml', 'tesco-double-cream-300ml', 'Rich and luxurious British double cream, perfect for pouring or whipping.', 1.20, NULL, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '300ml', 140),
    (@CatDairy, 'muller', 'Muller Corner Fruit Yogurt 6 Pack', 'muller-corner-fruit-yogurt-6pk', '6 pack of creamy yogurts with separate compartments for strawberry and peach.', 3.50, 2.50, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '6 Pack', 95),
    (@CatDairy, 'alpro', 'Alpro Original Soya Milk Alternative 1L', 'alpro-soya-milk-1l', '100% plant-based original soya milk, rich in plant protein.', 1.90, NULL, '/assets/images/categories/flavoured-milk-plant.jpg', 1, '1L', 85),

    -- ── 4. Bakery & Bread (10 Items) ───────────────────────────────
    (@CatBread, 'tesco', 'Tesco White Crumpets 6 Pack', 'tesco-white-crumpets-6pk', '6 light and fluffy white crumpets. Delicious toasted with butter.', 0.85, NULL, '/assets/images/categories/bread.jpg', 1, '6 Pack', 160),
    (@CatBread, 'warburtons', 'Warburtons Toastie Thick Sliced Bread 800g', 'warburtons-toastie-thick-sliced-800g', 'The ultimate thick sliced bread, baked to be soft and perfect for toast.', 1.40, NULL, '/assets/images/categories/bread.jpg', 1, '800g', 120),
    (@CatBread, 'hovis', 'Hovis Wholemeal Medium Sliced Bread 800g', 'hovis-wholemeal-medium-sliced-800g', 'Naturally high in fiber, delicious wheat wholemeal sliced loaf.', 1.40, 1.15, '/assets/images/categories/bread.jpg', 1, '800g', 100),
    (@CatBread, 'tesco', 'Tesco Plain Bagels 5 Pack', 'tesco-plain-bagels-5pk', '5 plain, soft, New York style boiled and baked bagels.', 1.20, NULL, '/assets/images/categories/bread.jpg', 1, '5 Pack', 130),
    (@CatCakes, 'tesco', 'Tesco Chocolate Fudge Cake', 'tesco-chocolate-fudge-cake', 'Rich chocolate sponge cake layered and covered with sweet chocolate fudge.', 3.00, 2.50, '/assets/images/categories/cakes-biscuits.jpg', 1, 'Each', 50),
    (@CatCakes, 'mcvities', 'McVities Jaffa Cakes 10 Pack 122g', 'mcvities-jaffa-cakes-10pk-122g', '10 light sponge cakes with a dark crackly chocolate topping and tangy orange center.', 1.35, 1.00, '/assets/images/categories/cakes-biscuits.jpg', 1, '122g', 180),
    (@CatCakes, 'oreo', 'Oreo Original Cookies 154g', 'oreo-original-cookies-154g', 'Tasty chocolate flavor sandwich biscuits filled with a sweet vanilla cream.', 1.10, NULL, '/assets/images/categories/cakes-biscuits.jpg', 1, '154g', 210),
    (@CatCakes, 'tesco', 'Tesco Lemon Drizzle Cake 225g', 'tesco-lemon-drizzle-cake-225g', 'A moist lemon sponge cake injected with a tangy lemon syrup.', 2.00, NULL, '/assets/images/categories/cakes-biscuits.jpg', 1, '225g', 65),
    (@CatCakes, 'tesco', 'Tesco Blueberry Muffins 4 Pack', 'tesco-blueberry-muffins-4-pack', '4 soft and sweet muffins packed full of juicy blueberries.', 1.50, 1.20, '/assets/images/categories/morning-goods-pastries.jpg', 1, '4 Pack', 80),
    (@CatBread, 'tesco', 'Tesco White Pitta Bread 6 Pack', 'tesco-white-pitta-bread-6pk', '6 classic white pitta breads, perfect for stuffing with salad and meats.', 0.75, NULL, '/assets/images/categories/bread.jpg', 1, '6 Pack', 120),

    -- ── 5. Frozen Food (9 Items) ───────────────────────────────────
    (@CatFrozenMeals, 'birds-eye', 'Birds Eye Cod Fish Fingers 10 Pack 280g', 'birds-eye-cod-fish-fingers-10pk', '10 wild-caught 100% cod fish fingers coated in golden breadcrumbs.', 2.80, 2.20, '/assets/images/categories/frozen-ready-meals.jpg', 1, '280g', 90),
    (@CatFrozenSides, 'mccain', 'McCain Crispy French Fries 900g', 'mccain-crispy-french-fries-900g', 'Thin and crispy French fries, cooked with sunflower oil.', 2.50, NULL, '/assets/images/categories/frozen-chips-sides.jpg', 1, '900g', 110),
    (@CatFrozenSides, 'aunt-bessies', 'Aunt Bessies Golden Yorkshire Puddings 12 Pack', 'aunt-bessies-yorkshire-puddings-12pk', '12 baked and frozen ready-to-heat golden, crisp Yorkshire puddings.', 1.80, NULL, '/assets/images/categories/frozen-chips-sides.jpg', 1, '12 Pack', 130),
    (@CatFrozenVeg, 'birds-eye', 'Birds Eye Select Mixed Vegetables 750g', 'birds-eye-mixed-veg-750g', 'Frozen sweet garden peas, carrots, sweetcorn and green beans.', 1.60, NULL, '/assets/images/categories/frozen-vegetables.jpg', 1, '750g', 140),
    (@CatIceCream, 'haagen-dazs', 'Haagen-Dazs Cookies & Cream Ice Cream 460ml', 'haagen-dazs-cookies-cream-460ml', 'Rich, smooth vanilla ice cream swirled with chocolate cookie chunks.', 4.80, 3.50, '/assets/images/categories/ice-cream-lollies.jpg', 1, '460ml', 70),
    (@CatIceCream, 'magnum', 'Magnum Classic Ice Cream Lollies 3 Pack', 'magnum-classic-3pk', '3 velvety smooth vanilla ice cream sticks coated in cracking milk chocolate.', 3.50, 2.75, '/assets/images/categories/ice-cream-lollies.jpg', 1, '3 Pack', 85),
    (@CatFrozenMeals, 'tesco', 'Tesco Frozen Beef Lasagne 400g', 'tesco-frozen-beef-lasagne-400g', 'Minced beef in a rich red wine and tomato sauce, layered with pasta sheets.', 2.00, NULL, '/assets/images/categories/frozen-ready-meals.jpg', 1, '400g', 95),
    (@CatFrozenPizza, 'chicago-town', 'Chicago Town Stuffed Crust Pepperoni Pizza', 'chicago-town-stuffed-crust-pepperoni', 'Stuffed crust pizza loaded with tomato sauce, pepperoni, and mozzarella cheese.', 3.80, 3.00, '/assets/images/categories/frozen-pizza.jpg', 1, 'Each', 75),
    (@CatFrozenMeals, 'birds-eye', 'Birds Eye Battered Cod Fillets 4 Pack', 'birds-eye-battered-cod-4pk', '4 wild-caught cod fillets coated in a crisp, bubbly batter.', 4.50, 3.75, '/assets/images/categories/frozen-ready-meals.jpg', 1, '4 Pack', 80),

    -- ── 6. Food Cupboard (14 Items) ────────────────────────────────
    (@CatPasta, 'tesco', 'Tesco Spaghetti Pasta 500g', 'tesco-spaghetti-pasta-500g', '100% durum wheat semolina dry spaghetti pasta. High in quality.', 0.75, NULL, '/assets/images/categories/pasta-rice-grains.jpg', 1, '500g', 220),
    (@CatTins, 'heinz', 'Heinz Baked Beans 415g', 'heinz-baked-beans-415g', 'The world-famous rich, sweet tomato sauce baked beans from Heinz.', 1.00, 0.80, '/assets/images/categories/tins-cans.jpg', 1, '415g', 240),
    (@CatTins, 'tesco', 'Tesco Peeled Plum Tomatoes 400g', 'tesco-peeled-plum-tomatoes-400g', 'Plum tomatoes in rich tomato juice, sourced from sun-soaked Italy.', 0.60, NULL, '/assets/images/categories/tins-cans.jpg', 1, '400g', 190),
    (@CatTins, 'john-west', 'John West Tuna Chunks in Sunflower Oil 4x145g', 'john-west-tuna-chunks-4pk', '4 pack of wild-caught tuna chunks, preserved in sunflower oil.', 4.50, 3.50, '/assets/images/categories/tins-cans.jpg', 1, '4 x 145g', 110),
    (@CatSauces, 'sarsons', 'Sarsons Malt Vinegar 250ml', 'sarsons-malt-vinegar-250ml', 'The traditional British brewed malt vinegar for fish and chips.', 1.10, NULL, '/assets/images/categories/condiments-sauces.jpg', 1, '250ml', 140),
    (@CatSauces, 'tesco', 'Tesco Pure Sunflower Oil 1L', 'tesco-pure-sunflower-oil-1l', '100% pure sunflower oil, perfect for frying and high temperature baking.', 2.10, NULL, '/assets/images/categories/condiments-sauces.jpg', 1, '1L', 130),
    (@CatCereals, 'kelloggs', 'Kelloggs Corn Flakes Cereal 720g', 'kelloggs-corn-flakes-720g', 'Toasted golden flakes of corn, fortified with vitamins and iron.', 3.00, 2.50, '/assets/images/categories/cereals-porridge.jpg', 1, '720g', 115),
    (@CatCereals, 'quaker', 'Quaker Oat So Simple Original Porridge 10 Pack', 'quaker-oat-so-simple-original-10pk', '10 sachets of 100% wholegrain rolled oats, ready in 2 minutes.', 2.80, 2.00, '/assets/images/categories/cereals-porridge.jpg', 1, '10 Pack', 120),
    (@CatHotDrinks, 'pg-tips', 'PG Tips Original Tea Bags 240s 690g', 'pg-tips-tea-bags-240s', '240 original pyramid tea bags. Perfectly blended for British tastes.', 4.80, NULL, '/assets/images/categories/tea-coffee-hot-drinks.jpg', 1, '240 Bags', 135),
    (@CatHotDrinks, 'kenco', 'Kenco Smooth Instant Coffee 200g', 'kenco-smooth-instant-coffee-200g', 'Medium roast instant coffee powder made from quality Arabica beans.', 5.50, 4.50, '/assets/images/categories/tea-coffee-hot-drinks.jpg', 1, '200g', 110),
    (@CatBaking, 'tesco', 'Tesco Granulated White Sugar 1kg', 'tesco-white-sugar-1kg', 'Pure cane granulated sugar, ideal for baking, tea, and coffee.', 1.00, NULL, '/assets/images/categories/baking.jpg', 1, '1kg', 160),
    (@CatBaking, 'tesco', 'Tesco Self Raising Flour 1.5kg', 'tesco-self-raising-flour-1.5kg', 'Finely milled white flour blended with baking agents for perfect rising.', 0.90, NULL, '/assets/images/categories/baking.jpg', 1, '1.5kg', 140),
    (@CatSauces, 'hellmanns', 'Hellmanns Real Squeezy Mayonnaise 430ml', 'hellmanns-mayo-squeezy-430ml', 'Hellmann''s famous rich and creamy real egg mayonnaise in a squeeze bottle.', 2.50, 2.00, '/assets/images/categories/condiments-sauces.jpg', 1, '430ml', 155),
    (@CatSoups, 'bisto', 'Bisto Gravy Granules Chicken 190g', 'bisto-gravy-granules-chicken-190g', 'Nation''s favorite chicken gravy granules. Quick and easy savory taste.', 2.00, NULL, '/assets/images/categories/soups-stocks-gravy.jpg', 1, '190g', 160),

    -- ── 7. Drinks (8 Items) ────────────────────────────────────────
    (@CatSoftDrinks, 'coca-cola', 'Coca-Cola Original Taste 12 x 330ml', 'coca-cola-original-12pk', '12 cans of classic original sweet Coca-Cola. Best served cold.', 7.00, 5.50, '/assets/images/categories/soft-drinks.jpg', 1, '12 x 330ml', 105),
    (@CatSoftDrinks, 'pepsi', 'Pepsi Max Sugar Free Cola 12 x 330ml', 'pepsi-max-12pk', '12 cans of maximum taste, zero sugar black cherry cola.', 5.50, 4.50, '/assets/images/categories/soft-drinks.jpg', 1, '12 x 330ml', 120),
    (@CatSoftDrinks, 'fanta', 'Fanta Orange Carbonated Soft Drink 2L', 'fanta-orange-2l', 'Refreshing sweet orange flavored fizzy drink. Caffeine free.', 2.20, NULL, '/assets/images/categories/soft-drinks.jpg', 1, '2L', 140),
    (@CatJuice, 'innocent', 'Innocent Strawberries & Bananas Smoothie 750ml', 'innocent-smoothie-strawberry-banana-750ml', '100% crushed fruit smoothie with absolutely no added sugar.', 3.20, 2.50, '/assets/images/categories/fruit-juice-squash.jpg', 1, '750ml', 80),
    (@CatJuice, 'tesco', 'Tesco Pure Apple Juice 1L', 'tesco-pure-apple-juice-1l', '100% pure squeezed apple juice from concentrate, fresh and sweet.', 1.20, NULL, '/assets/images/categories/fruit-juice-squash.jpg', 1, '1L', 160),
    (@CatWater, 'volvic', 'Volvic Natural Mineral Water 6 x 1.5L', 'volvic-water-6pk', '6 pack of large natural volcanic mineral water bottles from Auvergne.', 3.80, 3.00, '/assets/images/categories/water.jpg', 1, '6 x 1.5L', 90),
    (@CatWater, 'buxton', 'Buxton Still Mineral Water 750ml', 'buxton-still-water-750ml', 'Pure British mineral water, naturally filtered through peak district limestone.', 0.90, NULL, '/assets/images/categories/water.jpg', 1, '750ml', 150),
    (@CatJuice, 'innocent', 'Innocent Pure Orange Juice with Bits 1.35L', 'innocent-orange-juice-with-bits-1.35l', 'Never from concentrate orange juice, packed with juicy bits.', 3.50, 2.75, '/assets/images/categories/fruit-juice-squash.jpg', 1, '1.35L', 85),

    -- ── 8. Beer, Wine & Spirits (7 Items) ──────────────────────────
    (@CatBeer, 'stella-artois', 'Stella Artois Premium Lager Beer 18x284ml', 'stella-artois-18pack', 'Premium Belgian lager beer. Crisp, golden and refreshing. 4.6% ABV.', 15.00, 12.00, '/assets/images/categories/beer-cider.jpg', 1, '18 x 284ml', 65),
    (@CatBeer, 'guinness', 'Guinness Draught Stout Can 4 x 440ml', 'guinness-draught-4pk', 'Smooth and creamy Irish dry stout with a rich velvety head. 4.1% ABV.', 5.50, 4.75, '/assets/images/categories/beer-cider.jpg', 1, '4 x 440ml', 85),
    (@CatWine, 'hardys', 'Hardys VR Merlot Red Wine 75cl', 'hardys-merlot-75cl', 'Plum and cherry fruit flavors with a soft finish Argentine red wine.', 6.50, NULL, '/assets/images/categories/wine.jpg', 1, '75cl', 110),
    (@CatWine, 'oyster-bay', 'Oyster Bay Sauvignon Blanc White Wine 75cl', 'oyster-bay-sauvignon-blanc-75cl', 'Elegant, mineral and zesty white wine from Marlborough New Zealand.', 9.50, 8.00, '/assets/images/categories/wine.jpg', 1, '75cl', 95),
    (@CatSpirits, 'smirnoff', 'Smirnoff Red Label Vodka 70cl', 'smirnoff-vodka-70cl', 'Triple distilled and ten times filtered premium pure vodka. 37.5% ABV.', 16.50, 14.00, '/assets/images/categories/spirits.jpg', 1, '70cl', 60),
    (@CatSpirits, 'gordons', 'Gordons Special Dry London Gin 70cl', 'gordons-gin-70cl', 'The classic refreshing juniper dry gin. Perfect with tonic.', 17.00, NULL, '/assets/images/categories/spirits.jpg', 1, '70cl', 55),
    (@CatSparkling, 'moet-chandon', 'Moet & Chandon Brut Imperial Champagne 75cl', 'moet-chandon-champagne-75cl', 'Elegance, complexity and premium sparkling notes from France.', 40.00, 35.00, '/assets/images/categories/champagne-sparkling-wine.jpg', 1, '75cl', 25),

    -- ── 9. Baby & Toddler (5 Items) ─────────────────────────────────
    (@CatBabyFood, 'ellas-kitchen', 'Ellas Kitchen Organic Bananas Baby Food 120g', 'ellas-kitchen-bananas-120g', '100% organic banana puree, smooth and perfect for baby weaning.', 1.30, NULL, '/assets/images/categories/baby-food-milk.jpg', 1, '120g', 180),
    (@CatBabyFood, 'aptamil', 'Aptamil 1 First Infant Milk Formula 800g', 'aptamil-formula-1-800g', 'Nutritionally complete breast milk substitute formula for newborns.', 14.50, NULL, '/assets/images/categories/baby-food-milk.jpg', 1, '800g', 60),
    (@CatBabyWipes, 'pampers', 'Pampers Sensitive Baby Wipes 12 Pack 624s', 'pampers-wipes-12pk', 'Gentle cleaning for sensitive skin, pH balanced and dermatologically tested.', 11.00, 9.00, '/assets/images/categories/nappies-wipes.jpg', 1, '12 Pack', 70),
    (@CatBabyWipes, 'huggies', 'Huggies DryNites Pyjama Pants Boy Age 4-7 10s', 'huggies-drynites-pants-boys-10s', 'Absorbent night-time pants specifically designed for boys aged 4-7.', 5.50, NULL, '/assets/images/categories/nappies-wipes.jpg', 1, '10s', 85),
    (@CatBabyToiletries, 'aveeno', 'Aveeno Baby Daily Care Hair & Body Wash 250ml', 'aveeno-baby-wash-250ml', 'Gently cleanses and leaves baby skin moisturized and soft.', 6.00, 4.50, '/assets/images/categories/baby-health-toiletries.jpg', 1, '250ml', 90),

    -- ── 10. Health & Beauty (7 Items) ──────────────────────────────
    (@CatBathShower, 'carex', 'Carex Complete Hand Wash Sensitive 250ml', 'carex-handwash-sensitive-250ml', 'Kills 99.9% of bacteria. Supports the skin''s natural antibacterial defenses.', 1.20, NULL, '/assets/images/categories/bath-shower.jpg', 1, '250ml', 160),
    (@CatHairCare, 'head-shoulders', 'Head & Shoulders Classic Clean Shampoo 400ml', 'head-shoulders-classic-400ml', 'Clinically proven up to 100% dandruff protection for hair and scalp.', 4.50, 3.50, '/assets/images/categories/hair-care.jpg', 1, '400ml', 115),
    (@CatDental, 'colgate', 'Colgate Triple Action Toothpaste 75ml', 'colgate-toothpaste-75ml', 'Cavity protection, white teeth and fresh breath confidence.', 1.20, NULL, '/assets/images/categories/dental.jpg', 1, '75ml', 200),
    (@CatDental, 'oral-b', 'Oral-B Precision Clean Electric Toothbrush', 'oral-b-precision-toothbrush', 'Electric toothbrush delivers superior plaque removal compared to manual.', 25.00, 20.00, '/assets/images/categories/dental.jpg', 1, 'Each', 40),
    (@CatSkinCare, 'vaseline', 'Vaseline Intensive Care Cocoa Butter Body Lotion 400ml', 'vaseline-cocoa-butter-lotion-400ml', 'Formulated with cocoa butter to restore and deeply moisturize skin.', 4.00, 3.00, '/assets/images/categories/skin-care.jpg', 1, '400ml', 95),
    (@CatGrooming, 'lynx', 'Lynx Africa Bodyspray Deodorant 150ml', 'lynx-africa-bodyspray-150ml', 'The classic Lynx Africa warm zesty squeeze scent deodorant spray.', 2.80, NULL, '/assets/images/categories/mens-grooming.jpg', 1, '150ml', 150),
    (@CatGrooming, 'gillette', 'Gillette Series Sensitive Shave Gel 200ml', 'gillette-series-shave-gel-200ml', 'Lightly fragranced shaving foam with aloe vera to soothe skin.', 2.50, 2.00, '/assets/images/categories/mens-grooming.jpg', 1, '200ml', 110),

    -- ── 11. Household (6 Items) ────────────────────────────────────
    (@CatCleaning, 'flash', 'Flash All Purpose Liquid Cleaner Lemon 1L', 'flash-liquid-lemon-1l', 'Cuts grease and dirt on all hard washable surfaces. Refreshing lemon.', 2.20, NULL, '/assets/images/categories/cleaning.jpg', 1, '1L', 120),
    (@CatCleaning, 'fairy', 'Fairy Liquid Original Dishwashing Soap 320ml', 'fairy-liquid-original-320ml', 'Long-lasting suds and exceptional grease cutting for washing dishes.', 1.00, NULL, '/assets/images/categories/cleaning.jpg', 1, '320ml', 250),
    (@CatLaundry, 'comfort', 'Comfort Intense Sunburst Fabric Conditioner 36W', 'comfort-intense-sunburst-36w', 'Ultra concentrated fabric conditioner, locking in intense freshness.', 3.00, 2.50, '/assets/images/categories/laundry.jpg', 1, '36 Washes', 110),
    (@CatCleaning, 'finish', 'Finish All In One Dishwasher Tablets 80s', 'finish-dishwasher-tablets-80s', 'Powerball technology cuts through grease and targets baking residue.', 12.00, 10.00, '/assets/images/categories/cleaning.jpg', 1, '80 Pack', 65),
    (@CatToiletPaper, 'andrex', 'Andrex Classic Clean Toilet Tissue 12 Roll', 'andrex-classic-clean-12roll', '12 rolls of soft, strong, classic clean toilet tissue.', 5.50, 4.50, '/assets/images/categories/bathroom-toilet.jpg', 1, '12 Pack', 110),
    (@CatToiletPaper, 'kleenex', 'Kleenex Original Facial Tissues 2 Pack', 'kleenex-tissues-2pk', '2 boxes of soft and reliable facial tissues, great for allergies.', 2.80, NULL, '/assets/images/categories/bathroom-toilet.jpg', 1, '2 Pack', 130),

    -- ── 12. Pets (5 Items) ─────────────────────────────────────────
    (@CatDogFood, 'pedigree', 'Pedigree Dog Food Tins Gravy Selection 12x400g', 'pedigree-tins-gravy-12pk', '12 cans of beef, chicken, lamb in gravy dog food variety pack.', 11.50, 9.50, '/assets/images/categories/dog-food-accessories.jpg', 1, '12 x 400g', 55),
    (@CatCatFood, 'whiskas', 'Whiskas Cat Food Pouches Jelly Selection 40 Pack', 'whiskas-pouches-jelly-40pk', '40 pouches of fresh poultry and meat chunks in rich jelly.', 13.00, 11.00, '/assets/images/categories/cat-food-accessories.jpg', 1, '40 Pack', 45),
    (@CatDogFood, 'bakers', 'Bakers Adult Dry Dog Food Beef & Veg 5kg', 'bakers-beef-veg-dog-food-5kg', 'Dry dog food kibble with beef and vegetables, 100% complete.', 12.00, NULL, '/assets/images/categories/dog-food-accessories.jpg', 1, '5kg', 40),
    (@CatCatFood, 'dreamies', 'Dreamies Cat Treats with Chicken 60g', 'dreamies-cat-treats-chicken-60g', 'Crunchy biscuits with a soft chicken filling, cats go mad for them.', 1.25, NULL, '/assets/images/categories/cat-food-accessories.jpg', 1, '60g', 220),
    (@CatDogFood, 'pedigree', 'Pedigree Schmackos Dog Treats Chicken 20s', 'pedigree-schmackos-chicken-20s', '20 soft and chewy meat straps with tasty chicken, dogs love them.', 1.80, 1.40, '/assets/images/categories/dog-food-accessories.jpg', 1, '20s', 150);

    -- ================================================================
    -- 4. INSERT LOOP FOR PRODUCTS, VARIANTS, AND INVENTORY
    -- ================================================================
    DECLARE @ProdCategoryId INT, @ProdBrandSlug NVARCHAR(200), @ProdName NVARCHAR(500),
            @ProdSlug NVARCHAR(500), @ProdDesc NVARCHAR(MAX),
            @ProdBasePrice DECIMAL(10,2), @ProdClubcardPrice DECIMAL(10,2),
            @ProdImageUrl NVARCHAR(500), @ProdIsAvailable BIT,
            @ProdVariantName NVARCHAR(200), @ProdStockQuantity INT,
            @ProdBrandId INT, @ProdId INT;

    DECLARE prod_cur CURSOR LOCAL FOR
        SELECT CategoryId, BrandSlug, Name, Slug, Description, BasePrice, ClubcardPrice, ImageUrl, IsAvailable, VariantName, StockQuantity
        FROM @Products;

    OPEN prod_cur;
    FETCH NEXT FROM prod_cur INTO @ProdCategoryId, @ProdBrandSlug, @ProdName, @ProdSlug,
                                   @ProdDesc, @ProdBasePrice, @ProdClubcardPrice, @ProdImageUrl, @ProdIsAvailable,
                                   @ProdVariantName, @ProdStockQuantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @ProdBrandId = Id FROM m.tblBrand WHERE Slug = @ProdBrandSlug AND IsDeleted = 0;

        IF NOT EXISTS (SELECT 1 FROM m.tblProduct WHERE Slug = @ProdSlug AND IsDeleted = 0)
        BEGIN
            INSERT INTO m.tblProduct
                (CategoryId, BrandId, Name, Slug, Description, BasePrice, ClubcardPrice,
                 ImageUrl, IsAvailable, RecordStatusId, CreatedBy)
            VALUES
                (@ProdCategoryId, @ProdBrandId, @ProdName, @ProdSlug, @ProdDesc,
                 @ProdBasePrice, @ProdClubcardPrice, @ProdImageUrl, @ProdIsAvailable, 1, @Admin);

            SET @ProdId = SCOPE_IDENTITY();

            -- Insert default variant with customized unit/size label (e.g. 500g, 6 Pack) and low stock threshold
            IF NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE ProductId = @ProdId AND IsDeleted = 0)
                INSERT INTO m.tblProductVariant
                    (ProductId, Sku, VariantName, PriceModifier, StockQuantity, LowStockThreshold, RecordStatusId, CreatedBy, CreatedOn, IsDeleted)
                VALUES
                    (@ProdId, 'SKU-' + CAST(@ProdId AS NVARCHAR(10)) + '-DEFAULT', @ProdVariantName, 0, @ProdStockQuantity, 10, 1, @Admin, GETUTCDATE(), 0);

            -- Insert default inventory record
            IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblInventory')
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM t.tblInventory WHERE ProductId = @ProdId)
                    INSERT INTO t.tblInventory (ProductId, QuantityOnHand, ReorderLevel, RecordStatusId, CreatedBy)
                    VALUES (@ProdId, @ProdStockQuantity, 10, 1, @Admin);
            END

            PRINT 'Inserted Product: ' + @ProdName;
        END

        FETCH NEXT FROM prod_cur INTO @ProdCategoryId, @ProdBrandSlug, @ProdName, @ProdSlug,
                                       @ProdDesc, @ProdBasePrice, @ProdClubcardPrice, @ProdImageUrl, @ProdIsAvailable,
                                       @ProdVariantName, @ProdStockQuantity;
    END

    CLOSE prod_cur; DEALLOCATE prod_cur;

    -- ================================================================
    -- 5. LINK NEW PRODUCTS TO EXISTING PROMOTIONS DYNAMICALLY
    -- ================================================================
    DECLARE @Promo1Id INT = (SELECT Id FROM m.tblPromotion WHERE Name = 'Save 15% on Breakfast & Baking Essentials' AND IsDeleted = 0);
    DECLARE @Promo3Id INT = (SELECT Id FROM m.tblPromotion WHERE Name = 'Buy 2 Get 1 Free on Selected Canned Foods' AND IsDeleted = 0);
    DECLARE @Promo4Id INT = (SELECT Id FROM m.tblPromotion WHERE Name = '3 for £5 on selected Soft Drinks & Juices' AND IsDeleted = 0);
    DECLARE @Promo5Id INT = (SELECT Id FROM m.tblPromotion WHERE Name = 'Clubcard Special Deals' AND IsDeleted = 0);
    DECLARE @Promo6Id INT = (SELECT Id FROM m.tblPromotion WHERE Name = 'Buy 1 Get 1 Free on Pet Treats' AND IsDeleted = 0);

    -- Map Promo 1 (15% off Baking & Breakfast) to selected cereals, flour, coffee, tea
    DECLARE @BakingBreakfast TABLE (Slug NVARCHAR(500));
    INSERT INTO @BakingBreakfast VALUES
        ('kelloggs-corn-flakes-720g'),
        ('quaker-oat-so-simple-original-10pk'),
        ('pg-tips-tea-bags-240s'),
        ('kenco-smooth-instant-coffee-200g'),
        ('tesco-white-sugar-1kg'),
        ('tesco-self-raising-flour-1.5kg');

    IF @Promo1Id IS NOT NULL
        INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
        SELECT @Promo1Id, p.Id, 0
        FROM m.tblProduct p
        INNER JOIN @BakingBreakfast bb ON p.Slug = bb.Slug
        WHERE p.IsDeleted = 0
          AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo1Id AND ProductId = p.Id AND IsDeleted = 0);

    -- Map Promo 3 (Buy 2 Get 1 Free Canned) to beans, tuna, plum tomatoes
    DECLARE @Canned TABLE (Slug NVARCHAR(500));
    INSERT INTO @Canned VALUES
        ('heinz-baked-beans-415g'),
        ('john-west-tuna-chunks-4pk'),
        ('tesco-peeled-plum-tomatoes-400g');

    IF @Promo3Id IS NOT NULL
        INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
        SELECT @Promo3Id, p.Id, 0
        FROM m.tblProduct p
        INNER JOIN @Canned cn ON p.Slug = cn.Slug
        WHERE p.IsDeleted = 0
          AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo3Id AND ProductId = p.Id AND IsDeleted = 0);

    -- Map Promo 4 (3 for £5 Drinks) to coke, pepsi, fanta, juices
    DECLARE @Drinks TABLE (Slug NVARCHAR(500));
    INSERT INTO @Drinks VALUES
        ('coca-cola-original-12pk'),
        ('pepsi-max-12pk'),
        ('fanta-orange-2l'),
        ('innocent-smoothie-strawberry-banana-750ml'),
        ('innocent-orange-juice-with-bits-1.35l');

    IF @Promo4Id IS NOT NULL
        INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
        SELECT @Promo4Id, p.Id, 0
        FROM m.tblProduct p
        INNER JOIN @Drinks dr ON p.Slug = dr.Slug
        WHERE p.IsDeleted = 0
          AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo4Id AND ProductId = p.Id AND IsDeleted = 0);

    -- Map Promo 6 (BOGO Pet Treats) to Schmackos, Dreamies
    DECLARE @PetTreats TABLE (Slug NVARCHAR(500));
    INSERT INTO @PetTreats VALUES
        ('dreamies-cat-treats-chicken-60g'),
        ('pedigree-schmackos-chicken-20s');

    IF @Promo6Id IS NOT NULL
        INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
        SELECT @Promo6Id, p.Id, 0
        FROM m.tblProduct p
        INNER JOIN @PetTreats pt ON p.Slug = pt.Slug
        WHERE p.IsDeleted = 0
          AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo6Id AND ProductId = p.Id AND IsDeleted = 0);

    -- DYNAMICALLY map Promo 5 (Clubcard Special Deals) to ALL products that have a ClubcardPrice set
    IF @Promo5Id IS NOT NULL
        INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
        SELECT @Promo5Id, p.Id, 0
        FROM m.tblProduct p
        INNER JOIN @Products pr ON p.Slug = pr.Slug
        WHERE p.IsDeleted = 0
          AND pr.ClubcardPrice IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo5Id AND ProductId = p.Id AND IsDeleted = 0);

    -- ================================================================
    -- 6. RECORD MIGRATION
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V085')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V085', 'SeedOneHundredMoreProducts');

    COMMIT TRANSACTION;
    PRINT 'V085 completed successfully. 100 new products, variants, and inventory items seeded and linked to promotions.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V085_SeedOneHundredMoreProducts.sql', ERROR_MESSAGE(), GETUTCDATE());

    THROW;
END CATCH
