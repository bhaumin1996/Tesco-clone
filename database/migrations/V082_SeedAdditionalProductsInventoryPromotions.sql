-- V082_SeedAdditionalProductsInventoryPromotions.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Seed 55+ additional realistic Tesco-style products across departments,
--              complete with variants (size/unit labels), stock/inventory levels,
--              and 6 realistic promotions mapped to products.
-- Dependencies: V001-V081

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Admin INT = 1;

    -- ================================================================
    -- 1. ENSURE ADDITIONAL BRANDS EXIST
    -- ================================================================
    DECLARE @Brands TABLE (Name NVARCHAR(200), Slug NVARCHAR(200));
    INSERT INTO @Brands VALUES
        ('Alpro',           'alpro'),
        ('McVities',        'mcvities'),
        ('Tropicana',       'tropicana'),
        ('Nescafe',         'nescafe'),
        ('Yorkshire Tea',   'yorkshire-tea'),
        ('Pampers',         'pampers'),
        ('Gillette',        'gillette'),
        ('Nivea',           'nivea'),
        ('Radox',           'radox'),
        ('Domestos',        'domestos'),
        ('Purina',          'purina'),
        ('Felix',           'felix'),
        ('McCain',          'mccain'),
        ('Robinsons',       'robinsons'),
        ('Corona',          'corona'),
        ('Napolina',        'napolina'),
        ('Bisto',           'bisto'),
        ('Heinz',           'heinz'),
        ('Kelloggs',        'kelloggs'),
        ('Walkers',         'walkers'),
        ('Cadbury',         'cadbury'),
        ('Warburtons',      'warburtons'),
        ('Muller',          'muller'),
        ('Lurpak',          'lurpak'),
        ('Innocent',        'innocent'),
        ('Coca-Cola',       'coca-cola'),
        ('Pepsi',           'pepsi'),
        ('Peroni',          'peroni'),
        ('Stella Artois',   'stella-artois'),
        ('Cif',             'cif'),
        ('Fairy',           'fairy'),
        ('Ariel',           'ariel'),
        ('Andrex',          'andrex'),
        ('Pedigree',        'pedigree'),
        ('Whiskas',         'whiskas'),
        ('Pantene',         'pantene'),
        ('Dove',            'dove'),
        ('Colgate',         'colgate'),
        ('Birds Eye',       'birds-eye'),
        ('Chicago Town',    'chicago-town'),
        ('Hovis',           'hovis'),
        ('Tesco',           'tesco'),
        ('Tesco Finest',    'tesco-finest'),
        ('Tesco Organic',   'tesco-organic'),
        ('Nivea Men',       'nivea-men'),
        ('Johnson''s',      'johnsons');

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
    -- 3. PRODUCT INSERTION DATA STRUCTURE
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

    -- ── 55 DETAILED PRODUCTS ACROSS CATEGORIES ────────────────────
    INSERT INTO @Products VALUES
    -- 1. Fruit & Veg
    (@CatFruitVeg, 'tesco', 'Tesco Royal Gala Apples 6 Pack', 'tesco-royal-gala-apples-6-pack', 'Sweet and crisp Royal Gala apples, sourced from trusted growers.', 1.60, 1.20, '/assets/images/categories/fruit-vegetables.jpg', 1, '6 Pack', 85),
    (@CatFruitVeg, 'tesco-organic', 'Tesco Organic Blueberries 150g', 'tesco-organic-blueberries-150g', 'Juicy, sweet organic blueberries packed with antioxidants.', 2.00, 1.60, '/assets/images/categories/fruit-vegetables.jpg', 1, '150g', 90),
    (@CatFruitVeg, 'tesco', 'Tesco Sweet Mandarins 600g', 'tesco-sweet-mandarins-600g', 'Easy peel sweet mandarin oranges, ideal for lunchboxes.', 1.30, NULL, '/assets/images/categories/fruit-vegetables.jpg', 1, '600g', 120),
    (@CatFruitVeg, 'tesco', 'Tesco Red Seedless Grapes 500g', 'tesco-red-grapes-500g', 'Crisp and sweet red seedless grapes, washed and ready to eat.', 2.40, 1.90, '/assets/images/categories/fruit-vegetables.jpg', 1, '500g', 75),
    (@CatFruitVeg, 'tesco-organic', 'Tesco Organic Carrots 1kg', 'tesco-organic-carrots-1kg', 'Organic sweet crunchy carrots, perfect for boiling, roasting, or snacking.', 1.20, NULL, '/assets/images/categories/fruit-vegetables.jpg', 1, '1kg', 160),
    (@CatFruitVeg, 'tesco', 'Tesco Conference Pears 4 Pack', 'tesco-conference-pears-4pk', 'Sweet and juicy Conference pears, great for eating fresh.', 1.50, 1.20, '/assets/images/categories/fruit-vegetables.jpg', 1, '4 Pack', 100),
    (@CatFruitVeg, 'tesco', 'Tesco Chestnut Mushrooms 250g', 'tesco-chestnut-mushrooms-250g', 'Earthy, firm chestnut mushrooms, ideal for stir-fries and risottos.', 1.00, 0.80, '/assets/images/categories/fruit-vegetables.jpg', 1, '250g', 120),

    -- 2. Meat & Fish
    (@CatMeatFish, 'tesco-finest', 'Tesco Finest Ribeye Steak 225g', 'tesco-finest-ribeye-steak-225g', '21-day matured British beef ribeye steak for exceptional flavour and tenderness.', 5.50, 4.50, '/assets/images/categories/meat-fish.jpg', 1, '225g', 40),
    (@CatMeatFish, 'tesco', 'Tesco British Pork Chops 700g', 'tesco-british-pork-chops-700g', '4 thick-cut British pork chops, perfect for grilling or roasting.', 4.00, NULL, '/assets/images/categories/meat-fish.jpg', 1, '700g', 45),
    (@CatMeatFish, 'tesco-finest', 'Tesco Finest Oak Smoked Salmon 100g', 'tesco-finest-smoked-salmon-100g', 'Slow cured and oak smoked Atlantic salmon slices, rich and delicate.', 4.80, 4.00, '/assets/images/categories/meat-fish.jpg', 1, '100g', 55),
    (@CatMeatFish, 'tesco', 'Tesco British Beef Burgers 4 Pack 454g', 'tesco-beef-burgers-4pk', '4 seasoned British beef burgers. High quality, great on the BBQ.', 3.00, 2.50, '/assets/images/categories/meat-fish.jpg', 1, '454g', 80),
    (@CatMeatFish, 'tesco', 'Tesco Smoked Back Bacon 300g', 'tesco-smoked-back-bacon-300g', '10 rashers of oak smoked British back bacon, thick cut.', 2.20, NULL, '/assets/images/categories/meat-fish.jpg', 1, '300g', 90),

    -- 3. Dairy & Alternatives
    (@CatDairy, 'tesco', 'Tesco British Salted Butter 250g', 'tesco-salted-butter-250g', 'Rich and creamy butter made with 100% British milk.', 1.80, 1.50, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '250g', 110),
    (@CatDairy, 'alpro', 'Alpro Oat Milk Alternative 1L', 'alpro-oat-milk-1l', '100% plant-based oat drink, foamable and rich in calcium.', 2.00, 1.50, '/assets/images/categories/flavoured-milk-plant.jpg', 1, '1L', 130),
    (@CatDairy, 'muller', 'Muller Rice Strawberry Dairypot 180g', 'muller-rice-strawberry-180g', 'Low fat creamy dairy rice pudding with strawberry sauce.', 1.00, NULL, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '180g', 140),
    (@CatDairy, 'tesco', 'Tesco Greek Style Yogurt 500g', 'tesco-greek-style-yogurt-500g', 'Thick and creamy Greek-style plain yogurt. Great with fruit and honey.', 1.15, NULL, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '500g', 110),
    (@CatDairy, 'lurpak', 'Lurpak Spreadable Butter 500g', 'lurpak-spreadable-500g', 'Lurpak spreadable butter, ready to use straight from the fridge.', 4.50, 3.50, '/assets/images/categories/dairy-eggs-chilled.jpg', 1, '500g', 95),

    -- 4. Bakery & Bread
    (@CatBread, 'hovis', 'Hovis Soft White Medium Sliced 800g', 'hovis-soft-white-800g', 'Hovis Soft White is baked to be deliciously soft for the perfect sandwich.', 1.40, 1.10, '/assets/images/categories/bread.jpg', 1, '800g', 95),
    (@CatBread, 'warburtons', 'Warburtons Gluten Free White Loaf 400g', 'warburtons-gf-white-400g', 'Soft, wheat-free sliced white bread. Perfect for coeliacs.', 2.50, 2.00, '/assets/images/categories/bread.jpg', 1, '400g', 50),
    (@CatCakes, 'mcvities', 'McVities Milk Chocolate Digestives 266g', 'mcvities-milk-choc-digestives-266g', 'The nation''s favourite biscuit, topped with smooth milk chocolate.', 1.80, 1.25, '/assets/images/categories/cakes-biscuits.jpg', 1, '266g', 160),
    (@CatCakes, 'tesco', 'Tesco Jam Tarts 6 Pack', 'tesco-jam-tarts-6-pack', 'Shortcrust pastry cases filled with apricot, raspberry, and blackcurrant jam.', 1.10, NULL, '/assets/images/categories/cakes-biscuits.jpg', 1, '6 Pack', 80),
    (@CatCakes, 'tesco-finest', 'Tesco Finest All Butter Croissants 4 Pack', 'tesco-finest-butter-croissants-4pk', '4 buttery, flaky croissants, made with French butter.', 2.00, 1.60, '/assets/images/categories/morning-goods-pastries.jpg', 1, '4 Pack', 85),
    (@CatCakes, 'tesco', 'Tesco Chocolate Chip Cookies 200g', 'tesco-choc-chip-cookies-200g', 'Crunchy cookies packed with Belgian chocolate chips.', 1.20, 1.00, '/assets/images/categories/cakes-biscuits.jpg', 1, '200g', 140),

    -- 5. Frozen Food
    (@CatFrozenPizza, 'chicago-town', 'Chicago Town Deep Dish Four Cheese Pizza 2 Pack', 'chicago-town-four-cheese-2pk', 'Two deep dish pizzas loaded with a blend of mozzarella, red cheddar, and emmental.', 2.50, 1.80, '/assets/images/categories/frozen-pizza.jpg', 1, '2 Pack', 70),
    (@CatFrozenMeals, 'birds-eye', 'Birds Eye Green Cuisine Veggie Fingers 10 Pack', 'birds-eye-veggie-fingers-10pk', 'Tasty vegetable fingers made with peas, carrots, potatoes, and sweetcorn in breadcrumbs.', 2.20, NULL, '/assets/images/categories/frozen-ready-meals.jpg', 1, '10 Pack', 80),
    (@CatIceCream, 'tesco-finest', 'Tesco Finest Salted Caramel Ice Cream 500ml', 'tesco-finest-salted-caramel-500ml', 'Rich West Country cream ice cream swirled with sea-salted caramel sauce.', 3.50, 2.75, '/assets/images/categories/ice-cream-lollies.jpg', 1, '500ml', 65),
    (@CatFrozenSides, 'mccain', 'McCain Home Chips Straight Cut 1.6kg', 'mccain-home-chips-1.6kg', 'Golden straight-cut chips, crispy on the outside, fluffy on the inside.', 3.80, 3.00, '/assets/images/categories/frozen-chips-sides.jpg', 1, '1.6kg', 75),
    (@CatFrozenVeg, 'birds-eye', 'Birds Eye Garden Peas 800g', 'birds-eye-garden-peas-800g', 'Freshly frozen sweet garden peas. High in fiber and protein.', 2.00, NULL, '/assets/images/categories/frozen-vegetables.jpg', 1, '800g', 120),

    -- 6. Food Cupboard - Pasta, Rice & Tins
    (@CatPasta, 'tesco', 'Tesco Penne Rigate Pasta 500g', 'tesco-penne-rigate-500g', 'Durum wheat semolina penne pasta tubes, ideal for holding rich tomato sauces.', 0.75, NULL, '/assets/images/categories/pasta-rice-grains.jpg', 1, '500g', 200),
    (@CatPasta, 'tesco', 'Tesco Basmati Rice 1kg', 'tesco-basmati-rice-1kg', 'Aromatic, long-grain basmati rice, perfect for curries and side dishes.', 1.85, 1.40, '/assets/images/categories/pasta-rice-grains.jpg', 1, '1kg', 150),
    (@CatTins, 'heinz', 'Heinz Spaghetti Hoops in Tomato Sauce 400g', 'heinz-spaghetti-hoops-400g', 'Freshly made pasta hoops in a juicy tomato sauce, enriched with iron and vitamin D.', 1.10, 0.90, '/assets/images/categories/tins-cans.jpg', 1, '400g', 180),
    (@CatTins, 'heinz', 'Heinz Cream of Chicken Soup 400g', 'heinz-cream-of-chicken-soup-400g', 'Classic, comforting smooth cream of chicken soup, perfect with a warm roll.', 1.30, 1.00, '/assets/images/categories/tins-cans.jpg', 1, '400g', 140),
    (@CatSauces, 'heinz', 'Heinz Tomato Ketchup 460g', 'heinz-tomato-ketchup-460g', 'The classic rich tomato ketchup made from sun-ripened tomatoes.', 2.30, 1.80, '/assets/images/categories/condiments-sauces.jpg', 1, '460g', 150),
    (@CatSauces, 'heinz', 'Heinz Seriously Good Mayonnaise 540g', 'heinz-seriously-good-mayo-540g', 'Rich, creamy and smooth mayonnaise made with 100% free range eggs.', 2.60, 2.00, '/assets/images/categories/condiments-sauces.jpg', 1, '540g', 130),
    (@CatTins, 'napolina', 'Napolina Chopped Tomatoes 4 x 400g', 'napolina-chopped-tomatoes-4pk', 'Premium Italian chopped tomatoes in rich tomato juice. Pack of 4.', 3.20, 2.50, '/assets/images/categories/tins-cans.jpg', 1, '4 x 400g', 110),
    (@CatSoups, 'bisto', 'Bisto Gravy Granules Original 190g', 'bisto-gravy-granules-190g', 'The nation''s favourite gravy granules, quick and easy to make.', 2.00, NULL, '/assets/images/categories/soups-stocks-gravy.jpg', 1, '190g', 160),
    (@CatWorldFoods, 'tesco', 'Tesco Coconut Milk 400ml', 'tesco-coconut-milk-400ml', 'Rich and creamy coconut milk, perfect for curries and baking.', 0.80, NULL, '/assets/images/categories/world-foods.jpg', 1, '400ml', 150),

    -- 7. Snacks & Confectionery & Cereals
    (@CatSnacks, 'walkers', 'Walkers Cheese & Onion Crisps 6 Pack', 'walkers-cheese-onion-6pk', 'Classic British cheese and onion flavour crisps made with 100% British potatoes.', 2.50, 2.00, '/assets/images/categories/snacks-confectionery.jpg', 1, '6 Pack', 170),
    (@CatCereals, 'kelloggs', 'Kelloggs Coco Pops Cereal 480g', 'kelloggs-coco-pops-480g', 'Toasted chocolate flavour rice cereal. Turns the milk chocolatey!', 3.20, 2.50, '/assets/images/categories/cereals-porridge.jpg', 1, '480g', 110),
    (@CatSnacks, 'cadbury', 'Cadbury Dairy Milk Giant Buttons 119g', 'cadbury-dairy-milk-buttons-119g', 'Giant bags of creamy Cadbury Dairy Milk chocolate buttons, ideal for sharing.', 1.50, 1.10, '/assets/images/categories/snacks-confectionery.jpg', 1, '119g', 200),

    -- 8. Drinks
    (@CatSoftDrinks, 'coca-cola', 'Coca-Cola Zero Sugar 12 x 330ml', 'coke-zero-12pk', 'Zero sugar, zero calories. Great classic Coca-Cola taste.', 6.50, 5.00, '/assets/images/categories/soft-drinks.jpg', 1, '12 x 330ml', 125),
    (@CatJuice, 'tropicana', 'Tropicana Smooth Orange Juice 900ml', 'tropicana-smooth-orange-900ml', '100% pure squeezed smooth orange juice with no bits and no added sugar.', 2.90, 2.20, '/assets/images/categories/fruit-juice-squash.jpg', 1, '900ml', 80),
    (@CatHotDrinks, 'nescafe', 'Nescafe Azera Americano Instant Coffee 100g', 'nescafe-azera-americano-100g', 'Barista-style instant coffee with a rich aroma and velvety crema.', 4.50, 3.00, '/assets/images/categories/tea-coffee-hot-drinks.jpg', 1, '100g', 115),
    (@CatHotDrinks, 'yorkshire-tea', 'Yorkshire Tea Bags 80s 250g', 'yorkshire-tea-bags-80s', 'A proper brew. Rich, satisfying, and full of flavour.', 2.80, NULL, '/assets/images/categories/tea-coffee-hot-drinks.jpg', 1, '80 Bags', 150),
    (@CatSoftDrinks, 'pepsi', 'Pepsi Max Cherry No Sugar 2L', 'pepsi-max-cherry-2l', 'Maximum cherry taste, zero sugar. Refreshing carbonated soft drink.', 2.00, 1.60, '/assets/images/categories/soft-drinks.jpg', 1, '2L', 110),
    (@CatJuice, 'robinsons', 'Robinsons Orange Squash Double Strength 1L', 'robinsons-orange-squash-1l', 'Double strength orange fruit squash with no added sugar.', 2.00, 1.50, '/assets/images/categories/fruit-juice-squash.jpg', 1, '1L', 130),

    -- 9. Beer, Wine & Spirits
    (@CatBeer, 'peroni', 'Peroni Nastro Azzurro Gluten Free Beer 4x330ml', 'peroni-gf-4pack', 'The same crisp, refreshing taste of Peroni Nastro Azzurro, gluten free.', 6.00, 5.00, '/assets/images/categories/beer-cider.jpg', 1, '4 x 330ml', 90),
    (@CatSparkling, 'tesco-finest', 'Tesco Finest Prosecco DOC 750ml', 'tesco-finest-prosecco-750ml', 'Elegant sparkling wine with flavors of peach, pear, and blossom.', 8.50, 7.00, '/assets/images/categories/champagne-sparkling-wine.jpg', 1, '750ml', 70),
    (@CatBeer, 'corona', 'Corona Extra Premium Lager Beer 12 x 330ml', 'corona-extra-12pk', 'Corona is a crisp, refreshing, easy-drinking Mexican lager. 4.5% ABV.', 14.00, 11.00, '/assets/images/categories/beer-cider.jpg', 1, '12 x 330ml', 80),
    (@CatWine, 'tesco-finest', 'Tesco Finest Malbec 750ml', 'tesco-finest-malbec-750ml', 'Full-bodied Argentine red wine with rich plum and blackberry flavours. 14% ABV.', 8.50, 7.00, '/assets/images/categories/wine.jpg', 1, '750ml', 85),

    -- 10. Baby & Toddler
    (@CatBabyToiletries, 'johnsons', 'Johnsons Baby Gold Shampoo 500ml', 'johnsons-baby-shampoo-500ml', 'As gentle to the eyes as pure water. Leaves baby''s hair soft and shiny.', 2.20, 1.80, '/assets/images/categories/baby-health-toiletries.jpg', 1, '500ml', 100),
    (@CatBabyWipes, 'pampers', 'Pampers Active Fit Nappies Size 4 44 Pack', 'pampers-active-fit-size4', 'Premium protection and 360-degree comfort fit for active babies.', 9.00, 7.50, '/assets/images/categories/nappies-wipes.jpg', 1, '44 Pack', 60),

    -- 11. Health & Beauty
    (@CatBathShower, 'dove', 'Dove Beauty Bar Soap Cream 4 x 90g', 'dove-beauty-bar-4pk', 'Contains 1/4 moisturizing cream to leave skin soft and glowing.', 3.00, NULL, '/assets/images/categories/bath-shower.jpg', 1, '4 x 90g', 120),
    (@CatHairCare, 'pantene', 'Pantene Repair & Protect Conditioner 400ml', 'pantene-repair-protect-conditioner', 'Instantly fights signs of damage to leave hair strong and shiny.', 4.00, 3.20, '/assets/images/categories/hair-care.jpg', 1, '400ml', 95),
    (@CatDental, 'colgate', 'Colgate Plax Cool Mint Mouthwash 500ml', 'colgate-plax-mouthwash-500ml', 'Provides 24/7 plaque protection and fresh breath confidence.', 3.50, 2.50, '/assets/images/categories/dental.jpg', 1, '500ml', 110),
    (@CatGrooming, 'gillette', 'Gillette Fusion 5 Razor Blades 4 Pack', 'gillette-fusion5-blades-4pk', 'Razor blade refills featuring 5 anti-friction blades for a close shave.', 12.50, 10.00, '/assets/images/categories/mens-grooming.jpg', 1, '4 Pack', 50),
    (@CatSkinCare, 'nivea', 'Nivea Creme Body Moisturiser 200ml', 'nivea-creme-200ml', 'The original all-purpose cream for skin care and soft skin.', 3.00, 2.50, '/assets/images/categories/skin-care.jpg', 1, '200ml', 120),
    (@CatBathShower, 'radox', 'Radox Feel Refreshed Shower Gel 250ml', 'radox-shower-gel-250ml', 'Eucalyptus and citrus scent shower gel to revive body and mind.', 1.50, NULL, '/assets/images/categories/bath-shower.jpg', 1, '250ml', 140),

    -- 12. Household
    (@CatLaundry, 'fairy', 'Fairy Non Bio Liquid Laundry Detergent 38 Washes', 'fairy-non-bio-liquid-38w', 'Voted No. 1 laundry brand for sensitive skin. Clean, soft clothes.', 7.50, 6.00, '/assets/images/categories/laundry.jpg', 1, '1.33L', 85),
    (@CatCleaning, 'cif', 'Cif Power & Shine Kitchen Spray 700ml', 'cif-kitchen-spray-700ml', 'Cuts through tough kitchen grease easily, leaving a 100% streak-free shine.', 2.00, 1.50, '/assets/images/categories/cleaning.jpg', 1, '700ml', 130),
    (@CatToiletPaper, 'andrex', 'Andrex Supreme Easy Clean Toilet Roll 9 Pack', 'andrex-supreme-9pk', 'Thick, soft toilet tissue rolls with a touch of cotton for a fresh feel.', 4.50, 3.50, '/assets/images/categories/bathroom-toilet.jpg', 1, '9 Pack', 115),
    (@CatCleaning, 'domestos', 'Domestos Original Thick Bleach 750ml', 'domestos-bleach-750ml', 'Kills 99.9% of bacteria and viruses, protecting your home.', 1.50, 1.10, '/assets/images/categories/cleaning.jpg', 1, '750ml', 135),
    (@CatLaundry, 'ariel', 'Ariel Original Washing Powder 40 Washes', 'ariel-powder-40w', 'Ariel laundry powder delivers outstanding stain removal in one wash.', 8.50, 7.00, '/assets/images/categories/laundry.jpg', 1, '2.6kg', 70),

    -- 13. Pets
    (@CatDogFood, 'pedigree', 'Pedigree Dentastix Medium Dog Chews 28 Pack', 'pedigree-dentastix-28pk', 'Daily dental treats proven to reduce tartar buildup by up to 80%.', 6.50, 5.00, '/assets/images/categories/dog-food-accessories.jpg', 1, '28 Pack', 95),
    (@CatCatFood, 'felix', 'Felix As Good As It Looks Cat Food 40 Pack', 'felix-as-good-as-it-looks-40pk', 'Tender meaty chunks in jelly. 40 delicious pouches of variety meals.', 13.00, 11.00, '/assets/images/categories/cat-food-accessories.jpg', 1, '40 Pack', 40);

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
    -- 5. SEED PROMOTIONS
    -- ================================================================
    DECLARE @Promo1Id INT, @Promo2Id INT, @Promo3Id INT, @Promo4Id INT, @Promo5Id INT, @Promo6Id INT;

    -- Promotion 1: 15% off Home Baking & Breakfast
    IF NOT EXISTS (SELECT 1 FROM m.tblPromotion WHERE Name = 'Save 15% on Breakfast & Baking Essentials' AND IsDeleted = 0)
    BEGIN
        INSERT INTO m.tblPromotion (Name, TypeId, DiscountPercent, MinimumQuantity, ValidFrom, ValidTo, IsActive, RecordStatusId, CreatedBy, CreatedOn)
        VALUES ('Save 15% on Breakfast & Baking Essentials', 1, 15.00, 1, DATEADD(day, -1, GETUTCDATE()), DATEADD(day, 90, GETUTCDATE()), 1, 1, @Admin, GETUTCDATE());
        SET @Promo1Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SET @Promo1Id = (SELECT Id FROM m.tblPromotion WHERE Name = 'Save 15% on Breakfast & Baking Essentials' AND IsDeleted = 0);
    END

    -- Promotion 2: Save £2.00 on Premium Beer & Spirits
    IF NOT EXISTS (SELECT 1 FROM m.tblPromotion WHERE Name = 'Save £2.00 on Selected Beer & Spirits' AND IsDeleted = 0)
    BEGIN
        INSERT INTO m.tblPromotion (Name, TypeId, DiscountValue, MinimumQuantity, ValidFrom, ValidTo, IsActive, RecordStatusId, CreatedBy, CreatedOn)
        VALUES ('Save £2.00 on Selected Beer & Spirits', 2, 2.00, 1, DATEADD(day, -1, GETUTCDATE()), DATEADD(day, 90, GETUTCDATE()), 1, 1, @Admin, GETUTCDATE());
        SET @Promo2Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SET @Promo2Id = (SELECT Id FROM m.tblPromotion WHERE Name = 'Save £2.00 on Selected Beer & Spirits' AND IsDeleted = 0);
    END

    -- Promotion 3: Buy 2 Get 1 Free on Heinz Soup & Canned Foods
    IF NOT EXISTS (SELECT 1 FROM m.tblPromotion WHERE Name = 'Buy 2 Get 1 Free on Selected Canned Foods' AND IsDeleted = 0)
    BEGIN
        INSERT INTO m.tblPromotion (Name, TypeId, DiscountPercent, MinimumQuantity, ValidFrom, ValidTo, IsActive, RecordStatusId, CreatedBy, CreatedOn)
        VALUES ('Buy 2 Get 1 Free on Selected Canned Foods', 3, 100.00, 2, DATEADD(day, -1, GETUTCDATE()), DATEADD(day, 90, GETUTCDATE()), 1, 1, @Admin, GETUTCDATE());
        SET @Promo3Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SET @Promo3Id = (SELECT Id FROM m.tblPromotion WHERE Name = 'Buy 2 Get 1 Free on Selected Canned Foods' AND IsDeleted = 0);
    END

    -- Promotion 4: Multi-Buy: 3 for £5.00 on Selected Juices & Soft Drinks
    IF NOT EXISTS (SELECT 1 FROM m.tblPromotion WHERE Name = '3 for £5 on selected Soft Drinks & Juices' AND IsDeleted = 0)
    BEGIN
        INSERT INTO m.tblPromotion (Name, TypeId, DiscountValue, MinimumQuantity, ValidFrom, ValidTo, IsActive, RecordStatusId, CreatedBy, CreatedOn)
        VALUES ('3 for £5 on selected Soft Drinks & Juices', 4, 5.00, 3, DATEADD(day, -1, GETUTCDATE()), DATEADD(day, 90, GETUTCDATE()), 1, 1, @Admin, GETUTCDATE());
        SET @Promo4Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SET @Promo4Id = (SELECT Id FROM m.tblPromotion WHERE Name = '3 for £5 on selected Soft Drinks & Juices' AND IsDeleted = 0);
    END

    -- Promotion 5: Clubcard Price Special Discounts
    IF NOT EXISTS (SELECT 1 FROM m.tblPromotion WHERE Name = 'Clubcard Special Deals' AND IsDeleted = 0)
    BEGIN
        INSERT INTO m.tblPromotion (Name, TypeId, MinimumQuantity, ValidFrom, ValidTo, IsActive, RecordStatusId, CreatedBy, CreatedOn)
        VALUES ('Clubcard Special Deals', 5, 1, DATEADD(day, -1, GETUTCDATE()), DATEADD(day, 90, GETUTCDATE()), 1, 1, @Admin, GETUTCDATE());
        SET @Promo5Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SET @Promo5Id = (SELECT Id FROM m.tblPromotion WHERE Name = 'Clubcard Special Deals' AND IsDeleted = 0);
    END

    -- Promotion 6: Buy 1 Get 1 Free on Pedigree Dog Chews
    IF NOT EXISTS (SELECT 1 FROM m.tblPromotion WHERE Name = 'Buy 1 Get 1 Free on Pet Treats' AND IsDeleted = 0)
    BEGIN
        INSERT INTO m.tblPromotion (Name, TypeId, DiscountPercent, MinimumQuantity, ValidFrom, ValidTo, IsActive, RecordStatusId, CreatedBy, CreatedOn)
        VALUES ('Buy 1 Get 1 Free on Pet Treats', 3, 100.00, 1, DATEADD(day, -1, GETUTCDATE()), DATEADD(day, 90, GETUTCDATE()), 1, 1, @Admin, GETUTCDATE());
        SET @Promo6Id = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        SET @Promo6Id = (SELECT Id FROM m.tblPromotion WHERE Name = 'Buy 1 Get 1 Free on Pet Treats' AND IsDeleted = 0);
    END

    -- ================================================================
    -- 6. LINK PRODUCTS TO PROMOTIONS (m.tblPromotionProduct)
    -- ================================================================

    -- Map Promotion 1 (15% off Breakfast & Baking)
    DECLARE @BakingAndCerealProducts TABLE (Slug NVARCHAR(500));
    INSERT INTO @BakingAndCerealProducts VALUES 
        ('kelloggs-coco-pops-480g'), 
        ('mcvities-milk-choc-digestives-266g'),
        ('tesco-finest-butter-croissants-4pk'),
        ('tesco-choc-chip-cookies-200g');

    INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
    SELECT @Promo1Id, p.Id, 0
    FROM m.tblProduct p
    INNER JOIN @BakingAndCerealProducts bp ON p.Slug = bp.Slug
    WHERE p.IsDeleted = 0
      AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo1Id AND ProductId = p.Id AND IsDeleted = 0);

    -- Map Promotion 2 (Save £2.00 on Selected Beer & Spirits)
    DECLARE @SpiritsAndBeerProducts TABLE (Slug NVARCHAR(500));
    INSERT INTO @SpiritsAndBeerProducts VALUES 
        ('peroni-gf-4pack'),
        ('corona-extra-12pk'),
        ('tesco-finest-prosecco-750ml');

    INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
    SELECT @Promo2Id, p.Id, 0
    FROM m.tblProduct p
    INNER JOIN @SpiritsAndBeerProducts sp ON p.Slug = sp.Slug
    WHERE p.IsDeleted = 0
      AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo2Id AND ProductId = p.Id AND IsDeleted = 0);

    -- Map Promotion 3 (Buy 2 Get 1 Free on Heinz & Canned)
    DECLARE @CannedFoods TABLE (Slug NVARCHAR(500));
    INSERT INTO @CannedFoods VALUES 
        ('heinz-spaghetti-hoops-400g'),
        ('heinz-cream-of-chicken-soup-400g'),
        ('napolina-chopped-tomatoes-4pk');

    INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
    SELECT @Promo3Id, p.Id, 0
    FROM m.tblProduct p
    INNER JOIN @CannedFoods cf ON p.Slug = cf.Slug
    WHERE p.IsDeleted = 0
      AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo3Id AND ProductId = p.Id AND IsDeleted = 0);

    -- Map Promotion 4 (3 for £5 on Soft Drinks & Juices)
    DECLARE @Beverages TABLE (Slug NVARCHAR(500));
    INSERT INTO @Beverages VALUES 
        ('coke-zero-12pk'),
        ('tropicana-smooth-orange-900ml'),
        ('pepsi-max-cherry-2l'),
        ('robinsons-orange-squash-1l');

    INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
    SELECT @Promo4Id, p.Id, 0
    FROM m.tblProduct p
    INNER JOIN @Beverages bv ON p.Slug = bv.Slug
    WHERE p.IsDeleted = 0
      AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo4Id AND ProductId = p.Id AND IsDeleted = 0);

    -- Map Promotion 5 (Clubcard Price Deals - Extra Savings)
    DECLARE @ClubcardProducts TABLE (Slug NVARCHAR(500));
    INSERT INTO @ClubcardProducts VALUES
        ('tesco-royal-gala-apples-6-pack'),
        ('tesco-organic-blueberries-150g'),
        ('tesco-finest-ribeye-steak-225g'),
        ('alpro-oat-milk-1l'),
        ('chicago-town-four-cheese-2pk'),
        ('nescafe-azera-americano-100g'),
        ('gillette-fusion5-blades-4pk'),
        ('fairy-non-bio-liquid-38w'),
        ('pedigree-dentastix-28pk');

    INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
    SELECT @Promo5Id, p.Id, 0
    FROM m.tblProduct p
    INNER JOIN @ClubcardProducts cp ON p.Slug = cp.Slug
    WHERE p.IsDeleted = 0
      AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo5Id AND ProductId = p.Id AND IsDeleted = 0);

    -- Map Promotion 6 (Buy 1 Get 1 Free on Pet Treats)
    DECLARE @PetProducts TABLE (Slug NVARCHAR(500));
    INSERT INTO @PetProducts VALUES 
        ('pedigree-dentastix-28pk'),
        ('felix-as-good-as-it-looks-40pk');

    INSERT INTO m.tblPromotionProduct (PromotionId, ProductId, IsDeleted)
    SELECT @Promo6Id, p.Id, 0
    FROM m.tblProduct p
    INNER JOIN @PetProducts pp ON p.Slug = pp.Slug
    WHERE p.IsDeleted = 0
      AND NOT EXISTS (SELECT 1 FROM m.tblPromotionProduct WHERE PromotionId = @Promo6Id AND ProductId = p.Id AND IsDeleted = 0);

    -- ================================================================
    -- 7. AUDIT LOG
    -- ================================================================
    INSERT INTO t.tblAuditLog (TableName, RecordId, Action, OldValues, NewValues, ChangedBy)
    VALUES (
        'm.tblProduct',
        0,
        'INSERT',
        NULL,
        N'{"operation":"V082_SeedAdditionalProductsInventoryPromotions","description":"Seed 55 additional products and 6 promotions"}',
        @Admin
    );

    -- ================================================================
    -- 8. RECORD MIGRATION
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V082')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V082', 'SeedAdditionalProductsInventoryPromotions');

    COMMIT TRANSACTION;
    PRINT 'V082 completed successfully. 55 new products, variants, default inventory, and 6 active promotions seeded.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V082_SeedAdditionalProductsInventoryPromotions.sql', ERROR_MESSAGE(), GETUTCDATE());

    THROW;
END CATCH
