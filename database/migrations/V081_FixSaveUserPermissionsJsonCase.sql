-- V081_FixSaveUserPermissionsJsonCase.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Support both PascalCase and camelCase in JSON deserialization for proc_Admin_SaveUserPermissions.
-- Dependencies: V080

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

ALTER PROCEDURE proc_Admin_SaveUserPermissions
    @UserId          INT,
    @AdminId         INT,
    @PermissionsJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Merge into tblAdminPermission
        MERGE t.tblAdminPermission AS target
        USING (
            SELECT 
                @UserId AS UserId,
                COALESCE(JSON_VALUE(value, '$.ModuleName'), JSON_VALUE(value, '$.moduleName')) AS ModuleName,
                ISNULL(CAST(COALESCE(JSON_VALUE(value, '$.CanView'), JSON_VALUE(value, '$.canView')) AS BIT), 0) AS CanView,
                ISNULL(CAST(COALESCE(JSON_VALUE(value, '$.CanAdd'), JSON_VALUE(value, '$.canAdd')) AS BIT), 0) AS CanAdd,
                ISNULL(CAST(COALESCE(JSON_VALUE(value, '$.CanEdit'), JSON_VALUE(value, '$.canEdit')) AS BIT), 0) AS CanEdit,
                ISNULL(CAST(COALESCE(JSON_VALUE(value, '$.CanDelete'), JSON_VALUE(value, '$.canDelete')) AS BIT), 0) AS CanDelete
            FROM OPENJSON(@PermissionsJson)
        ) AS source
        ON (target.UserId = source.UserId AND target.ModuleName = source.ModuleName AND target.IsDeleted = 0)
        WHEN MATCHED THEN
            UPDATE SET 
                target.CanView = source.CanView,
                target.CanAdd = source.CanAdd,
                target.CanEdit = source.CanEdit,
                target.CanDelete = source.CanDelete,
                target.ModifiedBy = @AdminId,
                target.ModifiedOn = GETUTCDATE()
        WHEN NOT MATCHED THEN
            INSERT (UserId, ModuleName, CanView, CanAdd, CanEdit, CanDelete, CreatedBy)
            VALUES (source.UserId, source.ModuleName, source.CanView, source.CanAdd, source.CanEdit, source.CanDelete, @AdminId);

        -- Soft-delete any permissions that weren't in the payload for this user
        UPDATE target
        SET target.IsDeleted = 1,
            target.ModifiedBy = @AdminId,
            target.ModifiedOn = GETUTCDATE()
        FROM t.tblAdminPermission target
        WHERE target.UserId = @UserId 
          AND target.IsDeleted = 0
          AND target.ModuleName NOT IN (
              SELECT COALESCE(JSON_VALUE(value, '$.ModuleName'), JSON_VALUE(value, '$.moduleName'))
              FROM OPENJSON(@PermissionsJson)
          );

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SaveUserPermissions', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V081')
    INSERT INTO t.tblMigration (Version, Description)
    VALUES ('V081', 'FixSaveUserPermissionsJsonCase');
GO
