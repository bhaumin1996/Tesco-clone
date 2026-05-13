-- Roles: Admin=1, Customer=2, Seller=3
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Drop existing procedures idempotently
    IF OBJECT_ID('proc_Identity_GetUserByEmail',        'P') IS NOT NULL DROP PROCEDURE proc_Identity_GetUserByEmail;
    IF OBJECT_ID('proc_Identity_GetUserById',           'P') IS NOT NULL DROP PROCEDURE proc_Identity_GetUserById;
    IF OBJECT_ID('proc_Identity_CheckEmailExists',      'P') IS NOT NULL DROP PROCEDURE proc_Identity_CheckEmailExists;
    IF OBJECT_ID('proc_Identity_CreateUser',            'P') IS NOT NULL DROP PROCEDURE proc_Identity_CreateUser;
    IF OBJECT_ID('proc_Identity_UpdateUser',            'P') IS NOT NULL DROP PROCEDURE proc_Identity_UpdateUser;
    IF OBJECT_ID('proc_Identity_GetUserRoles',          'P') IS NOT NULL DROP PROCEDURE proc_Identity_GetUserRoles;
    IF OBJECT_ID('proc_Identity_SaveRefreshToken',      'P') IS NOT NULL DROP PROCEDURE proc_Identity_SaveRefreshToken;
    IF OBJECT_ID('proc_Identity_ValidateRefreshToken',  'P') IS NOT NULL DROP PROCEDURE proc_Identity_ValidateRefreshToken;
    IF OBJECT_ID('proc_Identity_RevokeRefreshToken',    'P') IS NOT NULL DROP PROCEDURE proc_Identity_RevokeRefreshToken;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Identity_GetUserByEmail
-- =========================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
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
            u.ModifiedOn
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
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
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
            u.ModifiedOn
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
-- proc_Identity_CheckEmailExists
-- =========================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE proc_Identity_CheckEmailExists
    @Email NVARCHAR(256)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT COUNT(1)
        FROM t.tblUser
        WHERE Email = @Email
          AND IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_CheckEmailExists', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_CreateUser
-- =========================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE proc_Identity_CreateUser
    @FirstName    NVARCHAR(100),
    @LastName     NVARCHAR(100),
    @Email        NVARCHAR(256),
    @PasswordHash NVARCHAR(512),
    @PhoneNumber  NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @UserId INT;

        INSERT INTO t.tblUser (FirstName, LastName, Email, PasswordHash, PhoneNumber, StatusId, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@FirstName, @LastName, @Email, @PasswordHash, @PhoneNumber, 1, 1, 1, GETUTCDATE());

        SET @UserId = SCOPE_IDENTITY();

        -- Assign default Customer role (RoleId = 2)
        INSERT INTO t.tblUserRole (UserId, RoleId, CreatedBy, CreatedOn)
        VALUES (@UserId, 2, 1, GETUTCDATE());

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblUser', @UserId, 'INSERT',
                CONCAT('{"Email":"', @Email, '","FirstName":"', @FirstName, '","LastName":"', @LastName, '"}'),
                1, GETUTCDATE());

        COMMIT TRANSACTION;

        SELECT @UserId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_CreateUser', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_UpdateUser
-- =========================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE proc_Identity_UpdateUser
    @UserId              INT,
    @Status              TINYINT,
    @FailedLoginAttempts TINYINT,
    @LockedUntil         DATETIME2 = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblUser
        SET StatusId            = @Status,
            FailedLoginAttempts = @FailedLoginAttempts,
            LockedUntil         = @LockedUntil,
            ModifiedBy          = @UserId,
            ModifiedOn          = GETUTCDATE()
        WHERE Id = @UserId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblUser', @UserId, 'UPDATE',
                CONCAT('{"StatusId":', @Status, ',"FailedLoginAttempts":', @FailedLoginAttempts, '}'),
                @UserId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_UpdateUser', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_GetUserRoles
-- =========================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE proc_Identity_GetUserRoles
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT r.Name AS RoleName
        FROM t.tblUserRole ur
        INNER JOIN m.tblRole r ON r.Id = ur.RoleId
        WHERE ur.UserId = @UserId
          AND ur.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_GetUserRoles', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_SaveRefreshToken
-- =========================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE proc_Identity_SaveRefreshToken
    @UserId    INT,
    @TokenHash NVARCHAR(512),
    @ExpiresAt DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO t.tblRefreshToken (UserId, TokenHash, ExpiresAt, IsRevoked, CreatedOn)
        VALUES (@UserId, @TokenHash, @ExpiresAt, 0, GETUTCDATE());
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_SaveRefreshToken', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_ValidateRefreshToken
-- =========================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE proc_Identity_ValidateRefreshToken
    @UserId    INT,
    @TokenHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT COUNT(1)
        FROM t.tblRefreshToken
        WHERE UserId    = @UserId
          AND TokenHash = @TokenHash
          AND IsRevoked = 0
          AND ExpiresAt > GETUTCDATE();
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_ValidateRefreshToken', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Identity_RevokeRefreshToken
-- =========================================================
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE proc_Identity_RevokeRefreshToken
    @UserId    INT,
    @TokenHash NVARCHAR(512)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblRefreshToken
        SET IsRevoked = 1,
            RevokedOn = GETUTCDATE()
        WHERE UserId    = @UserId
          AND TokenHash = @TokenHash
          AND IsRevoked = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Identity_RevokeRefreshToken', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V013')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V013', 'CreateIdentityStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
