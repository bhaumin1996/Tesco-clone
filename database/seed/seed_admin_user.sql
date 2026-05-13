-- seed_admin_user.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Insert the initial SuperAdmin user directly into the database.
--              Password: Admin@1234  (PBKDF2-SHA256, 100 000 iterations, 16-byte salt)
--              Change the password immediately after first login.
-- Dependencies: V001-V019 (all migrations must be applied first)
--
-- How the hash was generated (matches PasswordService.cs):
--   Salt (fixed):  K34VFiiu0qar9xWICc9PPA==
--   Algorithm:     PBKDF2-SHA256, 100 000 iterations, 32-byte output
--   Stored format: <base64-salt>.<base64-hash>

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- ----------------------------------------------------------------
    -- 1. Ensure SuperAdmin role exists (V004 only added Admin/Customer/Seller)
    -- ----------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM m.tblRole WHERE Name = 'SuperAdmin' AND IsDeleted = 0)
    BEGIN
        INSERT INTO m.tblRole (Name, Description, CreatedBy)
        VALUES ('SuperAdmin', 'Super administrator with unrestricted access', 1);
        PRINT 'Role [SuperAdmin] created.';
    END

    -- ----------------------------------------------------------------
    -- 2. Insert admin user if the email is not already present
    -- ----------------------------------------------------------------
    DECLARE @AdminEmail    NVARCHAR(256) = N'admin@tescoclone.com';
    DECLARE @PasswordHash  NVARCHAR(512) = N'K34VFiiu0qar9xWICc9PPA==.oWuA4srw+RTz7WBzI9lwL7S3P1lBRUq0l2CQHa/XW1U=';
    DECLARE @AdminUserId   INT;

    IF NOT EXISTS (SELECT 1 FROM t.tblUser WHERE Email = @AdminEmail AND IsDeleted = 0)
    BEGIN
        INSERT INTO t.tblUser
            (FirstName, LastName, Email, PasswordHash, PhoneNumber, StatusId,
             FailedLoginAttempts, RecordStatusId, CreatedBy)
        VALUES
            (N'Super', N'Admin', @AdminEmail, @PasswordHash, NULL, 1,
             0, 1, 1);

        SET @AdminUserId = SCOPE_IDENTITY();
        PRINT 'Admin user created with Id = ' + CAST(@AdminUserId AS NVARCHAR);
    END
    ELSE
    BEGIN
        SELECT @AdminUserId = Id FROM t.tblUser WHERE Email = @AdminEmail AND IsDeleted = 0;
        PRINT 'Admin user already exists with Id = ' + CAST(@AdminUserId AS NVARCHAR) + '. Skipping insert.';
    END

    -- ----------------------------------------------------------------
    -- 3. Assign Admin and SuperAdmin roles (idempotent)
    -- ----------------------------------------------------------------
    DECLARE @AdminRoleId      INT;
    DECLARE @SuperAdminRoleId INT;

    SELECT @AdminRoleId      = Id FROM m.tblRole WHERE Name = 'Admin'      AND IsDeleted = 0;
    SELECT @SuperAdminRoleId = Id FROM m.tblRole WHERE Name = 'SuperAdmin' AND IsDeleted = 0;

    IF @AdminRoleId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM t.tblUserRole
                       WHERE UserId = @AdminUserId AND RoleId = @AdminRoleId AND IsDeleted = 0)
    BEGIN
        INSERT INTO t.tblUserRole (UserId, RoleId, CreatedBy)
        VALUES (@AdminUserId, @AdminRoleId, 1);
        PRINT 'Role [Admin] assigned.';
    END

    IF @SuperAdminRoleId IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM t.tblUserRole
                       WHERE UserId = @AdminUserId AND RoleId = @SuperAdminRoleId AND IsDeleted = 0)
    BEGIN
        INSERT INTO t.tblUserRole (UserId, RoleId, CreatedBy)
        VALUES (@AdminUserId, @SuperAdminRoleId, 1);
        PRINT 'Role [SuperAdmin] assigned.';
    END

    -- ----------------------------------------------------------------
    -- 4. Audit log entry
    -- ----------------------------------------------------------------
    INSERT INTO t.tblAuditLog
        (TableName, RecordId, Action, OldValues, NewValues, ChangedBy)
    VALUES
        ('t.tblUser',
         @AdminUserId,
         'INSERT',
         NULL,
         N'{"Email":"admin@tescoclone.com","FirstName":"Super","LastName":"Admin","Roles":["Admin","SuperAdmin"]}',
         1);

    COMMIT TRANSACTION;
    PRINT 'seed_admin_user.sql completed successfully.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'seed_admin_user.sql', ERROR_MESSAGE(), GETUTCDATE());

    THROW;
END CATCH
