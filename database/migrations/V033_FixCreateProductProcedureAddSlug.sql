-- V033_FixCreateProductProcedureAddSlug.sql
-- Author: Tesco Clone
-- Date: 2026-05-14
-- Description: Recreate proc_Admin_CreateProduct with the @Slug parameter that was
--              added to V020 after the migration was first applied to the database.
--              Also recreate proc_Admin_UpdateProduct for consistency (slug is
--              preserved from the existing row on update, no parameter needed).
-- Dependencies: V020

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_CreateProduct', 'P') IS NOT NULL
        DROP PROCEDURE proc_Admin_CreateProduct;

    IF OBJECT_ID('proc_Admin_UpdateProduct', 'P') IS NOT NULL
        DROP PROCEDURE proc_Admin_UpdateProduct;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_CreateProduct  (with @Slug)
-- =========================================================
CREATE PROCEDURE proc_Admin_CreateProduct
    @CategoryId    INT,
    @BrandId       INT           = NULL,
    @Name          NVARCHAR(300),
    @Slug          NVARCHAR(320),
    @Description   NVARCHAR(MAX) = NULL,
    @BasePrice     DECIMAL(10,2),
    @ClubcardPrice DECIMAL(10,2) = NULL,
    @ImageUrl      NVARCHAR(500) = NULL,
    @IsAvailable   BIT,
    @AdminId       INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ProductId INT;

        INSERT INTO m.tblProduct
            (CategoryId, BrandId, Name, Slug, Description,
             BasePrice, ClubcardPrice, ImageUrl, IsAvailable,
             RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@CategoryId, @BrandId, @Name, @Slug, @Description,
             @BasePrice, @ClubcardPrice, @ImageUrl, @IsAvailable,
             1, @AdminId, GETUTCDATE());

        SET @ProductId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblProduct', @ProductId, 'INSERT',
                CONCAT('{"Name":"', @Name, '","CategoryId":', @CategoryId, ',"Slug":"', @Slug, '"}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @ProductId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreateProduct', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UpdateProduct  (slug preserved from existing row)
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdateProduct
    @ProductId     INT,
    @CategoryId    INT,
    @BrandId       INT           = NULL,
    @Name          NVARCHAR(300),
    @Description   NVARCHAR(MAX) = NULL,
    @BasePrice     DECIMAL(10,2),
    @ClubcardPrice DECIMAL(10,2) = NULL,
    @ImageUrl      NVARCHAR(500) = NULL,
    @IsAvailable   BIT,
    @AdminId       INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblProduct
        SET CategoryId    = @CategoryId,
            BrandId       = @BrandId,
            Name          = @Name,
            Description   = @Description,
            BasePrice     = @BasePrice,
            ClubcardPrice = @ClubcardPrice,
            ImageUrl      = @ImageUrl,
            IsAvailable   = @IsAvailable,
            ModifiedBy    = @AdminId,
            ModifiedOn    = GETUTCDATE()
        WHERE Id = @ProductId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblProduct', @ProductId, 'UPDATE',
                CONCAT('{"Name":"', @Name, '","BasePrice":', @BasePrice, '}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdateProduct', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V033')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V033', 'FixCreateProductProcedureAddSlug');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
