-- V026_FixAdminTwoFactorCodeTable.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Fixes two bugs introduced by V019.
--
--   Bug 1 — t.tblAdminTwoFactorCode missing:
--     V019 creates the table and drops stored procedures inside a single
--     transaction batch (first GO block). If that batch fails and is rolled
--     back, the subsequent GO batches still execute and create the stored
--     procedures against a non-existent table. proc_Admin_SaveTwoFactorCode
--     therefore fails at runtime with "Invalid object name".
--
--   Bug 2 — tblUserRole.RecordStatusId missing:
--     proc_Admin_RemoveRole (V019) sets RecordStatusId = 3 on t.tblUserRole,
--     but tblUserRole was created in V005 without that column.
--
-- Both fixes are idempotent and safe to re-run.
-- Dependencies: V001, V005, V019

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- ----------------------------------------------------------------
    -- Fix 1: create t.tblAdminTwoFactorCode if it does not exist
    -- ----------------------------------------------------------------
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
            CONSTRAINT FK_tblAdminTwoFactorCode_tblUser
                FOREIGN KEY (UserId) REFERENCES t.tblUser (Id)
        );

        CREATE INDEX IX_tblAdminTwoFactorCode_UserId
            ON t.tblAdminTwoFactorCode (UserId);
    END

    -- ----------------------------------------------------------------
    -- Fix 2: add missing columns to tblUserRole if not already present
    -- ----------------------------------------------------------------
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 't'
          AND TABLE_NAME   = 'tblUserRole'
          AND COLUMN_NAME  = 'RecordStatusId'
    )
    BEGIN
        ALTER TABLE t.tblUserRole
            ADD RecordStatusId TINYINT NOT NULL DEFAULT 1;
    END

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 't'
          AND TABLE_NAME   = 'tblUserRole'
          AND COLUMN_NAME  = 'ModifiedBy'
    )
    BEGIN
        ALTER TABLE t.tblUserRole
            ADD ModifiedBy INT NULL;
    END

    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 't'
          AND TABLE_NAME   = 'tblUserRole'
          AND COLUMN_NAME  = 'ModifiedOn'
    )
    BEGIN
        ALTER TABLE t.tblUserRole
            ADD ModifiedOn DATETIME2 NULL;
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V026')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V026', 'FixAdminTwoFactorCodeTable');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V026_FixAdminTwoFactorCodeTable', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- ----------------------------------------------------------------
-- Recreate proc_Admin_RemoveRole with the now-valid RecordStatusId
-- column (dropped idempotently so re-running is safe)
-- ----------------------------------------------------------------
IF OBJECT_ID('proc_Admin_RemoveRole', 'P') IS NOT NULL
    DROP PROCEDURE proc_Admin_RemoveRole;
GO

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
            RecordStatusId = 3,
            ModifiedBy     = @AdminId,
            ModifiedOn     = GETUTCDATE()
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
