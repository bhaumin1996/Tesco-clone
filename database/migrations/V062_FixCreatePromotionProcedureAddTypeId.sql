-- V062_FixCreatePromotionProcedureAddTypeId.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: Add @TypeId parameter to proc_Admin_CreatePromotion so the
--              promotion type is stored correctly instead of being hardcoded to 1.
-- Dependencies: V021

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF OBJECT_ID('proc_Admin_CreatePromotion', 'P') IS NOT NULL
    DROP PROCEDURE proc_Admin_CreatePromotion;
GO

CREATE PROCEDURE proc_Admin_CreatePromotion
    @Name            NVARCHAR(200),
    @TypeId          INT,
    @DiscountValue   DECIMAL(10,2) = NULL,
    @DiscountPercent DECIMAL(5,2)  = NULL,
    @MinQuantity     INT           = NULL,
    @StartsAt        DATETIME2     = NULL,
    @EndsAt          DATETIME2     = NULL,
    @AdminId         INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @PromotionId INT;

        INSERT INTO m.tblPromotion
            (Name, PromotionTypeId, DiscountValue, DiscountPercent, MinQuantity, StartsAt, EndsAt,
             IsActive, RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@Name, @TypeId, @DiscountValue, @DiscountPercent, @MinQuantity, @StartsAt, @EndsAt,
             1, 1, @AdminId, GETUTCDATE());

        SET @PromotionId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPromotion', @PromotionId, 'INSERT',
                CONCAT('{"Name":"', @Name, '","TypeId":', @TypeId, '}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @PromotionId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreatePromotion', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V062')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V062', 'FixCreatePromotionProcedureAddTypeId');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
