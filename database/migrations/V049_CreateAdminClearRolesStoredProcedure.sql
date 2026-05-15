-- V049_CreateAdminClearRolesStoredProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Create proc_Admin_ClearRoles to remove all roles for a user.

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF OBJECT_ID('proc_Admin_ClearRoles', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_ClearRoles;
GO

CREATE PROCEDURE proc_Admin_ClearRoles
    @UserId  INT,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblUserRole
        SET IsDeleted      = 1,
            RecordStatusId = 3,
            ModifiedBy     = @AdminId,
            ModifiedOn     = GETUTCDATE()
        WHERE UserId    = @UserId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblUserRole', @UserId, 'DELETE', '{"Action":"ClearAllRoles"}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_ClearRoles', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V049')
    INSERT INTO t.tblMigration (Version, Description) VALUES ('V049', 'CreateAdminClearRolesStoredProcedure');
GO
