-- V031_FixQuotedIdentifierOnStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-14
-- Description: Recreate proc_Admin_AdjustInventory (and all V020 + V028 stored procedures)
--              with SET QUOTED_IDENTIFIER ON. SQL Server stores the QUOTED_IDENTIFIER
--              setting at procedure creation time; without it ON, UPDATEs on tables with
--              filtered indexes or computed columns raise error 1934.
-- Dependencies: V001-V028

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- Drop and recreate all V020 stored procedures
-- =========================================================
IF OBJECT_ID('proc_Admin_GetProducts',        'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetProducts;
IF OBJECT_ID('proc_Admin_CreateProduct',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreateProduct;
IF OBJECT_ID('proc_Admin_UpdateProduct',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdateProduct;
IF OBJECT_ID('proc_Admin_SoftDeleteProduct',  'P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeleteProduct;
IF OBJECT_ID('proc_Admin_CreateCategory',     'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreateCategory;
IF OBJECT_ID('proc_Admin_UpdateCategory',     'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdateCategory;
IF OBJECT_ID('proc_Admin_SoftDeleteCategory', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeleteCategory;
IF OBJECT_ID('proc_Admin_CreateDepartment',   'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreateDepartment;
IF OBJECT_ID('proc_Admin_UpdateDepartment',   'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdateDepartment;
IF OBJECT_ID('proc_Admin_AdjustInventory',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_AdjustInventory;
GO

-- =========================================================
-- proc_Admin_GetProducts
-- =========================================================
CREATE PROCEDURE proc_Admin_GetProducts
    @PageNumber     INT = 1,
    @PageSize       INT = 20,
    @SearchTerm     NVARCHAR(200) = NULL,
    @CategoryId     INT = NULL,
    @DepartmentId   INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            p.Id,
            p.Name,
            p.Slug,
            p.Description,
            p.BasePrice,
            p.ClubcardPrice,
            p.ImageUrl,
            p.IsAvailable,
            p.RecordStatusId,
            c.Name  AS CategoryName,
            d.Name  AS DepartmentName,
            b.Name  AS BrandName,
            COUNT(*) OVER () AS TotalCount
        FROM m.tblProduct p
        INNER JOIN m.tblCategory   c ON c.Id = p.CategoryId   AND c.IsDeleted = 0
        INNER JOIN m.tblDepartment d ON d.Id = c.DepartmentId AND d.IsDeleted = 0
        LEFT  JOIN m.tblBrand      b ON b.Id = p.BrandId      AND b.IsDeleted = 0
        WHERE p.IsDeleted = 0
          AND (@SearchTerm   IS NULL OR p.Name LIKE '%' + @SearchTerm + '%')
          AND (@CategoryId   IS NULL OR p.CategoryId = @CategoryId)
          AND (@DepartmentId IS NULL OR c.DepartmentId = @DepartmentId)
        ORDER BY p.Name
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetProducts', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreateProduct
-- =========================================================
CREATE PROCEDURE proc_Admin_CreateProduct
    @Name         NVARCHAR(200),
    @Slug         NVARCHAR(200),
    @Description  NVARCHAR(MAX) = NULL,
    @BasePrice    DECIMAL(10,2),
    @ClubcardPrice DECIMAL(10,2) = NULL,
    @ImageUrl     NVARCHAR(500) = NULL,
    @CategoryId   INT,
    @BrandId      INT = NULL,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @ProductId INT;

        INSERT INTO m.tblProduct (Name, Slug, Description, BasePrice, ClubcardPrice, ImageUrl,
                                  CategoryId, BrandId, IsAvailable, RecordStatusId,
                                  CreatedBy, CreatedOn)
        VALUES (@Name, @Slug, @Description, @BasePrice, @ClubcardPrice, @ImageUrl,
                @CategoryId, @BrandId, 1, 1, @AdminId, GETUTCDATE());

        SET @ProductId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblProduct', @ProductId, 'INSERT',
                CONCAT('{"Name":"', @Name, '","CategoryId":', @CategoryId, '}'),
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
-- proc_Admin_UpdateProduct
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdateProduct
    @ProductId    INT,
    @Name         NVARCHAR(200),
    @Slug         NVARCHAR(200),
    @Description  NVARCHAR(MAX) = NULL,
    @BasePrice    DECIMAL(10,2),
    @ClubcardPrice DECIMAL(10,2) = NULL,
    @ImageUrl     NVARCHAR(500) = NULL,
    @CategoryId   INT,
    @BrandId      INT = NULL,
    @IsAvailable  BIT,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblProduct
        SET Name          = @Name,
            Slug          = @Slug,
            Description   = @Description,
            BasePrice     = @BasePrice,
            ClubcardPrice = @ClubcardPrice,
            ImageUrl      = @ImageUrl,
            CategoryId    = @CategoryId,
            BrandId       = @BrandId,
            IsAvailable   = @IsAvailable,
            ModifiedBy    = @AdminId,
            ModifiedOn    = GETUTCDATE()
        WHERE Id = @ProductId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblProduct', @ProductId, 'UPDATE',
                CONCAT('{"Name":"', @Name, '","CategoryId":', @CategoryId, '}'),
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
-- proc_Admin_SoftDeleteProduct
-- =========================================================
CREATE PROCEDURE proc_Admin_SoftDeleteProduct
    @ProductId INT,
    @AdminId   INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblProduct
        SET RecordStatusId = 3,
            IsDeleted      = 1,
            ModifiedBy     = @AdminId,
            ModifiedOn     = GETUTCDATE()
        WHERE Id = @ProductId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblProduct', @ProductId, 'DELETE', '{"IsDeleted":1}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SoftDeleteProduct', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreateCategory
-- =========================================================
CREATE PROCEDURE proc_Admin_CreateCategory
    @Name         NVARCHAR(200),
    @DepartmentId INT,
    @ImageUrl     NVARCHAR(500) = NULL,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CategoryId INT;

        INSERT INTO m.tblCategory (Name, DepartmentId, ImageUrl, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@Name, @DepartmentId, @ImageUrl, 1, @AdminId, GETUTCDATE());

        SET @CategoryId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCategory', @CategoryId, 'INSERT',
                CONCAT('{"Name":"', @Name, '","DepartmentId":', @DepartmentId,
                       ',"ImageUrl":', ISNULL(CONCAT('"', @ImageUrl, '"'), 'null'), '}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @CategoryId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreateCategory', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UpdateCategory
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdateCategory
    @CategoryId   INT,
    @Name         NVARCHAR(200),
    @DepartmentId INT,
    @ImageUrl     NVARCHAR(500) = NULL,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblCategory
        SET Name         = @Name,
            DepartmentId = @DepartmentId,
            ImageUrl     = CASE WHEN @ImageUrl IS NOT NULL THEN @ImageUrl ELSE ImageUrl END,
            ModifiedBy   = @AdminId,
            ModifiedOn   = GETUTCDATE()
        WHERE Id = @CategoryId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCategory', @CategoryId, 'UPDATE',
                CONCAT('{"Name":"', @Name, '","DepartmentId":', @DepartmentId,
                       ',"ImageUrl":', ISNULL(CONCAT('"', @ImageUrl, '"'), 'null'), '}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdateCategory', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SoftDeleteCategory
-- =========================================================
CREATE PROCEDURE proc_Admin_SoftDeleteCategory
    @CategoryId INT,
    @AdminId    INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblCategory
        SET RecordStatusId = 3,
            IsDeleted      = 1,
            ModifiedBy     = @AdminId,
            ModifiedOn     = GETUTCDATE()
        WHERE Id = @CategoryId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCategory', @CategoryId, 'DELETE', '{"IsDeleted":1}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SoftDeleteCategory', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreateDepartment
-- =========================================================
CREATE PROCEDURE proc_Admin_CreateDepartment
    @Name    NVARCHAR(200),
    @Slug    NVARCHAR(200),
    @IconUrl NVARCHAR(500) = NULL,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @DepartmentId INT;

        INSERT INTO m.tblDepartment (Name, Slug, ImageUrl, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@Name, @Slug, @IconUrl, 1, @AdminId, GETUTCDATE());

        SET @DepartmentId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblDepartment', @DepartmentId, 'INSERT',
                CONCAT('{"Name":"', @Name, '"}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @DepartmentId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreateDepartment', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UpdateDepartment
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdateDepartment
    @DepartmentId INT,
    @Name         NVARCHAR(200),
    @Slug         NVARCHAR(200),
    @IconUrl      NVARCHAR(500) = NULL,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblDepartment
        SET Name       = @Name,
            Slug       = @Slug,
            ImageUrl    = @IconUrl,
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @DepartmentId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblDepartment', @DepartmentId, 'UPDATE',
                CONCAT('{"Name":"', @Name, '"}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdateDepartment', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_AdjustInventory
-- =========================================================
CREATE PROCEDURE proc_Admin_AdjustInventory
    @ProductVariantId INT,
    @QuantityDelta    INT,
    @AdminId          INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblProductVariant
        SET StockQuantity = StockQuantity + @QuantityDelta,
            ModifiedBy    = @AdminId,
            ModifiedOn    = GETUTCDATE()
        WHERE Id = @ProductVariantId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblProductVariant', @ProductVariantId, 'UPDATE',
                CONCAT('{"QuantityDelta":', @QuantityDelta, '}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_AdjustInventory', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V031')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V031', 'FixQuotedIdentifierOnStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
