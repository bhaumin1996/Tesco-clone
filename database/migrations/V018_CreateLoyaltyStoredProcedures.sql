-- V018_CreateLoyaltyStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Create stored procedures for Clubcard points and voucher management
-- Dependencies: V001-V009

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Loyalty_GetClubcardByUserId',    'P') IS NOT NULL DROP PROCEDURE proc_Loyalty_GetClubcardByUserId;
    IF OBJECT_ID('proc_Loyalty_AddPoints',              'P') IS NOT NULL DROP PROCEDURE proc_Loyalty_AddPoints;
    IF OBJECT_ID('proc_Loyalty_RedeemPoints',           'P') IS NOT NULL DROP PROCEDURE proc_Loyalty_RedeemPoints;
    IF OBJECT_ID('proc_Loyalty_GetVouchersByUserId',    'P') IS NOT NULL DROP PROCEDURE proc_Loyalty_GetVouchersByUserId;
    IF OBJECT_ID('proc_Loyalty_GetVoucherByCode',       'P') IS NOT NULL DROP PROCEDURE proc_Loyalty_GetVoucherByCode;
    IF OBJECT_ID('proc_Loyalty_RedeemVoucher',          'P') IS NOT NULL DROP PROCEDURE proc_Loyalty_RedeemVoucher;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Loyalty_GetClubcardByUserId
-- =========================================================
CREATE PROCEDURE proc_Loyalty_GetClubcardByUserId
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, ClubcardNumber, PointsBalance
        FROM t.tblClubcardAccount
        WHERE UserId    = @UserId
          AND IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Loyalty_GetClubcardByUserId', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Loyalty_AddPoints
-- Creates the Clubcard account if it does not exist, then adds points.
-- =========================================================
CREATE PROCEDURE proc_Loyalty_AddPoints
    @UserId      INT,
    @Points      INT,
    @Description NVARCHAR(500),
    @CreatedBy   INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM t.tblClubcardAccount WHERE UserId = @UserId AND IsDeleted = 0)
        BEGIN
            DECLARE @CardNumber NVARCHAR(20) =
                CONCAT('634004', RIGHT('00000000000000' + CAST(@UserId AS NVARCHAR), 13));

            INSERT INTO t.tblClubcardAccount (UserId, ClubcardNumber, PointsBalance, RecordStatusId, CreatedBy, CreatedOn)
            VALUES (@UserId, @CardNumber, 0, 1, @CreatedBy, GETUTCDATE());
        END

        UPDATE t.tblClubcardAccount
        SET PointsBalance = PointsBalance + @Points,
            ModifiedBy    = @CreatedBy,
            ModifiedOn    = GETUTCDATE()
        WHERE UserId = @UserId AND IsDeleted = 0;

        INSERT INTO t.tblLoyaltyTransaction (UserId, Points, Description, CreatedBy, CreatedOn)
        VALUES (@UserId, @Points, @Description, @CreatedBy, GETUTCDATE());

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblClubcardAccount', @UserId, 'UPDATE',
                CONCAT('{"Points":+', @Points, ',"Description":"', @Description, '"}'),
                @CreatedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Loyalty_AddPoints', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Loyalty_RedeemPoints
-- Returns 1 on success, 0 if insufficient balance.
-- =========================================================
CREATE PROCEDURE proc_Loyalty_RedeemPoints
    @UserId      INT,
    @Points      INT,
    @Description NVARCHAR(500),
    @CreatedBy   INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CurrentBalance INT;
        SELECT @CurrentBalance = PointsBalance
        FROM t.tblClubcardAccount WITH (UPDLOCK, HOLDLOCK)
        WHERE UserId = @UserId AND IsDeleted = 0;

        IF @CurrentBalance IS NULL OR @CurrentBalance < @Points
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 0;
            RETURN;
        END

        UPDATE t.tblClubcardAccount
        SET PointsBalance = PointsBalance - @Points,
            ModifiedBy    = @CreatedBy,
            ModifiedOn    = GETUTCDATE()
        WHERE UserId = @UserId AND IsDeleted = 0;

        INSERT INTO t.tblLoyaltyTransaction (UserId, Points, Description, CreatedBy, CreatedOn)
        VALUES (@UserId, -@Points, @Description, @CreatedBy, GETUTCDATE());

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblClubcardAccount', @UserId, 'UPDATE',
                CONCAT('{"Points":-', @Points, ',"Description":"', @Description, '"}'),
                @CreatedBy, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT 1;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Loyalty_RedeemPoints', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Loyalty_GetVouchersByUserId
-- =========================================================
CREATE PROCEDURE proc_Loyalty_GetVouchersByUserId
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, Code, DiscountAmount, MinimumSpend, ValidFrom, ValidTo, IsRedeemed
        FROM t.tblVoucher
        WHERE UserId    = @UserId
          AND IsDeleted = 0
        ORDER BY ValidTo DESC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Loyalty_GetVouchersByUserId', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Loyalty_GetVoucherByCode
-- =========================================================
CREATE PROCEDURE proc_Loyalty_GetVoucherByCode
    @UserId INT,
    @Code   NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, Code, DiscountAmount, MinimumSpend, ValidFrom, ValidTo, IsRedeemed
        FROM t.tblVoucher
        WHERE UserId    = @UserId
          AND Code      = @Code
          AND IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Loyalty_GetVoucherByCode', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Loyalty_RedeemVoucher
-- =========================================================
CREATE PROCEDURE proc_Loyalty_RedeemVoucher
    @UserId     INT,
    @Code       NVARCHAR(50),
    @OrderId    INT,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (
            SELECT 1 FROM t.tblVoucher
            WHERE UserId = @UserId AND Code = @Code AND IsRedeemed = 0 AND IsDeleted = 0
        )
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50020, 'Voucher not found or already redeemed.', 1;
        END

        UPDATE t.tblVoucher
        SET IsRedeemed      = 1,
            RedeemedOn      = GETUTCDATE(),
            RedeemedOrderId = @OrderId
        WHERE UserId = @UserId AND Code = @Code AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblVoucher', @OrderId, 'UPDATE',
                CONCAT('{"Code":"', @Code, '","OrderId":', @OrderId, '}'),
                @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Loyalty_RedeemVoucher', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V018')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V018', 'CreateLoyaltyStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
