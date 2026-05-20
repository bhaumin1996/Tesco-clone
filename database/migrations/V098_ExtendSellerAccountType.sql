-- V098_ExtendSellerAccountType.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Phase 11 — extend seller account model.
--              Adds IsSeller and SellerId to t.tblUser.
--              Extends t.tblSeller with RegistrationNumber, VatNumber,
--              BankDetailsRef, Phone, Description, ApprovedOn, SuspendedOn.
--              Adds CommissionTierId FK (created in V097) to t.tblSeller.
--              Updates proc_Marketplace_GetSellerByUserId to return full profile.
-- Dependencies: V001-V012, V028, V097

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- PART 1: Extend t.tblUser
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblUser' AND COLUMN_NAME='IsSeller')
        ALTER TABLE t.tblUser ADD IsSeller BIT NOT NULL DEFAULT 0;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblUser' AND COLUMN_NAME='SellerId')
        ALTER TABLE t.tblUser ADD SellerId INT NULL;

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V098_Part1')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V098_Part1', 'ExtendSellerAccountType_UserColumns');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V098_Part1', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 2: Add FK from tblUser.SellerId → t.tblSeller.Id
--         (separate batch — column must exist first)
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE CONSTRAINT_NAME = 'FK_tblUser_tblSeller' AND TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblUser')
    BEGIN
        ALTER TABLE t.tblUser
            ADD CONSTRAINT FK_tblUser_tblSeller
            FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id);
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V098_Part2')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V098_Part2', 'ExtendSellerAccountType_UserFK');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V098_Part2', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 3: Extend t.tblSeller with business detail columns
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='RegistrationNumber')
        ALTER TABLE t.tblSeller ADD RegistrationNumber NVARCHAR(50) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='VatNumber')
        ALTER TABLE t.tblSeller ADD VatNumber NVARCHAR(50) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='BankDetailsRef')
        ALTER TABLE t.tblSeller ADD BankDetailsRef NVARCHAR(200) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='Phone')
        ALTER TABLE t.tblSeller ADD Phone NVARCHAR(30) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='Description')
        ALTER TABLE t.tblSeller ADD Description NVARCHAR(MAX) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='ApprovedOn')
        ALTER TABLE t.tblSeller ADD ApprovedOn DATETIME2 NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='SuspendedOn')
        ALTER TABLE t.tblSeller ADD SuspendedOn DATETIME2 NULL;

    -- CommissionTierId was added by V097 but guard for idempotency
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSeller' AND COLUMN_NAME='CommissionTierId')
        ALTER TABLE t.tblSeller ADD CommissionTierId INT NULL;

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V098_Part3')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V098_Part3', 'ExtendSellerAccountType_SellerColumns');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V098_Part3', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 3b: Back-fill ApprovedOn for existing approved sellers
-- Separate batch required — cannot reference a newly added column
-- in the same batch as the ALTER TABLE that created it.
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE t.tblSeller
    SET ApprovedOn = ModifiedOn
    WHERE StatusId = 2 AND ApprovedOn IS NULL;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V098_Part3b', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 4: Update stored procedures that return seller data
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('proc_Admin_GetSellers',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellers;
    IF OBJECT_ID('proc_Admin_GetSellerById',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellerById;
    IF OBJECT_ID('proc_Admin_ApproveSeller',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_ApproveSeller;
    IF OBJECT_ID('proc_Admin_SuspendSeller',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_SuspendSeller;
    IF OBJECT_ID('proc_Marketplace_GetSellerByUserId', 'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerByUserId;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

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
            s.ApprovedOn,
            s.SuspendedOn,
            s.CommissionTierId,
            s.CreatedOn,
            s.ModifiedOn
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
            ApprovedOn = GETUTCDATE(),
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @SellerId AND IsDeleted = 0;

        -- Mark the linked user as a seller
        UPDATE t.tblUser
        SET IsSeller = 1, SellerId = @SellerId
        WHERE Id = (SELECT UserId FROM t.tblSeller WHERE Id = @SellerId);

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSeller', @SellerId, 'UPDATE',
                '{"StatusId":2,"Action":"Approved"}', @AdminId, GETUTCDATE());

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
            SuspendReason = @Reason,
            SuspendedOn   = GETUTCDATE(),
            ModifiedBy    = @AdminId,
            ModifiedOn    = GETUTCDATE()
        WHERE Id = @SellerId AND IsDeleted = 0;

        -- Revoke seller role on the user
        UPDATE t.tblUser
        SET IsSeller = 0
        WHERE Id = (SELECT UserId FROM t.tblSeller WHERE Id = @SellerId);

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
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V098')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V098', 'ExtendSellerAccountType');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
