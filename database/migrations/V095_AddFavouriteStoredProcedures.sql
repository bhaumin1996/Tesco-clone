-- V095_AddFavouriteStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-19
-- Description: Recreate Favourites stored procedures with correct column names.
--   V094 created t.tblFavourite successfully but the SPs failed because
--   the wrong column names were used for t.tblLog, t.tblAuditLog, and
--   the computed m.tblProduct columns (IsInStock, UnitPrice, PromotionLabel).
--   Correct column names:
--     t.tblLog:      Level, Source, Message, LoggedOn
--     t.tblAuditLog: TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn
--     IsInStock, UnitPrice, PromotionLabel — computed via subqueries (not direct columns)
-- Dependencies: V094

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- 1. proc_Catalogue_AddFavourite
--    Upserts: reactivates a soft-deleted row or inserts new.
--    Returns the FavouriteId.
-- =========================================================
IF OBJECT_ID('proc_Catalogue_AddFavourite', 'P') IS NOT NULL
    DROP PROCEDURE proc_Catalogue_AddFavourite;
GO

CREATE PROCEDURE proc_Catalogue_AddFavourite
    @UserId    INT,
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

            DECLARE @ExistingId INT;

            -- Check for a soft-deleted row to reactivate
            SELECT @ExistingId = Id
            FROM   t.tblFavourite
            WHERE  UserId = @UserId AND ProductId = @ProductId AND IsDeleted = 1;

            IF @ExistingId IS NOT NULL
            BEGIN
                UPDATE t.tblFavourite
                SET    IsDeleted      = 0,
                       RecordStatusId = 1,
                       ModifiedBy     = @UserId,
                       ModifiedOn     = GETUTCDATE()
                WHERE  Id = @ExistingId;

                INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
                VALUES ('tblFavourite', @ExistingId, 'REACTIVATE', NULL, @UserId, GETUTCDATE());

                SELECT @ExistingId AS FavouriteId;
            END
            ELSE
            BEGIN
                -- Guard: if an active row already exists, return it
                DECLARE @ActiveId INT;
                SELECT @ActiveId = Id
                FROM   t.tblFavourite
                WHERE  UserId = @UserId AND ProductId = @ProductId AND IsDeleted = 0;

                IF @ActiveId IS NOT NULL
                BEGIN
                    SELECT @ActiveId AS FavouriteId;
                END
                ELSE
                BEGIN
                    INSERT INTO t.tblFavourite (UserId, ProductId, RecordStatusId, CreatedBy, CreatedOn)
                    VALUES (@UserId, @ProductId, 1, @UserId, GETUTCDATE());

                    DECLARE @NewId INT = SCOPE_IDENTITY();

                    INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
                    VALUES ('tblFavourite', @NewId, 'CREATE', NULL, @UserId, GETUTCDATE());

                    SELECT @NewId AS FavouriteId;
                END
            END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_AddFavourite', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH;
END
GO

-- =========================================================
-- 2. proc_Catalogue_RemoveFavourite
--    Soft-deletes the favourite row.
-- =========================================================
IF OBJECT_ID('proc_Catalogue_RemoveFavourite', 'P') IS NOT NULL
    DROP PROCEDURE proc_Catalogue_RemoveFavourite;
GO

CREATE PROCEDURE proc_Catalogue_RemoveFavourite
    @UserId    INT,
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

            DECLARE @FavId INT;
            SELECT @FavId = Id
            FROM   t.tblFavourite
            WHERE  UserId = @UserId AND ProductId = @ProductId AND IsDeleted = 0;

            IF @FavId IS NOT NULL
            BEGIN
                UPDATE t.tblFavourite
                SET    IsDeleted      = 1,
                       RecordStatusId = 3,
                       ModifiedBy     = @UserId,
                       ModifiedOn     = GETUTCDATE()
                WHERE  Id = @FavId;

                INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
                VALUES ('tblFavourite', @FavId, 'DELETE', NULL, @UserId, GETUTCDATE());
            END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_RemoveFavourite', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH;
END
GO

-- =========================================================
-- 3. proc_Catalogue_GetUserFavourites
--    Returns full product details for all active favourites,
--    newest first. IsInStock, UnitPrice and PromotionLabel
--    are computed via subqueries matching existing catalogue SPs.
-- =========================================================
IF OBJECT_ID('proc_Catalogue_GetUserFavourites', 'P') IS NOT NULL
    DROP PROCEDURE proc_Catalogue_GetUserFavourites;
GO

CREATE PROCEDURE proc_Catalogue_GetUserFavourites
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        SELECT
            f.Id              AS FavouriteId,
            p.Id              AS ProductId,
            p.Name,
            b.Name            AS BrandName,
            p.BasePrice,
            p.ClubcardPrice,
            c.Name            AS CategoryName,
            p.ImageUrl,
            p.AverageRating,
            p.ReviewCount,
            f.CreatedOn,
            CAST(CASE WHEN EXISTS (
                SELECT 1
                FROM   m.tblProductVariant sv
                WHERE  sv.ProductId    = p.Id
                  AND  sv.StockQuantity > 0
                  AND  sv.IsDeleted    = 0
            ) THEN 1 ELSE 0 END AS BIT) AS IsInStock,
            (SELECT TOP 1 dv.VariantName
             FROM   m.tblProductVariant dv
             WHERE  dv.ProductId      = p.Id
               AND  dv.IsDeleted      = 0
               AND  dv.RecordStatusId = 1
             ORDER BY dv.Id) AS UnitPrice,
            (SELECT TOP 1 prm.Name
             FROM   m.tblPromotionProduct pp
             INNER JOIN m.tblPromotion prm ON prm.Id = pp.PromotionId
             WHERE  pp.ProductId  = p.Id
               AND  pp.IsDeleted  = 0
               AND  prm.IsDeleted = 0
               AND  prm.IsActive  = 1
               AND  (prm.ValidFrom IS NULL OR prm.ValidFrom <= GETUTCDATE())
               AND  (prm.ValidTo   IS NULL OR prm.ValidTo   >= GETUTCDATE())
             ORDER BY prm.CreatedOn DESC) AS PromotionLabel
        FROM  t.tblFavourite f
        INNER JOIN m.tblProduct  p ON p.Id = f.ProductId AND p.IsDeleted = 0
        INNER JOIN m.tblCategory c ON c.Id = p.CategoryId AND c.IsDeleted = 0
        LEFT  JOIN m.tblBrand    b ON b.Id = p.BrandId AND b.IsDeleted = 0
        WHERE f.UserId    = @UserId
          AND f.IsDeleted = 0
        ORDER BY f.CreatedOn DESC;

    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetUserFavourites', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH;
END
GO

-- =========================================================
-- 4. proc_Catalogue_GetFavouriteStatus
--    Returns: IsFavourited BIT, FavouriteId INT NULL
-- =========================================================
IF OBJECT_ID('proc_Catalogue_GetFavouriteStatus', 'P') IS NOT NULL
    DROP PROCEDURE proc_Catalogue_GetFavouriteStatus;
GO

CREATE PROCEDURE proc_Catalogue_GetFavouriteStatus
    @UserId    INT,
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        SELECT
            CASE WHEN f.Id IS NOT NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsFavourited,
            f.Id AS FavouriteId
        FROM  (SELECT NULL AS Dummy) x
        LEFT  JOIN t.tblFavourite f
               ON  f.UserId    = @UserId
               AND f.ProductId = @ProductId
               AND f.IsDeleted = 0;

    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetFavouriteStatus', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH;
END
GO
