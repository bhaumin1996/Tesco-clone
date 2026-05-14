-- seed_catalogue_departments_categories.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Seed m.tblDepartment and m.tblCategory with data matching Tesco.com's
--              shop navigation structure: 16 departments, ~113 top-level categories.
--              ImageUrl follows the pattern /assets/images/departments/{slug}.jpg
--              and /assets/images/categories/{slug}.jpg — swap in real CDN paths as needed.
-- Dependencies: V006 (CreateCatalogueTables), seed_admin_user.sql (CreatedBy = 1)

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
SET NOCOUNT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- ================================================================
    -- DEPARTMENTS
    -- ================================================================

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'fresh-food' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Fresh Food', N'fresh-food', N'/assets/images/departments/fresh-food.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'bakery' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Bakery', N'bakery', N'/assets/images/departments/bakery.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'frozen-food' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Frozen Food', N'frozen-food', N'/assets/images/departments/frozen-food.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'food-cupboard' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Food Cupboard', N'food-cupboard', N'/assets/images/departments/food-cupboard.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'drinks' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Drinks', N'drinks', N'/assets/images/departments/drinks.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'beer-wine-spirits' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Beer, Wine & Spirits', N'beer-wine-spirits', N'/assets/images/departments/beer-wine-spirits.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'baby-toddler' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Baby & Toddler', N'baby-toddler', N'/assets/images/departments/baby-toddler.jpg', 70, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'health-beauty' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Health & Beauty', N'health-beauty', N'/assets/images/departments/health-beauty.jpg', 80, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'household' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Household', N'household', N'/assets/images/departments/household.jpg', 90, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'pets' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Pets', N'pets', N'/assets/images/departments/pets.jpg', 100, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'home-garden' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Home & Garden', N'home-garden', N'/assets/images/departments/home-garden.jpg', 110, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'clothing' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Clothing', N'clothing', N'/assets/images/departments/clothing.jpg', 120, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'toys' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Toys', N'toys', N'/assets/images/departments/toys.jpg', 130, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'entertainment' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Entertainment', N'entertainment', N'/assets/images/departments/entertainment.jpg', 140, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'sports-leisure' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Sports & Leisure', N'sports-leisure', N'/assets/images/departments/sports-leisure.jpg', 150, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblDepartment WHERE Slug = 'technology' AND IsDeleted = 0)
        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (N'Technology', N'technology', N'/assets/images/departments/technology.jpg', 160, 1);

    PRINT '16 departments seeded.';

    -- ================================================================
    -- RESOLVE DEPARTMENT IDs
    -- ================================================================
    DECLARE @FreshFood      INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'fresh-food'       AND IsDeleted = 0);
    DECLARE @Bakery         INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'bakery'            AND IsDeleted = 0);
    DECLARE @FrozenFood     INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'frozen-food'       AND IsDeleted = 0);
    DECLARE @FoodCupboard   INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'food-cupboard'     AND IsDeleted = 0);
    DECLARE @Drinks         INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'drinks'            AND IsDeleted = 0);
    DECLARE @BeerWine       INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'beer-wine-spirits' AND IsDeleted = 0);
    DECLARE @Baby           INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'baby-toddler'      AND IsDeleted = 0);
    DECLARE @HealthBeauty   INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'health-beauty'     AND IsDeleted = 0);
    DECLARE @Household      INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'household'         AND IsDeleted = 0);
    DECLARE @Pets           INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'pets'              AND IsDeleted = 0);
    DECLARE @HomeGarden     INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'home-garden'       AND IsDeleted = 0);
    DECLARE @Clothing       INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'clothing'          AND IsDeleted = 0);
    DECLARE @Toys           INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'toys'              AND IsDeleted = 0);
    DECLARE @Entertainment  INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'entertainment'     AND IsDeleted = 0);
    DECLARE @Sports         INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'sports-leisure'    AND IsDeleted = 0);
    DECLARE @Technology     INT = (SELECT Id FROM m.tblDepartment WHERE Slug = 'technology'        AND IsDeleted = 0);

    -- ================================================================
    -- FRESH FOOD
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'fruit-vegetables' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FreshFood, NULL, N'Fruit & Vegetables', N'fruit-vegetables', N'/assets/images/categories/fruit-vegetables.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'meat-fish' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FreshFood, NULL, N'Meat & Fish', N'meat-fish', N'/assets/images/categories/meat-fish.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'dairy-eggs-chilled' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FreshFood, NULL, N'Dairy, Eggs & Chilled', N'dairy-eggs-chilled', N'/assets/images/categories/dairy-eggs-chilled.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'salad-herbs' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FreshFood, NULL, N'Salad & Herbs', N'salad-herbs', N'/assets/images/categories/salad-herbs.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'deli' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FreshFood, NULL, N'Deli', N'deli', N'/assets/images/categories/deli.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'chilled-snacks-juice' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FreshFood, NULL, N'Chilled Snacks & Juice', N'chilled-snacks-juice', N'/assets/images/categories/chilled-snacks-juice.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'ready-meals' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FreshFood, NULL, N'Ready Meals', N'ready-meals', N'/assets/images/categories/ready-meals.jpg', 70, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'desserts-puddings' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FreshFood, NULL, N'Desserts & Puddings', N'desserts-puddings', N'/assets/images/categories/desserts-puddings.jpg', 80, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'party-food-entertaining' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FreshFood, NULL, N'Party Food & Entertaining', N'party-food-entertaining', N'/assets/images/categories/party-food-entertaining.jpg', 90, 1);

    -- ================================================================
    -- BAKERY
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'bread' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Bakery, NULL, N'Bread', N'bread', N'/assets/images/categories/bread.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'morning-goods-pastries' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Bakery, NULL, N'Morning Goods & Pastries', N'morning-goods-pastries', N'/assets/images/categories/morning-goods-pastries.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'rolls-baps-wraps' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Bakery, NULL, N'Rolls, Baps & Wraps', N'rolls-baps-wraps', N'/assets/images/categories/rolls-baps-wraps.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'cakes-biscuits' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Bakery, NULL, N'Cakes & Biscuits', N'cakes-biscuits', N'/assets/images/categories/cakes-biscuits.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'crumpets-muffins-pancakes' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Bakery, NULL, N'Crumpets, Muffins & Pancakes', N'crumpets-muffins-pancakes', N'/assets/images/categories/crumpets-muffins-pancakes.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'instore-bakery' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Bakery, NULL, N'In-Store Bakery', N'instore-bakery', N'/assets/images/categories/instore-bakery.jpg', 60, 1);

    -- ================================================================
    -- FROZEN FOOD
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'frozen-meat-fish' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FrozenFood, NULL, N'Frozen Meat & Fish', N'frozen-meat-fish', N'/assets/images/categories/frozen-meat-fish.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'frozen-ready-meals' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FrozenFood, NULL, N'Frozen Ready Meals', N'frozen-ready-meals', N'/assets/images/categories/frozen-ready-meals.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'frozen-pizza' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FrozenFood, NULL, N'Frozen Pizza', N'frozen-pizza', N'/assets/images/categories/frozen-pizza.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'frozen-chips-sides' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FrozenFood, NULL, N'Frozen Chips & Sides', N'frozen-chips-sides', N'/assets/images/categories/frozen-chips-sides.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'frozen-vegetables' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FrozenFood, NULL, N'Frozen Vegetables', N'frozen-vegetables', N'/assets/images/categories/frozen-vegetables.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'ice-cream-lollies' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FrozenFood, NULL, N'Ice Cream & Lollies', N'ice-cream-lollies', N'/assets/images/categories/ice-cream-lollies.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'frozen-desserts' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FrozenFood, NULL, N'Frozen Desserts', N'frozen-desserts', N'/assets/images/categories/frozen-desserts.jpg', 70, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'frozen-pastry-dough-bread' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FrozenFood, NULL, N'Frozen Pastry, Dough & Bread', N'frozen-pastry-dough-bread', N'/assets/images/categories/frozen-pastry-dough-bread.jpg', 80, 1);

    -- ================================================================
    -- FOOD CUPBOARD
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'pasta-rice-grains' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FoodCupboard, NULL, N'Pasta, Rice & Grains', N'pasta-rice-grains', N'/assets/images/categories/pasta-rice-grains.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'tins-cans' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FoodCupboard, NULL, N'Tins & Cans', N'tins-cans', N'/assets/images/categories/tins-cans.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'condiments-sauces' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FoodCupboard, NULL, N'Condiments & Sauces', N'condiments-sauces', N'/assets/images/categories/condiments-sauces.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'baking' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FoodCupboard, NULL, N'Baking', N'baking', N'/assets/images/categories/baking.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'snacks-confectionery' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FoodCupboard, NULL, N'Snacks & Confectionery', N'snacks-confectionery', N'/assets/images/categories/snacks-confectionery.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'tea-coffee-hot-drinks' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FoodCupboard, NULL, N'Tea, Coffee & Hot Drinks', N'tea-coffee-hot-drinks', N'/assets/images/categories/tea-coffee-hot-drinks.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'cereals-porridge' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FoodCupboard, NULL, N'Cereals & Porridge', N'cereals-porridge', N'/assets/images/categories/cereals-porridge.jpg', 70, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'world-foods' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FoodCupboard, NULL, N'World Foods', N'world-foods', N'/assets/images/categories/world-foods.jpg', 80, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'oils-vinegars-dressings' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FoodCupboard, NULL, N'Oils, Vinegars & Dressings', N'oils-vinegars-dressings', N'/assets/images/categories/oils-vinegars-dressings.jpg', 90, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'soups-stocks-gravy' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@FoodCupboard, NULL, N'Soups, Stocks & Gravy', N'soups-stocks-gravy', N'/assets/images/categories/soups-stocks-gravy.jpg', 100, 1);

    -- ================================================================
    -- DRINKS
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'soft-drinks' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Drinks, NULL, N'Soft Drinks', N'soft-drinks', N'/assets/images/categories/soft-drinks.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'fruit-juice-squash' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Drinks, NULL, N'Fruit Juice & Squash', N'fruit-juice-squash', N'/assets/images/categories/fruit-juice-squash.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'water' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Drinks, NULL, N'Water', N'water', N'/assets/images/categories/water.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'sports-energy-drinks' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Drinks, NULL, N'Sports & Energy Drinks', N'sports-energy-drinks', N'/assets/images/categories/sports-energy-drinks.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'flavoured-milk-plant' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Drinks, NULL, N'Flavoured Milk & Plant Drinks', N'flavoured-milk-plant', N'/assets/images/categories/flavoured-milk-plant.jpg', 50, 1);

    -- ================================================================
    -- BEER, WINE & SPIRITS
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'beer-cider' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@BeerWine, NULL, N'Beer & Cider', N'beer-cider', N'/assets/images/categories/beer-cider.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'wine' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@BeerWine, NULL, N'Wine', N'wine', N'/assets/images/categories/wine.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'champagne-sparkling-wine' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@BeerWine, NULL, N'Champagne & Sparkling Wine', N'champagne-sparkling-wine', N'/assets/images/categories/champagne-sparkling-wine.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'spirits' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@BeerWine, NULL, N'Spirits', N'spirits', N'/assets/images/categories/spirits.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'premixed-cocktails' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@BeerWine, NULL, N'Premixed Drinks & Cocktails', N'premixed-cocktails', N'/assets/images/categories/premixed-cocktails.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'low-no-alcohol' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@BeerWine, NULL, N'Low & No Alcohol', N'low-no-alcohol', N'/assets/images/categories/low-no-alcohol.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'port-sherry-liqueurs' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@BeerWine, NULL, N'Port, Sherry & Liqueurs', N'port-sherry-liqueurs', N'/assets/images/categories/port-sherry-liqueurs.jpg', 70, 1);

    -- ================================================================
    -- BABY & TODDLER
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'baby-food-milk' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Baby, NULL, N'Baby Food & Milk', N'baby-food-milk', N'/assets/images/categories/baby-food-milk.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'nappies-wipes' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Baby, NULL, N'Nappies & Wipes', N'nappies-wipes', N'/assets/images/categories/nappies-wipes.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'baby-health-toiletries' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Baby, NULL, N'Baby Health & Toiletries', N'baby-health-toiletries', N'/assets/images/categories/baby-health-toiletries.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'baby-clothing' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Baby, NULL, N'Baby Clothing', N'baby-clothing', N'/assets/images/categories/baby-clothing.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'baby-toys-play' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Baby, NULL, N'Toys & Play', N'baby-toys-play', N'/assets/images/categories/baby-toys-play.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'nursery-travel' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Baby, NULL, N'Nursery & Travel', N'nursery-travel', N'/assets/images/categories/nursery-travel.jpg', 60, 1);

    -- ================================================================
    -- HEALTH & BEAUTY
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'vitamins-supplements' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Vitamins & Supplements', N'vitamins-supplements', N'/assets/images/categories/vitamins-supplements.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'medicine-treatments' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Medicine & Treatments', N'medicine-treatments', N'/assets/images/categories/medicine-treatments.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'dental' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Dental', N'dental', N'/assets/images/categories/dental.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'feminine-care' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Feminine Care', N'feminine-care', N'/assets/images/categories/feminine-care.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'hair-care' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Hair Care', N'hair-care', N'/assets/images/categories/hair-care.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'skin-care' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Skin Care', N'skin-care', N'/assets/images/categories/skin-care.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'bath-shower' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Bath & Shower', N'bath-shower', N'/assets/images/categories/bath-shower.jpg', 70, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'mens-grooming' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Men''s Grooming', N'mens-grooming', N'/assets/images/categories/mens-grooming.jpg', 80, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'fragrance' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Fragrance', N'fragrance', N'/assets/images/categories/fragrance.jpg', 90, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'cosmetics-makeup' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Cosmetics & Makeup', N'cosmetics-makeup', N'/assets/images/categories/cosmetics-makeup.jpg', 100, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'sexual-health' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HealthBeauty, NULL, N'Sexual Health', N'sexual-health', N'/assets/images/categories/sexual-health.jpg', 110, 1);

    -- ================================================================
    -- HOUSEHOLD
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'cleaning' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Household, NULL, N'Cleaning', N'cleaning', N'/assets/images/categories/cleaning.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'laundry' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Household, NULL, N'Laundry', N'laundry', N'/assets/images/categories/laundry.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'kitchen-accessories' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Household, NULL, N'Kitchen Accessories', N'kitchen-accessories', N'/assets/images/categories/kitchen-accessories.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'paper-foil-bags' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Household, NULL, N'Paper, Foil & Bags', N'paper-foil-bags', N'/assets/images/categories/paper-foil-bags.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'bathroom-toilet' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Household, NULL, N'Bathroom & Toilet', N'bathroom-toilet', N'/assets/images/categories/bathroom-toilet.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'air-fresheners' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Household, NULL, N'Air Fresheners', N'air-fresheners', N'/assets/images/categories/air-fresheners.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'batteries-light-bulbs' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Household, NULL, N'Batteries & Light Bulbs', N'batteries-light-bulbs', N'/assets/images/categories/batteries-light-bulbs.jpg', 70, 1);

    -- ================================================================
    -- PETS
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'dog-food-accessories' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Pets, NULL, N'Dog Food & Accessories', N'dog-food-accessories', N'/assets/images/categories/dog-food-accessories.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'cat-food-accessories' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Pets, NULL, N'Cat Food & Accessories', N'cat-food-accessories', N'/assets/images/categories/cat-food-accessories.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'small-animals-birds' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Pets, NULL, N'Small Animals & Birds', N'small-animals-birds', N'/assets/images/categories/small-animals-birds.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'fish-aquatics' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Pets, NULL, N'Fish & Aquatics', N'fish-aquatics', N'/assets/images/categories/fish-aquatics.jpg', 40, 1);

    -- ================================================================
    -- HOME & GARDEN
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'bedding-towels' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HomeGarden, NULL, N'Bedding & Towels', N'bedding-towels', N'/assets/images/categories/bedding-towels.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'cookware-bakeware' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HomeGarden, NULL, N'Cookware & Bakeware', N'cookware-bakeware', N'/assets/images/categories/cookware-bakeware.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'dining-tableware' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HomeGarden, NULL, N'Dining & Tableware', N'dining-tableware', N'/assets/images/categories/dining-tableware.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'candles-home-fragrance' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HomeGarden, NULL, N'Candles & Home Fragrance', N'candles-home-fragrance', N'/assets/images/categories/candles-home-fragrance.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'storage-organisation' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HomeGarden, NULL, N'Storage & Organisation', N'storage-organisation', N'/assets/images/categories/storage-organisation.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'garden-outdoor' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HomeGarden, NULL, N'Garden & Outdoor', N'garden-outdoor', N'/assets/images/categories/garden-outdoor.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'diy-tools' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HomeGarden, NULL, N'DIY & Tools', N'diy-tools', N'/assets/images/categories/diy-tools.jpg', 70, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'furniture' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@HomeGarden, NULL, N'Furniture', N'furniture', N'/assets/images/categories/furniture.jpg', 80, 1);

    -- ================================================================
    -- CLOTHING  (F&F brand)
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'womens-clothing' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Clothing, NULL, N'Women''s Clothing', N'womens-clothing', N'/assets/images/categories/womens-clothing.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'mens-clothing' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Clothing, NULL, N'Men''s Clothing', N'mens-clothing', N'/assets/images/categories/mens-clothing.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'boys-clothing' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Clothing, NULL, N'Boys'' Clothing', N'boys-clothing', N'/assets/images/categories/boys-clothing.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'girls-clothing' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Clothing, NULL, N'Girls'' Clothing', N'girls-clothing', N'/assets/images/categories/girls-clothing.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'school-uniform' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Clothing, NULL, N'School Uniform', N'school-uniform', N'/assets/images/categories/school-uniform.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'footwear' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Clothing, NULL, N'Footwear', N'footwear', N'/assets/images/categories/footwear.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'accessories' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Clothing, NULL, N'Accessories', N'accessories', N'/assets/images/categories/accessories.jpg', 70, 1);

    -- ================================================================
    -- TOYS
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'building-toys' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Toys, NULL, N'Building Toys', N'building-toys', N'/assets/images/categories/building-toys.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'dolls-accessories' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Toys, NULL, N'Dolls & Accessories', N'dolls-accessories', N'/assets/images/categories/dolls-accessories.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'soft-toys' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Toys, NULL, N'Soft Toys', N'soft-toys', N'/assets/images/categories/soft-toys.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'outdoor-toys' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Toys, NULL, N'Outdoor Toys', N'outdoor-toys', N'/assets/images/categories/outdoor-toys.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'games-puzzles' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Toys, NULL, N'Games & Puzzles', N'games-puzzles', N'/assets/images/categories/games-puzzles.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'vehicles-remote-control' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Toys, NULL, N'Vehicles & Remote Control', N'vehicles-remote-control', N'/assets/images/categories/vehicles-remote-control.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'arts-crafts' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Toys, NULL, N'Arts & Crafts', N'arts-crafts', N'/assets/images/categories/arts-crafts.jpg', 70, 1);

    -- ================================================================
    -- ENTERTAINMENT
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'books' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Entertainment, NULL, N'Books', N'books', N'/assets/images/categories/books.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'music' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Entertainment, NULL, N'Music', N'music', N'/assets/images/categories/music.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'films-tv' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Entertainment, NULL, N'Films & TV', N'films-tv', N'/assets/images/categories/films-tv.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'video-games' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Entertainment, NULL, N'Video Games', N'video-games', N'/assets/images/categories/video-games.jpg', 40, 1);

    -- ================================================================
    -- SPORTS & LEISURE
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'fitness-equipment' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Sports, NULL, N'Fitness Equipment', N'fitness-equipment', N'/assets/images/categories/fitness-equipment.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'cycling' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Sports, NULL, N'Cycling', N'cycling', N'/assets/images/categories/cycling.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'outdoor-camping' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Sports, NULL, N'Outdoor & Camping', N'outdoor-camping', N'/assets/images/categories/outdoor-camping.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'sports-clothing' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Sports, NULL, N'Sports Clothing', N'sports-clothing', N'/assets/images/categories/sports-clothing.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'swimming-water-sports' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Sports, NULL, N'Swimming & Water Sports', N'swimming-water-sports', N'/assets/images/categories/swimming-water-sports.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'ball-sports' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Sports, NULL, N'Ball Sports', N'ball-sports', N'/assets/images/categories/ball-sports.jpg', 60, 1);

    -- ================================================================
    -- TECHNOLOGY
    -- ================================================================
    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'laptops-tablets' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Technology, NULL, N'Laptops & Tablets', N'laptops-tablets', N'/assets/images/categories/laptops-tablets.jpg', 10, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'mobile-phones-accessories' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Technology, NULL, N'Mobile Phones & Accessories', N'mobile-phones-accessories', N'/assets/images/categories/mobile-phones-accessories.jpg', 20, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'tv-audio' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Technology, NULL, N'TV & Audio', N'tv-audio', N'/assets/images/categories/tv-audio.jpg', 30, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'smart-home' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Technology, NULL, N'Smart Home', N'smart-home', N'/assets/images/categories/smart-home.jpg', 40, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'computing' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Technology, NULL, N'Computing', N'computing', N'/assets/images/categories/computing.jpg', 50, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'cameras-photography' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Technology, NULL, N'Cameras & Photography', N'cameras-photography', N'/assets/images/categories/cameras-photography.jpg', 60, 1);

    IF NOT EXISTS (SELECT 1 FROM m.tblCategory WHERE Slug = 'wearable-tech' AND IsDeleted = 0)
        INSERT INTO m.tblCategory (DepartmentId, ParentCategoryId, Name, Slug, ImageUrl, DisplayOrder, CreatedBy)
        VALUES (@Technology, NULL, N'Wearable Tech', N'wearable-tech', N'/assets/images/categories/wearable-tech.jpg', 70, 1);

    PRINT 'Categories seeded.';

    -- ================================================================
    -- AUDIT LOG
    -- ================================================================
    INSERT INTO t.tblAuditLog (TableName, RecordId, Action, OldValues, NewValues, ChangedBy)
    VALUES (
        'm.tblDepartment / m.tblCategory',
        0,
        'INSERT',
        NULL,
        N'{"operation":"seed_catalogue_departments_categories","departments":16,"categories":"~113"}',
        1
    );

    COMMIT TRANSACTION;
    PRINT 'seed_catalogue_departments_categories.sql completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'seed_catalogue_departments_categories.sql', ERROR_MESSAGE(), GETUTCDATE());

    THROW;
END CATCH
