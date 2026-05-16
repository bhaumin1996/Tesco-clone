-- V060_AddSlugToAdminCategoryProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-16
-- Description: Add @Slug parameter to proc_Admin_CreateCategory and proc_Admin_UpdateCategory.
--              V029 added @ImageUrl but left Slug out of the INSERT, causing NOT NULL violation.
--              The application now generates the slug from the name and passes it explicitly.
-- Dependencies: V029

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;
    IF OBJECT_ID('proc_Admin_CreateCategory', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreateCategory;
    IF OBJECT_ID('proc_Admin_UpdateCategory', 'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdateCategory;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_CreateCategory
-- =========================================================
CREATE PROCEDURE proc_Admin_CreateCategory
    @Name         NVARCHAR(200),
    @Slug         NVARCHAR(220),
    @DepartmentId INT,
    @ImageUrl     NVARCHAR(500) = NULL,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CategoryId INT;

        INSERT INTO m.tblCategory (Name, Slug, DepartmentId, ImageUrl, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@Name, @Slug, @DepartmentId, @ImageUrl, 1, @AdminId, GETUTCDATE());

        SET @CategoryId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCategory', @CategoryId, 'INSERT',
                CONCAT('{"Name":"', @Name, '","Slug":"', @Slug, '","DepartmentId":', @DepartmentId,
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
    @Slug         NVARCHAR(220),
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
            Slug         = @Slug,
            DepartmentId = @DepartmentId,
            ImageUrl     = CASE WHEN @ImageUrl IS NOT NULL THEN @ImageUrl ELSE ImageUrl END,
            ModifiedBy   = @AdminId,
            ModifiedOn   = GETUTCDATE()
        WHERE Id = @CategoryId
          AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCategory', @CategoryId, 'UPDATE',
                CONCAT('{"Name":"', @Name, '","Slug":"', @Slug, '","DepartmentId":', @DepartmentId,
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
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V060')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V060', 'AddSlugToAdminCategoryProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
