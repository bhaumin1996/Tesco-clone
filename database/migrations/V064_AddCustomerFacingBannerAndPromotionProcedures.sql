-- V064_AddCustomerFacingBannerAndPromotionProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: Add two customer-facing (unauthenticated) stored procedures for
--              the storefront Offers page and Banners hub. These differ from the
--              admin variants by filtering on active date ranges and not requiring
--              any admin context.
-- Dependencies: V011 (tblBanner), V010 (tblPromotion), V063 (promotion schema fix)

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- proc_Content_GetActiveBanners
-- Returns banners that are active and within their date window,
-- ordered by DisplayOrder for predictable carousel/grid ordering.
-- =========================================================
IF OBJECT_ID('proc_Content_GetActiveBanners', 'P') IS NOT NULL
    DROP PROCEDURE proc_Content_GetActiveBanners;
GO

CREATE PROCEDURE proc_Content_GetActiveBanners
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            b.Id,
            b.Title,
            b.SubTitle,
            b.ImageUrl,
            b.LinkUrl,
            b.DisplayOrder,
            b.IsActive,
            b.StartsAt,
            b.EndsAt,
            b.CreatedOn,
            b.ModifiedOn
        FROM t.tblBanner b
        WHERE b.IsDeleted = 0
          AND b.IsActive  = 1
          AND (b.StartsAt IS NULL OR b.StartsAt <= GETUTCDATE())
          AND (b.EndsAt   IS NULL OR b.EndsAt   >= GETUTCDATE())
        ORDER BY b.DisplayOrder ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Content_GetActiveBanners', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Promotions_GetActivePromotions
-- Returns promotions that are active and within their validity
-- window, paginated for the storefront Offers page.
-- =========================================================
IF OBJECT_ID('proc_Promotions_GetActivePromotions', 'P') IS NOT NULL
    DROP PROCEDURE proc_Promotions_GetActivePromotions;
GO

CREATE PROCEDURE proc_Promotions_GetActivePromotions
    @PageNumber INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            p.Id,
            p.Name,
            CASE p.TypeId
                WHEN 1 THEN 'Percentage Discount'
                WHEN 2 THEN 'Fixed Amount Discount'
                WHEN 3 THEN 'Buy X Get Y'
                WHEN 4 THEN 'Multi Buy'
                WHEN 5 THEN 'Clubcard Price'
                ELSE        'Unknown'
            END                     AS TypeName,
            p.DiscountValue,
            p.DiscountPercent,
            p.MinimumQuantity       AS MinQuantity,
            p.ValidFrom             AS StartsAt,
            p.ValidTo               AS EndsAt,
            p.IsActive,
            p.RequiresClubcard,
            COUNT(1) OVER ()        AS TotalCount
        FROM m.tblPromotion p
        WHERE p.IsDeleted = 0
          AND p.IsActive  = 1
          AND (p.ValidFrom IS NULL OR p.ValidFrom <= GETUTCDATE())
          AND (p.ValidTo   IS NULL OR p.ValidTo   >= GETUTCDATE())
        ORDER BY p.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Promotions_GetActivePromotions', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V064')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V064', 'AddCustomerFacingBannerAndPromotionProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
