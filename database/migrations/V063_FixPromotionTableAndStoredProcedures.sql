-- V063_FixPromotionTableAndStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: Fix m.tblPromotion schema and rewrite all five promotion stored
--              procedures so column names match the application layer.
--              V021 procedures referenced non-existent columns (DiscountPercent,
--              IsActive, StartsAt, EndsAt, MinQuantity, PromotionTypeId) and
--              joined to m.tblPromotionType which does not exist.
-- Dependencies: V010, V021, V062

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- 1. Patch m.tblPromotion – add missing columns and relax
--    NOT NULL constraints that the application treats as optional
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblPromotion' AND COLUMN_NAME='DiscountPercent')
        ALTER TABLE m.tblPromotion ADD DiscountPercent DECIMAL(5,2) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
                   WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblPromotion' AND COLUMN_NAME='IsActive')
        ALTER TABLE m.tblPromotion ADD IsActive BIT NOT NULL DEFAULT 1;

    -- DiscountValue and ValidFrom were NOT NULL; make them nullable so
    -- promotions without a discount amount or an explicit start date are valid.
    ALTER TABLE m.tblPromotion ALTER COLUMN DiscountValue DECIMAL(10,2) NULL;
    ALTER TABLE m.tblPromotion ALTER COLUMN ValidFrom     DATETIME2     NULL;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V063_FixPromotionTable', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- 2. Drop all five promotion stored procedures
-- =========================================================
IF OBJECT_ID('proc_Admin_GetPromotions',       'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetPromotions;
IF OBJECT_ID('proc_Admin_GetPromotionById',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetPromotionById;
IF OBJECT_ID('proc_Admin_CreatePromotion',     'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreatePromotion;
IF OBJECT_ID('proc_Admin_UpdatePromotion',     'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdatePromotion;
IF OBJECT_ID('proc_Admin_SoftDeletePromotion', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeletePromotion;
GO

-- =========================================================
-- proc_Admin_GetPromotions
-- =========================================================
CREATE PROCEDURE proc_Admin_GetPromotions
    @IsActive   BIT = NULL,
    @PageNumber INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            p.Id,
            p.Name,
            CASE p.TypeId
                WHEN 1 THEN 'Percentage Discount'
                WHEN 2 THEN 'Fixed Amount Discount'
                WHEN 3 THEN 'Buy X Get Y'
                WHEN 4 THEN 'Multi Buy'
                WHEN 5 THEN 'Clubcard Price'
                ELSE        'Unknown'
            END                 AS TypeName,
            p.DiscountValue,
            p.DiscountPercent,
            p.MinimumQuantity   AS MinQuantity,
            p.ValidFrom         AS StartsAt,
            p.ValidTo           AS EndsAt,
            p.IsActive,
            p.CreatedOn,
            p.ModifiedOn,
            COUNT(1) OVER ()    AS TotalCount
        FROM m.tblPromotion p
        WHERE p.IsDeleted = 0
          AND (@IsActive IS NULL OR p.IsActive = @IsActive)
        ORDER BY p.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetPromotions', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetPromotionById
-- =========================================================
CREATE PROCEDURE proc_Admin_GetPromotionById
    @PromotionId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            p.Id,
            p.Name,
            CASE p.TypeId
                WHEN 1 THEN 'Percentage Discount'
                WHEN 2 THEN 'Fixed Amount Discount'
                WHEN 3 THEN 'Buy X Get Y'
                WHEN 4 THEN 'Multi Buy'
                WHEN 5 THEN 'Clubcard Price'
                ELSE        'Unknown'
            END                 AS TypeName,
            p.DiscountValue,
            p.DiscountPercent,
            p.MinimumQuantity   AS MinQuantity,
            p.ValidFrom         AS StartsAt,
            p.ValidTo           AS EndsAt,
            p.IsActive,
            p.CreatedOn,
            p.ModifiedOn
        FROM m.tblPromotion p
        WHERE p.Id        = @PromotionId
          AND p.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetPromotionById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreatePromotion
-- =========================================================
CREATE PROCEDURE proc_Admin_CreatePromotion
    @Name            NVARCHAR(200),
    @TypeId          TINYINT,
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
            (Name, TypeId, DiscountValue, DiscountPercent, MinimumQuantity,
             ValidFrom, ValidTo, IsActive,
             RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@Name, @TypeId, @DiscountValue, @DiscountPercent, @MinQuantity,
             @StartsAt, @EndsAt, 1,
             1, @AdminId, GETUTCDATE());

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

-- =========================================================
-- proc_Admin_UpdatePromotion
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdatePromotion
    @PromotionId     INT,
    @Name            NVARCHAR(200),
    @DiscountValue   DECIMAL(10,2) = NULL,
    @DiscountPercent DECIMAL(5,2)  = NULL,
    @MinQuantity     INT           = NULL,
    @StartsAt        DATETIME2     = NULL,
    @EndsAt          DATETIME2     = NULL,
    @IsActive        BIT,
    @AdminId         INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblPromotion
        SET Name             = @Name,
            DiscountValue    = @DiscountValue,
            DiscountPercent  = @DiscountPercent,
            MinimumQuantity  = @MinQuantity,
            ValidFrom        = @StartsAt,
            ValidTo          = @EndsAt,
            IsActive         = @IsActive,
            ModifiedBy       = @AdminId,
            ModifiedOn       = GETUTCDATE()
        WHERE Id        = @PromotionId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPromotion', @PromotionId, 'UPDATE',
                CONCAT('{"Name":"', @Name, '","IsActive":', @IsActive, '}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdatePromotion', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SoftDeletePromotion
-- =========================================================
CREATE PROCEDURE proc_Admin_SoftDeletePromotion
    @PromotionId INT,
    @AdminId     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblPromotion
        SET IsDeleted      = 1,
            RecordStatusId = 3,
            IsActive       = 0,
            ModifiedBy     = @AdminId,
            ModifiedOn     = GETUTCDATE()
        WHERE Id        = @PromotionId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPromotion', @PromotionId, 'DELETE', '{"IsDeleted":1}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SoftDeletePromotion', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V063')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V063', 'FixPromotionTableAndStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
