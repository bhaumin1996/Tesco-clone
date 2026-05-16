-- V071_CreatePaymentStoredProcedures.sql
-- Description: Create procedures to manage user cards and update Stripe customer ID

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Update User Stripe Customer ID
    IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spUpdateUserStripeCustomerId')
        DROP PROCEDURE spUpdateUserStripeCustomerId;
    EXEC('
    CREATE PROCEDURE spUpdateUserStripeCustomerId
        @UserId INT,
        @StripeCustomerId NVARCHAR(100)
    AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE t.tblUser SET StripeCustomerId = @StripeCustomerId, ModifiedOn = GETUTCDATE() WHERE Id = @UserId;
    END');

    -- Add User Card
    IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spAddUserCard')
        DROP PROCEDURE spAddUserCard;
    EXEC('
    CREATE PROCEDURE spAddUserCard
        @UserId INT,
        @PaymentMethodId NVARCHAR(100),
        @Brand NVARCHAR(50),
        @Last4 CHAR(4),
        @ExpiryMonth INT,
        @ExpiryYear INT,
        @IsDefault BIT
    AS
    BEGIN
        SET NOCOUNT ON;
        
        IF @IsDefault = 1
            UPDATE t.tblUserCard SET IsDefault = 0 WHERE UserId = @UserId;

        INSERT INTO t.tblUserCard (UserId, PaymentMethodId, Brand, Last4, ExpiryMonth, ExpiryYear, IsDefault)
        VALUES (@UserId, @PaymentMethodId, @Brand, @Last4, @ExpiryMonth, @ExpiryYear, @IsDefault);
    END');

    -- Get User Cards
    IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spGetUserCards')
        DROP PROCEDURE spGetUserCards;
    EXEC('
    CREATE PROCEDURE spGetUserCards
        @UserId INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT Id, PaymentMethodId, Brand, Last4, ExpiryMonth, ExpiryYear, IsDefault, CreatedOn
        FROM t.tblUserCard
        WHERE UserId = @UserId AND IsDeleted = 0
        ORDER BY IsDefault DESC, CreatedOn DESC;
    END');

    -- Delete User Card
    IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'spDeleteUserCard')
        DROP PROCEDURE spDeleteUserCard;
    EXEC('
    CREATE PROCEDURE spDeleteUserCard
        @UserId INT,
        @CardId INT
    AS
    BEGIN
        SET NOCOUNT ON;
        UPDATE t.tblUserCard SET IsDeleted = 1, ModifiedOn = GETUTCDATE() 
        WHERE Id = @CardId AND UserId = @UserId;
    END');

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V071')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V071', 'CreatePaymentStoredProcedures');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
