-- V007_CreateOrderTables.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create order tables: tblCart, tblCartItem, tblOrder, tblOrderLine, tblPayment, tblRefund
-- Dependencies: V001-V006

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblCart')
    BEGIN
        CREATE TABLE t.tblCart (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId         INT NOT NULL,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblCart_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id),
            CONSTRAINT FK_tblCart_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE UNIQUE INDEX IX_tblCart_UserId ON t.tblCart (UserId) WHERE IsDeleted = 0;
        PRINT 'Table [t].[tblCart] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblCartItem')
    BEGIN
        CREATE TABLE t.tblCartItem (
            Id               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            CartId           INT NOT NULL,
            ProductVariantId INT NOT NULL,
            ProductName      NVARCHAR(500) NOT NULL,
            UnitPrice        DECIMAL(10, 2) NOT NULL,
            Quantity         INT NOT NULL,
            CreatedBy        INT NOT NULL,
            CreatedOn        DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy       INT NULL,
            ModifiedOn       DATETIME2 NULL,
            IsDeleted        BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblCartItem_tblCart FOREIGN KEY (CartId) REFERENCES t.tblCart (Id),
            CONSTRAINT FK_tblCartItem_tblProductVariant FOREIGN KEY (ProductVariantId) REFERENCES m.tblProductVariant (Id)
        );
        CREATE INDEX IX_tblCartItem_CartId ON t.tblCartItem (CartId);
        PRINT 'Table [t].[tblCartItem] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblOrder')
    BEGIN
        CREATE TABLE t.tblOrder (
            Id              INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            UserId          INT NOT NULL,
            OrderReference  NVARCHAR(20) NOT NULL,
            StatusId        TINYINT NOT NULL DEFAULT 1,  -- maps to OrderStatus enum
            SubTotal        DECIMAL(10, 2) NOT NULL,
            DeliveryCharge  DECIMAL(10, 2) NOT NULL DEFAULT 0,
            DiscountTotal   DECIMAL(10, 2) NOT NULL DEFAULT 0,
            Total           DECIMAL(10, 2) NOT NULL,
            DeliverySlotId  INT NULL,
            DeliveryAddress NVARCHAR(1000) NULL,
            RecordStatusId  TINYINT NOT NULL DEFAULT 1,
            CreatedBy       INT NOT NULL,
            CreatedOn       DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy      INT NULL,
            ModifiedOn      DATETIME2 NULL,
            IsDeleted       BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblOrder_tblUser FOREIGN KEY (UserId) REFERENCES t.tblUser (Id),
            CONSTRAINT FK_tblOrder_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE UNIQUE INDEX IX_tblOrder_OrderReference ON t.tblOrder (OrderReference);
        CREATE INDEX IX_tblOrder_UserId ON t.tblOrder (UserId);
        PRINT 'Table [t].[tblOrder] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblOrderLine')
    BEGIN
        CREATE TABLE t.tblOrderLine (
            Id               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            OrderId          INT NOT NULL,
            ProductVariantId INT NOT NULL,
            ProductName      NVARCHAR(500) NOT NULL,
            UnitPrice        DECIMAL(10, 2) NOT NULL,
            Quantity         INT NOT NULL,
            LineTotal        DECIMAL(10, 2) NOT NULL,
            CreatedBy        INT NOT NULL,
            CreatedOn        DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            CONSTRAINT FK_tblOrderLine_tblOrder FOREIGN KEY (OrderId) REFERENCES t.tblOrder (Id),
            CONSTRAINT FK_tblOrderLine_tblProductVariant FOREIGN KEY (ProductVariantId) REFERENCES m.tblProductVariant (Id)
        );
        CREATE INDEX IX_tblOrderLine_OrderId ON t.tblOrderLine (OrderId);
        PRINT 'Table [t].[tblOrderLine] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblPayment')
    BEGIN
        CREATE TABLE t.tblPayment (
            Id              INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            OrderId         INT NOT NULL,
            Amount          DECIMAL(10, 2) NOT NULL,
            StatusId        TINYINT NOT NULL DEFAULT 1,  -- maps to PaymentStatus enum
            Provider        NVARCHAR(50) NOT NULL,
            ProviderRef     NVARCHAR(200) NULL,
            RecordStatusId  TINYINT NOT NULL DEFAULT 1,
            CreatedBy       INT NOT NULL,
            CreatedOn       DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy      INT NULL,
            ModifiedOn      DATETIME2 NULL,
            IsDeleted       BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblPayment_tblOrder FOREIGN KEY (OrderId) REFERENCES t.tblOrder (Id),
            CONSTRAINT FK_tblPayment_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblPayment_OrderId ON t.tblPayment (OrderId);
        PRINT 'Table [t].[tblPayment] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblRefund')
    BEGIN
        CREATE TABLE t.tblRefund (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            PaymentId      INT NOT NULL,
            OrderId        INT NOT NULL,
            Amount         DECIMAL(10, 2) NOT NULL,
            Reason         NVARCHAR(500) NOT NULL,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblRefund_tblPayment FOREIGN KEY (PaymentId) REFERENCES t.tblPayment (Id),
            CONSTRAINT FK_tblRefund_tblOrder FOREIGN KEY (OrderId) REFERENCES t.tblOrder (Id),
            CONSTRAINT FK_tblRefund_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblRefund_OrderId ON t.tblRefund (OrderId);
        PRINT 'Table [t].[tblRefund] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V007')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V007', 'CreateOrderTables');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
