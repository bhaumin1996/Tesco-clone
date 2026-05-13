-- V021_CreateAdminPromotionStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Admin stored procedures for promotion management
-- Dependencies: V001-V010

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetPromotions',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetPromotions;
    IF OBJECT_ID('proc_Admin_GetPromotionById',   'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetPromotionById;
    IF OBJECT_ID('proc_Admin_CreatePromotion',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreatePromotion;
    IF OBJECT_ID('proc_Admin_UpdatePromotion',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdatePromotion;
    IF OBJECT_ID('proc_Admin_SoftDeletePromotion','P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeletePromotion;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
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
            pt.Name AS TypeName,
            p.DiscountValue,
            p.DiscountPercent,
            p.MinQuantity,
            p.StartsAt,
            p.EndsAt,
            p.IsActive,
            p.CreatedOn,
            p.ModifiedOn,
            COUNT(1) OVER () AS TotalCount
        FROM m.tblPromotion p
        INNER JOIN m.tblPromotionType pt ON pt.Id = p.PromotionTypeId
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
            pt.Name AS TypeName,
            p.DiscountValue,
            p.DiscountPercent,
            p.MinQuantity,
            p.StartsAt,
            p.EndsAt,
            p.IsActive,
            p.CreatedOn,
            p.ModifiedOn
        FROM m.tblPromotion p
        INNER JOIN m.tblPromotionType pt ON pt.Id = p.PromotionTypeId
        WHERE p.Id = @PromotionId
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
    @DiscountValue   DECIMAL(10,2) = NULL,
    @DiscountPercent DECIMAL(5,2)  = NULL,
    @MinQuantity     INT = NULL,
    @StartsAt        DATETIME2 = NULL,
    @EndsAt          DATETIME2 = NULL,
    @AdminId         INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @PromotionId INT;

        INSERT INTO m.tblPromotion
            (Name, PromotionTypeId, DiscountValue, DiscountPercent, MinQuantity, StartsAt, EndsAt, IsActive,
             RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@Name, 1, @DiscountValue, @DiscountPercent, @MinQuantity, @StartsAt, @EndsAt, 1,
             1, @AdminId, GETUTCDATE());

        SET @PromotionId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPromotion', @PromotionId, 'INSERT',
                CONCAT('{"Name":"', @Name, '"}'),
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
    @MinQuantity     INT = NULL,
    @StartsAt        DATETIME2 = NULL,
    @EndsAt          DATETIME2 = NULL,
    @IsActive        BIT,
    @AdminId         INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblPromotion
        SET Name            = @Name,
            DiscountValue   = @DiscountValue,
            DiscountPercent = @DiscountPercent,
            MinQuantity     = @MinQuantity,
            StartsAt        = @StartsAt,
            EndsAt          = @EndsAt,
            IsActive        = @IsActive,
            ModifiedBy      = @AdminId,
            ModifiedOn      = GETUTCDATE()
        WHERE Id = @PromotionId
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
        WHERE Id = @PromotionId
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
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V021')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V021', 'CreateAdminPromotionStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
