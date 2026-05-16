-- V070_AddUserCardTableAndStripeCustomerId.sql
-- Description: Add StripeCustomerId to tblUser and create tblUserCard table

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Add StripeCustomerId to t.tblUser
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblUser' AND COLUMN_NAME = 'StripeCustomerId')
    BEGIN
        ALTER TABLE t.tblUser ADD StripeCustomerId NVARCHAR(100) NULL;
        PRINT 'Column [StripeCustomerId] added to [t].[tblUser].';
    END

    -- 2. Create t.tblUserCard
    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblUserCard')
    BEGIN
        CREATE TABLE t.tblUserCard (
            Id              INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId          INT NOT NULL,
            PaymentMethodId NVARCHAR(100) NOT NULL, -- Stripe PM ID
            Brand           NVARCHAR(50) NOT NULL,  -- visa, mastercard, etc.
            Last4           CHAR(4) NOT NULL,
            ExpiryMonth     INT NOT NULL,
            ExpiryYear      INT NOT NULL,
            IsDefault       BIT NOT NULL DEFAULT 0,
            CreatedOn       DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedOn      DATETIME2 NULL,
            IsDeleted       BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblUserCard_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id)
        );
        CREATE INDEX IX_tblUserCard_UserId ON t.tblUserCard (UserId);
        PRINT 'Table [t].[tblUserCard] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V070')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V070', 'AddUserCardTableAndStripeCustomerId');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
