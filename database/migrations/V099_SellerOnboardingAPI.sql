-- V099_SellerOnboardingAPI.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Seller onboarding: application submission, document tracking,
--              status workflow (Draft → Submitted → UnderReview → Approved / Rejected).
--              Adds t.tblSellerApplication and t.tblSellerDocument tables.
--              Creates proc_Marketplace_ApplyAsSeller, proc_Marketplace_SubmitApplication,
--              proc_Marketplace_GetApplicationByUserId, proc_Admin_ReviewApplication.
-- Dependencies: V001-V012, V028, V098

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- PART 1: Reference table — m.tblApplicationStatus
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblApplicationStatus')
    BEGIN
        CREATE TABLE m.tblApplicationStatus (
            Id   TINYINT NOT NULL PRIMARY KEY,
            Name NVARCHAR(50) NOT NULL
        );
        INSERT INTO m.tblApplicationStatus (Id, Name)
        VALUES (1,'Draft'),(2,'Submitted'),(3,'UnderReview'),(4,'Approved'),(5,'Rejected');
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V099_Part1')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V099_Part1', 'SellerOnboarding_StatusTable');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V099_Part1', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 2: t.tblSellerApplication and t.tblSellerDocument
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSellerApplication')
    BEGIN
        CREATE TABLE t.tblSellerApplication (
            Id                 INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId             INT NOT NULL,
            BusinessName       NVARCHAR(300) NOT NULL,
            BusinessEmail      NVARCHAR(256) NOT NULL,
            Phone              NVARCHAR(30) NULL,
            Description        NVARCHAR(MAX) NULL,
            RegistrationNumber NVARCHAR(50) NULL,
            VatNumber          NVARCHAR(50) NULL,
            BankDetailsRef     NVARCHAR(200) NULL,
            CategoryIds        NVARCHAR(500) NULL,   -- comma-separated category IDs
            TsAndCsAccepted    BIT NOT NULL DEFAULT 0,
            StatusId           TINYINT NOT NULL DEFAULT 1,
            ReviewNotes        NVARCHAR(1000) NULL,
            ReviewedBy         INT NULL,
            ReviewedOn         DATETIME2 NULL,
            RecordStatusId     TINYINT NOT NULL DEFAULT 1,
            CreatedBy          INT NOT NULL,
            CreatedOn          DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy         INT NULL,
            ModifiedOn         DATETIME2 NULL,
            IsDeleted          BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSellerApplication_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id),
            CONSTRAINT FK_tblSellerApplication_tblApplicationStatus FOREIGN KEY (StatusId) REFERENCES m.tblApplicationStatus (Id),
            CONSTRAINT FK_tblSellerApplication_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblSellerApplication_UserId ON t.tblSellerApplication (UserId);
        CREATE INDEX IX_tblSellerApplication_StatusId ON t.tblSellerApplication (StatusId);
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSellerDocument')
    BEGIN
        CREATE TABLE t.tblSellerDocument (
            Id            INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            ApplicationId INT NOT NULL,
            DocumentType  NVARCHAR(100) NOT NULL,   -- CompaniesHouseNumber, VatCertificate, PublicLiabilityInsurance, Other
            FileName      NVARCHAR(300) NOT NULL,
            FilePath      NVARCHAR(500) NOT NULL,
            ContentType   NVARCHAR(100) NULL,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy     INT NOT NULL,
            CreatedOn     DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            IsDeleted     BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSellerDocument_tblSellerApplication FOREIGN KEY (ApplicationId) REFERENCES t.tblSellerApplication (Id),
            CONSTRAINT FK_tblSellerDocument_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblSellerDocument_ApplicationId ON t.tblSellerDocument (ApplicationId);
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V099_Part2')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V099_Part2', 'SellerOnboarding_ApplicationTables');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V099_Part2', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 3: Drop/create stored procedures
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('proc_Marketplace_ApplyAsSeller',         'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_ApplyAsSeller;
    IF OBJECT_ID('proc_Marketplace_UpdateApplication',     'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_UpdateApplication;
    IF OBJECT_ID('proc_Marketplace_SubmitApplication',     'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_SubmitApplication;
    IF OBJECT_ID('proc_Marketplace_GetApplicationByUserId','P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetApplicationByUserId;
    IF OBJECT_ID('proc_Admin_GetSellerApplications',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellerApplications;
    IF OBJECT_ID('proc_Admin_ReviewApplication',           'P') IS NOT NULL DROP PROCEDURE proc_Admin_ReviewApplication;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Marketplace_ApplyAsSeller (step 1: create draft)
-- =========================================================
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
    @TsAndCsAccepted   BIT = 0
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
             TsAndCsAccepted, StatusId, RecordStatusId, CreatedBy, CreatedOn, IsDeleted)
        VALUES
            (@UserId, @BusinessName, @BusinessEmail, @Phone, @Description,
             @RegistrationNumber, @VatNumber, @BankDetailsRef, @CategoryIds,
             @TsAndCsAccepted, 1, 1, @UserId, GETUTCDATE(), 0);

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

-- =========================================================
-- proc_Marketplace_UpdateApplication (update draft before submit)
-- =========================================================
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
    @TsAndCsAccepted   BIT = 0
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

-- =========================================================
-- proc_Marketplace_SubmitApplication (move Draft → Submitted)
-- =========================================================
CREATE PROCEDURE proc_Marketplace_SubmitApplication
    @ApplicationId INT,
    @UserId        INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Status TINYINT, @TsAccepted BIT;
        SELECT @Status = StatusId, @TsAccepted = TsAndCsAccepted
        FROM t.tblSellerApplication
        WHERE Id = @ApplicationId AND UserId = @UserId AND IsDeleted = 0;

        IF @Status IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Application not found.', 16, 1);
            RETURN;
        END

        IF @Status <> 1
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Only Draft applications can be submitted.', 16, 1);
            RETURN;
        END

        IF @TsAccepted = 0
        BEGIN
            ROLLBACK TRANSACTION;
            RAISERROR('Terms and conditions must be accepted before submitting.', 16, 1);
            RETURN;
        END

        UPDATE t.tblSellerApplication
        SET StatusId   = 2,
            ModifiedBy = @UserId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @ApplicationId AND UserId = @UserId;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSellerApplication', @ApplicationId, 'UPDATE',
                '{"StatusId":2,"Action":"Submitted"}', @UserId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_SubmitApplication', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Marketplace_GetApplicationByUserId
-- =========================================================
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
            a.ModifiedOn
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

-- =========================================================
-- proc_Admin_GetSellerApplications
-- =========================================================
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

-- =========================================================
-- proc_Admin_ReviewApplication (Approve or Reject)
-- Creates t.tblSeller record on Approve
-- =========================================================
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
                @Description NVARCHAR(MAX);

        SELECT
            @AppStatus    = a.StatusId,
            @UserId       = a.UserId,
            @BusinessName = a.BusinessName,
            @BusinessEmail= a.BusinessEmail,
            @Phone        = a.Phone,
            @RegNo        = a.RegistrationNumber,
            @Vat          = a.VatNumber,
            @BankRef      = a.BankDetailsRef,
            @Description  = a.Description
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
                     RecordStatusId, CreatedBy, CreatedOn, IsDeleted)
                VALUES
                    (@UserId, @BusinessName, @BusinessEmail, @BusinessEmail, @Phone,
                     @Description, @RegNo, @Vat, @BankRef,
                     2, 10.00, GETUTCDATE(),
                     1, @AdminId, GETUTCDATE(), 0);

                SET @NewSellerId = SCOPE_IDENTITY();
            END
            ELSE
            BEGIN
                SELECT @NewSellerId = Id FROM t.tblSeller WHERE UserId = @UserId AND IsDeleted = 0;
                UPDATE t.tblSeller
                SET StatusId   = 2,
                    ApprovedOn = GETUTCDATE(),
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

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V099')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V099', 'SellerOnboardingAPI');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
