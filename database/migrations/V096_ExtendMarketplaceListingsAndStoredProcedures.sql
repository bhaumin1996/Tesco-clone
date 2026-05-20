-- V096_ExtendMarketplaceListingsAndStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Full seller listing CRUD support.
--              Adds m.tblListingStatus reference table, extends t.tblListing with
--              content columns (Title, Description, Slug, ImageUrl, StatusId, EAN,
--              Weight, CategoryId), and creates all marketplace listing stored procedures.
-- Dependencies: V001-V012, V028

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- PART 1: Reference table — m.tblListingStatus
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblListingStatus')
    BEGIN
        CREATE TABLE m.tblListingStatus (
            Id   TINYINT NOT NULL PRIMARY KEY,
            Name NVARCHAR(50) NOT NULL
        );
        INSERT INTO m.tblListingStatus (Id, Name)
        VALUES (1, 'Draft'), (2, 'Published'), (3, 'Unpublished');
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V096_Part1')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V096_Part1', 'ExtendMarketplace_ListingStatusTable');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V096_Part1', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 2: Extend t.tblListing with content columns
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblListing' AND COLUMN_NAME='Title')
        ALTER TABLE t.tblListing ADD Title NVARCHAR(300) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblListing' AND COLUMN_NAME='Description')
        ALTER TABLE t.tblListing ADD Description NVARCHAR(MAX) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblListing' AND COLUMN_NAME='Slug')
        ALTER TABLE t.tblListing ADD Slug NVARCHAR(300) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblListing' AND COLUMN_NAME='ImageUrl')
        ALTER TABLE t.tblListing ADD ImageUrl NVARCHAR(500) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblListing' AND COLUMN_NAME='StatusId')
        ALTER TABLE t.tblListing ADD StatusId TINYINT NOT NULL DEFAULT 1;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblListing' AND COLUMN_NAME='EAN')
        ALTER TABLE t.tblListing ADD EAN NVARCHAR(50) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblListing' AND COLUMN_NAME='Weight')
        ALTER TABLE t.tblListing ADD Weight DECIMAL(8,3) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblListing' AND COLUMN_NAME='CategoryId')
        ALTER TABLE t.tblListing ADD CategoryId INT NULL;

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V096_Part2')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V096_Part2', 'ExtendMarketplace_ListingColumns');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V096_Part2', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 2b: Back-fill StatusId for existing rows
-- Must be a separate batch from the ALTER TABLE statements above.
-- SQL Server compiles the whole batch before execution, so referencing
-- newly added columns in the same batch as ALTER TABLE causes a
-- parse-time "Invalid column name" error.
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE t.tblListing
    SET StatusId = CASE WHEN IsActive = 1 THEN 2 ELSE 3 END
    WHERE StatusId = 1 AND Title IS NULL;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
    VALUES ('Error', 'V096_Part2b', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 3: Drop existing listing SPs before re-creating
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('proc_Marketplace_GetSellerListings',  'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerListings;
    IF OBJECT_ID('proc_Marketplace_GetListingById',     'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetListingById;
    IF OBJECT_ID('proc_Marketplace_CreateListing',      'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_CreateListing;
    IF OBJECT_ID('proc_Marketplace_UpdateListing',      'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_UpdateListing;
    IF OBJECT_ID('proc_Marketplace_PublishListing',     'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_PublishListing;
    IF OBJECT_ID('proc_Marketplace_UnpublishListing',   'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_UnpublishListing;
    IF OBJECT_ID('proc_Marketplace_SoftDeleteListing',  'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_SoftDeleteListing;
    IF OBJECT_ID('proc_Marketplace_GetSellerByUserId',  'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerByUserId;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Marketplace_GetSellerByUserId
-- =========================================================
CREATE PROCEDURE proc_Marketplace_GetSellerByUserId
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            s.Id,
            s.BusinessName,
            s.ContactEmail,
            ss.Name AS StatusName,
            s.CommissionRate,
            s.CreatedOn,
            s.ModifiedOn
        FROM t.tblSeller s
        INNER JOIN m.tblSellerStatus ss ON ss.Id = s.StatusId
        WHERE s.UserId = @UserId AND s.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_GetSellerByUserId', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Marketplace_GetSellerListings
-- =========================================================
CREATE PROCEDURE proc_Marketplace_GetSellerListings
    @SellerId    INT,
    @StatusFilter NVARCHAR(50) = NULL,
    @PageNumber  INT = 1,
    @PageSize    INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            l.Id,
            l.SellerId,
            l.ProductId,
            l.Title,
            l.Description,
            l.Slug,
            l.ImageUrl,
            l.Price,
            l.StockQuantity,
            l.EAN,
            l.Weight,
            l.CategoryId,
            ls.Name AS StatusName,
            l.IsActive,
            l.CreatedOn,
            l.ModifiedOn,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblListing l
        INNER JOIN m.tblListingStatus ls ON ls.Id = l.StatusId
        WHERE l.SellerId = @SellerId
          AND l.IsDeleted = 0
          AND (@StatusFilter IS NULL OR ls.Name = @StatusFilter)
        ORDER BY l.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_GetSellerListings', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Marketplace_GetListingById
-- =========================================================
CREATE PROCEDURE proc_Marketplace_GetListingById
    @ListingId INT,
    @SellerId  INT = NULL  -- NULL = admin access (no ownership check)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            l.Id,
            l.SellerId,
            l.ProductId,
            l.Title,
            l.Description,
            l.Slug,
            l.ImageUrl,
            l.Price,
            l.StockQuantity,
            l.EAN,
            l.Weight,
            l.CategoryId,
            ls.Name AS StatusName,
            l.IsActive,
            l.CreatedOn,
            l.ModifiedOn
        FROM t.tblListing l
        INNER JOIN m.tblListingStatus ls ON ls.Id = l.StatusId
        WHERE l.Id = @ListingId
          AND l.IsDeleted = 0
          AND (@SellerId IS NULL OR l.SellerId = @SellerId);
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_GetListingById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Marketplace_CreateListing
-- =========================================================
CREATE PROCEDURE proc_Marketplace_CreateListing
    @SellerId     INT,
    @ProductId    INT = NULL,
    @Title        NVARCHAR(300),
    @Description  NVARCHAR(MAX) = NULL,
    @Slug         NVARCHAR(300) = NULL,
    @ImageUrl     NVARCHAR(500) = NULL,
    @Price        DECIMAL(10,2),
    @StockQuantity INT,
    @EAN          NVARCHAR(50) = NULL,
    @Weight       DECIMAL(8,3) = NULL,
    @CategoryId   INT = NULL,
    @CreatedBy    INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Auto-generate slug from title if not supplied
        IF @Slug IS NULL OR LEN(LTRIM(RTRIM(@Slug))) = 0
            SET @Slug = LOWER(REPLACE(REPLACE(REPLACE(@Title, ' ', '-'), '''', ''), ',', ''));

        INSERT INTO t.tblListing
            (SellerId, ProductId, Title, Description, Slug, ImageUrl,
             Price, StockQuantity, EAN, Weight, CategoryId,
             StatusId, IsActive,
             RecordStatusId, CreatedBy, CreatedOn, IsDeleted)
        VALUES
            (@SellerId, @ProductId, @Title, @Description, @Slug, @ImageUrl,
             @Price, @StockQuantity, @EAN, @Weight, @CategoryId,
             1, 0,
             1, @CreatedBy, GETUTCDATE(), 0);

        DECLARE @NewId INT = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblListing', @NewId, 'CREATE',
                CONCAT('{"SellerId":', @SellerId, ',"Title":"', @Title, '","Price":', @Price, '}'),
                @CreatedBy, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @NewId AS ListingId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_CreateListing', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Marketplace_UpdateListing
-- =========================================================
CREATE PROCEDURE proc_Marketplace_UpdateListing
    @ListingId    INT,
    @SellerId     INT,
    @Title        NVARCHAR(300),
    @Description  NVARCHAR(MAX) = NULL,
    @Slug         NVARCHAR(300) = NULL,
    @ImageUrl     NVARCHAR(500) = NULL,
    @Price        DECIMAL(10,2),
    @StockQuantity INT,
    @EAN          NVARCHAR(50) = NULL,
    @Weight       DECIMAL(8,3) = NULL,
    @CategoryId   INT = NULL,
    @ModifiedBy   INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM t.tblListing WHERE Id = @ListingId AND SellerId = @SellerId AND IsDeleted = 0)
        BEGIN
            COMMIT TRANSACTION;
            RETURN;
        END

        UPDATE t.tblListing
        SET Title         = @Title,
            Description   = @Description,
            Slug          = ISNULL(NULLIF(@Slug,''), Slug),
            ImageUrl      = @ImageUrl,
            Price         = @Price,
            StockQuantity = @StockQuantity,
            EAN           = @EAN,
            Weight        = @Weight,
            CategoryId    = @CategoryId,
            ModifiedBy    = @ModifiedBy,
            ModifiedOn    = GETUTCDATE()
        WHERE Id = @ListingId AND SellerId = @SellerId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblListing', @ListingId, 'UPDATE',
                CONCAT('{"Title":"', @Title, '","Price":', @Price, '}'),
                @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_UpdateListing', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Marketplace_PublishListing
-- =========================================================
CREATE PROCEDURE proc_Marketplace_PublishListing
    @ListingId  INT,
    @SellerId   INT,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblListing
        SET StatusId   = 2,
            IsActive   = 1,
            ModifiedBy = @ModifiedBy,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @ListingId AND SellerId = @SellerId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblListing', @ListingId, 'UPDATE', '{"StatusId":2,"Action":"Published"}', @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_PublishListing', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Marketplace_UnpublishListing
-- =========================================================
CREATE PROCEDURE proc_Marketplace_UnpublishListing
    @ListingId  INT,
    @SellerId   INT,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblListing
        SET StatusId   = 3,
            IsActive   = 0,
            ModifiedBy = @ModifiedBy,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @ListingId AND SellerId = @SellerId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblListing', @ListingId, 'UPDATE', '{"StatusId":3,"Action":"Unpublished"}', @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_UnpublishListing', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Marketplace_SoftDeleteListing
-- =========================================================
CREATE PROCEDURE proc_Marketplace_SoftDeleteListing
    @ListingId  INT,
    @SellerId   INT,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE t.tblListing
        SET RecordStatusId = 3,
            IsDeleted      = 1,
            IsActive       = 0,
            ModifiedBy     = @ModifiedBy,
            ModifiedOn     = GETUTCDATE()
        WHERE Id = @ListingId AND SellerId = @SellerId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblListing', @ListingId, 'DELETE', '{"Action":"SoftDeleted"}', @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Marketplace_SoftDeleteListing', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V096')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V096', 'ExtendMarketplaceListingsAndStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
