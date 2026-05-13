-- V019_CreateAdminAuthStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Admin 2FA table and stored procedures for admin auth and user management
-- Dependencies: V001-V005

BEGIN TRY
    BEGIN TRANSACTION;

    -- Admin 2FA codes table
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.TABLES
        WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblAdminTwoFactorCode'
    )
    BEGIN
        CREATE TABLE t.tblAdminTwoFactorCode (
            Id           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId       INT NOT NULL,
            CodeHash     NVARCHAR(512) NOT NULL,
            ExpiresAt    DATETIME2 NOT NULL,
            IsConsumed   BIT NOT NULL DEFAULT 0,
            ConsumedOn   DATETIME2 NULL,
            CreatedOn    DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            CONSTRAINT FK_tblAdminTwoFactorCode_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id)
        );
        CREATE INDEX IX_tblAdminTwoFactorCode_UserId ON t.tblAdminTwoFactorCode (UserId);
    END

    -- Drop existing admin procs idempotently
    IF OBJECT_ID('proc_Admin_GetUsers',               'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetUsers;
    IF OBJECT_ID('proc_Admin_GetUserDetail',           'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetUserDetail;
    IF OBJECT_ID('proc_Admin_LockUser',                'P') IS NOT NULL DROP PROCEDURE proc_Admin_LockUser;
    IF OBJECT_ID('proc_Admin_UnlockUser',              'P') IS NOT NULL DROP PROCEDURE proc_Admin_UnlockUser;
    IF OBJECT_ID('proc_Admin_AssignRole',              'P') IS NOT NULL DROP PROCEDURE proc_Admin_AssignRole;
    IF OBJECT_ID('proc_Admin_RemoveRole',              'P') IS NOT NULL DROP PROCEDURE proc_Admin_RemoveRole;
    IF OBJECT_ID('proc_Admin_SaveTwoFactorCode',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_SaveTwoFactorCode;
    IF OBJECT_ID('proc_Admin_ValidateTwoFactorCode',   'P') IS NOT NULL DROP PROCEDURE proc_Admin_ValidateTwoFactorCode;
    IF OBJECT_ID('proc_Admin_ConsumeTwoFactorCode',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_ConsumeTwoFactorCode;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetUsers
-- =========================================================
CREATE PROCEDURE proc_Admin_GetUsers
    @Search     NVARCHAR(256) = NULL,
    @PageNumber INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            u.Id,
            u.FirstName,
            u.LastName,
            u.Email,
            u.PhoneNumber,
            us.Name AS StatusName,
            u.FailedLoginAttempts,
            u.LockedUntil,
            u.CreatedOn,
            u.ModifiedOn,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblUser u
        INNER JOIN m.tblUserStatus us ON us.Id = u.StatusId
        WHERE u.IsDeleted = 0
          AND (@Search IS NULL
               OR u.Email LIKE '%' + @Search + '%'
               OR u.FirstName LIKE '%' + @Search + '%'
               OR u.LastName LIKE '%' + @Search + '%')
        ORDER BY u.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetUsers', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetUserDetail
-- =========================================================
CREATE PROCEDURE proc_Admin_GetUserDetail
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            u.Id,
            u.FirstName,
            u.LastName,
            u.Email,
            u.PhoneNumber,
            us.Name AS StatusName,
            u.FailedLoginAttempts,
            u.LockedUntil,
            u.CreatedOn,
            u.ModifiedOn
        FROM t.tblUser u
        INNER JOIN m.tblUserStatus us ON us.Id = u.StatusId
        WHERE u.Id = @UserId
          AND u.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetUserDetail', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_LockUser
-- =========================================================
CREATE PROCEDURE proc_Admin_LockUser
    @UserId  INT,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblUser
        SET StatusId   = 2, -- Locked
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @UserId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblUser', @UserId, 'UPDATE',
                '{"StatusId":2,"Action":"AdminLock"}',
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_LockUser', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UnlockUser
-- =========================================================
CREATE PROCEDURE proc_Admin_UnlockUser
    @UserId  INT,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblUser
        SET StatusId            = 1, -- Active
            FailedLoginAttempts = 0,
            LockedUntil         = NULL,
            ModifiedBy          = @AdminId,
            ModifiedOn          = GETUTCDATE()
        WHERE Id = @UserId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblUser', @UserId, 'UPDATE',
                '{"StatusId":1,"Action":"AdminUnlock"}',
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UnlockUser', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_AssignRole
-- =========================================================
CREATE PROCEDURE proc_Admin_AssignRole
    @UserId  INT,
    @RoleId  INT,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM t.tblUserRole WHERE UserId = @UserId AND RoleId = @RoleId AND IsDeleted = 0)
        BEGIN
            INSERT INTO t.tblUserRole (UserId, RoleId, CreatedBy, CreatedOn)
            VALUES (@UserId, @RoleId, @AdminId, GETUTCDATE());
        END

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblUserRole', @UserId, 'INSERT',
                CONCAT('{"UserId":', @UserId, ',"RoleId":', @RoleId, '}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_AssignRole', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_RemoveRole
-- =========================================================
CREATE PROCEDURE proc_Admin_RemoveRole
    @UserId  INT,
    @RoleId  INT,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblUserRole
        SET IsDeleted      = 1,
            RecordStatusId = 3
        WHERE UserId    = @UserId
          AND RoleId    = @RoleId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblUserRole', @UserId, 'UPDATE',
                CONCAT('{"UserId":', @UserId, ',"RoleId":', @RoleId, ',"Action":"RemoveRole"}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_RemoveRole', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SaveTwoFactorCode
-- =========================================================
CREATE PROCEDURE proc_Admin_SaveTwoFactorCode
    @UserId   INT,
    @CodeHash NVARCHAR(512),
    @ExpiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Invalidate any existing unused codes for this user
        UPDATE t.tblAdminTwoFactorCode
        SET IsConsumed = 1, ConsumedOn = GETUTCDATE()
        WHERE UserId = @UserId AND IsConsumed = 0;

        INSERT INTO t.tblAdminTwoFactorCode (UserId, CodeHash, ExpiresAt, IsConsumed, CreatedOn)
        VALUES (@UserId, @CodeHash, @ExpiresAt, 0, GETUTCDATE());
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SaveTwoFactorCode', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_ValidateTwoFactorCode
-- =========================================================
CREATE PROCEDURE proc_Admin_ValidateTwoFactorCode
    @UserId   INT,
    @CodeHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT COUNT(1)
        FROM t.tblAdminTwoFactorCode
        WHERE UserId     = @UserId
          AND CodeHash   = @CodeHash
          AND IsConsumed = 0
          AND ExpiresAt  > GETUTCDATE();
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_ValidateTwoFactorCode', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_ConsumeTwoFactorCode
-- =========================================================
CREATE PROCEDURE proc_Admin_ConsumeTwoFactorCode
    @UserId   INT,
    @CodeHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblAdminTwoFactorCode
        SET IsConsumed = 1,
            ConsumedOn = GETUTCDATE()
        WHERE UserId     = @UserId
          AND CodeHash   = @CodeHash
          AND IsConsumed = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_ConsumeTwoFactorCode', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V019')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V019', 'CreateAdminAuthStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
