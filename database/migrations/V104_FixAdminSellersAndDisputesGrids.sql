-- V104_FixAdminSellersAndDisputesGrids.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Drop and recreate stored procedures to support all fields in admin Sellers and Disputes grids.
-- Dependencies: V012, V028, V098

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- ─────────────────────────────────────────────────────────
    -- 1. Drop existing procedures to recreate them
    -- ─────────────────────────────────────────────────────────
    IF OBJECT_ID('proc_Admin_GetSellers',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellers;
    IF OBJECT_ID('proc_Admin_GetSellerById',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellerById;
    IF OBJECT_ID('proc_Marketplace_GetSellerByUserId', 'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerByUserId;
    IF OBJECT_ID('proc_Admin_GetDisputes',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetDisputes;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V104_DropProcedures', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- ─────────────────────────────────────────────────────────
-- 2. Create proc_Admin_GetSellers (added TotalListings)
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Admin_GetSellers
    @StatusFilter NVARCHAR(50) = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            s.Id,
            s.BusinessName,
            s.ContactEmail,
            ss.Name AS StatusName,
            s.CommissionRate,
            s.RegistrationNumber,
            s.VatNumber,
            s.Phone,
            CAST(NULL AS NVARCHAR(MAX)) AS Description,
            CAST(NULL AS NVARCHAR(200)) AS BankDetailsRef,
            s.ApprovedOn,
            s.SuspendedOn,
            s.CommissionTierId,
            s.CreatedOn,
            s.ModifiedOn,
            (SELECT COUNT(1) FROM t.tblListing l WHERE l.SellerId = s.Id AND l.IsDeleted = 0) AS TotalListings,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblSeller s
        INNER JOIN m.tblSellerStatus ss ON ss.Id = s.StatusId
        WHERE s.IsDeleted = 0
          AND (@StatusFilter IS NULL OR ss.Name = @StatusFilter)
        ORDER BY s.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetSellers', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────────
-- 3. Create proc_Admin_GetSellerById (added TotalListings)
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Admin_GetSellerById
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            s.Id,
            s.BusinessName,
            s.ContactEmail,
            ss.Name AS StatusName,
            s.CommissionRate,
            s.RegistrationNumber,
            s.VatNumber,
            s.Phone,
            s.Description,
            s.BankDetailsRef,
            s.ApprovedOn,
            s.SuspendedOn,
            s.CommissionTierId,
            s.CreatedOn,
            s.ModifiedOn,
            (SELECT COUNT(1) FROM t.tblListing l WHERE l.SellerId = s.Id AND l.IsDeleted = 0) AS TotalListings
        FROM t.tblSeller s
        INNER JOIN m.tblSellerStatus ss ON ss.Id = s.StatusId
        WHERE s.Id = @SellerId AND s.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetSellerById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────────
-- 4. Create proc_Marketplace_GetSellerByUserId (added TotalListings)
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Marketplace_GetSellerByUserId
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            s.Id,
            s.BusinessName,
            s.ContactEmail,
            ss.Name AS StatusName,
            s.CommissionRate,
            s.RegistrationNumber,
            s.VatNumber,
            s.Phone,
            s.Description,
            s.BankDetailsRef,
            s.ApprovedOn,
            s.SuspendedOn,
            s.CommissionTierId,
            s.CreatedOn,
            s.ModifiedOn,
            (SELECT COUNT(1) FROM t.tblListing l WHERE l.SellerId = s.Id AND l.IsDeleted = 0) AS TotalListings
        FROM t.tblSeller s
        INNER JOIN m.tblSellerStatus ss ON ss.Id = s.StatusId
        WHERE s.UserId = @UserId AND s.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_GetSellerByUserId', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────────
-- 5. Create proc_Admin_GetDisputes (added SellerName, Reason)
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Admin_GetDisputes
    @StatusFilter NVARCHAR(50) = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            d.Id,
            d.OrderId,
            d.SellerId,
            ISNULL(d.Subject, LEFT(d.Reason, 300))       AS Subject,
            ISNULL(d.Description, d.Reason)               AS Description,
            ds.Name                                        AS StatusName,
            d.Resolution,
            d.CreatedOn,
            d.ResolvedOn,
            s.BusinessName                                 AS SellerName,
            d.Reason                                       AS Reason,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblDispute d
        INNER JOIN m.tblDisputeStatus ds ON ds.Id = d.StatusId
        INNER JOIN t.tblSeller s ON s.Id = d.SellerId
        WHERE d.IsDeleted = 0
          AND (@StatusFilter IS NULL OR ds.Name = @StatusFilter)
        ORDER BY d.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetDisputes', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────────
-- 6. Record migration in t.tblMigration
-- ─────────────────────────────────────────────────────────
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V104')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V104', 'FixAdminSellersAndDisputesGrids');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
