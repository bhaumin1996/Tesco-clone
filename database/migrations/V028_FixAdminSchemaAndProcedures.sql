-- V028_FixAdminSchemaAndProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-14
-- Description: Fix schema mismatches between initial table migrations (V005–V012)
--              and the admin stored procedures created in V019–V025.
--              Creates missing reference tables, adds missing columns to existing
--              tables, corrects schema prefixes and column names in all affected
--              stored procedures, and adds proc_Admin_GetInventory.
-- Dependencies: V001–V027

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- PART 1 – Create missing reference / lookup tables
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblUserStatus')
    BEGIN
        CREATE TABLE m.tblUserStatus (
            Id   TINYINT NOT NULL PRIMARY KEY,
            Name NVARCHAR(50) NOT NULL
        );
        INSERT INTO m.tblUserStatus (Id, Name) VALUES (1,'Active'),(2,'Locked'),(3,'Disabled');
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblPromotionType')
    BEGIN
        CREATE TABLE m.tblPromotionType (
            Id   TINYINT NOT NULL PRIMARY KEY,
            Name NVARCHAR(100) NOT NULL
        );
        INSERT INTO m.tblPromotionType (Id, Name)
        VALUES (1,'Percentage'),(2,'FixedAmount'),(3,'BuyXGetY'),(4,'FreeShipping');
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblSellerStatus')
    BEGIN
        CREATE TABLE m.tblSellerStatus (
            Id   TINYINT NOT NULL PRIMARY KEY,
            Name NVARCHAR(50) NOT NULL
        );
        INSERT INTO m.tblSellerStatus (Id, Name) VALUES (1,'Pending'),(2,'Approved'),(3,'Suspended');
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblDisputeStatus')
    BEGIN
        CREATE TABLE m.tblDisputeStatus (
            Id   TINYINT NOT NULL PRIMARY KEY,
            Name NVARCHAR(50) NOT NULL
        );
        INSERT INTO m.tblDisputeStatus (Id, Name) VALUES (1,'Open'),(2,'UnderReview'),(3,'Resolved');
    END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V028_Part1', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 2a – Add missing columns to existing tables
-- NOTE: ALTER TABLE and the backfill UPDATEs that reference those
--       columns must be in separate batches (GO-separated). SQL Server
--       compiles an entire batch before executing it, so a column added
--       by ALTER TABLE in the same batch is invisible at compile time to
--       any DML that follows it.
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    -- m.tblPromotion
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblPromotion' AND COLUMN_NAME='PromotionTypeId')
        ALTER TABLE m.tblPromotion ADD PromotionTypeId TINYINT NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblPromotion' AND COLUMN_NAME='DiscountPercent')
        ALTER TABLE m.tblPromotion ADD DiscountPercent DECIMAL(5,2) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblPromotion' AND COLUMN_NAME='MinQuantity')
        ALTER TABLE m.tblPromotion ADD MinQuantity INT NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblPromotion' AND COLUMN_NAME='StartsAt')
        ALTER TABLE m.tblPromotion ADD StartsAt DATETIME2 NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblPromotion' AND COLUMN_NAME='EndsAt')
        ALTER TABLE m.tblPromotion ADD EndsAt DATETIME2 NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblPromotion' AND COLUMN_NAME='IsActive')
        ALTER TABLE m.tblPromotion ADD IsActive BIT NOT NULL DEFAULT 1;

    -- t.tblSeller
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='StatusId')
        ALTER TABLE t.tblSeller ADD StatusId TINYINT NOT NULL DEFAULT 1;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='ContactEmail')
        ALTER TABLE t.tblSeller ADD ContactEmail NVARCHAR(256) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='SuspendReason')
        ALTER TABLE t.tblSeller ADD SuspendReason NVARCHAR(500) NULL;

    -- t.tblDispute
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblDispute' AND COLUMN_NAME='Subject')
        ALTER TABLE t.tblDispute ADD Subject NVARCHAR(300) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblDispute' AND COLUMN_NAME='Description')
        ALTER TABLE t.tblDispute ADD Description NVARCHAR(MAX) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblDispute' AND COLUMN_NAME='ResolvedOn')
        ALTER TABLE t.tblDispute ADD ResolvedOn DATETIME2 NULL;

    -- t.tblBanner
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblBanner' AND COLUMN_NAME='SubTitle')
        ALTER TABLE t.tblBanner ADD SubTitle NVARCHAR(300) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblBanner' AND COLUMN_NAME='IsActive')
        ALTER TABLE t.tblBanner ADD IsActive BIT NOT NULL DEFAULT 1;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblBanner' AND COLUMN_NAME='StartsAt')
        ALTER TABLE t.tblBanner ADD StartsAt DATETIME2 NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblBanner' AND COLUMN_NAME='EndsAt')
        ALTER TABLE t.tblBanner ADD EndsAt DATETIME2 NULL;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V028_Part2a', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 2b – Back-fill new columns from legacy values
--           (separate batch so the new columns are visible at compile time)
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE m.tblPromotion
    SET PromotionTypeId = ISNULL(TypeId, 1),
        MinQuantity     = MinimumQuantity,
        StartsAt        = ValidFrom,
        EndsAt          = ValidTo
    WHERE PromotionTypeId IS NULL;

    UPDATE t.tblSeller
    SET StatusId     = CASE WHEN IsApproved = 1 THEN 2 ELSE 1 END,
        ContactEmail = BusinessEmail
    WHERE ContactEmail IS NULL;

    UPDATE t.tblDispute
    SET Subject     = LEFT(Reason, 300),
        Description = Reason
    WHERE Subject IS NULL;

    UPDATE t.tblBanner
    SET StartsAt = ValidFrom,
        EndsAt   = ValidTo
    WHERE StartsAt IS NULL;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V028_Part2b', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 3 – Drop all affected stored procedures before recreating
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetUsers',            'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetUsers;
    IF OBJECT_ID('proc_Admin_GetPromotions',        'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetPromotions;
    IF OBJECT_ID('proc_Admin_CreatePromotion',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreatePromotion;
    IF OBJECT_ID('proc_Admin_UpdatePromotion',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdatePromotion;
    IF OBJECT_ID('proc_Admin_SoftDeletePromotion',  'P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeletePromotion;
    IF OBJECT_ID('proc_Admin_GetSellers',           'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellers;
    IF OBJECT_ID('proc_Admin_ApproveSeller',        'P') IS NOT NULL DROP PROCEDURE proc_Admin_ApproveSeller;
    IF OBJECT_ID('proc_Admin_SuspendSeller',        'P') IS NOT NULL DROP PROCEDURE proc_Admin_SuspendSeller;
    IF OBJECT_ID('proc_Admin_GetDisputes',          'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetDisputes;
    IF OBJECT_ID('proc_Admin_ResolveDispute',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_ResolveDispute;
    IF OBJECT_ID('proc_Admin_GetPages',             'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetPages;
    IF OBJECT_ID('proc_Admin_GetPageById',          'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetPageById;
    IF OBJECT_ID('proc_Admin_CreatePage',           'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreatePage;
    IF OBJECT_ID('proc_Admin_UpdatePage',           'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdatePage;
    IF OBJECT_ID('proc_Admin_SoftDeletePage',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeletePage;
    IF OBJECT_ID('proc_Admin_GetBanners',           'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetBanners;
    IF OBJECT_ID('proc_Admin_CreateBanner',         'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreateBanner;
    IF OBJECT_ID('proc_Admin_UpdateBanner',         'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdateBanner;
    IF OBJECT_ID('proc_Admin_SoftDeleteBanner',     'P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeleteBanner;
    IF OBJECT_ID('proc_Admin_GetInventory',         'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetInventory;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetUsers  (fixed: join m.tblUserStatus)
-- =========================================================
CREATE PROCEDURE proc_Admin_GetUsers
    @Search     NVARCHAR(256) = NULL,
    @PageNumber INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            u.Id,
            u.FirstName,
            u.LastName,
            u.Email,
            u.PhoneNumber,
            us.Name AS StatusName,
            u.FailedLoginAttempts,
            u.LockedUntil,
            u.CreatedOn,
            u.ModifiedOn,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblUser u
        INNER JOIN m.tblUserStatus us ON us.Id = u.StatusId
        WHERE u.IsDeleted = 0
          AND (@Search IS NULL
               OR u.Email      LIKE '%' + @Search + '%'
               OR u.FirstName  LIKE '%' + @Search + '%'
               OR u.LastName   LIKE '%' + @Search + '%')
        ORDER BY u.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetUsers', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetPromotions  (fixed: join m.tblPromotionType,
--   use new columns PromotionTypeId, DiscountPercent, MinQuantity, StartsAt, EndsAt, IsActive)
-- =========================================================
CREATE PROCEDURE proc_Admin_GetPromotions
    @IsActive   BIT = NULL,
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
            ISNULL(pt.Name, 'Percentage') AS TypeName,
            p.DiscountValue,
            p.DiscountPercent,
            p.MinQuantity,
            p.StartsAt,
            p.EndsAt,
            p.IsActive,
            p.CreatedOn,
            p.ModifiedOn,
            COUNT(1) OVER () AS TotalCount
        FROM m.tblPromotion p
        LEFT JOIN m.tblPromotionType pt ON pt.Id = p.PromotionTypeId
        WHERE p.IsDeleted = 0
          AND (@IsActive IS NULL OR p.IsActive = @IsActive)
        ORDER BY p.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetPromotions', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetPromotionById  (fixed)
-- =========================================================
CREATE PROCEDURE proc_Admin_GetPromotionById
    @PromotionId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            p.Id,
            p.Name,
            ISNULL(pt.Name, 'Percentage') AS TypeName,
            p.DiscountValue,
            p.DiscountPercent,
            p.MinQuantity,
            p.StartsAt,
            p.EndsAt,
            p.IsActive,
            p.CreatedOn,
            p.ModifiedOn
        FROM m.tblPromotion p
        LEFT JOIN m.tblPromotionType pt ON pt.Id = p.PromotionTypeId
        WHERE p.Id = @PromotionId
          AND p.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetPromotionById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreatePromotion  (fixed: use new column names)
-- =========================================================
CREATE PROCEDURE proc_Admin_CreatePromotion
    @Name            NVARCHAR(200),
    @DiscountValue   DECIMAL(10,2) = NULL,
    @DiscountPercent DECIMAL(5,2)  = NULL,
    @MinQuantity     INT = NULL,
    @StartsAt        DATETIME2 = NULL,
    @EndsAt          DATETIME2 = NULL,
    @AdminId         INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @PromotionId INT;

        INSERT INTO m.tblPromotion
            (Name, PromotionTypeId, DiscountValue, DiscountPercent, MinQuantity,
             StartsAt, EndsAt, IsActive, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@Name, 1, @DiscountValue, @DiscountPercent, @MinQuantity,
             @StartsAt, @EndsAt, 1, 1, @AdminId, GETUTCDATE());

        SET @PromotionId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPromotion', @PromotionId, 'INSERT',
                CONCAT('{"Name":"', @Name, '"}'), @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @PromotionId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreatePromotion', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UpdatePromotion  (fixed: use new column names)
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdatePromotion
    @PromotionId     INT,
    @Name            NVARCHAR(200),
    @DiscountValue   DECIMAL(10,2) = NULL,
    @DiscountPercent DECIMAL(5,2)  = NULL,
    @MinQuantity     INT = NULL,
    @StartsAt        DATETIME2 = NULL,
    @EndsAt          DATETIME2 = NULL,
    @IsActive        BIT,
    @AdminId         INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblPromotion
        SET Name            = @Name,
            DiscountValue   = @DiscountValue,
            DiscountPercent = @DiscountPercent,
            MinQuantity     = @MinQuantity,
            StartsAt        = @StartsAt,
            EndsAt          = @EndsAt,
            IsActive        = @IsActive,
            ModifiedBy      = @AdminId,
            ModifiedOn      = GETUTCDATE()
        WHERE Id = @PromotionId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPromotion', @PromotionId, 'UPDATE',
                CONCAT('{"Name":"', @Name, '","IsActive":', @IsActive, '}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdatePromotion', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SoftDeletePromotion  (unchanged, re-created for completeness)
-- =========================================================
CREATE PROCEDURE proc_Admin_SoftDeletePromotion
    @PromotionId INT,
    @AdminId     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblPromotion
        SET IsDeleted      = 1,
            RecordStatusId = 3,
            IsActive       = 0,
            ModifiedBy     = @AdminId,
            ModifiedOn     = GETUTCDATE()
        WHERE Id = @PromotionId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPromotion', @PromotionId, 'DELETE', '{"IsDeleted":1}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SoftDeletePromotion', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetSellers  (fixed: t.tblSeller, m.tblSellerStatus, ContactEmail)
-- =========================================================
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
            ISNULL(s.ContactEmail, s.BusinessEmail) AS ContactEmail,
            ss.Name AS StatusName,
            s.CommissionRate,
            s.CreatedOn,
            s.ModifiedOn,
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

-- =========================================================
-- proc_Admin_GetSellerById  (fixed: t.tblSeller)
-- =========================================================
CREATE PROCEDURE proc_Admin_GetSellerById
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            s.Id,
            s.BusinessName,
            ISNULL(s.ContactEmail, s.BusinessEmail) AS ContactEmail,
            ss.Name AS StatusName,
            s.CommissionRate,
            s.CreatedOn,
            s.ModifiedOn
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

-- =========================================================
-- proc_Admin_ApproveSeller  (fixed: t.tblSeller, StatusId=2)
-- =========================================================
CREATE PROCEDURE proc_Admin_ApproveSeller
    @SellerId INT,
    @AdminId  INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblSeller
        SET StatusId   = 2,
            IsApproved = 1,
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @SellerId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSeller', @SellerId, 'UPDATE', '{"StatusId":2,"Action":"Approved"}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_ApproveSeller', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SuspendSeller  (fixed: t.tblSeller, StatusId=3, SuspendReason)
-- =========================================================
CREATE PROCEDURE proc_Admin_SuspendSeller
    @SellerId INT,
    @Reason   NVARCHAR(500),
    @AdminId  INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblSeller
        SET StatusId      = 3,
            IsApproved    = 0,
            SuspendReason = @Reason,
            ModifiedBy    = @AdminId,
            ModifiedOn    = GETUTCDATE()
        WHERE Id = @SellerId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSeller', @SellerId, 'UPDATE',
                CONCAT('{"StatusId":3,"Action":"Suspended","Reason":"', @Reason, '"}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SuspendSeller', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetDisputes  (fixed: t.tblDispute, m.tblDisputeStatus, Subject/Description)
-- =========================================================
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
            COUNT(1) OVER () AS TotalCount
        FROM t.tblDispute d
        INNER JOIN m.tblDisputeStatus ds ON ds.Id = d.StatusId
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

-- =========================================================
-- proc_Admin_ResolveDispute  (fixed: t.tblDispute, ResolvedOn)
-- =========================================================
CREATE PROCEDURE proc_Admin_ResolveDispute
    @DisputeId  INT,
    @Resolution NVARCHAR(1000),
    @AdminId    INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblDispute
        SET StatusId   = 3,
            Resolution = @Resolution,
            ResolvedOn = GETUTCDATE(),
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @DisputeId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblDispute', @DisputeId, 'UPDATE',
                CONCAT('{"StatusId":3,"Resolution":"', @Resolution, '"}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_ResolveDispute', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetPages  (fixed: t.tblPage not m.tblPage)
-- =========================================================
CREATE PROCEDURE proc_Admin_GetPages
    @IsPublished BIT = NULL,
    @PageNumber  INT = 1,
    @PageSize    INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            p.Id,
            p.Title,
            p.Slug,
            p.Content,
            p.IsPublished,
            p.CreatedOn,
            p.ModifiedOn,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblPage p
        WHERE p.IsDeleted = 0
          AND (@IsPublished IS NULL OR p.IsPublished = @IsPublished)
        ORDER BY p.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetPages', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetPageById  (fixed: t.tblPage)
-- =========================================================
CREATE PROCEDURE proc_Admin_GetPageById
    @PageId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, Title, Slug, Content, IsPublished, CreatedOn, ModifiedOn
        FROM t.tblPage
        WHERE Id = @PageId AND IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetPageById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreatePage  (fixed: t.tblPage)
-- =========================================================
CREATE PROCEDURE proc_Admin_CreatePage
    @Title       NVARCHAR(300),
    @Slug        NVARCHAR(320),
    @Content     NVARCHAR(MAX) = NULL,
    @IsPublished BIT,
    @AdminId     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @PageId INT;

        INSERT INTO t.tblPage (Title, Slug, Content, IsPublished, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@Title, @Slug, @Content, @IsPublished, 1, @AdminId, GETUTCDATE());

        SET @PageId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPage', @PageId, 'INSERT', CONCAT('{"Title":"', @Title, '"}'), @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @PageId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreatePage', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UpdatePage  (fixed: t.tblPage)
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdatePage
    @PageId      INT,
    @Title       NVARCHAR(300),
    @Content     NVARCHAR(MAX) = NULL,
    @IsPublished BIT,
    @AdminId     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblPage
        SET Title       = @Title,
            Content     = @Content,
            IsPublished = @IsPublished,
            ModifiedBy  = @AdminId,
            ModifiedOn  = GETUTCDATE()
        WHERE Id = @PageId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPage', @PageId, 'UPDATE', CONCAT('{"Title":"', @Title, '"}'), @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdatePage', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SoftDeletePage  (fixed: t.tblPage)
-- =========================================================
CREATE PROCEDURE proc_Admin_SoftDeletePage
    @PageId  INT,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblPage
        SET IsDeleted = 1, RecordStatusId = 3, ModifiedBy = @AdminId, ModifiedOn = GETUTCDATE()
        WHERE Id = @PageId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPage', @PageId, 'DELETE', '{"IsDeleted":1}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SoftDeletePage', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetBanners  (fixed: t.tblBanner, new columns)
-- =========================================================
CREATE PROCEDURE proc_Admin_GetBanners
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            Id, Title, SubTitle, ImageUrl, LinkUrl,
            DisplayOrder, IsActive, StartsAt, EndsAt,
            CreatedOn, ModifiedOn
        FROM t.tblBanner
        WHERE IsDeleted = 0
          AND (@IsActive IS NULL OR IsActive = @IsActive)
        ORDER BY DisplayOrder ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetBanners', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreateBanner  (fixed: t.tblBanner, new columns)
-- =========================================================
CREATE PROCEDURE proc_Admin_CreateBanner
    @Title        NVARCHAR(200),
    @SubTitle     NVARCHAR(300) = NULL,
    @ImageUrl     NVARCHAR(500) = NULL,
    @LinkUrl      NVARCHAR(500) = NULL,
    @DisplayOrder INT = 0,
    @IsActive     BIT = 1,
    @StartsAt     DATETIME2 = NULL,
    @EndsAt       DATETIME2 = NULL,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @BannerId INT;

        INSERT INTO t.tblBanner
            (Title, SubTitle, ImageUrl, LinkUrl, DisplayOrder, IsActive,
             StartsAt, EndsAt, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@Title, @SubTitle, @ImageUrl, @LinkUrl, @DisplayOrder, @IsActive,
             @StartsAt, @EndsAt, 1, @AdminId, GETUTCDATE());

        SET @BannerId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblBanner', @BannerId, 'INSERT', CONCAT('{"Title":"', @Title, '"}'), @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @BannerId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreateBanner', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UpdateBanner  (fixed: t.tblBanner, new columns)
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdateBanner
    @BannerId     INT,
    @Title        NVARCHAR(200),
    @SubTitle     NVARCHAR(300) = NULL,
    @ImageUrl     NVARCHAR(500) = NULL,
    @LinkUrl      NVARCHAR(500) = NULL,
    @DisplayOrder INT,
    @IsActive     BIT,
    @StartsAt     DATETIME2 = NULL,
    @EndsAt       DATETIME2 = NULL,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblBanner
        SET Title        = @Title,
            SubTitle     = @SubTitle,
            ImageUrl     = @ImageUrl,
            LinkUrl      = @LinkUrl,
            DisplayOrder = @DisplayOrder,
            IsActive     = @IsActive,
            StartsAt     = @StartsAt,
            EndsAt       = @EndsAt,
            ModifiedBy   = @AdminId,
            ModifiedOn   = GETUTCDATE()
        WHERE Id = @BannerId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblBanner', @BannerId, 'UPDATE', CONCAT('{"Title":"', @Title, '"}'), @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdateBanner', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SoftDeleteBanner  (fixed: t.tblBanner)
-- =========================================================
CREATE PROCEDURE proc_Admin_SoftDeleteBanner
    @BannerId INT,
    @AdminId  INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblBanner
        SET IsDeleted = 1, RecordStatusId = 3, IsActive = 0,
            ModifiedBy = @AdminId, ModifiedOn = GETUTCDATE()
        WHERE Id = @BannerId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblBanner', @BannerId, 'DELETE', '{"IsDeleted":1}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SoftDeleteBanner', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetInventory  (new: list all product variant stock levels)
-- =========================================================
CREATE PROCEDURE proc_Admin_GetInventory
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            pv.Id                                                          AS ProductVariantId,
            p.Id                                                           AS ProductId,
            p.Name                                                         AS ProductName,
            pv.Sku,
            pv.StockQuantity,
            10                                                             AS LowStockThreshold,
            CAST(CASE WHEN pv.StockQuantity <= 10 THEN 1 ELSE 0 END AS BIT) AS IsLowStock
        FROM m.tblProductVariant pv
        INNER JOIN m.tblProduct p ON p.Id = pv.ProductId AND p.IsDeleted = 0
        WHERE pv.IsDeleted = 0
        ORDER BY pv.StockQuantity ASC, p.Name ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetInventory', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V028')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V028', 'FixAdminSchemaAndProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
