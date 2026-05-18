-- V084_AddPromotionAndUnitLabelsToCartProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Recreate proc_Order_GetCartByUserId to return real UnitPriceLabel and PromotionLabel.
-- Dependencies: V001-V083

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF OBJECT_ID('proc_Order_GetCartByUserId', 'P') IS NOT NULL
    DROP PROCEDURE proc_Order_GetCartByUserId;
GO

CREATE PROCEDURE proc_Order_GetCartByUserId
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            c.Id          AS CartId,
            c.UserId,
            ci.Id         AS CartItemId,
            ci.ProductVariantId,
            ci.ProductName,
            ci.UnitPrice,
            ci.Quantity,
            CAST(ci.UnitPrice * ci.Quantity AS DECIMAL(10,2)) AS LineTotal,
            p.ImageUrl,
            p.BasePrice   AS OriginalPrice,
            p.ClubcardPrice,
            (SELECT TOP 1 prm.Name
             FROM m.tblPromotionProduct pp
             INNER JOIN m.tblPromotion prm ON prm.Id = pp.PromotionId
             WHERE pp.ProductId = p.Id
               AND pp.IsDeleted = 0
               AND prm.IsDeleted = 0
               AND prm.IsActive = 1
               AND (prm.ValidFrom IS NULL OR prm.ValidFrom <= GETUTCDATE())
               AND (prm.ValidTo IS NULL OR prm.ValidTo >= GETUTCDATE())
             ORDER BY prm.CreatedOn DESC) AS PromotionLabel,
            pv.VariantName AS UnitPriceLabel
        FROM t.tblCart c
        INNER JOIN t.tblCartItem ci ON ci.CartId = c.Id AND ci.IsDeleted = 0
        LEFT JOIN m.tblProductVariant pv ON pv.Id = ci.ProductVariantId
        LEFT JOIN m.tblProduct p ON p.Id = pv.ProductId
        WHERE c.UserId    = @UserId
          AND c.IsDeleted = 0
        ORDER BY ci.Id;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_GetCartByUserId', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V084')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V084', 'AddPromotionAndUnitLabelsToCartProcedure');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
