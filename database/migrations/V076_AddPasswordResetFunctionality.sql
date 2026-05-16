-- V076_AddPasswordResetFunctionality.sql
-- Author: Antigravity
-- Date: 2026-05-16
-- Description: Add password reset token columns and stored procedures

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- 1. Add columns to t.tblUser if they don't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblUser' AND COLUMN_NAME = 'PasswordResetToken')
BEGIN
    ALTER TABLE t.tblUser ADD PasswordResetToken NVARCHAR(256) NULL;
    ALTER TABLE t.tblUser ADD PasswordResetTokenExpires DATETIME2 NULL;
    PRINT 'Columns PasswordResetToken and PasswordResetTokenExpires added to t.tblUser.';
END
GO

-- 2. Create index for performance
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_tblUser_PasswordResetToken' AND object_id = OBJECT_ID('t.tblUser'))
BEGIN
    CREATE INDEX IX_tblUser_PasswordResetToken ON t.tblUser (PasswordResetToken) WHERE PasswordResetToken IS NOT NULL;
    PRINT 'Index IX_tblUser_PasswordResetToken created.';
END
GO

-- 3. Drop existing procedures to ensure they can be recreated
IF OBJECT_ID('proc_Identity_SetPasswordResetToken', 'P') IS NOT NULL DROP PROCEDURE proc_Identity_SetPasswordResetToken;
IF OBJECT_ID('proc_Identity_GetUserByPasswordResetToken', 'P') IS NOT NULL DROP PROCEDURE proc_Identity_GetUserByPasswordResetToken;
IF OBJECT_ID('proc_Identity_GetUserByEmail', 'P') IS NOT NULL DROP PROCEDURE proc_Identity_GetUserByEmail;
IF OBJECT_ID('proc_Identity_GetUserById', 'P') IS NOT NULL DROP PROCEDURE proc_Identity_GetUserById;
IF OBJECT_ID('proc_Identity_UpdatePassword', 'P') IS NOT NULL DROP PROCEDURE proc_Identity_UpdatePassword;
GO

-- =========================================================
-- proc_Identity_GetUserByEmail
-- =========================================================
CREATE PROCEDURE proc_Identity_GetUserByEmail
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            u.Id,
            u.FirstName,
            u.LastName,
            u.Email,
            u.PasswordHash,
            u.PhoneNumber,
            u.StatusId,
            u.FailedLoginAttempts,
            u.LockedUntil,
            u.RecordStatusId,
            u.CreatedOn,
            u.ModifiedOn,
            u.StripeCustomerId,
            u.PasswordResetToken,
            u.PasswordResetTokenExpires
        FROM t.tblUser u
        WHERE u.Email = @Email
          AND u.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_GetUserByEmail', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_GetUserById
-- =========================================================
CREATE PROCEDURE proc_Identity_GetUserById
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
            u.PasswordHash,
            u.PhoneNumber,
            u.StatusId,
            u.FailedLoginAttempts,
            u.LockedUntil,
            u.RecordStatusId,
            u.CreatedOn,
            u.ModifiedOn,
            u.StripeCustomerId,
            u.PasswordResetToken,
            u.PasswordResetTokenExpires
        FROM t.tblUser u
        WHERE u.Id = @UserId
          AND u.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_GetUserById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_SetPasswordResetToken
-- =========================================================
CREATE PROCEDURE proc_Identity_SetPasswordResetToken
    @Email NVARCHAR(256),
    @Token NVARCHAR(256),
    @ExpiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE t.tblUser
        SET PasswordResetToken = @Token,
            PasswordResetTokenExpires = @ExpiresAt,
            ModifiedOn = GETUTCDATE()
        WHERE Email = @Email AND IsDeleted = 0;
        
        SELECT @@ROWCOUNT;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_SetPasswordResetToken', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_GetUserByPasswordResetToken
-- =========================================================
CREATE PROCEDURE proc_Identity_GetUserByPasswordResetToken
    @Token NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            u.Id,
            u.FirstName,
            u.LastName,
            u.Email,
            u.PasswordHash,
            u.PhoneNumber,
            u.StatusId,
            u.FailedLoginAttempts,
            u.LockedUntil,
            u.RecordStatusId,
            u.CreatedOn,
            u.ModifiedOn,
            u.StripeCustomerId,
            u.PasswordResetToken,
            u.PasswordResetTokenExpires
        FROM t.tblUser u
        WHERE u.PasswordResetToken = @Token
          AND u.PasswordResetTokenExpires > GETUTCDATE()
          AND u.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_GetUserByPasswordResetToken', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_UpdatePassword
-- =========================================================
CREATE PROCEDURE proc_Identity_UpdatePassword
    @UserId       INT,
    @PasswordHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        UPDATE t.tblUser
        SET PasswordHash = @PasswordHash,
            PasswordResetToken = NULL,
            PasswordResetTokenExpires = NULL,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @UserId AND IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_UpdatePassword', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V076')
    INSERT INTO t.tblMigration (Version, Description) VALUES ('V076', 'AddPasswordResetFunctionality');
GO
