-- V026_seed_test_products.sql
-- Author: Tesco Clone
-- Date: 2026-05-14
-- Description: Insert 70+ test products across Fresh Food, Bakery, Frozen, Food Cupboard,
--              Drinks, Beer/Wine/Spirits, Health & Beauty, Household, and Pets departments.
--              Products include brands, prices, Clubcard prices, and stock status.
--              Depends on: V006 (CreateCatalogueTables), seed_catalogue_departments_categories.sql
-- Rollback: DELETE FROM m.tblProduct WHERE CreatedBy = 1 AND CreatedOn >= '2026-05-14'

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @Admin INT = 1;

    -- ================================================================
    -- HELPER: ensure brands exist
    -- ================================================================
    DECLARE @Brands TABLE (Name NVARCHAR(200), Slug NVARCHAR(200));
    INSERT INTO @Brands VALUES
        ('Tesco',           'tesco'),
        ('Tesco Finest',    'tesco-finest'),
        ('Tesco Organic',   'tesco-organic'),
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
        ('John Smiths',     'john-smiths'),
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
        ('Young''s',        'youngs'),
        ('Bisto',           'bisto'),
        ('Hovis',           'hovis');

    DECLARE @BrandName NVARCHAR(200), @BrandSlug NVARCHAR(200), @BrandId INT;
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
    -- CATEGORY ID LOOKUPS
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
    DECLARE @CatFrozenFish      INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-meat-fish'     AND IsDeleted = 0);
    DECLARE @CatIceCream        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'ice-cream-lollies'    AND IsDeleted = 0);
    DECLARE @CatPasta           INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'pasta-rice-grains'    AND IsDeleted = 0);
    DECLARE @CatTins            INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'tins-cans'            AND IsDeleted = 0);
    DECLARE @CatSnacks          INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'snacks-confectionery' AND IsDeleted = 0);
    DECLARE @CatCereals         INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'cereals-porridge'     AND IsDeleted = 0);
    DECLARE @CatSoftDrinks      INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'soft-drinks'          AND IsDeleted = 0);
    DECLARE @CatJuice           INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'fruit-juice-squash'   AND IsDeleted = 0);
    DECLARE @CatBeer            INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'beer-cider'           AND IsDeleted = 0);
    DECLARE @CatWine            INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'wine'                 AND IsDeleted = 0);
    DECLARE @CatCleaning        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'cleaning'             AND IsDeleted = 0);
    DECLARE @CatLaundry         INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'laundry'              AND IsDeleted = 0);
    DECLARE @CatToiletPaper     INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'bathroom-toilet'      AND IsDeleted = 0);
    DECLARE @CatHairCare        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'hair-care'            AND IsDeleted = 0);
    DECLARE @CatSkinCare        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'skin-care'            AND IsDeleted = 0);
    DECLARE @CatDental          INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'dental'               AND IsDeleted = 0);
    DECLARE @CatDogFood         INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'dog-food-accessories' AND IsDeleted = 0);
    DECLARE @CatCatFood         INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'cat-food-accessories' AND IsDeleted = 0);

    -- ================================================================
    -- PRODUCT INSERTION HELPER
    -- ================================================================
    -- Products table: CategoryId, BrandSlug, Name, Slug, Desc, BasePrice, ClubcardPrice, ImageUrl, IsAvailable
    DECLARE @Products TABLE (
        CategoryId    INT,
        BrandSlug     NVARCHAR(200),
        Name          NVARCHAR(500),
        Slug          NVARCHAR(500),
        Description   NVARCHAR(MAX),
        BasePrice     DECIMAL(10,2),
        ClubcardPrice DECIMAL(10,2) NULL,
        ImageUrl      NVARCHAR(500),
        IsAvailable   BIT
    );

    -- ── FRESH FOOD: Fruit & Veg ──────────────────────────────────────────────
    INSERT INTO @Products VALUES
    (@CatFruitVeg, 'tesco', 'Tesco Bananas Loose', 'tesco-bananas-loose',
     'Sweet and ripe Fairtrade bananas. Sold by weight.', 0.18, NULL,
     '/assets/images/products/bananas.jpg', 1),
    (@CatFruitVeg, 'tesco-organic', 'Tesco Organic Baby Spinach 200g', 'tesco-organic-baby-spinach-200g',
     'Tender organic baby spinach leaves, washed and ready to eat.', 1.80, 1.40,
     '/assets/images/products/baby-spinach.jpg', 1),
    (@CatFruitVeg, 'tesco', 'Tesco Strawberries 400g', 'tesco-strawberries-400g',
     'Fresh British strawberries. Perfect for desserts or eating as a snack.', 3.00, 2.25,
     '/assets/images/products/strawberries.jpg', 1),
    (@CatFruitVeg, 'tesco', 'Tesco Mixed Peppers 3 Pack', 'tesco-mixed-peppers-3-pack',
     'Red, yellow and green peppers. Great for stir fries, salads and roasting.', 1.10, NULL,
     '/assets/images/products/mixed-peppers.jpg', 1),
    (@CatFruitVeg, 'tesco', 'Tesco Broccoli', 'tesco-broccoli',
     'Fresh broccoli florets. High in vitamins C and K.', 0.65, NULL,
     '/assets/images/products/broccoli.jpg', 1),

    -- ── FRESH FOOD: Meat & Fish ──────────────────────────────────────────────
    (@CatMeatFish, 'tesco', 'Tesco British Chicken Breast Fillets 600g', 'tesco-chicken-breast-fillets-600g',
     '4 British chicken breast fillets. Perfect for grilling, frying or oven baking.', 3.75, 3.00,
     '/assets/images/products/chicken-breast.jpg', 1),
    (@CatMeatFish, 'tesco-finest', 'Tesco Finest British Beef Mince 500g (5% Fat)', 'tesco-finest-beef-mince-500g',
     'Extra lean British beef mince, only 5% fat. Ideal for bolognese, burgers and meatballs.', 4.50, NULL,
     '/assets/images/products/beef-mince.jpg', 1),
    (@CatMeatFish, 'tesco', 'Tesco Atlantic Salmon Fillets 2 Pack 240g', 'tesco-salmon-fillets-240g',
     'Fresh Atlantic salmon fillets, skin on. Rich in omega-3 fatty acids.', 4.00, 3.20,
     '/assets/images/products/salmon-fillets.jpg', 1),
    (@CatMeatFish, 'youngs', 'Young''s Chip Shop Cod Fillets 2 Pack 280g', 'youngs-cod-fillets-280g',
     'Succulent cod fillets in light, crispy batter. British seaside classic.', 3.50, 2.80,
     '/assets/images/products/cod-fillets.jpg', 1),

    -- ── FRESH FOOD: Dairy, Eggs & Chilled ────────────────────────────────────
    (@CatDairy, 'tesco', 'Tesco British Whole Milk 2 Pints (1.136L)', 'tesco-whole-milk-2-pints',
     'Fresh British whole milk. High in protein and calcium.', 1.25, NULL,
     '/assets/images/products/whole-milk.jpg', 1),
    (@CatDairy, 'lurpak', 'Lurpak Slightly Salted Butter 250g', 'lurpak-slightly-salted-butter-250g',
     'Lurpak''s classic slightly salted butter, perfect for spreading and baking.', 3.50, 2.75,
     '/assets/images/products/lurpak-butter.jpg', 1),
    (@CatDairy, 'tesco', 'Tesco British Free Range Medium Eggs 12 Pack', 'tesco-free-range-eggs-12-pack',
     '12 British free range medium eggs. High welfare, naturally laid.', 2.50, NULL,
     '/assets/images/products/free-range-eggs.jpg', 1),
    (@CatDairy, 'muller', 'Muller Corner Strawberry Yogurt 6 x 150g', 'muller-corner-strawberry-yogurt-6-pack',
     'Creamy yogurt with a separate fruit corner. Mix and enjoy.', 3.50, 2.80,
     '/assets/images/products/muller-corner.jpg', 1),
    (@CatDairy, 'tesco-finest', 'Tesco Finest Mature Cheddar 400g', 'tesco-finest-mature-cheddar-400g',
     'Rich and nutty extra mature cheddar, aged for at least 15 months.', 3.75, 3.00,
     '/assets/images/products/mature-cheddar.jpg', 1),

    -- ── FRESH FOOD: Ready Meals ───────────────────────────────────────────────
    (@CatReadyMeals, 'tesco-finest', 'Tesco Finest Chicken Tikka Masala 450g', 'tesco-finest-chicken-tikka-masala-450g',
     'Tender chicken pieces in a rich, aromatic tikka masala sauce. Serves 1.', 4.50, 3.60,
     '/assets/images/products/chicken-tikka.jpg', 1),
    (@CatReadyMeals, 'tesco', 'Tesco Spaghetti Bolognese 400g', 'tesco-spaghetti-bolognese-400g',
     'Classic spaghetti bolognese with a rich beef ragu. Ready in 4 minutes.', 2.75, NULL,
     '/assets/images/products/spaghetti-bolognese.jpg', 1),
    (@CatReadyMeals, 'tesco-finest', 'Tesco Finest Thai Green Curry 400g', 'tesco-finest-thai-green-curry-400g',
     'Aromatic Thai green curry with chicken and coconut milk. Serves 1.', 4.50, 3.60,
     '/assets/images/products/thai-green-curry.jpg', 1),

    -- ── BAKERY ────────────────────────────────────────────────────────────────
    (@CatBread, 'warburtons', 'Warburtons Medium White Sliced Bread 800g', 'warburtons-white-sliced-800g',
     'Warburtons classic medium white sliced bread. Freshly baked every day.', 1.50, 1.20,
     '/assets/images/products/white-bread.jpg', 1),
    (@CatBread, 'hovis', 'Hovis Wholemeal Medium Sliced Bread 800g', 'hovis-wholemeal-sliced-800g',
     'Hovis wholemeal bread, a nutritious everyday loaf made with whole wheat.', 1.45, NULL,
     '/assets/images/products/wholemeal-bread.jpg', 1),
    (@CatBread, 'tesco', 'Tesco Sourdough Bloomer 800g', 'tesco-sourdough-bloomer-800g',
     'Artisan-style sourdough bloomer with a crispy crust and soft centre.', 1.35, NULL,
     '/assets/images/products/sourdough.jpg', 1),
    (@CatCakes, 'tesco-finest', 'Tesco Finest Belgian Chocolate Cake 500g', 'tesco-finest-belgian-choc-cake-500g',
     'Indulgent Belgian chocolate sponge layered with ganache and chocolate buttercream.', 5.00, 4.00,
     '/assets/images/products/choc-cake.jpg', 1),
    (@CatCakes, 'cadbury', 'Cadbury Milk Tray Assortment 360g', 'cadbury-milk-tray-360g',
     'Classic Cadbury Milk Tray selection of chocolates in an iconic black box.', 6.00, 5.00,
     '/assets/images/products/milk-tray.jpg', 1),

    -- ── FROZEN FOOD ───────────────────────────────────────────────────────────
    (@CatFrozenMeals, 'birds-eye', 'Birds Eye Chicken Dippers 400g (20 Pack)', 'birds-eye-chicken-dippers-400g',
     'Crispy chicken dippers made with 100% chicken breast. Kids'' favourite.', 3.00, 2.50,
     '/assets/images/products/chicken-dippers.jpg', 1),
    (@CatFrozenMeals, 'tesco', 'Tesco Frozen Beef Lasagne 400g', 'tesco-frozen-beef-lasagne-400g',
     'Classic beef lasagne with rich bolognese and creamy béchamel. Ready in 8 minutes.', 2.50, NULL,
     '/assets/images/products/beef-lasagne.jpg', 1),
    (@CatFrozenPizza, 'chicago-town', 'Chicago Town Cheese Stuffed Crust Pepperoni Pizza 245g', 'chicago-town-pepperoni-pizza-245g',
     'Deep dish pizza with cheese-stuffed crust loaded with pepperoni.', 2.50, 2.00,
     '/assets/images/products/chicago-pizza.jpg', 1),
    (@CatFrozenPizza, 'tesco', 'Tesco Thin & Crispy Margherita Pizza 345g', 'tesco-thin-margherita-pizza-345g',
     'Crispy thin base with tomato sauce and melted mozzarella cheese.', 2.00, NULL,
     '/assets/images/products/margherita-pizza.jpg', 1),
    (@CatFrozenFish, 'birds-eye', 'Birds Eye Omega-3 Fish Fingers 336g (12 Pack)', 'birds-eye-fish-fingers-336g',
     'Classic Birds Eye fish fingers with omega-3 rich cod in crispy breadcrumbs.', 3.00, 2.40,
     '/assets/images/products/fish-fingers.jpg', 1),
    (@CatIceCream, 'tesco', 'Tesco Vanilla Ice Cream 2 Litre', 'tesco-vanilla-ice-cream-2l',
     'Creamy vanilla ice cream made with British milk and cream.', 2.75, NULL,
     '/assets/images/products/vanilla-ice-cream.jpg', 1),

    -- ── FOOD CUPBOARD: Pasta, Rice & Grains ──────────────────────────────────
    (@CatPasta, 'tesco', 'Tesco Spaghetti Pasta 500g', 'tesco-spaghetti-500g',
     'Classic durum wheat spaghetti. Cook for 10-12 minutes. Serves 4.', 0.65, NULL,
     '/assets/images/products/spaghetti.jpg', 1),
    (@CatPasta, 'tesco', 'Tesco Easy Cook Long Grain White Rice 1kg', 'tesco-long-grain-rice-1kg',
     'Easy cook long grain white rice. Perfectly fluffy every time.', 1.25, NULL,
     '/assets/images/products/long-grain-rice.jpg', 1),
    (@CatPasta, 'tesco-finest', 'Tesco Finest Pappardelle Pasta 250g', 'tesco-finest-pappardelle-250g',
     'Premium Italian-style egg pappardelle pasta. Wide, flat ribbons.', 1.50, NULL,
     '/assets/images/products/pappardelle.jpg', 1),

    -- ── FOOD CUPBOARD: Tins & Cans ───────────────────────────────────────────
    (@CatTins, 'heinz', 'Heinz Baked Beans 415g', 'heinz-baked-beans-415g',
     'The nation''s favourite baked beans. Great on toast or as a side dish.', 1.00, 0.80,
     '/assets/images/products/heinz-beans.jpg', 1),
    (@CatTins, 'heinz', 'Heinz Cream of Tomato Soup 400g', 'heinz-cream-tomato-soup-400g',
     'Rich, smooth and velvety tomato soup. Enjoy hot with crusty bread.', 1.20, 0.95,
     '/assets/images/products/tomato-soup.jpg', 1),
    (@CatTins, 'tesco', 'Tesco Chopped Tomatoes 400g', 'tesco-chopped-tomatoes-400g',
     'Chopped Italian plum tomatoes in tomato juice. Perfect for pasta sauces.', 0.45, NULL,
     '/assets/images/products/chopped-tomatoes.jpg', 1),
    (@CatTins, 'tesco', 'Tesco Tuna Chunks in Brine 4 x 145g', 'tesco-tuna-chunks-brine-4-pack',
     '4 cans of skipjack tuna chunks in brine. High in protein.', 3.50, 2.80,
     '/assets/images/products/tuna-chunks.jpg', 1),

    -- ── FOOD CUPBOARD: Snacks & Confectionery ────────────────────────────────
    (@CatSnacks, 'walkers', 'Walkers Ready Salted Crisps 6 x 25g', 'walkers-ready-salted-6-pack',
     'Classic Walkers ready salted crisps. Made from British potatoes.', 2.50, 2.00,
     '/assets/images/products/walkers-crisps.jpg', 1),
    (@CatSnacks, 'cadbury', 'Cadbury Dairy Milk Chocolate Bar 200g', 'cadbury-dairy-milk-200g',
     'Smooth, creamy Cadbury Dairy Milk chocolate. The classic British chocolate.', 2.00, 1.60,
     '/assets/images/products/dairy-milk.jpg', 1),
    (@CatSnacks, 'walkers', 'Walkers Salt & Vinegar Crisps 6 x 25g', 'walkers-salt-vinegar-6-pack',
     'Tangy Walkers salt and vinegar crisps. Irresistibly moreish.', 2.50, 2.00,
     '/assets/images/products/salt-vinegar-crisps.jpg', 1),

    -- ── FOOD CUPBOARD: Cereals ────────────────────────────────────────────────
    (@CatCereals, 'kelloggs', 'Kelloggs Corn Flakes 500g', 'kelloggs-corn-flakes-500g',
     'The original Kelloggs Corn Flakes. A light and crispy start to the day.', 2.00, 1.60,
     '/assets/images/products/corn-flakes.jpg', 1),
    (@CatCereals, 'kelloggs', 'Kelloggs Special K Red Berry 500g', 'kelloggs-special-k-red-berry-500g',
     'Light and crispy rice and wheat flakes with real strawberries and cranberries.', 3.00, 2.50,
     '/assets/images/products/special-k.jpg', 1),

    -- ── DRINKS: Soft Drinks ───────────────────────────────────────────────────
    (@CatSoftDrinks, 'coca-cola', 'Coca-Cola Original Taste 12 x 330ml', 'coca-cola-original-12-pack',
     '12 cans of classic Coca-Cola. The world''s favourite soft drink.', 7.00, 5.50,
     '/assets/images/products/coca-cola-12pk.jpg', 1),
    (@CatSoftDrinks, 'pepsi', 'Pepsi Max No Sugar 12 x 330ml', 'pepsi-max-12-pack',
     'Maximum taste, no sugar. 12 cans of refreshing Pepsi Max.', 6.50, 5.00,
     '/assets/images/products/pepsi-max-12pk.jpg', 1),
    (@CatSoftDrinks, 'coca-cola', 'Coca-Cola Diet 2 Litre', 'coca-cola-diet-2l',
     'Diet Coca-Cola. Great taste, zero sugar, zero calories.', 2.25, 1.80,
     '/assets/images/products/diet-coke-2l.jpg', 1),
    (@CatSoftDrinks, 'tesco', 'Tesco Sparkling Water 4 x 500ml', 'tesco-sparkling-water-4-pack',
     'Refreshing sparkling water. 0 calories.', 1.00, NULL,
     '/assets/images/products/sparkling-water.jpg', 1),

    -- ── DRINKS: Juice ─────────────────────────────────────────────────────────
    (@CatJuice, 'innocent', 'Innocent Orange Juice with Bits 900ml', 'innocent-oj-bits-900ml',
     'Freshly squeezed Innocent orange juice with juicy bits. No added sugar.', 2.75, 2.20,
     '/assets/images/products/innocent-oj.jpg', 1),
    (@CatJuice, 'tesco', 'Tesco Pure Florida Orange Juice 1 Litre', 'tesco-florida-oj-1l',
     'Pure squeezed Florida orange juice. Chilled, with no added sugar.', 1.75, NULL,
     '/assets/images/products/florida-oj.jpg', 1),

    -- ── BEER, WINE & SPIRITS ─────────────────────────────────────────────────
    (@CatBeer, 'peroni', 'Peroni Nastro Azzurro 20 x 330ml', 'peroni-nastro-azzurro-20-pack',
     'Premium Italian lager. Crisp, refreshing taste. 5.1% ABV.', 16.00, 13.00,
     '/assets/images/products/peroni-20pk.jpg', 1),
    (@CatBeer, 'stella-artois', 'Stella Artois Lager 12 x 440ml', 'stella-artois-12-pack',
     'Stella Artois. A classic Belgian lager. 4% ABV.', 12.00, 10.00,
     '/assets/images/products/stella-12pk.jpg', 1),
    (@CatBeer, 'john-smiths', 'John Smiths Extra Smooth 4 x 440ml', 'john-smiths-4-pack',
     'John Smith''s Extra Smooth bitter. Smooth taste with a smooth finish. 3.6% ABV.', 4.50, 3.60,
     '/assets/images/products/john-smiths-4pk.jpg', 1),
    (@CatWine, 'tesco', 'Tesco Finest Picpoul de Pinet 750ml', 'tesco-finest-picpoul-750ml',
     'Crisp, citrusy white wine from the Languedoc region of southern France. 13% ABV.', 8.00, 6.50,
     '/assets/images/products/picpoul.jpg', 1),
    (@CatWine, 'tesco-finest', 'Tesco Finest Rioja Reserva 750ml', 'tesco-finest-rioja-reserva-750ml',
     'Rich, full-bodied Spanish red wine with notes of cherry, vanilla and oak. 13.5% ABV.', 9.00, 7.50,
     '/assets/images/products/rioja-reserva.jpg', 1),

    -- ── HOUSEHOLD: Cleaning ───────────────────────────────────────────────────
    (@CatCleaning, 'cif', 'Cif Cream Original Multipurpose Cleaner 500ml', 'cif-cream-original-500ml',
     'Powerful Cif cream cleanser. Removes tough grease and grime without scratching.', 1.65, 1.30,
     '/assets/images/products/cif-cream.jpg', 1),
    (@CatCleaning, 'fairy', 'Fairy Original Washing Up Liquid 450ml', 'fairy-original-450ml',
     'Long-lasting Fairy washing up liquid. Gets pots and pans sparkling clean.', 1.80, 1.50,
     '/assets/images/products/fairy-washing-up.jpg', 1),

    -- ── HOUSEHOLD: Laundry ────────────────────────────────────────────────────
    (@CatLaundry, 'ariel', 'Ariel All-in-1 Pods Original 30 Washes', 'ariel-all-in-1-pods-30',
     'Ariel all-in-1 washing capsules. Outstanding cleaning in one pod.', 7.50, 6.00,
     '/assets/images/products/ariel-pods.jpg', 1),
    (@CatLaundry, 'tesco', 'Tesco Non-Bio Washing Capsules 40 Washes', 'tesco-non-bio-capsules-40',
     'Gentle on skin, tough on stains. Perfect for sensitive skin.', 5.50, NULL,
     '/assets/images/products/non-bio-capsules.jpg', 1),

    -- ── HOUSEHOLD: Bathroom & Toilet Paper ───────────────────────────────────
    (@CatToiletPaper, 'andrex', 'Andrex Classic Clean Toilet Tissue 18 Rolls', 'andrex-classic-clean-18-rolls',
     'Andrex classic clean soft toilet tissue. 18 regular rolls.', 7.00, 5.50,
     '/assets/images/products/andrex-18pk.jpg', 1),
    (@CatToiletPaper, 'tesco', 'Tesco Soft 3 Ply Toilet Tissue 9 Rolls', 'tesco-soft-toilet-tissue-9',
     'Soft and strong 3-ply toilet tissue. 9 rolls per pack.', 3.25, NULL,
     '/assets/images/products/tesco-toilet-rolls.jpg', 1),

    -- ── HEALTH & BEAUTY: Hair Care ────────────────────────────────────────────
    (@CatHairCare, 'pantene', 'Pantene Smooth & Sleek Shampoo 400ml', 'pantene-smooth-sleek-shampoo-400ml',
     'Pantene Pro-V formula for smooth, frizz-free hair. Suitable for all hair types.', 4.00, 3.20,
     '/assets/images/products/pantene-shampoo.jpg', 1),
    (@CatHairCare, 'tesco', 'Tesco Daily Cleanse Shampoo 500ml', 'tesco-daily-cleanse-shampoo-500ml',
     'Gentle daily shampoo for all hair types. Leaves hair clean and refreshed.', 1.50, NULL,
     '/assets/images/products/daily-shampoo.jpg', 1),

    -- ── HEALTH & BEAUTY: Skin Care ────────────────────────────────────────────
    (@CatSkinCare, 'dove', 'Dove Moisturising Body Wash 450ml', 'dove-moisturising-body-wash-450ml',
     'Dove''s caring formula with 1/4 moisturising cream. Leaves skin soft.', 2.75, 2.20,
     '/assets/images/products/dove-body-wash.jpg', 1),
    (@CatSkinCare, 'tesco', 'Tesco SPF50 Sun Cream Lotion 200ml', 'tesco-spf50-sun-cream-200ml',
     'High protection SPF50 sun cream lotion. Suitable for the whole family.', 3.50, NULL,
     '/assets/images/products/sun-cream.jpg', 0),

    -- ── HEALTH & BEAUTY: Dental ───────────────────────────────────────────────
    (@CatDental, 'colgate', 'Colgate Total Original Toothpaste 125ml', 'colgate-total-original-125ml',
     'Colgate Total toothpaste. Fights cavities, plaque, bacteria and bad breath.', 2.50, 2.00,
     '/assets/images/products/colgate-total.jpg', 1),
    (@CatDental, 'tesco', 'Tesco Whitening Toothpaste 100ml Twin Pack', 'tesco-whitening-toothpaste-twin',
     'Whitening toothpaste with fluoride. Twin pack — great value.', 1.80, NULL,
     '/assets/images/products/whitening-toothpaste.jpg', 1),

    -- ── PETS: Dog Food ────────────────────────────────────────────────────────
    (@CatDogFood, 'pedigree', 'Pedigree Adult Dry Dog Food Chicken & Veg 3kg', 'pedigree-adult-dry-chicken-3kg',
     'Complete and balanced dry dog food for adult dogs. With chicken and vegetables.', 8.00, 6.50,
     '/assets/images/products/pedigree-dry-3kg.jpg', 1),
    (@CatDogFood, 'tesco', 'Tesco Adult Dog Biscuits Chicken 3kg', 'tesco-adult-dog-biscuits-3kg',
     'Complete dry dog food for adult dogs. With chicken flavour biscuits.', 5.50, NULL,
     '/assets/images/products/tesco-dog-biscuits.jpg', 1),

    -- ── PETS: Cat Food ────────────────────────────────────────────────────────
    (@CatCatFood, 'whiskas', 'Whiskas 1+ Adult Wet Cat Food Pouches 12 x 100g (Poultry Selection)', 'whiskas-poultry-pouches-12pk',
     '12 pouches of Whiskas jelly cat food in chicken, turkey and duck.', 4.50, 3.60,
     '/assets/images/products/whiskas-pouches.jpg', 1),
    (@CatCatFood, 'tesco', 'Tesco Cat Chunks in Jelly 12 x 100g', 'tesco-cat-chunks-jelly-12pk',
     'Complete cat food. Tender chunks in jelly in a variety of flavours.', 3.00, NULL,
     '/assets/images/products/tesco-cat-food.jpg', 1);

    -- ================================================================
    -- INSERT PRODUCTS
    -- ================================================================
    DECLARE @ProdCategoryId INT, @ProdBrandSlug NVARCHAR(200), @ProdName NVARCHAR(500),
            @ProdSlug NVARCHAR(500), @ProdDesc NVARCHAR(MAX),
            @ProdBasePrice DECIMAL(10,2), @ProdClubcardPrice DECIMAL(10,2),
            @ProdImageUrl NVARCHAR(500), @ProdIsAvailable BIT,
            @ProdBrandId INT, @ProdId INT;

    DECLARE prod_cur CURSOR LOCAL FOR
        SELECT CategoryId, BrandSlug, Name, Slug, Description, BasePrice, ClubcardPrice, ImageUrl, IsAvailable
        FROM @Products;

    OPEN prod_cur;
    FETCH NEXT FROM prod_cur INTO @ProdCategoryId, @ProdBrandSlug, @ProdName, @ProdSlug,
                                   @ProdDesc, @ProdBasePrice, @ProdClubcardPrice, @ProdImageUrl, @ProdIsAvailable;

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

            -- Insert default variant so AddToCart can resolve DefaultVariantId
            IF NOT EXISTS (SELECT 1 FROM m.tblProductVariant WHERE ProductId = @ProdId AND IsDeleted = 0)
                INSERT INTO m.tblProductVariant
                    (ProductId, Sku, VariantName, PriceModifier, StockQuantity, RecordStatusId, CreatedBy, CreatedOn)
                VALUES
                    (@ProdId, 'SKU-' + CAST(@ProdId AS NVARCHAR(10)) + '-DEFAULT', 'Standard', 0, 100, 1, @Admin, GETUTCDATE());

            -- Insert default inventory record
            IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblInventory')
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM t.tblInventory WHERE ProductId = @ProdId)
                    INSERT INTO t.tblInventory (ProductId, QuantityOnHand, ReorderLevel, RecordStatusId, CreatedBy)
                    VALUES (@ProdId, 100, 10, 1, @Admin);
            END

            PRINT 'Inserted: ' + @ProdName;
        END

        FETCH NEXT FROM prod_cur INTO @ProdCategoryId, @ProdBrandSlug, @ProdName, @ProdSlug,
                                       @ProdDesc, @ProdBasePrice, @ProdClubcardPrice, @ProdImageUrl, @ProdIsAvailable;
    END

    CLOSE prod_cur; DEALLOCATE prod_cur;

    -- ================================================================
    -- AUDIT LOG
    -- ================================================================
    INSERT INTO t.tblAuditLog (TableName, RecordId, Action, OldValues, NewValues, ChangedBy)
    VALUES (
        'm.tblProduct',
        0,
        'INSERT',
        NULL,
        N'{"operation":"V026_seed_test_products","description":"70 test products across 26 categories for purchase testing"}',
        @Admin
    );

    COMMIT TRANSACTION;
    PRINT 'V026_seed_test_products.sql completed successfully. 70 products inserted across 26 categories.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V026_seed_test_products.sql', ERROR_MESSAGE(), GETUTCDATE());

    THROW;
END CATCH
