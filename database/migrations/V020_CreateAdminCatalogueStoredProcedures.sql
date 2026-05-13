-- V020_CreateAdminCatalogueStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Admin stored procedures for catalogue, category, department, and inventory management
-- Dependencies: V001-V006

BEGIN TRY
    BEGIN TRANSACTION;

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

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetProducts
-- =========================================================
CREATE PROCEDURE proc_Admin_GetProducts
    @Search       NVARCHAR(256) = NULL,
    @CategoryId   INT = NULL,
    @DepartmentId INT = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            p.Id,
            p.CategoryId,
            c.Name AS CategoryName,
            p.BrandId,
            b.Name AS BrandName,
            p.Name,
            p.Slug,
            p.Description,
            p.BasePrice,
            p.ClubcardPrice,
            p.ImageUrl,
            p.IsAvailable,
            ISNULL(pv.TotalStock, 0) AS StockQuantity,
            p.CreatedOn,
            p.ModifiedOn,
            COUNT(1) OVER () AS TotalCount
        FROM m.tblProduct p
        INNER JOIN m.tblCategory c ON c.Id = p.CategoryId
        INNER JOIN m.tblDepartment d ON d.Id = c.DepartmentId
        LEFT  JOIN m.tblBrand b ON b.Id = p.BrandId
        LEFT  JOIN (
            SELECT ProductId, SUM(StockQuantity) AS TotalStock
            FROM m.tblProductVariant
            WHERE IsDeleted = 0
            GROUP BY ProductId
        ) pv ON pv.ProductId = p.Id
        WHERE p.IsDeleted = 0
          AND (@Search IS NULL OR p.Name LIKE '%' + @Search + '%' OR p.Slug LIKE '%' + @Search + '%')
          AND (@CategoryId IS NULL OR p.CategoryId = @CategoryId)
          AND (@DepartmentId IS NULL OR c.DepartmentId = @DepartmentId)
        ORDER BY p.CreatedOn DESC
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
    @CategoryId    INT,
    @BrandId       INT = NULL,
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
            (CategoryId, BrandId, Name, Slug, Description, BasePrice, ClubcardPrice, ImageUrl, IsAvailable,
             RecordStatusId, CreatedBy, CreatedOn)
        VALUES
            (@CategoryId, @BrandId, @Name, @Slug, @Description, @BasePrice, @ClubcardPrice, @ImageUrl, @IsAvailable,
             1, @AdminId, GETUTCDATE());

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
    @ProductId     INT,
    @CategoryId    INT,
    @BrandId       INT = NULL,
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
        SET IsDeleted      = 1,
            RecordStatusId = 3,
            ModifiedBy     = @AdminId,
            ModifiedOn     = GETUTCDATE()
        WHERE Id = @ProductId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblProduct', @ProductId, 'DELETE',
                '{"IsDeleted":1}',
                @AdminId, GETUTCDATE());

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
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CategoryId INT;

        INSERT INTO m.tblCategory (Name, DepartmentId, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@Name, @DepartmentId, 1, @AdminId, GETUTCDATE());

        SET @CategoryId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCategory', @CategoryId, 'INSERT',
                CONCAT('{"Name":"', @Name, '","DepartmentId":', @DepartmentId, '}'),
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
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblCategory
        SET Name         = @Name,
            DepartmentId = @DepartmentId,
            ModifiedBy   = @AdminId,
            ModifiedOn   = GETUTCDATE()
        WHERE Id = @CategoryId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCategory', @CategoryId, 'UPDATE',
                CONCAT('{"Name":"', @Name, '"}'),
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
        SET IsDeleted      = 1,
            RecordStatusId = 3,
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
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @DepartmentId INT;

        INSERT INTO m.tblDepartment (Name, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@Name, 1, @AdminId, GETUTCDATE());

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
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblDepartment
        SET Name       = @Name,
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
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V020')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V020', 'CreateAdminCatalogueStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
