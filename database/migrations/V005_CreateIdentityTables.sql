-- V005_CreateIdentityTables.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create identity tables: tblUser, tblUserRole, tblRefreshToken
-- Dependencies: V001-V004

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblUser')
    BEGIN
        CREATE TABLE t.tblUser (
            Id                   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            FirstName            NVARCHAR(100) NOT NULL,
            LastName             NVARCHAR(100) NOT NULL,
            Email                NVARCHAR(256) NOT NULL,
            PasswordHash         NVARCHAR(512) NOT NULL,
            PhoneNumber          NVARCHAR(20) NULL,
            StatusId             TINYINT NOT NULL DEFAULT 1,  -- 1 Active, 2 Locked, 3 Disabled
            FailedLoginAttempts  TINYINT NOT NULL DEFAULT 0,
            LockedUntil          DATETIME2 NULL,
            RecordStatusId       TINYINT NOT NULL DEFAULT 1,
            CreatedBy            INT NOT NULL DEFAULT 1,
            CreatedOn            DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy           INT NULL,
            ModifiedOn           DATETIME2 NULL,
            IsDeleted            BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblUser_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE UNIQUE INDEX IX_tblUser_Email ON t.tblUser (Email) WHERE IsDeleted = 0;
        PRINT 'Table [t].[tblUser] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblUserRole')
    BEGIN
        CREATE TABLE t.tblUserRole (
            Id         INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId     INT NOT NULL,
            RoleId     INT NOT NULL,
            CreatedBy  INT NOT NULL,
            CreatedOn  DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            IsDeleted  BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblUserRole_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id),
            CONSTRAINT FK_tblUserRole_tblRole FOREIGN KEY (RoleId) REFERENCES m.tblRole (Id)
        );
        CREATE UNIQUE INDEX IX_tblUserRole_UserId_RoleId ON t.tblUserRole (UserId, RoleId) WHERE IsDeleted = 0;
        PRINT 'Table [t].[tblUserRole] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblRefreshToken')
    BEGIN
        CREATE TABLE t.tblRefreshToken (
            Id         BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId     INT NOT NULL,
            TokenHash  NVARCHAR(512) NOT NULL,
            ExpiresAt  DATETIME2 NOT NULL,
            IsRevoked  BIT NOT NULL DEFAULT 0,
            CreatedOn  DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            RevokedOn  DATETIME2 NULL,
            CONSTRAINT FK_tblRefreshToken_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id)
        );
        CREATE INDEX IX_tblRefreshToken_UserId ON t.tblRefreshToken (UserId);
        CREATE INDEX IX_tblRefreshToken_TokenHash ON t.tblRefreshToken (TokenHash);
        PRINT 'Table [t].[tblRefreshToken] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V005')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V005', 'CreateIdentityTables');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
