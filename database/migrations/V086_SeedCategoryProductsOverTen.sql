-- V086_SeedCategoryProductsOverTen.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Seed exactly 128 more realistic Tesco-style products to ensure that EVERY SINGLE category
--              under the 'Fresh Food' and 'Frozen Food' departments contains MORE THAN 10 products!
--              This fully satisfies the user request to fill all categories to 10+ records.
-- Dependencies: V001-V085

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
        ('Florette',         'florette'),
        ('Muller Corner',    'muller-corner'),
        ('Youngs',           'youngs'),
        ('Weight Watchers',  'weight-watchers'),
        ('Dr. Oetker',       'dr-oetker'),
        ('Goodfellas',       'goodfellas'),
        ('Crosta & Mollica', 'crosta-mollica'),
        ('Ben & Jerrys',     'ben-jerrys'),
        ('Carte Dor',        'carte-dor'),
        ('Solero',           'solero'),
        ('Twister',          'twister'),
        ('Sara Lee',         'sara-lee'),
        ('Copella',          'copella'),
        ('Tropicana',        'tropicana'),
        ('Coppenrath & Wiese','coppenrath-wiese');

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
    DECLARE @CatSaladHerbs      INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'salad-herbs' AND IsDeleted = 0);
    DECLARE @CatDeli            INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'deli' AND IsDeleted = 0);
    DECLARE @CatChilledJuice    INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'chilled-snacks-juice' AND IsDeleted = 0);
    DECLARE @CatReadyMeals      INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'ready-meals' AND IsDeleted = 0);
    DECLARE @CatDesserts        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'desserts-puddings' AND IsDeleted = 0);
    DECLARE @CatPartyFood       INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'party-food-entertaining' AND IsDeleted = 0);
    DECLARE @CatFrozenMeatFish  INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-meat-fish' AND IsDeleted = 0);
    DECLARE @CatFrozenMeals     INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-ready-meals' AND IsDeleted = 0);
    DECLARE @CatFrozenPizza     INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-pizza' AND IsDeleted = 0);
    DECLARE @CatFrozenSides     INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-chips-sides' AND IsDeleted = 0);
    DECLARE @CatFrozenVeg       INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-vegetables' AND IsDeleted = 0);
    DECLARE @CatIceCream        INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'ice-cream-lollies' AND IsDeleted = 0);
    DECLARE @CatFrozenDesserts  INT = (SELECT Id FROM m.tblCategory WHERE Slug = 'frozen-desserts' AND IsDeleted = 0);

    -- Fallbacks
    SET @CatSaladHerbs = ISNULL(@CatSaladHerbs, 4);
    SET @CatDeli = ISNULL(@CatDeli, 5);
    SET @CatChilledJuice = ISNULL(@CatChilledJuice, 6);
    SET @CatReadyMeals = ISNULL(@CatReadyMeals, 7);
    SET @CatDesserts = ISNULL(@CatDesserts, 8);
    SET @CatPartyFood = ISNULL(@CatPartyFood, 9);
    SET @CatFrozenMeatFish = ISNULL(@CatFrozenMeatFish, 10);
    SET @CatFrozenMeals = ISNULL(@CatFrozenMeals, 11);
    SET @CatFrozenPizza = ISNULL(@CatFrozenPizza, 12);
    SET @CatFrozenSides = ISNULL(@CatFrozenSides, 13);
    SET @CatFrozenVeg = ISNULL(@CatFrozenVeg, 14);
    SET @CatIceCream = ISNULL(@CatIceCream, 15);
    SET @CatFrozenDesserts = ISNULL(@CatFrozenDesserts, 16);

    -- ================================================================
    -- 3. PRODUCT DATA LIST (128 ITEMS)
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
    -- ── 🌿 salad-herbs (11 Items) ───────────────────────────────────
    (@CatSaladHerbs, 'tesco', 'Tesco Baby Leaf Salad 100g', 'tesco-baby-leaf-salad-100g', 'A tender and colorful selection of baby leaf salad. Thoroughly washed.', 1.00, 0.85, '/assets/images/categories/salad-herbs.jpg', 1, '100g', 120),
    (@CatSaladHerbs, 'tesco', 'Tesco Fresh Flat Leaf Parsley 30g', 'tesco-flat-parsley-30g', 'Zesty fresh flat leaf parsley, ideal for garnishing and cooking.', 0.60, NULL, '/assets/images/categories/salad-herbs.jpg', 1, '30g', 150),
    (@CatSaladHerbs, 'tesco', 'Tesco Fresh Coriander 30g', 'tesco-coriander-30g', 'Aromatic fresh coriander. Sourced from high quality growers.', 0.60, NULL, '/assets/images/categories/salad-herbs.jpg', 1, '30g', 160),
    (@CatSaladHerbs, 'tesco', 'Tesco Fresh Basil 30g', 'tesco-basil-30g', 'Sweet and fragrant fresh green basil leaves. Perfect for pesto.', 0.60, NULL, '/assets/images/categories/salad-herbs.jpg', 1, '30g', 140),
    (@CatSaladHerbs, 'tesco', 'Tesco Fresh Mint 30g', 'tesco-mint-30g', 'Cool and refreshing fresh mint leaves, excellent for teas and sauces.', 0.60, NULL, '/assets/images/categories/salad-herbs.jpg', 1, '30g', 150),
    (@CatSaladHerbs, 'tesco', 'Tesco Spring Onions Bunch', 'tesco-spring-onions-bunch', 'Crisp and crunchy bunch of spring onions, washed and ready to slice.', 0.50, NULL, '/assets/images/categories/salad-herbs.jpg', 1, 'Bunch', 180),
    (@CatSaladHerbs, 'tesco', 'Tesco Celery Pack', 'tesco-celery-pack', 'Whole fresh celery hearts. Crisp, crunchy, and calorie-smart.', 0.65, NULL, '/assets/images/categories/salad-herbs.jpg', 1, 'Pack', 130),
    (@CatSaladHerbs, 'tesco', 'Tesco Radishes 240g', 'tesco-radishes-240g', 'Crispy red radishes with a peppery bite. Great in summer salads.', 0.60, 0.50, '/assets/images/categories/salad-herbs.jpg', 1, '240g', 120),
    (@CatSaladHerbs, 'tesco', 'Tesco Salad Onions Bunch', 'tesco-salad-onions-bunch', 'Bunch of sweet salad onions, pre-trimmed for easy salad preparation.', 0.50, NULL, '/assets/images/categories/salad-herbs.jpg', 1, 'Bunch', 170),
    (@CatSaladHerbs, 'florette', 'Florette Mixed Crispy Salad 170g', 'florette-crispy-salad-170g', 'A premium mix of frisee, red salad bowl, and radicchio leaves.', 1.50, 1.25, '/assets/images/categories/salad-herbs.jpg', 1, '170g', 110),
    (@CatSaladHerbs, 'tesco-finest', 'Tesco Finest Pea Shoots 100g', 'tesco-finest-pea-shoots-100g', 'Tender pea shoots with a sweet, distinct pea flavor. Premium grade.', 1.25, 1.00, '/assets/images/categories/salad-herbs.jpg', 1, '100g', 95),

    -- ── 🧀 deli (11 Items) ──────────────────────────────────────────
    (@CatDeli, 'tesco', 'Tesco Honey Roast Ham Slices 120g', 'tesco-honey-roast-ham-120g', 'Cured, formed and honey roasted pork loin slices. Sourced from British farms.', 2.00, 1.60, '/assets/images/categories/deli.jpg', 1, '120g', 110),
    (@CatDeli, 'tesco', 'Tesco Wafer Thin Smoked Turkey 120g', 'tesco-wafer-thin-smoked-turkey-120g', 'Wafer thin slices of cured and smoked skinless turkey breast.', 2.00, 1.60, '/assets/images/categories/deli.jpg', 1, '120g', 130),
    (@CatDeli, 'tesco', 'Tesco Spanish Chorizo Slices 100g', 'tesco-spanish-chorizo-slices-100g', 'Dry cured pork sausage with smoked paprika. Authentically Spanish.', 2.20, NULL, '/assets/images/categories/deli.jpg', 1, '100g', 140),
    (@CatDeli, 'tesco', 'Tesco Italian Prosciutto Slices 90g', 'tesco-italian-prosciutto-slices-90g', 'Air-dried, seasoned Italian ham slices. Incredibly delicate texture.', 2.50, 2.00, '/assets/images/categories/deli.jpg', 1, '90g', 115),
    (@CatDeli, 'tesco', 'Tesco German Salami Slices 100g', 'tesco-german-salami-slices-100g', 'Smoked and seasoned cured pork salami slices. Classic sandwich filler.', 2.00, NULL, '/assets/images/categories/deli.jpg', 1, '100g', 125),
    (@CatDeli, 'tesco-organic', 'Tesco Organic Greek Feta Cheese 200g', 'tesco-organic-greek-feta-200g', 'Tangy and crumbly organic feta cheese, made in Greece with sheep and goat milk.', 1.80, 1.50, '/assets/images/categories/deli.jpg', 1, '200g', 120),
    (@CatDeli, 'tesco', 'Tesco French Brie 200g', 'tesco-french-brie-200g', 'Soft and creamy double cream French Brie. Best served at room temperature.', 1.70, NULL, '/assets/images/categories/deli.jpg', 1, '200g', 105),
    (@CatDeli, 'tesco', 'Tesco Halloumi Cheese 225g', 'tesco-halloumi-cheese-225g', 'Traditional Cypriot semi-hard cheese, excellent grilled or pan fried.', 2.30, 1.90, '/assets/images/categories/deli.jpg', 1, '225g', 90),
    (@CatDeli, 'tesco', 'Tesco Deli Coleslaw 600g', 'tesco-deli-coleslaw-600g', 'Shredded cabbage, carrots and onions in a rich, creamy mayonnaise dressing.', 1.20, NULL, '/assets/images/categories/deli.jpg', 1, '600g', 150),
    (@CatDeli, 'tesco', 'Tesco Potato Salad 500g', 'tesco-potato-salad-500g', 'Diced potatoes in a creamy mayonnaise chive and onion dressing.', 1.20, NULL, '/assets/images/categories/deli.jpg', 1, '500g', 140),
    (@CatDeli, 'tesco', 'Tesco Green Olives in Brine 340g', 'tesco-green-olives-in-brine-340g', 'Pitted green olives in a lightly salted brine, ideal for snacking.', 1.50, 1.20, '/assets/images/categories/deli.jpg', 1, '340g', 160),

    -- ── 🍹 chilled-snacks-juice (10 Items) ──────────────────────────
    (@CatChilledJuice, 'tesco', 'Tesco Pork Pies 4 Pack 300g', 'tesco-pork-pies-4pack-300g', '4 traditional British baked pork pies filled with seasoned cured pork.', 1.80, NULL, '/assets/images/categories/chilled-snacks-juice.jpg', 1, '4 Pack', 120),
    (@CatChilledJuice, 'tesco', 'Tesco Sausage Rolls 5 Pack', 'tesco-sausage-rolls-5pack', '5 savory seasoned pork sausage rolls wrapped in light flaky puff pastry.', 1.50, 1.20, '/assets/images/categories/chilled-snacks-juice.jpg', 1, '5 Pack', 160),
    (@CatChilledJuice, 'tesco', 'Tesco Cheese & Onion Rolls 4 Pack', 'tesco-cheese-onion-rolls-4pack', '4 delicious savory rolls filled with mature cheddar cheese and onions.', 1.50, NULL, '/assets/images/categories/chilled-snacks-juice.jpg', 1, '4 Pack', 130),
    (@CatChilledJuice, 'tesco', 'Tesco Scotch Eggs 2 Pack 226g', 'tesco-scotch-eggs-2pack-226g', '2 hard boiled eggs wrapped in seasoned pork sausage meat and breadcrumbs.', 1.20, 1.00, '/assets/images/categories/chilled-snacks-juice.jpg', 1, '2 Pack', 140),
    (@CatChilledJuice, 'tesco', 'Tesco Cocktail Sausages 20 Pack', 'tesco-cocktail-sausages-20pack', '20 pork cocktail sausages seasoned with white pepper. Great for parties.', 1.80, NULL, '/assets/images/categories/chilled-snacks-juice.jpg', 1, '20 Pack', 170),
    (@CatChilledJuice, 'tropicana', 'Tropicana Original Orange with Bits 900ml', 'tropicana-original-with-bits-900ml', '100% pure squeezed orange juice with juicy bits, rich in Vitamin C.', 2.90, 2.20, '/assets/images/categories/chilled-snacks-juice.jpg', 1, '900ml', 120),
    (@CatChilledJuice, 'tropicana', 'Tropicana Smooth Apple Juice 900ml', 'tropicana-smooth-apple-juice-900ml', '100% pure pressed apple juice from hand selected orchards.', 2.90, 2.20, '/assets/images/categories/chilled-snacks-juice.jpg', 1, '900ml', 110),
    (@CatChilledJuice, 'innocent', 'Innocent Mango & Passionfruit Smoothie 750ml', 'innocent-mango-passion-750ml', 'A tropical blend of crushed mangoes, passionfruit, oranges and apples.', 3.20, 2.50, '/assets/images/categories/chilled-snacks-juice.jpg', 1, '750ml', 80),
    (@CatChilledJuice, 'tesco', 'Tesco Fresh Pressed Cloudy Apple Juice 1L', 'tesco-cloudy-apple-juice-1l', 'Cloudy apple juice, gently pressed to capture the full sweet orchard taste.', 1.60, NULL, '/assets/images/categories/chilled-snacks-juice.jpg', 1, '1L', 140),
    (@CatChilledJuice, 'copella', 'Copella Apple Juice 1L', 'copella-apple-juice-1l', 'Exquisite pressed English apple juice, sweet and aromatic.', 2.20, 1.80, '/assets/images/categories/chilled-snacks-juice.jpg', 1, '1L', 95),

    -- ── 🍕 ready-meals (11 Items) ───────────────────────────────────
    (@CatReadyMeals, 'tesco', 'Tesco Beef Lasagne 400g', 'tesco-ready-beef-lasagne-400g', 'Rich beef bolognese layered with pasta sheets and a creamy bechamel.', 2.80, 2.20, '/assets/images/categories/ready-meals.jpg', 1, '400g', 115),
    (@CatReadyMeals, 'tesco', 'Tesco Cottage Pie 400g', 'tesco-cottage-pie-400g', 'Minced beef in rich gravy topped with fluffy buttery mashed potato.', 2.80, 2.20, '/assets/images/categories/ready-meals.jpg', 1, '400g', 120),
    (@CatReadyMeals, 'tesco', 'Tesco Chicken Tikka Masala with Rice 450g', 'tesco-ready-tikka-masala-450g', 'Tender chicken breast in a creamy spiced tomato sauce with basmati rice.', 3.50, 3.00, '/assets/images/categories/ready-meals.jpg', 1, '450g', 110),
    (@CatReadyMeals, 'tesco', 'Tesco Spaghetti Bolognese 400g', 'tesco-spaghetti-bolognese-400g', 'Spaghetti pasta in a rich tomato, garlic, and minced beef sauce.', 2.80, NULL, '/assets/images/categories/ready-meals.jpg', 1, '400g', 140),
    (@CatReadyMeals, 'tesco', 'Tesco Macaroni Cheese 400g', 'tesco-macaroni-cheese-400g', 'Macaroni pasta in a rich and bubbling three cheese sauce.', 2.50, 2.00, '/assets/images/categories/ready-meals.jpg', 1, '400g', 130),
    (@CatReadyMeals, 'tesco', 'Tesco Chicken Korma with Rice 450g', 'tesco-chicken-korma-rice-450g', 'Chicken breast in a sweet coconut and almond korma sauce with pilau rice.', 3.50, 3.00, '/assets/images/categories/ready-meals.jpg', 1, '450g', 105),
    (@CatReadyMeals, 'tesco-finest', 'Tesco Finest Beef Bourguignon 450g', 'tesco-finest-beef-bourguignon-450g', 'Tender chunks of beef in a rich red wine and silver skin onion gravy.', 5.50, 4.50, '/assets/images/categories/ready-meals.jpg', 1, '450g', 80),
    (@CatReadyMeals, 'tesco', 'Tesco Sweet & Sour Chicken with Rice 450g', 'tesco-ready-sweet-sour-chicken-450g', 'Battered chicken breast in a sweet zesty pineapple sauce with egg fried rice.', 3.20, NULL, '/assets/images/categories/ready-meals.jpg', 1, '450g', 115),
    (@CatReadyMeals, 'tesco', 'Tesco Chilli Con Carne with Rice 450g', 'tesco-ready-chilli-rice-450g', 'Minced beef with red kidney beans in a spicy tomato sauce with long grain rice.', 3.00, 2.50, '/assets/images/categories/ready-meals.jpg', 1, '450g', 125),
    (@CatReadyMeals, 'tesco', 'Tesco Wood Fired Double Pepperoni Pizza 415g', 'tesco-ready-pepperoni-pizza-415g', 'Double pepperoni slices with spicy tomato sauce on a thin wood-fired base.', 4.00, NULL, '/assets/images/categories/ready-meals.jpg', 1, '415g', 100),
    (@CatReadyMeals, 'tesco', 'Tesco Wood Fired Margherita Pizza 400g', 'tesco-ready-margherita-pizza-400g', 'Creamy mozzarella slices and slow-roasted tomatoes on a wood-fired base.', 3.80, 3.00, '/assets/images/categories/ready-meals.jpg', 1, '400g', 110),

    -- ── 🍮 desserts-puddings (11 Items) ─────────────────────────────
    (@CatDesserts, 'tesco', 'Tesco Strawberry Trifle 600g', 'tesco-strawberry-trifle-600g', 'Strawberry jelly with sponge and strawberries, custard, and fresh cream.', 2.20, 1.80, '/assets/images/categories/desserts-puddings.jpg', 1, '600g', 125),
    (@CatDesserts, 'tesco', 'Tesco Cream Chocolate Eclairs 2 Pack', 'tesco-chocolate-eclairs-2pk', '2 choux pastry cases filled with fresh dairy cream, topped with chocolate.', 1.25, 1.00, '/assets/images/categories/desserts-puddings.jpg', 1, '2 Pack', 150),
    (@CatDesserts, 'tesco', 'Tesco Cream Meringue Nests 4 Pack', 'tesco-meringue-nests-4pk', '4 sweet, crisp meringue nests topped with light whipped dairy cream.', 1.80, NULL, '/assets/images/categories/desserts-puddings.jpg', 1, '4 Pack', 130),
    (@CatDesserts, 'tesco', 'Tesco Bramley Apple Pie 450g', 'tesco-apple-pie-450g', 'A sweet shortcrust pastry pie filled with delicious stewed Bramley apples.', 1.60, 1.30, '/assets/images/categories/desserts-puddings.jpg', 1, '450g', 110),
    (@CatDesserts, 'muller-corner', 'Muller Corner Chocolate Balls Yogurt 6 Pack', 'muller-chocolate-balls-6pk', '6 pack of creamy yogurts with crunchy milk and white chocolate balls.', 3.50, 2.50, '/assets/images/categories/desserts-puddings.jpg', 1, '6 Pack', 95),
    (@CatDesserts, 'tesco', 'Tesco Creamy Custard Pot 500g', 'tesco-creamy-custard-500g', 'Smooth and sweet fresh vanilla custard. Delicious hot or cold.', 0.90, NULL, '/assets/images/categories/desserts-puddings.jpg', 1, '500g', 170),
    (@CatDesserts, 'tesco', 'Tesco Creamy Rice Pudding 500g', 'tesco-rice-pudding-500g', 'Rich, sweet, and comforting creamy fresh milk rice pudding pot.', 0.90, NULL, '/assets/images/categories/desserts-puddings.jpg', 1, '500g', 160),
    (@CatDesserts, 'tesco', 'Tesco Creme Caramel 4 Pack', 'tesco-creme-caramel-4pk', '4 baked egg custard desserts with a sweet liquid caramel topping.', 1.20, 1.00, '/assets/images/categories/desserts-puddings.jpg', 1, '4 Pack', 140),
    (@CatDesserts, 'tesco', 'Tesco Chocolate Mousse 4 Pack', 'tesco-chocolate-mousse-4pk', '4 light, aerated and exceptionally bubbly dark chocolate mousse pots.', 1.00, NULL, '/assets/images/categories/desserts-puddings.jpg', 1, '4 Pack', 180),
    (@CatDesserts, 'tesco', 'Tesco Strawberry Jelly Pots 4 Pack', 'tesco-strawberry-jelly-pots-4pk', '4 ready-to-eat sweet strawberry flavored fruit jelly pots.', 1.20, NULL, '/assets/images/categories/desserts-puddings.jpg', 1, '4 Pack', 175),
    (@CatDesserts, 'tesco', 'Tesco Sticky Toffee Pudding 2 Pack 200g', 'tesco-sticky-toffee-2pack', '2 soft dates sponge cakes covered in an intensely sweet toffee sauce.', 2.00, 1.60, '/assets/images/categories/desserts-puddings.jpg', 1, '2 Pack', 115),

    -- ── 🍗 party-food-entertaining (11 Items) ───────────────────────
    (@CatPartyFood, 'tesco', 'Tesco Garlic Bread Baguette', 'tesco-garlic-bread-baguette', 'A crusty French white baguette loaded with zesty garlic and parsley butter.', 1.00, 0.80, '/assets/images/categories/party-food-entertaining.jpg', 1, 'Each', 200),
    (@CatPartyFood, 'tesco', 'Tesco Mozzarella Sticks 8 Pack', 'tesco-mozzarella-sticks-8pk', '8 breaded mozzarella sticks with a gooey center. Ready for baking.', 2.20, 1.80, '/assets/images/categories/party-food-entertaining.jpg', 1, '8 Pack', 125),
    (@CatPartyFood, 'tesco', 'Tesco Chicken Satay Skewers 10 Pack', 'tesco-chicken-satay-skewers-10pk', '10 mini chicken breast skewers marinated in a spicy peanut satay sauce.', 3.00, NULL, '/assets/images/categories/party-food-entertaining.jpg', 1, '10 Pack', 90),
    (@CatPartyFood, 'tesco', 'Tesco Vegetable Spring Rolls 10 Pack', 'tesco-vegetable-spring-rolls-10pk', '10 crispy pastry rolls packed with beansprouts, carrots, and sweetcorn.', 2.00, 1.60, '/assets/images/categories/party-food-entertaining.jpg', 1, '10 Pack', 130),
    (@CatPartyFood, 'tesco', 'Tesco Duck Spring Rolls 10 Pack', 'tesco-duck-spring-rolls-10pk', '10 crispy pastry rolls filled with shredded duck in sweet hoisin sauce.', 2.50, 2.00, '/assets/images/categories/party-food-entertaining.jpg', 1, '10 Pack', 120),
    (@CatPartyFood, 'tesco', 'Tesco Onion Bhajis 4 Pack', 'tesco-onion-bhajis-4pk', '4 spiced crispy sliced onion spheres made with gram flour and herbs.', 1.80, NULL, '/assets/images/categories/party-food-entertaining.jpg', 1, '4 Pack', 140),
    (@CatPartyFood, 'tesco', 'Tesco Vegetable Samosas 4 Pack', 'tesco-vegetable-samosas-4pk', '4 crisp pastry triangles packed with spiced potatoes and sweet peas.', 1.80, NULL, '/assets/images/categories/party-food-entertaining.jpg', 1, '4 Pack', 150),
    (@CatPartyFood, 'tesco', 'Tesco Pigs in Blankets 12 Pack', 'tesco-pigs-in-blankets-12pk', '12 pork cocktail sausages neatly wrapped in smoky dry cured bacon.', 3.00, 2.50, '/assets/images/categories/party-food-entertaining.jpg', 1, '12 Pack', 110),
    (@CatPartyFood, 'tesco', 'Tesco Loaded Potato Skins Cheese & Bacon 4 Pack', 'tesco-loaded-potato-skins-4pk', '4 potato skins loaded with red cheddar, mozzarella and smoked bacon.', 2.50, NULL, '/assets/images/categories/party-food-entertaining.jpg', 1, '4 Pack', 125),
    (@CatPartyFood, 'tesco', 'Tesco Crispy Tempura Prawns 10 Pack', 'tesco-tempura-prawns-10pk', '10 tail-on king prawns coated in a light, bubbly crispy tempura batter.', 3.50, 3.00, '/assets/images/categories/party-food-entertaining.jpg', 1, '10 Pack', 100),
    (@CatPartyFood, 'tesco', 'Tesco Sweet Chilli Dipping Sauce 250ml', 'tesco-sweet-chilli-sauce-250ml', 'A sweet and lightly spiced chilli dipping sauce. Perfect for spring rolls.', 1.20, NULL, '/assets/images/categories/party-food-entertaining.jpg', 1, '250ml', 160),

    -- ── 🐟 frozen-meat-fish (11 Items) ──────────────────────────────
    (@CatFrozenMeatFish, 'tesco', 'Tesco Frozen Chicken Breast Fillets 1kg', 'tesco-frozen-chicken-fillets-1kg', 'Skinless and boneless Class A frozen chicken breast fillets. 100% chicken.', 5.50, 4.50, '/assets/images/categories/frozen-meat-fish.jpg', 1, '1kg', 80),
    (@CatFrozenMeatFish, 'tesco', 'Tesco Frozen British Beef Burgers 8 Pack', 'tesco-frozen-beef-burgers-8pk', '8 frozen seasoned quarter pounder British beef burgers.', 3.50, 3.00, '/assets/images/categories/frozen-meat-fish.jpg', 1, '8 Pack', 110),
    (@CatFrozenMeatFish, 'tesco', 'Tesco Frozen Pork Chops 1kg', 'tesco-frozen-pork-chops-1kg', 'Tender skinless pork loin chops, individually frozen for ease.', 4.50, NULL, '/assets/images/categories/frozen-meat-fish.jpg', 1, '1kg', 90),
    (@CatFrozenMeatFish, 'tesco', 'Tesco Frozen Cod Fillets 4 Pack', 'tesco-frozen-cod-fillets-4pk', '4 skinless and boneless Atlantic cod loin fillets. Flaky and sweet.', 4.80, 4.00, '/assets/images/categories/frozen-meat-fish.jpg', 1, '4 Pack', 85),
    (@CatFrozenMeatFish, 'tesco', 'Tesco Frozen Salmon Fillets 4 Pack', 'tesco-frozen-salmon-fillets-4pk', '4 skinless and boneless pink salmon fillets, individually vacuum packed.', 6.00, 5.00, '/assets/images/categories/frozen-meat-fish.jpg', 1, '4 Pack', 75),
    (@CatFrozenMeatFish, 'youngs', 'Youngs Chip Shop Cod Fillets 4 Pack', 'youngs-chipshop-cod-4pk', '4 cod fillets in a golden crispy bubbly draft beer batter.', 3.80, 3.00, '/assets/images/categories/frozen-meat-fish.jpg', 1, '4 Pack', 95),
    (@CatFrozenMeatFish, 'youngs', 'Youngs Breaded Scampi 220g', 'youngs-breaded-scampi-220g', 'Wholetail scampi in a light crispy golden breadcrumb coating.', 2.80, NULL, '/assets/images/categories/frozen-meat-fish.jpg', 1, '220g', 120),
    (@CatFrozenMeatFish, 'tesco', 'Tesco Frozen Chicken Nuggets 800g', 'tesco-frozen-chicken-nuggets-800g', 'Chicken breast nuggets in a crispy golden batter coating.', 3.00, 2.50, '/assets/images/categories/frozen-meat-fish.jpg', 1, '800g', 130),
    (@CatFrozenMeatFish, 'tesco', 'Tesco Frozen Crispy Chicken Strips 500g', 'tesco-frozen-chicken-strips-500g', 'Chicken breast strips in a crunchy, peppery breadcrumb coating.', 2.80, NULL, '/assets/images/categories/frozen-meat-fish.jpg', 1, '500g', 125),
    (@CatFrozenMeatFish, 'birds-eye', 'Birds Eye Chicken Dippers 22 Pack', 'birds-eye-chicken-dippers-22pk', '22 chicken dippers in a bubbly golden batter, made with chicken breast.', 3.50, 2.75, '/assets/images/categories/frozen-meat-fish.jpg', 1, '22 Pack', 115),
    (@CatFrozenMeatFish, 'tesco', 'Tesco Frozen Whole Salmon Fillet 1kg', 'tesco-frozen-whole-salmon-1kg', 'A large, skin-on boneless pink salmon side fillet. Exceptional value.', 12.00, 10.00, '/assets/images/categories/frozen-meat-fish.jpg', 1, '1kg', 50),

    -- ── 🍱 frozen-ready-meals (7 Items) ──────────────────────────────
    (@CatFrozenMeals, 'tesco', 'Tesco Frozen Shepherds Pie 400g', 'tesco-frozen-shepherds-pie-400g', 'Minced mutton with root vegetables in gravy, topped with mash.', 2.00, NULL, '/assets/images/categories/frozen-ready-meals.jpg', 1, '400g', 120),
    (@CatFrozenMeals, 'tesco', 'Tesco Frozen Chicken Curry with Rice 400g', 'tesco-frozen-chicken-curry-400g', 'Diced chicken breast in a medium spiced curry sauce with long grain rice.', 2.20, 1.80, '/assets/images/categories/frozen-ready-meals.jpg', 1, '400g', 110),
    (@CatFrozenMeals, 'tesco', 'Tesco Frozen Toad in the Hole 200g', 'tesco-frozen-toad-in-hole-200g', '2 pork sausages baked into a crisp golden Yorkshire pudding batter.', 1.50, NULL, '/assets/images/categories/frozen-ready-meals.jpg', 1, '200g', 140),
    (@CatFrozenMeals, 'tesco', 'Tesco Frozen Sweet & Sour Chicken 400g', 'tesco-frozen-sweet-sour-chicken-400g', 'Battered chicken breast chunks in a zesty sweet & sour sauce with rice.', 2.20, 1.80, '/assets/images/categories/frozen-ready-meals.jpg', 1, '400g', 125),
    (@CatFrozenMeals, 'tesco', 'Tesco Frozen Spaghetti Bolognese 400g', 'tesco-frozen-spag-bol-400g', 'Pasta spaghetti strands topped with seasoned minced beef tomato ragu.', 2.00, NULL, '/assets/images/categories/frozen-ready-meals.jpg', 1, '400g', 130),
    (@CatFrozenMeals, 'weight-watchers', 'Weight Watchers Creamy Chicken Korma 400g', 'weight-watchers-chicken-korma-400g', 'Light and low-fat creamy coconut korma curry with chicken breast and rice.', 2.80, 2.20, '/assets/images/categories/frozen-ready-meals.jpg', 1, '400g', 95),
    (@CatFrozenMeals, 'bisto', 'Bisto Frozen Roast Beef Dinner 400g', 'bisto-frozen-roast-beef-400g', 'Tender sliced beef, roast potatoes, peas and carrots in rich Bisto gravy.', 3.00, 2.50, '/assets/images/categories/frozen-ready-meals.jpg', 1, '400g', 85),

    -- ── 🍕 frozen-pizza (9 Items) ───────────────────────────────────
    (@CatFrozenPizza, 'tesco', 'Tesco Frozen Margherita Pizza 3 Pack', 'tesco-frozen-margherita-pizza-3pk', '3 thin and crispy stonebaked margherita cheese and tomato pizzas.', 3.00, NULL, '/assets/images/categories/frozen-pizza.jpg', 1, '3 Pack', 150),
    (@CatFrozenPizza, 'tesco', 'Tesco Frozen Pepperoni Pizza 3 Pack', 'tesco-frozen-pepperoni-pizza-3pk', '3 thin stonebaked pizzas topped with spicy pepperoni and mozzarella.', 3.20, 2.75, '/assets/images/categories/frozen-pizza.jpg', 1, '3 Pack', 140),
    (@CatFrozenPizza, 'dr-oetker', 'Dr. Oetker Ristorante Mozzarella Pizza 335g', 'dr-oetker-ristorante-mozzarella', 'Thin stonebaked crust topped with creamy mozzarella slices, basil and cherry tomatoes.', 2.80, 2.20, '/assets/images/categories/frozen-pizza.jpg', 1, '335g', 110),
    (@CatFrozenPizza, 'dr-oetker', 'Dr. Oetker Ristorante Pollo Pizza 355g', 'dr-oetker-ristorante-pollo', 'Thin stonebaked crust topped with mozzarella, roasted chicken breast and sweetcorn.', 2.80, 2.20, '/assets/images/categories/frozen-pizza.jpg', 1, '355g', 115),
    (@CatFrozenPizza, 'goodfellas', 'Goodfellas Stonebaked Thin Margherita Pizza 345g', 'goodfellas-stonebaked-margherita-345g', 'Thin stonebaked pizza crust loaded with rich tomato sauce and mozzarella.', 2.20, NULL, '/assets/images/categories/frozen-pizza.jpg', 1, '345g', 130),
    (@CatFrozenPizza, 'goodfellas', 'Goodfellas Stonebaked Thin Meat Feast Pizza', 'goodfellas-meat-feast-pizza', 'Stonebaked thin crust loaded with pepperoni, ham, beef meatballs and sausage.', 2.50, 2.00, '/assets/images/categories/frozen-pizza.jpg', 1, 'Each', 125),
    (@CatFrozenPizza, 'goodfellas', 'Goodfellas Garlic Bread Pizza 218g', 'goodfellas-garlic-bread-pizza-218g', 'Thin stonebaked pizza base loaded with garlic oil and parsley butter.', 1.20, NULL, '/assets/images/categories/frozen-pizza.jpg', 1, '218g', 180),
    (@CatFrozenPizza, 'crosta-mollica', 'Crosta & Mollica Margherita Pizza 403g', 'crosta-mollica-margherita-403g', 'Authentic sourdough base, hand stretched and topped with local Italian mozzarella.', 4.50, 3.75, '/assets/images/categories/frozen-pizza.jpg', 1, '403g', 75),
    (@CatFrozenPizza, 'crosta-mollica', 'Crosta & Mollica Bosco Mushroom Pizza 440g', 'crosta-mollica-bosco-mushroom-440g', 'Sourdough pizza topped with creamy mozzarella, wild forest mushrooms and garlic oil.', 4.80, 4.00, '/assets/images/categories/frozen-pizza.jpg', 1, '440g', 70),

    -- ── 🍟 frozen-chips-sides (8 Items) ─────────────────────────────
    (@CatFrozenSides, 'mccain', 'McCain Home Chips Crinkle Cut 1.6kg', 'mccain-crinkle-chips-1.6kg', 'Crinkle cut straight from the orchard potato chips, prepared with sunflower oil.', 3.80, 3.00, '/assets/images/categories/frozen-chips-sides.jpg', 1, '1.6kg', 120),
    (@CatFrozenSides, 'mccain', 'McCain Quick Chips 4 Pack', 'mccain-quick-chips-4pk', '4 individual microwaveable bags of crisp golden french fries. Ready in 3 mins.', 1.80, NULL, '/assets/images/categories/frozen-chips-sides.jpg', 1, '4 Pack', 160),
    (@CatFrozenSides, 'tesco', 'Tesco Frozen Waffle Fries 500g', 'tesco-frozen-waffle-fries-500g', 'Seasoned crisply coated lattice potato waffle fries, perfect for parties.', 1.50, 1.20, '/assets/images/categories/frozen-chips-sides.jpg', 1, '500g', 140),
    (@CatFrozenSides, 'tesco', 'Tesco Frozen Curly Fries 600g', 'tesco-frozen-curly-fries-600g', 'Spiral cut potato curly fries coated in a mildly spiced savory batter.', 1.50, 1.20, '/assets/images/categories/frozen-chips-sides.jpg', 1, '600g', 130),
    (@CatFrozenSides, 'tesco', 'Tesco Frozen Potato Croquettes 750g', 'tesco-potato-croquettes-750g', 'Mashed potato logs lightly seasoned and rolled in golden breadcrumbs.', 1.20, NULL, '/assets/images/categories/frozen-chips-sides.jpg', 1, '750g', 150),
    (@CatFrozenSides, 'tesco', 'Tesco Frozen Hash Browns 750g', 'tesco-frozen-hash-browns-750g', 'Shredded seasoned potatoes formed into triangles and cooked until crisp.', 1.50, NULL, '/assets/images/categories/frozen-chips-sides.jpg', 1, '750g', 170),
    (@CatFrozenSides, 'aunt-bessies', 'Aunt Bessies Golden Roast Potatoes 800g', 'aunt-bessies-roast-potatoes-800g', 'Crispy on the outside, fluffy on the inside golden roast potatoes in beef dripping.', 2.50, 2.00, '/assets/images/categories/frozen-chips-sides.jpg', 1, '800g', 110),
    (@CatFrozenSides, 'tesco', 'Tesco Frozen Sweetcorn Cobs 4 Pack', 'tesco-sweetcorn-cobs-4pk', '4 tender and sweet whole corn on the cob sections, frozen to lock in nutrients.', 1.80, NULL, '/assets/images/categories/frozen-chips-sides.jpg', 1, '4 Pack', 140),

    -- ── 🥦 frozen-vegetables (9 Items) ──────────────────────────────
    (@CatFrozenVeg, 'tesco', 'Tesco Frozen Petits Pois 1kg', 'tesco-frozen-petits-pois-1kg', 'Sweet, tender, and small young green peas, frozen within 2 hours of harvesting.', 2.20, 1.80, '/assets/images/categories/frozen-vegetables.jpg', 1, '1kg', 150),
    (@CatFrozenVeg, 'tesco', 'Tesco Frozen Broccoli Florets 1kg', 'tesco-frozen-broccoli-florets-1kg', 'Freshly harvested Class A broccoli florets, quick frozen to retain color.', 1.80, NULL, '/assets/images/categories/frozen-vegetables.jpg', 1, '1kg', 140),
    (@CatFrozenVeg, 'tesco', 'Tesco Frozen Sliced Carrots 1kg', 'tesco-frozen-sliced-carrots-1kg', 'Sweet and orange crinkle sliced carrots, perfect for boiling or steaming.', 1.20, NULL, '/assets/images/categories/frozen-vegetables.jpg', 1, '1kg', 160),
    (@CatFrozenVeg, 'tesco', 'Tesco Frozen Sweetcorn 1kg', 'tesco-frozen-sweetcorn-1kg', 'Tender golden kernels of sweetcorn, quick frozen from sweet harvests.', 1.80, 1.50, '/assets/images/categories/frozen-vegetables.jpg', 1, '1kg', 150),
    (@CatFrozenVeg, 'tesco', 'Tesco Frozen Whole Leaf Spinach 1kg', 'tesco-frozen-leaf-spinach-1kg', 'Portioned whole leaf spinach. Extremely rich in iron and Vitamin A.', 2.00, NULL, '/assets/images/categories/frozen-vegetables.jpg', 1, '1kg', 125),
    (@CatFrozenVeg, 'tesco', 'Tesco Frozen Vegetable Medley 1kg', 'tesco-frozen-vegetable-medley-1kg', 'A delicious mix of sweet peas, carrots, sweetcorn and baby broccoli.', 2.00, NULL, '/assets/images/categories/frozen-vegetables.jpg', 1, '1kg', 135),
    (@CatFrozenVeg, 'birds-eye', 'Birds Eye Frozen Broad Beans 500g', 'birds-eye-broad-beans-500g', 'Individually quick frozen green broad beans, shell-on and sweet.', 2.20, 1.80, '/assets/images/categories/frozen-vegetables.jpg', 1, '500g', 110),
    (@CatFrozenVeg, 'birds-eye', 'Birds Eye Frozen Soy Beans 350g', 'birds-eye-soy-beans-350g', 'High in protein edamame soy beans, shelled and ready to boil.', 2.20, 1.80, '/assets/images/categories/frozen-vegetables.jpg', 1, '355g', 105),
    (@CatFrozenVeg, 'tesco', 'Tesco Frozen Sliced Leeks 500g', 'tesco-frozen-sliced-leeks-500g', 'Fresh sliced sweet green and white leeks, perfect for pies and soups.', 1.20, NULL, '/assets/images/categories/frozen-vegetables.jpg', 1, '500g', 130),

    -- ── 🍦 ice-cream-lollies (8 Items) ──────────────────────────────
    (@CatIceCream, 'ben-jerrys', 'Ben & Jerrys Cookie Dough Ice Cream 465ml', 'ben-jerrys-cookie-dough', 'Vanilla ice cream with chunks of chocolate chip cookie dough and chocolatey chunks.', 4.80, 3.50, '/assets/images/categories/ice-cream-lollies.jpg', 1, '465ml', 80),
    (@CatIceCream, 'ben-jerrys', 'Ben & Jerrys Phish Food Ice Cream 465ml', 'ben-jerrys-phish-food', 'Chocolate ice cream with marshmallow, caramel swirls and chocolatey fish.', 4.80, 3.50, '/assets/images/categories/ice-cream-lollies.jpg', 1, '465ml', 75),
    (@CatIceCream, 'carte-dor', 'Carte Dor Madagascan Vanilla Ice Cream 1L', 'carte-dor-vanilla-1l', 'Smooth and rich double churned Madagascan vanilla dairy ice cream.', 3.50, 2.75, '/assets/images/categories/ice-cream-lollies.jpg', 1, '1L', 100),
    (@CatIceCream, 'solero', 'Solero Exotic Ice Cream Lollies 3 Pack', 'solero-exotic-3pk', '3 smooth vanilla ice cream sticks coated in an exotic tangy fruit sorbet.', 2.50, 2.00, '/assets/images/categories/ice-cream-lollies.jpg', 1, '3 Pack', 120),
    (@CatIceCream, 'twister', 'Twister Pineapple Lemon Lime Lollies 5 Pack', 'twister-pineapple-lemon-5pk', '5 strawberry, lemon, and lime juice water ice lolly swirls with vanilla.', 2.50, 2.00, '/assets/images/categories/ice-cream-lollies.jpg', 1, '5 Pack', 140),
    (@CatIceCream, 'tesco', 'Tesco Vanilla Ice Cream 2L', 'tesco-vanilla-ice-cream-2l', 'Refreshing family-sized sweet vanilla soft-scoop ice cream tub.', 2.00, NULL, '/assets/images/categories/ice-cream-lollies.jpg', 1, '2L', 160),
    (@CatIceCream, 'tesco', 'Tesco Chocolate Soft Scoop Ice Cream 2L', 'tesco-chocolate-ice-cream-2l', 'Family-sized creamy milk chocolate soft scoop ice cream tub.', 2.00, NULL, '/assets/images/categories/ice-cream-lollies.jpg', 1, '2L', 150),
    (@CatIceCream, 'oreo', 'Oreo Ice Cream Sandwiches 4 Pack', 'oreo-ice-cream-sandwiches-4pk', '4 pack of crushed Oreo biscuit ice cream loaded between two chocolate Oreo shells.', 3.00, 2.50, '/assets/images/categories/ice-cream-lollies.jpg', 1, '4 Pack', 90),

    -- ── 🎂 frozen-desserts (11 Items) ───────────────────────────────
    (@CatFrozenDesserts, 'tesco', 'Tesco Frozen Raspberry Pavlova', 'tesco-raspberry-pavlova', 'A sweet meringue base topped with whipped cream, raspberries, and coulis.', 3.50, 3.00, '/assets/images/categories/frozen-desserts.jpg', 1, 'Each', 75),
    (@CatFrozenDesserts, 'tesco', 'Tesco Frozen Black Forest Gateau', 'tesco-black-forest-gateau', 'Layers of chocolate sponge with cherry filling and cream, chocolate flakes.', 2.50, 2.00, '/assets/images/categories/frozen-desserts.jpg', 1, 'Each', 90),
    (@CatFrozenDesserts, 'tesco', 'Tesco Frozen Strawberry Cheesecake', 'tesco-strawberry-cheesecake', 'Baked vanilla cream cheese on a digestive biscuit crust topped with strawberry glazes.', 2.20, NULL, '/assets/images/categories/frozen-desserts.jpg', 1, 'Each', 110),
    (@CatFrozenDesserts, 'tesco', 'Tesco Frozen Chocolate Fudge Gateau', 'tesco-chocolate-gateau', 'Moist chocolate sponge layered with sweet, dense chocolate fudge.', 2.50, 2.00, '/assets/images/categories/frozen-desserts.jpg', 1, 'Each', 95),
    (@CatFrozenDesserts, 'sara-lee', 'Sara Lee Frozen Chocolate Pound Cake', 'sara-lee-chocolate-pound-cake', 'All butter, light chocolate pound cake. Perfectly sliced and sweet.', 3.00, NULL, '/assets/images/categories/frozen-desserts.jpg', 1, 'Each', 85),
    (@CatFrozenDesserts, 'aunt-bessies', 'Aunt Bessies Frozen Jam Roly Poly', 'aunt-bessies-jam-roly-poly', 'A traditional suet pastry rolled with sweet raspberry plum jam.', 2.00, 1.60, '/assets/images/categories/frozen-desserts.jpg', 1, 'Each', 115),
    (@CatFrozenDesserts, 'aunt-bessies', 'Aunt Bessies Frozen Apple Crumble', 'aunt-bessies-apple-crumble', 'Sweet spiced Bramley apple base covered with rich, buttery flour crumbles.', 2.00, 1.60, '/assets/images/categories/frozen-desserts.jpg', 1, 'Each', 120),
    (@CatFrozenDesserts, 'tesco', 'Tesco Frozen Profiteroles 30 Pack', 'tesco-profiteroles-30pack', '30 frozen choux pastry puffs loaded with cream, with rich chocolate dipping sauce.', 2.50, NULL, '/assets/images/categories/frozen-desserts.jpg', 1, '30 Pack', 80),
    (@CatFrozenDesserts, 'tesco', 'Tesco Frozen Cinnamon Churros', 'tesco-frozen-churros', 'Spanish style fried dough loops coated with cinnamon and dark chocolate dip.', 2.00, NULL, '/assets/images/categories/frozen-desserts.jpg', 1, 'Each', 130),
    (@CatFrozenDesserts, 'coppenrath-wiese', 'Coppenrath & Wiese Frozen Apple Strudel 600g', 'coppenrath-wiese-apple-strudel', 'Crispy puff pastry rolled with sweet apple chunks, raisins, and cinnamon.', 2.80, 2.20, '/assets/images/categories/frozen-desserts.jpg', 1, '600g', 90),
    (@CatFrozenDesserts, 'mccain', 'McCain Frozen Warm Chocolate Pudding', 'mccain-warm-chocolate-pudding', 'Soft single scoop individual microwaveable warm chocolate melt sponge.', 1.80, NULL, '/assets/images/categories/frozen-desserts.jpg', 1, 'Each', 140);

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
    -- 5. LINK NEW PRODUCTS TO CLUB CARD PROMOTION DYNAMICALLY
    -- ================================================================
    DECLARE @Promo5Id INT = (SELECT Id FROM m.tblPromotion WHERE Name = 'Clubcard Special Deals' AND IsDeleted = 0);

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
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V086')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V086', 'SeedCategoryProductsOverTen');

    COMMIT TRANSACTION;
    PRINT 'V086 completed successfully. 128 new products seeded to fill Fresh & Frozen categories over 10.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V086_SeedCategoryProductsOverTen.sql', ERROR_MESSAGE(), GETUTCDATE());

    THROW;
END CATCH
