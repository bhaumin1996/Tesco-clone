-- V092_RelaxRatingPurchaseCheck.sql
-- Author: Tesco Clone
-- Date: 2026-05-19
-- Description: Relax the purchase check in the rating stored procedures from
--              "Delivered only" (StatusId = 5) to "any non-cancelled, non-refunded
--              order" (StatusId NOT IN (6, 7)).  Users can now rate a product as
--              soon as their order is placed and confirmed, not only after delivery.
-- Dependencies: V091

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- 1. Recreate proc_Catalogue_GetUserRatingStatus
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

        -- User can rate if they have any non-cancelled, non-refunded order
        -- containing this product (StatusId NOT IN (6 = Cancelled, 7 = Refunded))
        DECLARE @HasPurchased BIT = 0;
        IF EXISTS (
            SELECT 1
            FROM   t.tblOrder           o
            INNER  JOIN t.tblOrderLine      ol ON ol.OrderId          = o.Id
            INNER  JOIN m.tblProductVariant  pv ON pv.Id               = ol.ProductVariantId
            WHERE  o.UserId     = @UserId
              AND  o.StatusId   NOT IN (6, 7)
              AND  o.IsDeleted  = 0
              AND  pv.ProductId = @ProductId
              AND  pv.IsDeleted = 0
        )
            SET @HasPurchased = 1;

        DECLARE @ExistingRating TINYINT = NULL;
        SELECT @ExistingRating = Rating
        FROM   t.tblProductRating
        WHERE  ProductId = @ProductId
          AND  UserId    = @UserId
          AND  IsDeleted = 0;

        SELECT
            @HasPurchased AS CanRate,
            CAST(CASE WHEN @ExistingRating IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS HasRated,
            @ExistingRating AS ExistingRating;

    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetUserRatingStatus', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- 2. Recreate proc_Catalogue_SubmitProductRating
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

            IF NOT EXISTS (
                SELECT 1 FROM m.tblProduct
                WHERE Id = @ProductId AND IsDeleted = 0
            )
            BEGIN
                ROLLBACK TRANSACTION;
                RAISERROR('Product not found.', 16, 1);
                RETURN;
            END

            -- Guard: user must have a non-cancelled, non-refunded order containing this product
            IF NOT EXISTS (
                SELECT 1
                FROM   t.tblOrder           o
                INNER  JOIN t.tblOrderLine      ol ON ol.OrderId          = o.Id
                INNER  JOIN m.tblProductVariant  pv ON pv.Id               = ol.ProductVariantId
                WHERE  o.UserId     = @UserId
                  AND  o.StatusId   NOT IN (6, 7)
                  AND  o.IsDeleted  = 0
                  AND  pv.ProductId = @ProductId
                  AND  pv.IsDeleted = 0
            )
            BEGIN
                ROLLBACK TRANSACTION;
                RAISERROR('User has not purchased this product.', 16, 1);
                RETURN;
            END

            IF EXISTS (
                SELECT 1 FROM t.tblProductRating
                WHERE ProductId = @ProductId AND UserId = @UserId AND IsDeleted = 0
            )
            BEGIN
                ROLLBACK TRANSACTION;
                RAISERROR('User has already rated this product.', 16, 1);
                RETURN;
            END

            INSERT INTO t.tblProductRating
                (ProductId, UserId, Rating, RecordStatusId, CreatedBy, CreatedOn)
            VALUES
                (@ProductId, @UserId, @Rating, 1, @UserId, GETUTCDATE());

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
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V092')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V092', 'RelaxRatingPurchaseCheck');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
