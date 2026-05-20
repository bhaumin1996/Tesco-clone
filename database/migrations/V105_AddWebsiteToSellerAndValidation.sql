-- V105_AddWebsiteToSellerAndValidation.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Add Website column to tblSellerApplication and tblSeller. Recreate procedures to support Website field. Create proc_Marketplace_CheckSellerUnique for duplicate validation.
-- Dependencies: V012, V099, V104

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- ─────────────────────────────────────────────────────────
-- 1. Table Alterations: Add Website column
-- ─────────────────────────────────────────────────────────
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSellerApplication' AND COLUMN_NAME = 'Website'
    )
    BEGIN
        ALTER TABLE t.tblSellerApplication ADD Website NVARCHAR(500) NULL;
        PRINT 'Column Website added to t.tblSellerApplication.';
    END

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'Website'
    )
    BEGIN
        ALTER TABLE t.tblSeller ADD Website NVARCHAR(500) NULL;
        PRINT 'Column Website added to t.tblSeller.';
    END

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V105_TableAlterations', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- ─────────────────────────────────────────────────────────
-- 2. Drop existing procedures to recreate them
-- ─────────────────────────────────────────────────────────
BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Marketplace_ApplyAsSeller',         'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_ApplyAsSeller;
    IF OBJECT_ID('proc_Marketplace_UpdateApplication',     'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_UpdateApplication;
    IF OBJECT_ID('proc_Marketplace_GetApplicationByUserId','P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetApplicationByUserId;
    IF OBJECT_ID('proc_Admin_ReviewApplication',           'P') IS NOT NULL DROP PROCEDURE proc_Admin_ReviewApplication;
    IF OBJECT_ID('proc_Admin_GetSellerApplications',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellerApplications;
    IF OBJECT_ID('proc_Admin_GetSellers',                  'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellers;
    IF OBJECT_ID('proc_Admin_GetSellerById',               'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellerById;
    IF OBJECT_ID('proc_Marketplace_GetSellerByUserId',     'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerByUserId;
    IF OBJECT_ID('proc_Marketplace_CheckSellerUnique',     'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_CheckSellerUnique;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V105_DropProcedures', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- ─────────────────────────────────────────────────────────
-- 3. Recreate: proc_Marketplace_ApplyAsSeller
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Marketplace_ApplyAsSeller
    @UserId            INT,
    @BusinessName      NVARCHAR(300),
    @BusinessEmail     NVARCHAR(256),
    @Phone             NVARCHAR(30)  = NULL,
    @Description       NVARCHAR(MAX) = NULL,
    @RegistrationNumber NVARCHAR(50) = NULL,
    @VatNumber         NVARCHAR(50)  = NULL,
    @BankDetailsRef    NVARCHAR(200) = NULL,
    @CategoryIds       NVARCHAR(500) = NULL,
    @TsAndCsAccepted   BIT = 0,
    @Website           NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Prevent duplicate active applications
        IF EXISTS (
            SELECT 1 FROM t.tblSellerApplication
            WHERE UserId = @UserId AND StatusId IN (1,2,3) AND IsDeleted = 0)
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('An active seller application already exists for this user.', 16, 1);
            RETURN;
        END

        INSERT INTO t.tblSellerApplication
            (UserId, BusinessName, BusinessEmail, Phone, Description,
             RegistrationNumber, VatNumber, BankDetailsRef, CategoryIds,
             TsAndCsAccepted, StatusId, RecordStatusId, CreatedBy, CreatedOn, IsDeleted, Website)
        VALUES
            (@UserId, @BusinessName, @BusinessEmail, @Phone, @Description,
             @RegistrationNumber, @VatNumber, @BankDetailsRef, @CategoryIds,
             @TsAndCsAccepted, 1, 1, @UserId, GETUTCDATE(), 0, @Website);

        DECLARE @NewId INT = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSellerApplication', @NewId, 'CREATE',
                CONCAT('{"BusinessName":"', @BusinessName, '","StatusId":1}'),
                @UserId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @NewId AS ApplicationId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_ApplyAsSeller', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────────
-- 4. Recreate: proc_Marketplace_UpdateApplication
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Marketplace_UpdateApplication
    @ApplicationId     INT,
    @UserId            INT,
    @BusinessName      NVARCHAR(300),
    @BusinessEmail     NVARCHAR(256),
    @Phone             NVARCHAR(30)  = NULL,
    @Description       NVARCHAR(MAX) = NULL,
    @RegistrationNumber NVARCHAR(50) = NULL,
    @VatNumber         NVARCHAR(50)  = NULL,
    @BankDetailsRef    NVARCHAR(200) = NULL,
    @CategoryIds       NVARCHAR(500) = NULL,
    @TsAndCsAccepted   BIT = 0,
    @Website           NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblSellerApplication
        SET BusinessName       = @BusinessName,
            BusinessEmail      = @BusinessEmail,
            Phone              = @Phone,
            Description        = @Description,
            RegistrationNumber = @RegistrationNumber,
            VatNumber          = @VatNumber,
            BankDetailsRef     = @BankDetailsRef,
            CategoryIds        = @CategoryIds,
            TsAndCsAccepted    = @TsAndCsAccepted,
            Website            = @Website,
            ModifiedBy         = @UserId,
            ModifiedOn         = GETUTCDATE()
        WHERE Id = @ApplicationId AND UserId = @UserId AND StatusId = 1 AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSellerApplication', @ApplicationId, 'UPDATE',
                '{"Action":"Updated"}', @UserId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_UpdateApplication', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────────
-- 5. Recreate: proc_Marketplace_GetApplicationByUserId
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Marketplace_GetApplicationByUserId
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            a.Id,
            a.UserId,
            a.BusinessName,
            a.BusinessEmail,
            a.Phone,
            a.Description,
            a.RegistrationNumber,
            a.VatNumber,
            a.CategoryIds,
            a.TsAndCsAccepted,
            ast.Name AS StatusName,
            a.ReviewNotes,
            a.ReviewedBy,
            a.ReviewedOn,
            a.CreatedOn,
            a.ModifiedOn,
            a.Website
        FROM t.tblSellerApplication a
        INNER JOIN m.tblApplicationStatus ast ON ast.Id = a.StatusId
        WHERE a.UserId = @UserId AND a.IsDeleted = 0
        ORDER BY a.CreatedOn DESC
        OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_GetApplicationByUserId', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────────
-- 6. Recreate: proc_Admin_ReviewApplication
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Admin_ReviewApplication
    @ApplicationId INT,
    @Decision      NVARCHAR(10),   -- 'Approve' or 'Reject'
    @ReviewNotes   NVARCHAR(1000) = NULL,
    @AdminId       INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @AppStatus TINYINT, @UserId INT, @BusinessName NVARCHAR(300),
                @BusinessEmail NVARCHAR(256), @Phone NVARCHAR(30),
                @RegNo NVARCHAR(50), @Vat NVARCHAR(50), @BankRef NVARCHAR(200),
                @Description NVARCHAR(MAX), @Website NVARCHAR(500);

        SELECT
            @AppStatus    = a.StatusId,
            @UserId       = a.UserId,
            @BusinessName = a.BusinessName,
            @BusinessEmail= a.BusinessEmail,
            @Phone        = a.Phone,
            @RegNo        = a.RegistrationNumber,
            @Vat          = a.VatNumber,
            @BankRef      = a.BankDetailsRef,
            @Description  = a.Description,
            @Website      = a.Website
        FROM t.tblSellerApplication a
        WHERE a.Id = @ApplicationId AND a.IsDeleted = 0;

        IF @UserId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Application not found.', 16, 1);
            RETURN;
        END

        IF @AppStatus NOT IN (2, 3)   -- Must be Submitted or UnderReview
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Application is not in a reviewable state.', 16, 1);
            RETURN;
        END

        DECLARE @NewStatusId TINYINT =
            CASE UPPER(@Decision)
                WHEN 'APPROVE' THEN 4
                WHEN 'REJECT'  THEN 5
                ELSE NULL
            END;

        IF @NewStatusId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Decision must be Approve or Reject.', 16, 1);
            RETURN;
        END

        -- Update application
        UPDATE t.tblSellerApplication
        SET StatusId   = @NewStatusId,
            ReviewNotes= @ReviewNotes,
            ReviewedBy = @AdminId,
            ReviewedOn = GETUTCDATE(),
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @ApplicationId;

        -- On Approve: create t.tblSeller record and update t.tblUser
        IF @NewStatusId = 4
        BEGIN
            DECLARE @NewSellerId INT;

            IF NOT EXISTS (SELECT 1 FROM t.tblSeller WHERE UserId = @UserId AND IsDeleted = 0)
            BEGIN
                INSERT INTO t.tblSeller
                    (UserId, BusinessName, BusinessEmail, ContactEmail, Phone,
                     Description, RegistrationNumber, VatNumber, BankDetailsRef,
                     StatusId, CommissionRate, ApprovedOn,
                     RecordStatusId, CreatedBy, CreatedOn, IsDeleted, Website)
                VALUES
                    (@UserId, @BusinessName, @BusinessEmail, @BusinessEmail, @Phone,
                     @Description, @RegNo, @Vat, @BankRef,
                     2, 10.00, GETUTCDATE(),
                     1, @AdminId, GETUTCDATE(), 0, @Website);

                SET @NewSellerId = SCOPE_IDENTITY();
            END
            ELSE
            BEGIN
                SELECT @NewSellerId = Id FROM t.tblSeller WHERE UserId = @UserId AND IsDeleted = 0;
                UPDATE t.tblSeller
                SET StatusId   = 2,
                    ApprovedOn = GETUTCDATE(),
                    Website    = @Website,
                    ModifiedBy = @AdminId,
                    ModifiedOn = GETUTCDATE()
                WHERE Id = @NewSellerId;
            END

            UPDATE t.tblUser
            SET IsSeller = 1, SellerId = @NewSellerId
            WHERE Id = @UserId;
        END

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSellerApplication', @ApplicationId, 'UPDATE',
                CONCAT('{"Decision":"', @Decision, '","StatusId":', @NewStatusId, '}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_ReviewApplication', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────────
-- 7. Recreate: proc_Admin_GetSellerApplications
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Admin_GetSellerApplications
    @StatusFilter NVARCHAR(50) = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            a.Id,
            a.UserId,
            a.BusinessName,
            a.BusinessEmail,
            a.Phone,
            ast.Name AS StatusName,
            a.TsAndCsAccepted,
            a.ReviewNotes,
            a.ReviewedOn,
            a.CreatedOn,
            a.ModifiedOn,
            a.Website,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblSellerApplication a
        INNER JOIN m.tblApplicationStatus ast ON ast.Id = a.StatusId
        WHERE a.IsDeleted = 0
          AND (@StatusFilter IS NULL OR ast.Name = @StatusFilter)
        ORDER BY a.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetSellerApplications', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- ─────────────────────────────────────────────────────────
-- 8. Recreate: proc_Admin_GetSellers
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
            s.Description,
            s.BankDetailsRef,
            s.ApprovedOn,
            s.SuspendedOn,
            s.CommissionTierId,
            s.CreatedOn,
            s.ModifiedOn,
            s.Website,
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
-- 9. Recreate: proc_Admin_GetSellerById
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
            s.Website,
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
-- 10. Recreate: proc_Marketplace_GetSellerByUserId
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
            s.Website,
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
-- 11. Create new: proc_Marketplace_CheckSellerUnique
-- ─────────────────────────────────────────────────────────
CREATE PROCEDURE proc_Marketplace_CheckSellerUnique
    @BusinessName  NVARCHAR(300),
    @Email         NVARCHAR(256),
    @Phone         NVARCHAR(30),
    @Website       NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SET @BusinessName = LTRIM(RTRIM(@BusinessName));
    SET @Email = LTRIM(RTRIM(@Email));
    SET @Phone = LTRIM(RTRIM(@Phone));
    SET @Website = LTRIM(RTRIM(NULLIF(@Website, '')));

    -- 1. Check BusinessName (case-insensitive by default under standard SQL Server collation)
    IF EXISTS (
        SELECT 1 FROM t.tblSellerApplication
        WHERE LTRIM(RTRIM(BusinessName)) = @BusinessName AND StatusId IN (1, 2, 3, 4) AND IsDeleted = 0
    ) OR EXISTS (
        SELECT 1 FROM t.tblSeller
        WHERE LTRIM(RTRIM(BusinessName)) = @BusinessName AND IsDeleted = 0
    )
    BEGIN
        SELECT 'BusinessName' AS ConflictType;
        RETURN;
    END

    -- 2. Check Email
    IF EXISTS (
        SELECT 1 FROM t.tblSellerApplication
        WHERE LTRIM(RTRIM(BusinessEmail)) = @Email AND StatusId IN (1, 2, 3, 4) AND IsDeleted = 0
    ) OR EXISTS (
        SELECT 1 FROM t.tblSeller
        WHERE (LTRIM(RTRIM(BusinessEmail)) = @Email OR LTRIM(RTRIM(ContactEmail)) = @Email) AND IsDeleted = 0
    )
    BEGIN
        SELECT 'Email' AS ConflictType;
        RETURN;
    END

    -- 3. Check Phone
    IF EXISTS (
        SELECT 1 FROM t.tblSellerApplication
        WHERE LTRIM(RTRIM(Phone)) = @Phone AND StatusId IN (1, 2, 3, 4) AND IsDeleted = 0
    ) OR EXISTS (
        SELECT 1 FROM t.tblSeller
        WHERE LTRIM(RTRIM(Phone)) = @Phone AND IsDeleted = 0
    )
    BEGIN
        SELECT 'Phone' AS ConflictType;
        RETURN;
    END

    -- 4. Check Website (only if supplied)
    IF @Website IS NOT NULL
    BEGIN
        IF EXISTS (
            SELECT 1 FROM t.tblSellerApplication
            WHERE LTRIM(RTRIM(Website)) = @Website AND StatusId IN (1, 2, 3, 4) AND IsDeleted = 0
        ) OR EXISTS (
            SELECT 1 FROM t.tblSeller
            WHERE LTRIM(RTRIM(Website)) = @Website AND IsDeleted = 0
        )
        BEGIN
            SELECT 'Website' AS ConflictType;
            RETURN;
        END
    END

    -- No conflict found
    SELECT CAST(NULL AS NVARCHAR(50)) AS ConflictType;
END
GO

-- ─────────────────────────────────────────────────────────
-- 12. Record migration in t.tblMigration
-- ─────────────────────────────────────────────────────────
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V105')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V105', 'AddWebsiteToSellerAndValidation');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
