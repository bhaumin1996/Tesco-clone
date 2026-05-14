-- V023_CreateAdminAuditLogStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Admin stored procedures for audit log and application log review
-- Dependencies: V001-V003

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetAuditLogs',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetAuditLogs;
    IF OBJECT_ID('proc_Admin_GetApplicationLogs', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetApplicationLogs;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetAuditLogs
-- =========================================================
CREATE PROCEDURE proc_Admin_GetAuditLogs
    @TableName    NVARCHAR(128) = NULL,
    @RecordId     INT = NULL,
    @ChangedBy    INT = NULL,
    @From         DATETIME2 = NULL,
    @To           DATETIME2 = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            al.Id,
            al.TableName,
            al.RecordId,
            al.Action,
            al.OldValues,
            al.NewValues,
            al.ChangedBy,
            al.ChangedOn,
            al.CorrelationId,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblAuditLog al
        WHERE (@TableName   IS NULL OR al.TableName = @TableName)
          AND (@RecordId    IS NULL OR al.RecordId  = @RecordId)
          AND (@ChangedBy   IS NULL OR al.ChangedBy = @ChangedBy)
          AND (@From        IS NULL OR al.ChangedOn >= @From)
          AND (@To          IS NULL OR al.ChangedOn <= @To)
        ORDER BY al.ChangedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetAuditLogs', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetApplicationLogs
-- =========================================================
CREATE PROCEDURE proc_Admin_GetApplicationLogs
    @Level         NVARCHAR(20)  = NULL,
    @Source        NVARCHAR(256) = NULL,
    @CorrelationId NVARCHAR(64)  = NULL,
    @From          DATETIME2 = NULL,
    @To            DATETIME2 = NULL,
    @PageNumber    INT = 1,
    @PageSize      INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            l.Id,
            l.Level,
            l.Source,
            l.Message,
            l.Exception,
            l.UserId,
            l.LoggedOn,
            l.CorrelationId,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblLog l
        WHERE (@Level         IS NULL OR l.Level         = @Level)
          AND (@Source        IS NULL OR l.Source        LIKE '%' + @Source + '%')
          AND (@CorrelationId IS NULL OR l.CorrelationId = @CorrelationId)
          AND (@From          IS NULL OR l.LoggedOn      >= @From)
          AND (@To            IS NULL OR l.LoggedOn      <= @To)
        ORDER BY l.LoggedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetApplicationLogs', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V023')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V023', 'CreateAdminAuditLogStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
