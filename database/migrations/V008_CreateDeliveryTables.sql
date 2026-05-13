-- V008_CreateDeliveryTables.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create delivery tables: tblStore, tblDeliveryZone, tblDeliverySlot, tblSlotBooking
-- Dependencies: V001-V007

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblStore')
    BEGIN
        CREATE TABLE m.tblStore (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Name           NVARCHAR(200) NOT NULL,
            AddressLine1   NVARCHAR(200) NOT NULL,
            AddressLine2   NVARCHAR(200) NULL,
            Town           NVARCHAR(100) NOT NULL,
            Postcode       NVARCHAR(10) NOT NULL,
            Latitude       DECIMAL(9, 6) NOT NULL,
            Longitude      DECIMAL(9, 6) NOT NULL,
            IsActive       BIT NOT NULL DEFAULT 1,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblStore_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblStore_Postcode ON m.tblStore (Postcode);
        PRINT 'Table [m].[tblStore] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblDeliveryZone')
    BEGIN
        CREATE TABLE m.tblDeliveryZone (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            StoreId        INT NOT NULL,
            PostcodePrefix NVARCHAR(5) NOT NULL,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblDeliveryZone_tblStore FOREIGN KEY (StoreId) REFERENCES m.tblStore (Id),
            CONSTRAINT FK_tblDeliveryZone_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblDeliveryZone_PostcodePrefix ON m.tblDeliveryZone (PostcodePrefix);
        PRINT 'Table [m].[tblDeliveryZone] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblDeliverySlot')
    BEGIN
        CREATE TABLE t.tblDeliverySlot (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            StoreId        INT NOT NULL,
            DeliveryTypeId TINYINT NOT NULL,   -- 1 Standard, 2 Express, 3 ClickAndCollect
            SlotStart      DATETIME2 NOT NULL,
            SlotEnd        DATETIME2 NOT NULL,
            Capacity       SMALLINT NOT NULL,
            BookedCount    SMALLINT NOT NULL DEFAULT 0,
            DeliveryCharge DECIMAL(10, 2) NOT NULL DEFAULT 0,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblDeliverySlot_tblStore FOREIGN KEY (StoreId) REFERENCES m.tblStore (Id),
            CONSTRAINT FK_tblDeliverySlot_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblDeliverySlot_StoreId_SlotStart ON t.tblDeliverySlot (StoreId, SlotStart);
        PRINT 'Table [t].[tblDeliverySlot] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSlotBooking')
    BEGIN
        CREATE TABLE t.tblSlotBooking (
            Id           INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            SlotId       INT NOT NULL,
            OrderId      INT NOT NULL,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy    INT NOT NULL,
            CreatedOn    DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            IsDeleted    BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSlotBooking_tblDeliverySlot FOREIGN KEY (SlotId) REFERENCES t.tblDeliverySlot (Id),
            CONSTRAINT FK_tblSlotBooking_tblOrder FOREIGN KEY (OrderId) REFERENCES t.tblOrder (Id),
            CONSTRAINT FK_tblSlotBooking_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblSlotBooking_SlotId ON t.tblSlotBooking (SlotId);
        PRINT 'Table [t].[tblSlotBooking] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V008')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V008', 'CreateDeliveryTables');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
