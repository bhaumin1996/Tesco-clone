-- V017_CreateDeliveryStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Create stored procedures for delivery slot search and booking
-- Dependencies: V001-V008

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Delivery_GetAvailableSlots', 'P') IS NOT NULL DROP PROCEDURE proc_Delivery_GetAvailableSlots;
    IF OBJECT_ID('proc_Delivery_GetSlotById',       'P') IS NOT NULL DROP PROCEDURE proc_Delivery_GetSlotById;
    IF OBJECT_ID('proc_Delivery_BookSlot',          'P') IS NOT NULL DROP PROCEDURE proc_Delivery_BookSlot;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Delivery_GetAvailableSlots
-- Finds slots for a postcode prefix within a date range.
-- =========================================================
CREATE PROCEDURE proc_Delivery_GetAvailableSlots
    @Postcode        NVARCHAR(10),
    @DeliveryTypeId  TINYINT   = NULL,
    @FromDate        DATETIME2,
    @ToDate          DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @PostcodePrefix NVARCHAR(5) = LEFT(REPLACE(@Postcode, ' ', ''), 4);

        SELECT
            s.Id,
            s.StoreId,
            st.Name        AS StoreName,
            s.DeliveryTypeId,
            s.SlotStart,
            s.SlotEnd,
            CAST(CASE WHEN s.BookedCount < s.Capacity THEN 1 ELSE 0 END AS BIT) AS HasCapacity,
            s.DeliveryCharge
        FROM t.tblDeliverySlot s
        INNER JOIN m.tblStore st ON st.Id = s.StoreId
        INNER JOIN m.tblDeliveryZone dz ON dz.StoreId = s.StoreId
        WHERE s.IsDeleted = 0
          AND s.RecordStatusId = 1
          AND s.SlotStart >= @FromDate
          AND s.SlotStart <  @ToDate
          AND s.BookedCount   < s.Capacity
          AND dz.IsDeleted    = 0
          AND dz.PostcodePrefix = @PostcodePrefix
          AND (@DeliveryTypeId IS NULL OR s.DeliveryTypeId = @DeliveryTypeId)
        ORDER BY s.SlotStart;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Delivery_GetAvailableSlots', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Delivery_GetSlotById
-- =========================================================
CREATE PROCEDURE proc_Delivery_GetSlotById
    @SlotId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            s.Id,
            s.StoreId,
            st.Name        AS StoreName,
            s.DeliveryTypeId,
            s.SlotStart,
            s.SlotEnd,
            CAST(CASE WHEN s.BookedCount < s.Capacity THEN 1 ELSE 0 END AS BIT) AS HasCapacity,
            s.DeliveryCharge
        FROM t.tblDeliverySlot s
        INNER JOIN m.tblStore st ON st.Id = s.StoreId
        WHERE s.Id = @SlotId
          AND s.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Delivery_GetSlotById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Delivery_BookSlot
-- Atomically increments BookedCount and records the booking.
-- Uses UPDLOCK + HOLDLOCK to prevent double-booking under concurrency.
-- =========================================================
CREATE PROCEDURE proc_Delivery_BookSlot
    @SlotId    INT,
    @OrderId   INT,
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Capacity    SMALLINT;
        DECLARE @BookedCount SMALLINT;

        SELECT @Capacity = Capacity, @BookedCount = BookedCount
        FROM t.tblDeliverySlot WITH (UPDLOCK, HOLDLOCK)
        WHERE Id = @SlotId AND IsDeleted = 0;

        IF @Capacity IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50010, 'Delivery slot not found.', 1;
        END

        IF @BookedCount >= @Capacity
        BEGIN
            ROLLBACK TRANSACTION;
            THROW 50011, 'Delivery slot is fully booked.', 1;
        END

        UPDATE t.tblDeliverySlot
        SET BookedCount = BookedCount + 1,
            ModifiedBy  = @CreatedBy,
            ModifiedOn  = GETUTCDATE()
        WHERE Id = @SlotId;

        INSERT INTO t.tblSlotBooking (SlotId, OrderId, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@SlotId, @OrderId, 1, @CreatedBy, GETUTCDATE());

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSlotBooking', @SlotId, 'INSERT',
                CONCAT('{"SlotId":', @SlotId, ',"OrderId":', @OrderId, '}'),
                @CreatedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Delivery_BookSlot', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V017')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V017', 'CreateDeliveryStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
