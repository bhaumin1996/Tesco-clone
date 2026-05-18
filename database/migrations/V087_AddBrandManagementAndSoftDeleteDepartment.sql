-- V087_AddBrandManagementAndSoftDeleteDepartment.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Add stored procedures for Brand creation, update, and soft deletion; add soft deletion for Departments; recreate GetDepartments and GetBrands to return all fields.
-- Dependencies: V006, V027, V031, V032

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetDepartments',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetDepartments;
    IF OBJECT_ID('proc_Admin_SoftDeleteDepartment', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeleteDepartment;
    IF OBJECT_ID('proc_Admin_GetBrands',            'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetBrands;
    IF OBJECT_ID('proc_Admin_CreateBrand',          'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreateBrand;
    IF OBJECT_ID('proc_Admin_UpdateBrand',          'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdateBrand;
    IF OBJECT_ID('proc_Admin_SoftDeleteBrand',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeleteBrand;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetDepartments
-- =========================================================
CREATE PROCEDURE proc_Admin_GetDepartments
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            d.Id   AS DepartmentId,
            d.Name,
            d.Slug,
            d.ImageUrl
        FROM m.tblDepartment d
        WHERE d.IsDeleted = 0
        ORDER BY d.DisplayOrder, d.Name;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetDepartments', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SoftDeleteDepartment
-- =========================================================
CREATE PROCEDURE proc_Admin_SoftDeleteDepartment
    @DepartmentId INT,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblDepartment
        SET RecordStatusId = 3,
            IsDeleted      = 1,
            ModifiedBy     = @AdminId,
            ModifiedOn     = GETUTCDATE()
        WHERE Id = @DepartmentId
          AND IsDeleted = 0;

        -- Soft delete categories belonging to this department
        UPDATE m.tblCategory
        SET RecordStatusId = 3,
            IsDeleted      = 1,
            ModifiedBy     = @AdminId,
            ModifiedOn     = GETUTCDATE()
        WHERE DepartmentId = @DepartmentId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblDepartment', @DepartmentId, 'DELETE', '{"IsDeleted":1}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SoftDeleteDepartment', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetBrands
-- =========================================================
CREATE PROCEDURE proc_Admin_GetBrands
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            Id       AS BrandId,
            Name,
            Slug,
            LogoUrl
        FROM m.tblBrand
        WHERE IsDeleted = 0
        ORDER BY Name ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetBrands', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreateBrand
-- =========================================================
CREATE PROCEDURE proc_Admin_CreateBrand
    @Name    NVARCHAR(200),
    @Slug    NVARCHAR(200),
    @LogoUrl NVARCHAR(500) = NULL,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @BrandId INT;

        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@Name, @Slug, @LogoUrl, 1, @AdminId, GETUTCDATE());

        SET @BrandId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblBrand', @BrandId, 'INSERT',
                CONCAT('{"Name":"', @Name, '","Slug":"', @Slug, '"}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @BrandId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreateBrand', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UpdateBrand
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdateBrand
    @BrandId INT,
    @Name    NVARCHAR(200),
    @Slug    NVARCHAR(200),
    @LogoUrl NVARCHAR(500) = NULL,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblBrand
        SET Name       = @Name,
            Slug       = @Slug,
            LogoUrl    = @LogoUrl,
            ModifiedBy = @AdminId,
            ModifiedOn = GETUTCDATE()
        WHERE Id = @BrandId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblBrand', @BrandId, 'UPDATE',
                CONCAT('{"Name":"', @Name, '","Slug":"', @Slug, '"}'),
                @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdateBrand', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SoftDeleteBrand
-- =========================================================
CREATE PROCEDURE proc_Admin_SoftDeleteBrand
    @BrandId INT,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblBrand
        SET RecordStatusId = 3,
            IsDeleted      = 1,
            ModifiedBy     = @AdminId,
            ModifiedOn     = GETUTCDATE()
        WHERE Id = @BrandId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblBrand', @BrandId, 'DELETE', '{"IsDeleted":1}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SoftDeleteBrand', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V087')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V087', 'AddBrandManagementAndSoftDeleteDepartment');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
