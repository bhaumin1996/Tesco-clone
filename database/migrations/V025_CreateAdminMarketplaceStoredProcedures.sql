-- V025_CreateAdminMarketplaceStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Admin stored procedures for seller and dispute management
-- Dependencies: V001-V012

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetSellers',     'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellers;
    IF OBJECT_ID('proc_Admin_GetSellerById',  'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetSellerById;
    IF OBJECT_ID('proc_Admin_ApproveSeller',  'P') IS NOT NULL DROP PROCEDURE proc_Admin_ApproveSeller;
    IF OBJECT_ID('proc_Admin_SuspendSeller',  'P') IS NOT NULL DROP PROCEDURE proc_Admin_SuspendSeller;
    IF OBJECT_ID('proc_Admin_GetDisputes',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetDisputes;
    IF OBJECT_ID('proc_Admin_ResolveDispute', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_ResolveDispute;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetSellers
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
            s.ContactEmail,
            ss.Name AS StatusName,
            s.CommissionRate,
            s.CreatedOn,
            s.ModifiedOn,
            COUNT(1) OVER () AS TotalCount
        FROM m.tblSeller s
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
-- proc_Admin_GetSellerById
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
            s.ContactEmail,
            ss.Name AS StatusName,
            s.CommissionRate,
            s.CreatedOn,
            s.ModifiedOn
        FROM m.tblSeller s
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

        UPDATE m.tblSeller
        SET StatusId   = 2, -- Approved
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

        UPDATE m.tblSeller
        SET StatusId   = 3, -- Suspended
            SuspendReason = @Reason,
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
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
-- proc_Admin_GetDisputes
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
            d.Subject,
            d.Description,
            ds.Name AS StatusName,
            d.Resolution,
            d.CreatedOn,
            d.ResolvedOn,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblDisputeTicket d
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
-- proc_Admin_ResolveDispute
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

        UPDATE t.tblDisputeTicket
        SET StatusId   = 3, -- Resolved
            Resolution = @Resolution,
            ResolvedOn = GETUTCDATE(),
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @DisputeId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblDisputeTicket', @DisputeId, 'UPDATE',
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
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V025')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V025', 'CreateAdminMarketplaceStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
