-- V079_AddSuperAdminAllPermissions.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Assign all module rights to admin@tescoclone.com (SuperAdmin user).
-- Dependencies: V078

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    DECLARE @AdminUserId INT;
    SELECT @AdminUserId = Id FROM t.tblUser WHERE Email = 'admin@tescoclone.com' AND IsDeleted = 0;

    IF @AdminUserId IS NOT NULL
    BEGIN
        BEGIN TRANSACTION;

        -- Insert or update permissions for all modules
        MERGE INTO t.tblAdminPermission AS target
        USING (
            SELECT @AdminUserId AS UserId, 'Products' AS ModuleName, 1 AS CanView, 1 AS CanAdd, 1 AS CanEdit, 1 AS CanDelete
            UNION ALL SELECT @AdminUserId, 'Categories', 1, 1, 1, 1
            UNION ALL SELECT @AdminUserId, 'Inventory', 1, 1, 1, 1
            UNION ALL SELECT @AdminUserId, 'Orders', 1, 1, 1, 1
            UNION ALL SELECT @AdminUserId, 'Promotions', 1, 1, 1, 1
            UNION ALL SELECT @AdminUserId, 'CMS', 1, 1, 1, 1
            UNION ALL SELECT @AdminUserId, 'Users', 1, 1, 1, 1
            UNION ALL SELECT @AdminUserId, 'Analytics', 1, 1, 1, 1
            UNION ALL SELECT @AdminUserId, 'Audit', 1, 1, 1, 1
        ) AS source
        ON (target.UserId = source.UserId AND target.ModuleName = source.ModuleName)
        WHEN MATCHED THEN
            UPDATE SET 
                CanView = source.CanView,
                CanAdd = source.CanAdd,
                CanEdit = source.CanEdit,
                CanDelete = source.CanDelete,
                IsDeleted = 0,
                ModifiedOn = GETUTCDATE(),
                ModifiedBy = 1
        WHEN NOT MATCHED THEN
            INSERT (UserId, ModuleName, CanView, CanAdd, CanEdit, CanDelete, IsDeleted, CreatedBy)
            VALUES (source.UserId, source.ModuleName, source.CanView, source.CanAdd, source.CanEdit, source.CanDelete, 0, 1);

        IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V079')
            INSERT INTO t.tblMigration (Version, Description)
            VALUES ('V079', 'AddSuperAdminAllPermissions');

        COMMIT TRANSACTION;
        PRINT 'All module rights assigned successfully to admin@tescoclone.com (UserId: ' + CAST(@AdminUserId AS VARCHAR) + ')';
    END
    ELSE
    BEGIN
        PRINT 'User admin@tescoclone.com not found.';
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V079_AddSuperAdminAllPermissions', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO
