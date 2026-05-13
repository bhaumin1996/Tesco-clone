-- V012_CreateMarketplaceTables.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create marketplace tables: tblSeller, tblListing, tblCommission, tblDispute
-- Dependencies: V001-V011

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller')
    BEGIN
        CREATE TABLE t.tblSeller (
            Id              INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId          INT NOT NULL,
            BusinessName    NVARCHAR(300) NOT NULL,
            BusinessEmail   NVARCHAR(256) NOT NULL,
            IsApproved      BIT NOT NULL DEFAULT 0,
            CommissionRate  DECIMAL(5, 2) NOT NULL DEFAULT 10.00,
            RecordStatusId  TINYINT NOT NULL DEFAULT 1,
            CreatedBy       INT NOT NULL,
            CreatedOn       DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy      INT NULL,
            ModifiedOn      DATETIME2 NULL,
            IsDeleted       BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSeller_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id),
            CONSTRAINT FK_tblSeller_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE UNIQUE INDEX IX_tblSeller_UserId ON t.tblSeller (UserId) WHERE IsDeleted = 0;
        PRINT 'Table [t].[tblSeller] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblListing')
    BEGIN
        CREATE TABLE t.tblListing (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            SellerId       INT NOT NULL,
            ProductId      INT NOT NULL,
            Price          DECIMAL(10, 2) NOT NULL,
            StockQuantity  INT NOT NULL DEFAULT 0,
            IsActive       BIT NOT NULL DEFAULT 1,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblListing_tblSeller FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id),
            CONSTRAINT FK_tblListing_tblProduct FOREIGN KEY (ProductId) REFERENCES m.tblProduct (Id),
            CONSTRAINT FK_tblListing_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblListing_SellerId ON t.tblListing (SellerId);
        CREATE INDEX IX_tblListing_ProductId ON t.tblListing (ProductId);
        PRINT 'Table [t].[tblListing] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblCommission')
    BEGIN
        CREATE TABLE t.tblCommission (
            Id              BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            SellerId        INT NOT NULL,
            OrderLineId     INT NOT NULL,
            SaleAmount      DECIMAL(10, 2) NOT NULL,
            CommissionAmount DECIMAL(10, 2) NOT NULL,
            RecordStatusId  TINYINT NOT NULL DEFAULT 1,
            CreatedBy       INT NOT NULL,
            CreatedOn       DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            IsDeleted       BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblCommission_tblSeller FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id),
            CONSTRAINT FK_tblCommission_tblOrderLine FOREIGN KEY (OrderLineId) REFERENCES t.tblOrderLine (Id),
            CONSTRAINT FK_tblCommission_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblCommission_SellerId ON t.tblCommission (SellerId);
        PRINT 'Table [t].[tblCommission] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblDispute')
    BEGIN
        CREATE TABLE t.tblDispute (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            OrderId        INT NOT NULL,
            SellerId       INT NOT NULL,
            Reason         NVARCHAR(1000) NOT NULL,
            Resolution     NVARCHAR(1000) NULL,
            StatusId       TINYINT NOT NULL DEFAULT 1,  -- 1 Open, 2 Resolved, 3 Closed
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblDispute_tblOrder FOREIGN KEY (OrderId) REFERENCES t.tblOrder (Id),
            CONSTRAINT FK_tblDispute_tblSeller FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id),
            CONSTRAINT FK_tblDispute_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblDispute_OrderId ON t.tblDispute (OrderId);
        PRINT 'Table [t].[tblDispute] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V012')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V012', 'CreateMarketplaceTables');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
