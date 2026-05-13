-- V009_CreateLoyaltyTables.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create loyalty tables: tblClubcardAccount, tblLoyaltyTransaction, tblVoucher
-- Dependencies: V001-V008

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblClubcardAccount')
    BEGIN
        CREATE TABLE t.tblClubcardAccount (
            Id              INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId          INT NOT NULL,
            ClubcardNumber  NVARCHAR(20) NOT NULL,
            PointsBalance   INT NOT NULL DEFAULT 0,
            RecordStatusId  TINYINT NOT NULL DEFAULT 1,
            CreatedBy       INT NOT NULL,
            CreatedOn       DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy      INT NULL,
            ModifiedOn      DATETIME2 NULL,
            IsDeleted       BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblClubcardAccount_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id),
            CONSTRAINT FK_tblClubcardAccount_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE UNIQUE INDEX IX_tblClubcardAccount_UserId ON t.tblClubcardAccount (UserId) WHERE IsDeleted = 0;
        CREATE UNIQUE INDEX IX_tblClubcardAccount_ClubcardNumber ON t.tblClubcardAccount (ClubcardNumber) WHERE IsDeleted = 0;
        PRINT 'Table [t].[tblClubcardAccount] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblLoyaltyTransaction')
    BEGIN
        CREATE TABLE t.tblLoyaltyTransaction (
            Id          BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId      INT NOT NULL,
            Points      INT NOT NULL,   -- positive = earned, negative = redeemed
            Description NVARCHAR(500) NOT NULL,
            OrderId     INT NULL,
            CreatedBy   INT NOT NULL,
            CreatedOn   DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            CONSTRAINT FK_tblLoyaltyTransaction_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id),
            CONSTRAINT FK_tblLoyaltyTransaction_tblOrder FOREIGN KEY (OrderId) REFERENCES t.tblOrder (Id)
        );
        CREATE INDEX IX_tblLoyaltyTransaction_UserId ON t.tblLoyaltyTransaction (UserId);
        PRINT 'Table [t].[tblLoyaltyTransaction] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblVoucher')
    BEGIN
        CREATE TABLE t.tblVoucher (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId         INT NOT NULL,
            Code           NVARCHAR(50) NOT NULL,
            DiscountAmount DECIMAL(10, 2) NOT NULL,
            MinimumSpend   DECIMAL(10, 2) NULL,
            ValidFrom      DATETIME2 NOT NULL,
            ValidTo        DATETIME2 NOT NULL,
            IsRedeemed     BIT NOT NULL DEFAULT 0,
            RedeemedOn     DATETIME2 NULL,
            RedeemedOrderId INT NULL,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblVoucher_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id),
            CONSTRAINT FK_tblVoucher_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE UNIQUE INDEX IX_tblVoucher_Code ON t.tblVoucher (Code) WHERE IsDeleted = 0;
        PRINT 'Table [t].[tblVoucher] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V009')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V009', 'CreateLoyaltyTables');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
