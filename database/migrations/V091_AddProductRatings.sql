-- V091_AddProductRatings.sql
-- Author: Tesco Clone
-- Date: 2026-05-19
-- Description: Add product rating feature:
--   1. Create t.tblProductRating (one row per user per product, immutable after insert)
--   2. proc_Catalogue_GetUserRatingStatus – returns whether the authenticated user
--      can rate a product (has a delivered order) and whether they already have.
--   3. proc_Catalogue_SubmitProductRating – inserts a rating, then recalculates and
--      updates AverageRating + ReviewCount on m.tblProduct.
--   4. Recreate proc_Admin_GetProducts to include AverageRating and ReviewCount columns.
-- Dependencies: V007, V037, V089, V090

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- 1. Create t.tblProductRating
-- =========================================================
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblProductRating'
)
BEGIN
    CREATE TABLE t.tblProductRating (
        Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        ProductId      INT NOT NULL,
        UserId         INT NOT NULL,
        Rating         TINYINT NOT NULL,               -- 1–5
        RecordStatusId TINYINT NOT NULL DEFAULT 1,
        CreatedBy      INT NOT NULL,
        CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy     INT NULL,
        ModifiedOn     DATETIME2 NULL,
        IsDeleted      BIT NOT NULL DEFAULT 0,
        CONSTRAINT FK_tblProductRating_tblProduct FOREIGN KEY (ProductId) REFERENCES m.tblProduct (Id),
        CONSTRAINT FK_tblProductRating_tblUser    FOREIGN KEY (UserId)    REFERENCES t.tblUser (Id),
        CONSTRAINT CK_tblProductRating_Rating     CHECK (Rating BETWEEN 1 AND 5)
    );

    -- One active rating per user per product
    CREATE UNIQUE INDEX IX_tblProductRating_ProductUser
        ON t.tblProductRating (ProductId, UserId)
        WHERE IsDeleted = 0;

    CREATE INDEX IX_tblProductRating_ProductId ON t.tblProductRating (ProductId);
    CREATE INDEX IX_tblProductRating_UserId    ON t.tblProductRating (UserId);

    PRINT 'Table [t].[tblProductRating] created.';
END
GO

-- =========================================================
-- 2. proc_Catalogue_GetUserRatingStatus
--    Returns one row: CanRate BIT, HasRated BIT, ExistingRating TINYINT NULL
-- =========================================================
IF OBJECT_ID('proc_Catalogue_GetUserRatingStatus', 'P') IS NOT NULL
    DROP PROCEDURE proc_Catalogue_GetUserRatingStatus;
GO

CREATE PROCEDURE proc_Catalogue_GetUserRatingStatus
    @ProductId INT,
    @UserId    INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        -- Check whether the user has a delivered order that contains this product
        DECLARE @HasPurchased BIT = 0;
        IF EXISTS (
            SELECT 1
            FROM   t.tblOrder     o
            INNER  JOIN t.tblOrderLine     ol  ON ol.OrderId          = o.Id
            INNER  JOIN m.tblProductVariant pv  ON pv.Id               = ol.ProductVariantId
            WHERE  o.UserId    = @UserId
              AND  o.StatusId  = 5           -- Delivered
              AND  o.IsDeleted = 0
              AND  pv.ProductId = @ProductId
              AND  pv.IsDeleted = 0
        )
            SET @HasPurchased = 1;

        -- Check whether the user has already submitted a rating
        DECLARE @ExistingRating TINYINT = NULL;
        SELECT @ExistingRating = Rating
        FROM   t.tblProductRating
        WHERE  ProductId  = @ProductId
          AND  UserId     = @UserId
          AND  IsDeleted  = 0;

        SELECT
            @HasPurchased                        AS CanRate,
            CAST(CASE WHEN @ExistingRating IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HasRated,
            @ExistingRating                      AS ExistingRating;

    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetUserRatingStatus', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- 3. proc_Catalogue_SubmitProductRating
--    Business rules enforced inside the SP:
--      a) User must have a Delivered order containing the product.
--      b) User must not have rated this product already.
--    On success: inserts rating row, recalculates aggregate columns
--    on m.tblProduct (AverageRating, ReviewCount), writes audit log.
-- =========================================================
IF OBJECT_ID('proc_Catalogue_SubmitProductRating', 'P') IS NOT NULL
    DROP PROCEDURE proc_Catalogue_SubmitProductRating;
GO

CREATE PROCEDURE proc_Catalogue_SubmitProductRating
    @ProductId INT,
    @UserId    INT,
    @Rating    TINYINT        -- 1–5
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

            -- Guard: product must exist and be active
            IF NOT EXISTS (
                SELECT 1 FROM m.tblProduct
                WHERE Id = @ProductId AND IsDeleted = 0
            )
            BEGIN
                ROLLBACK TRANSACTION;
                RAISERROR('Product not found.', 16, 1);
                RETURN;
            END

            -- Guard: user must have a delivered order containing this product
            IF NOT EXISTS (
                SELECT 1
                FROM   t.tblOrder           o
                INNER  JOIN t.tblOrderLine      ol  ON ol.OrderId          = o.Id
                INNER  JOIN m.tblProductVariant  pv  ON pv.Id               = ol.ProductVariantId
                WHERE  o.UserId    = @UserId
                  AND  o.StatusId  = 5       -- Delivered
                  AND  o.IsDeleted = 0
                  AND  pv.ProductId = @ProductId
                  AND  pv.IsDeleted = 0
            )
            BEGIN
                ROLLBACK TRANSACTION;
                RAISERROR('User has not purchased this product.', 16, 1);
                RETURN;
            END

            -- Guard: user must not have already rated this product
            IF EXISTS (
                SELECT 1 FROM t.tblProductRating
                WHERE ProductId = @ProductId AND UserId = @UserId AND IsDeleted = 0
            )
            BEGIN
                ROLLBACK TRANSACTION;
                RAISERROR('User has already rated this product.', 16, 1);
                RETURN;
            END

            -- Insert the rating
            INSERT INTO t.tblProductRating
                (ProductId, UserId, Rating, RecordStatusId, CreatedBy, CreatedOn)
            VALUES
                (@ProductId, @UserId, @Rating, 1, @UserId, GETUTCDATE());

            -- Recalculate aggregate rating on the product
            UPDATE m.tblProduct
            SET AverageRating = (
                    SELECT AVG(CAST(r.Rating AS DECIMAL(10, 4)))
                    FROM   t.tblProductRating r
                    WHERE  r.ProductId = @ProductId AND r.IsDeleted = 0
                ),
                ReviewCount = (
                    SELECT COUNT(1)
                    FROM   t.tblProductRating r
                    WHERE  r.ProductId = @ProductId AND r.IsDeleted = 0
                ),
                ModifiedBy = @UserId,
                ModifiedOn = GETUTCDATE()
            WHERE Id = @ProductId;

            -- Audit log
            INSERT INTO t.tblAuditLog (TableName, RecordId, Action, ChangedBy, ChangedOn)
            VALUES ('tblProductRating', @ProductId, 'RATE', @UserId, GETUTCDATE());

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_SubmitProductRating', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- 4. Recreate proc_Admin_GetProducts to include AverageRating
--    and ReviewCount columns (adds to V089 version)
-- =========================================================
IF OBJECT_ID('proc_Admin_GetProducts', 'P') IS NOT NULL
    DROP PROCEDURE proc_Admin_GetProducts;
GO

CREATE PROCEDURE proc_Admin_GetProducts
    @Search        NVARCHAR(256) = NULL,
    @CategoryId    INT           = NULL,
    @DepartmentId  INT           = NULL,
    @PageNumber    INT           = 1,
    @PageSize      INT           = 20,
    @SortBy        NVARCHAR(50)  = 'createdOn',
    @SortDirection NVARCHAR(4)   = 'desc'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            p.Id,
            p.CategoryId,
            c.Name                                                                       AS CategoryName,
            p.BrandId,
            b.Name                                                                       AS BrandName,
            p.Name,
            p.Slug,
            p.Description,
            p.BasePrice,
            p.ClubcardPrice,
            p.ImageUrl,
            p.IsAvailable,
            ISNULL(pv.TotalStock, 0)                                                    AS StockQuantity,
            p.CreatedOn,
            p.ModifiedOn,
            ISNULL(oc.PlacedAndConfirmedCount, 0)                                       AS PlacedAndConfirmedCount,
            ISNULL(oc.PendingOrderCount, 0)                                             AS PendingOrderCount,
            CASE
                WHEN ISNULL(pv.TotalStock, 0) - ISNULL(oc.CommittedQuantity, 0) < 0
                THEN 0
                ELSE ISNULL(pv.TotalStock, 0) - ISNULL(oc.CommittedQuantity, 0)
            END                                                                          AS RemainingStock,
            p.AverageRating,
            p.ReviewCount,
            COUNT(1) OVER ()                                                             AS TotalCount
        FROM m.tblProduct p
        INNER JOIN m.tblCategory   c  ON c.Id  = p.CategoryId   AND c.IsDeleted = 0
        INNER JOIN m.tblDepartment d  ON d.Id  = c.DepartmentId AND d.IsDeleted = 0
        LEFT  JOIN m.tblBrand      b  ON b.Id  = p.BrandId      AND b.IsDeleted = 0
        LEFT  JOIN (
            SELECT ProductId, SUM(StockQuantity) AS TotalStock
            FROM   m.tblProductVariant
            WHERE  IsDeleted = 0
            GROUP  BY ProductId
        ) pv ON pv.ProductId = p.Id
        LEFT  JOIN (
            SELECT
                pv2.ProductId,
                COUNT(DISTINCT CASE WHEN o.StatusId IN (1, 2) THEN o.Id END)   AS PlacedAndConfirmedCount,
                COUNT(DISTINCT CASE WHEN o.StatusId = 1        THEN o.Id END)   AS PendingOrderCount,
                SUM(CASE WHEN o.StatusId IN (1, 2) THEN ol.Quantity ELSE 0 END) AS CommittedQuantity
            FROM   m.tblProductVariant pv2
            INNER  JOIN t.tblOrderLine ol ON ol.ProductVariantId = pv2.Id
            INNER  JOIN t.tblOrder     o  ON o.Id = ol.OrderId   AND o.IsDeleted = 0
            WHERE  pv2.IsDeleted = 0
            GROUP  BY pv2.ProductId
        ) oc ON oc.ProductId = p.Id
        WHERE p.IsDeleted = 0
          AND (@Search       IS NULL OR p.Name LIKE '%' + @Search + '%' OR p.Slug LIKE '%' + @Search + '%')
          AND (@CategoryId   IS NULL OR p.CategoryId   = @CategoryId)
          AND (@DepartmentId IS NULL OR c.DepartmentId = @DepartmentId)
        ORDER BY
            CASE WHEN @SortBy = 'name'          AND @SortDirection = 'asc'  THEN p.Name          END ASC,
            CASE WHEN @SortBy = 'name'          AND @SortDirection = 'desc' THEN p.Name          END DESC,
            CASE WHEN @SortBy = 'basePrice'     AND @SortDirection = 'asc'  THEN p.BasePrice     END ASC,
            CASE WHEN @SortBy = 'basePrice'     AND @SortDirection = 'desc' THEN p.BasePrice     END DESC,
            CASE WHEN @SortBy = 'stockQuantity' AND @SortDirection = 'asc'  THEN pv.TotalStock   END ASC,
            CASE WHEN @SortBy = 'stockQuantity' AND @SortDirection = 'desc' THEN pv.TotalStock   END DESC,
            CASE WHEN @SortBy = 'isAvailable'   AND @SortDirection = 'asc'  THEN CAST(p.IsAvailable AS TINYINT) END ASC,
            CASE WHEN @SortBy = 'isAvailable'   AND @SortDirection = 'desc' THEN CAST(p.IsAvailable AS TINYINT) END DESC,
            CASE WHEN @SortBy = 'averageRating' AND @SortDirection = 'asc'  THEN p.AverageRating END ASC,
            CASE WHEN @SortBy = 'averageRating' AND @SortDirection = 'desc' THEN p.AverageRating END DESC,
            CASE WHEN @SortDirection = 'asc'  THEN p.CreatedOn END ASC,
            CASE WHEN @SortDirection = 'desc' THEN p.CreatedOn END DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetProducts', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V091')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V091', 'AddProductRatings');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
