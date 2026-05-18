-- V078_CreateAdminPermissionsTable.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Create tblAdminPermission table and related stored procedures for administrative rights/permissions.

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Create t.tblAdminPermission table
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblAdminPermission')
    BEGIN
        CREATE TABLE t.tblAdminPermission (
            Id           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId       INT NOT NULL,
            ModuleName   NVARCHAR(100) NOT NULL,
            CanView      BIT NOT NULL DEFAULT 0,
            CanAdd       BIT NOT NULL DEFAULT 0,
            CanEdit      BIT NOT NULL DEFAULT 0,
            CanDelete    BIT NOT NULL DEFAULT 0,
            CreatedBy    INT NOT NULL DEFAULT 1,
            CreatedOn    DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy   INT NULL,
            ModifiedOn   DATETIME2 NULL,
            IsDeleted    BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblAdminPermission_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id)
        );
        CREATE UNIQUE INDEX IX_tblAdminPermission_UserId_ModuleName ON t.tblAdminPermission (UserId, ModuleName) WHERE IsDeleted = 0;
        PRINT 'Table [t].[tblAdminPermission] created.';
    END

    -- 2. Create proc_Admin_GetUserPermissions stored procedure
    EXEC('
    CREATE OR ALTER PROCEDURE proc_Admin_GetUserPermissions
        @UserId INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT 
            Id,
            UserId,
            ModuleName,
            CanView,
            CanAdd,
            CanEdit,
            CanDelete
        FROM t.tblAdminPermission
        WHERE UserId = @UserId AND IsDeleted = 0;
    END
    ');

    -- 3. Create proc_Admin_SaveUserPermissions stored procedure
    EXEC('
    CREATE OR ALTER PROCEDURE proc_Admin_SaveUserPermissions
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
                    JSON_VALUE(value, ''$.moduleName'') AS ModuleName,
                    ISNULL(CAST(JSON_VALUE(value, ''$.canView'') AS BIT), 0) AS CanView,
                    ISNULL(CAST(JSON_VALUE(value, ''$.canAdd'') AS BIT), 0) AS CanAdd,
                    ISNULL(CAST(JSON_VALUE(value, ''$.canEdit'') AS BIT), 0) AS CanEdit,
                    ISNULL(CAST(JSON_VALUE(value, ''$.canDelete'') AS BIT), 0) AS CanDelete
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

            -- Soft-delete any permissions that weren''t in the payload for this user
            UPDATE target
            SET target.IsDeleted = 1,
                target.ModifiedBy = @AdminId,
                target.ModifiedOn = GETUTCDATE()
            FROM t.tblAdminPermission target
            WHERE target.UserId = @UserId 
              AND target.IsDeleted = 0
              AND target.ModuleName NOT IN (
                  SELECT JSON_VALUE(value, ''$.moduleName'')
                  FROM OPENJSON(@PermissionsJson)
              );

            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
            INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
            VALUES (''Error'', ''proc_Admin_SaveUserPermissions'', ERROR_MESSAGE(), GETUTCDATE());
            THROW;
        END CATCH
    END
    ');

    -- Record migration
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V078')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V078', 'CreateAdminPermissions');

    COMMIT TRANSACTION;
    PRINT 'Migration V078 applied successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
GO
