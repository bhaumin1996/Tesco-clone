-- V041_EnhanceGetCartProcedure.sql
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
            NULL          AS PromotionLabel,
            NULL          AS UnitPriceLabel
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

IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V041')
    INSERT INTO t.tblMigration (Version, Description) VALUES ('V041', 'EnhanceGetCartProcedure');
GO
