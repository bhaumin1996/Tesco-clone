-- V072_UpdateIdentityProceduresToIncludeStripeCustomerId.sql
-- Description: Update user retrieval procedures to include StripeCustomerId

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Update proc_Identity_GetUserByEmail
    IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'proc_Identity_GetUserByEmail')
        DROP PROCEDURE proc_Identity_GetUserByEmail;
    EXEC('
    CREATE PROCEDURE proc_Identity_GetUserByEmail
        @Email NVARCHAR(256)
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT Id, FirstName, LastName, Email, PasswordHash, PhoneNumber, StripeCustomerId, 
               StatusId, FailedLoginAttempts, LockedUntil, RecordStatusId, CreatedOn, ModifiedOn
        FROM t.tblUser
        WHERE Email = @Email AND IsDeleted = 0;
    END');

    -- Update proc_Identity_GetUserById
    IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'proc_Identity_GetUserById')
        DROP PROCEDURE proc_Identity_GetUserById;
    EXEC('
    CREATE PROCEDURE proc_Identity_GetUserById
        @UserId INT
    AS
    BEGIN
        SET NOCOUNT ON;
        SELECT Id, FirstName, LastName, Email, PasswordHash, PhoneNumber, StripeCustomerId, 
               StatusId, FailedLoginAttempts, LockedUntil, RecordStatusId, CreatedOn, ModifiedOn
        FROM t.tblUser
        WHERE Id = @UserId AND IsDeleted = 0;
    END');

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V072')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V072', 'UpdateIdentityProceduresToIncludeStripeCustomerId');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
