-- V103_FixSellerRoleAssignment.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Assign/revoke Seller role (RoleId = 3) on application review, approval, and suspension.
-- Dependencies: V098, V099

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_ReviewApplication', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_ReviewApplication;
    IF OBJECT_ID('proc_Admin_ApproveSeller',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_ApproveSeller;
    IF OBJECT_ID('proc_Admin_SuspendSeller',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_SuspendSeller;
    IF OBJECT_ID('proc_Admin_GetSellerApplications', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellerApplications;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_ReviewApplication (Approve or Reject)
-- Creates t.tblSeller record and assigns Seller role on Approve
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

            -- Assign Seller role (RoleId = 3)
            IF NOT EXISTS (SELECT 1 FROM t.tblUserRole WHERE UserId = @UserId AND RoleId = 3 AND IsDeleted = 0)
            BEGIN
                INSERT INTO t.tblUserRole (UserId, RoleId, CreatedBy, CreatedOn)
                VALUES (@UserId, 3, @AdminId, GETUTCDATE());
            END
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
-- proc_Admin_ApproveSeller
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
            ApprovedOn = GETUTCDATE(),
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @SellerId AND IsDeleted = 0;

        DECLARE @UserId INT;
        SELECT @UserId = UserId FROM t.tblSeller WHERE Id = @SellerId;

        -- Mark the linked user as a seller
        UPDATE t.tblUser
        SET IsSeller = 1, SellerId = @SellerId
        WHERE Id = @UserId;

        -- Assign Seller role (RoleId = 3)
        IF @UserId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM t.tblUserRole WHERE UserId = @UserId AND RoleId = 3 AND IsDeleted = 0)
        BEGIN
            INSERT INTO t.tblUserRole (UserId, RoleId, CreatedBy, CreatedOn)
            VALUES (@UserId, 3, @AdminId, GETUTCDATE());
        END

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

-- =========================================================
-- proc_Admin_SuspendSeller
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
            SuspendReason = @Reason,
            SuspendedOn   = GETUTCDATE(),
            ModifiedBy    = @AdminId,
            ModifiedOn    = GETUTCDATE()
        WHERE Id = @SellerId AND IsDeleted = 0;

        DECLARE @UserId INT;
        SELECT @UserId = UserId FROM t.tblSeller WHERE Id = @SellerId;

        -- Revoke seller status on the user
        UPDATE t.tblUser
        SET IsSeller = 0
        WHERE Id = @UserId;

        -- Revoke Seller role (RoleId = 3) by soft-deleting
        IF @UserId IS NOT NULL
        BEGIN
            UPDATE t.tblUserRole
            SET IsDeleted = 1, ModifiedBy = @AdminId, ModifiedOn = GETUTCDATE()
            WHERE UserId = @UserId AND RoleId = 3 AND IsDeleted = 0;
        END

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
            a.RegistrationNumber,
            a.VatNumber,
            a.Description,
            a.BankDetailsRef,
            a.CategoryIds,
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
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V103')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V103', 'FixSellerRoleAssignment');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
