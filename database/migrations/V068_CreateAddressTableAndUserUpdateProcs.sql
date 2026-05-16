-- V068_CreateAddressTableAndUserUpdateProcs.sql
-- Author: Antigravity
-- Date: 2026-05-16
-- Description: Create tblUserAddress table and stored procedures for profile updates

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Create tblUserAddress table
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblUserAddress')
    BEGIN
        CREATE TABLE t.tblUserAddress (
            Id              INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId          INT NOT NULL,
            AddressLine1    NVARCHAR(200) NOT NULL,
            AddressLine2    NVARCHAR(200) NULL,
            TownCity        NVARCHAR(100) NOT NULL,
            Postcode        NVARCHAR(20) NOT NULL,
            IsDefault       BIT NOT NULL DEFAULT 0,
            RecordStatusId  TINYINT NOT NULL DEFAULT 1,
            CreatedBy       INT NOT NULL,
            CreatedOn       DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy      INT NULL,
            ModifiedOn      DATETIME2 NULL,
            IsDeleted       BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblUserAddress_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id),
            CONSTRAINT FK_tblUserAddress_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblUserAddress_UserId ON t.tblUserAddress (UserId) WHERE IsDeleted = 0;
        PRINT 'Table [t].[tblUserAddress] created.';
    END

    -- 2. Drop existing procedures for idempotency
    IF OBJECT_ID('proc_Identity_UpdateProfile',    'P') IS NOT NULL DROP PROCEDURE proc_Identity_UpdateProfile;
    IF OBJECT_ID('proc_Identity_UpdatePassword',   'P') IS NOT NULL DROP PROCEDURE proc_Identity_UpdatePassword;
    IF OBJECT_ID('proc_Identity_GetUserAddresses', 'P') IS NOT NULL DROP PROCEDURE proc_Identity_GetUserAddresses;
    IF OBJECT_ID('proc_Identity_AddUserAddress',   'P') IS NOT NULL DROP PROCEDURE proc_Identity_AddUserAddress;
    IF OBJECT_ID('proc_Identity_UpdateUserAddress','P') IS NOT NULL DROP PROCEDURE proc_Identity_UpdateUserAddress;
    IF OBJECT_ID('proc_Identity_DeleteUserAddress','P') IS NOT NULL DROP PROCEDURE proc_Identity_DeleteUserAddress;
    IF OBJECT_ID('proc_Identity_SetDefaultAddress','P') IS NOT NULL DROP PROCEDURE proc_Identity_SetDefaultAddress;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- 3. Create Procedures

-- =========================================================
-- proc_Identity_UpdateProfile
-- =========================================================
CREATE PROCEDURE proc_Identity_UpdateProfile
    @UserId    INT,
    @FirstName NVARCHAR(100),
    @LastName  NVARCHAR(100),
    @Email     NVARCHAR(256),
    @Phone     NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblUser
        SET FirstName   = @FirstName,
            LastName    = @LastName,
            Email       = @Email,
            PhoneNumber = @Phone,
            ModifiedBy  = @UserId,
            ModifiedOn  = GETUTCDATE()
        WHERE Id = @UserId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblUser', @UserId, 'UPDATE_PROFILE',
                CONCAT('{"FirstName":"', @FirstName, '","LastName":"', @LastName, '","Email":"', @Email, '"}'),
                @UserId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_UpdateProfile', ERROR_MESSAGE(), GETUTCDATE());
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
        BEGIN TRANSACTION;

        UPDATE t.tblUser
        SET PasswordHash = @PasswordHash,
            ModifiedBy   = @UserId,
            ModifiedOn   = GETUTCDATE()
        WHERE Id = @UserId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblUser', @UserId, 'UPDATE_PASSWORD', '{"PasswordChanged":true}', @UserId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_UpdatePassword', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_GetUserAddresses
-- =========================================================
CREATE PROCEDURE proc_Identity_GetUserAddresses
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            Id,
            UserId,
            AddressLine1,
            AddressLine2,
            TownCity,
            Postcode,
            IsDefault
        FROM t.tblUserAddress
        WHERE UserId = @UserId AND IsDeleted = 0
        ORDER BY IsDefault DESC, CreatedOn DESC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_GetUserAddresses', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_AddUserAddress
-- =========================================================
CREATE PROCEDURE proc_Identity_AddUserAddress
    @UserId       INT,
    @Line1        NVARCHAR(200),
    @Line2        NVARCHAR(200) = NULL,
    @Town         NVARCHAR(100),
    @Postcode     NVARCHAR(20),
    @IsDefault    BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @IsDefault = 1
        BEGIN
            UPDATE t.tblUserAddress SET IsDefault = 0 WHERE UserId = @UserId AND IsDeleted = 0;
        END

        -- If this is the first address, make it default
        IF NOT EXISTS (SELECT 1 FROM t.tblUserAddress WHERE UserId = @UserId AND IsDeleted = 0)
        BEGIN
            SET @IsDefault = 1;
        END

        INSERT INTO t.tblUserAddress (UserId, AddressLine1, AddressLine2, TownCity, Postcode, IsDefault, CreatedBy, CreatedOn)
        VALUES (@UserId, @Line1, @Line2, @Town, @Postcode, @IsDefault, @UserId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_AddUserAddress', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_UpdateUserAddress
-- =========================================================
CREATE PROCEDURE proc_Identity_UpdateUserAddress
    @AddressId INT,
    @UserId    INT,
    @Line1     NVARCHAR(200),
    @Line2     NVARCHAR(200) = NULL,
    @Town      NVARCHAR(100),
    @Postcode  NVARCHAR(20),
    @IsDefault BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @IsDefault = 1
        BEGIN
            UPDATE t.tblUserAddress SET IsDefault = 0 WHERE UserId = @UserId AND IsDeleted = 0;
        END

        UPDATE t.tblUserAddress
        SET AddressLine1 = @Line1,
            AddressLine2 = @Line2,
            TownCity     = @Town,
            Postcode     = @Postcode,
            IsDefault    = @IsDefault,
            ModifiedBy   = @UserId,
            ModifiedOn   = GETUTCDATE()
        WHERE Id = @AddressId AND UserId = @UserId AND IsDeleted = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_UpdateUserAddress', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_DeleteUserAddress
-- =========================================================
CREATE PROCEDURE proc_Identity_DeleteUserAddress
    @AddressId INT,
    @UserId    INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblUserAddress
        SET IsDeleted  = 1,
            ModifiedBy = @UserId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @AddressId AND UserId = @UserId;

        -- If the deleted address was default, make another one default if exists
        IF EXISTS (SELECT 1 FROM t.tblUserAddress WHERE Id = @AddressId AND IsDefault = 1)
        BEGIN
            DECLARE @NewDefaultId INT;
            SELECT TOP 1 @NewDefaultId = Id FROM t.tblUserAddress WHERE UserId = @UserId AND IsDeleted = 0 ORDER BY CreatedOn DESC;
            IF @NewDefaultId IS NOT NULL
                UPDATE t.tblUserAddress SET IsDefault = 1 WHERE Id = @NewDefaultId;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_DeleteUserAddress', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_SetDefaultAddress
-- =========================================================
CREATE PROCEDURE proc_Identity_SetDefaultAddress
    @AddressId INT,
    @UserId    INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblUserAddress SET IsDefault = 0 WHERE UserId = @UserId AND IsDeleted = 0;
        UPDATE t.tblUserAddress SET IsDefault = 1 WHERE Id = @AddressId AND UserId = @UserId AND IsDeleted = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_SetDefaultAddress', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- 4. Record migration
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V068')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V068', 'CreateAddressTableAndUserUpdateProcs');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
