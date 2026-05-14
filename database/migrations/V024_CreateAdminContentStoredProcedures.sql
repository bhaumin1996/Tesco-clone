-- V024_CreateAdminContentStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Admin stored procedures for CMS pages and banners
-- Dependencies: V001-V011

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GetPages',        'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetPages;
    IF OBJECT_ID('proc_Admin_GetPageById',     'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetPageById;
    IF OBJECT_ID('proc_Admin_CreatePage',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreatePage;
    IF OBJECT_ID('proc_Admin_UpdatePage',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdatePage;
    IF OBJECT_ID('proc_Admin_SoftDeletePage',  'P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeletePage;
    IF OBJECT_ID('proc_Admin_GetBanners',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetBanners;
    IF OBJECT_ID('proc_Admin_CreateBanner',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_CreateBanner;
    IF OBJECT_ID('proc_Admin_UpdateBanner',    'P') IS NOT NULL DROP PROCEDURE proc_Admin_UpdateBanner;
    IF OBJECT_ID('proc_Admin_SoftDeleteBanner','P') IS NOT NULL DROP PROCEDURE proc_Admin_SoftDeleteBanner;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GetPages
-- =========================================================
CREATE PROCEDURE proc_Admin_GetPages
    @IsPublished BIT = NULL,
    @PageNumber  INT = 1,
    @PageSize    INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

        SELECT
            p.Id,
            p.Title,
            p.Slug,
            p.Content,
            p.IsPublished,
            p.CreatedOn,
            p.ModifiedOn,
            COUNT(1) OVER () AS TotalCount
        FROM m.tblPage p
        WHERE p.IsDeleted = 0
          AND (@IsPublished IS NULL OR p.IsPublished = @IsPublished)
        ORDER BY p.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetPages', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetPageById
-- =========================================================
CREATE PROCEDURE proc_Admin_GetPageById
    @PageId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, Title, Slug, Content, IsPublished, CreatedOn, ModifiedOn
        FROM m.tblPage
        WHERE Id = @PageId AND IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetPageById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreatePage
-- =========================================================
CREATE PROCEDURE proc_Admin_CreatePage
    @Title       NVARCHAR(300),
    @Slug        NVARCHAR(320),
    @Content     NVARCHAR(MAX) = NULL,
    @IsPublished BIT,
    @AdminId     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @PageId INT;

        INSERT INTO m.tblPage (Title, Slug, Content, IsPublished, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@Title, @Slug, @Content, @IsPublished, 1, @AdminId, GETUTCDATE());

        SET @PageId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPage', @PageId, 'INSERT', CONCAT('{"Title":"', @Title, '"}'), @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @PageId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreatePage', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UpdatePage
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdatePage
    @PageId      INT,
    @Title       NVARCHAR(300),
    @Content     NVARCHAR(MAX) = NULL,
    @IsPublished BIT,
    @AdminId     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblPage
        SET Title       = @Title,
            Content     = @Content,
            IsPublished = @IsPublished,
            ModifiedBy  = @AdminId,
            ModifiedOn  = GETUTCDATE()
        WHERE Id = @PageId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPage', @PageId, 'UPDATE', CONCAT('{"Title":"', @Title, '"}'), @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdatePage', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SoftDeletePage
-- =========================================================
CREATE PROCEDURE proc_Admin_SoftDeletePage
    @PageId  INT,
    @AdminId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblPage
        SET IsDeleted = 1, RecordStatusId = 3, ModifiedBy = @AdminId, ModifiedOn = GETUTCDATE()
        WHERE Id = @PageId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblPage', @PageId, 'DELETE', '{"IsDeleted":1}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SoftDeletePage', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_GetBanners
-- =========================================================
CREATE PROCEDURE proc_Admin_GetBanners
    @IsActive BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, Title, SubTitle, ImageUrl, LinkUrl, DisplayOrder, IsActive, StartsAt, EndsAt, CreatedOn, ModifiedOn
        FROM m.tblBanner
        WHERE IsDeleted = 0
          AND (@IsActive IS NULL OR IsActive = @IsActive)
        ORDER BY DisplayOrder ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetBanners', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_CreateBanner
-- =========================================================
CREATE PROCEDURE proc_Admin_CreateBanner
    @Title        NVARCHAR(200),
    @SubTitle     NVARCHAR(300) = NULL,
    @ImageUrl     NVARCHAR(500) = NULL,
    @LinkUrl      NVARCHAR(500) = NULL,
    @DisplayOrder INT = 0,
    @IsActive     BIT = 1,
    @StartsAt     DATETIME2 = NULL,
    @EndsAt       DATETIME2 = NULL,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @BannerId INT;

        INSERT INTO m.tblBanner (Title, SubTitle, ImageUrl, LinkUrl, DisplayOrder, IsActive, StartsAt, EndsAt, RecordStatusId, CreatedBy, CreatedOn)
        VALUES (@Title, @SubTitle, @ImageUrl, @LinkUrl, @DisplayOrder, @IsActive, @StartsAt, @EndsAt, 1, @AdminId, GETUTCDATE());

        SET @BannerId = SCOPE_IDENTITY();

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblBanner', @BannerId, 'INSERT', CONCAT('{"Title":"', @Title, '"}'), @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
        SELECT @BannerId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_CreateBanner', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_UpdateBanner
-- =========================================================
CREATE PROCEDURE proc_Admin_UpdateBanner
    @BannerId     INT,
    @Title        NVARCHAR(200),
    @SubTitle     NVARCHAR(300) = NULL,
    @ImageUrl     NVARCHAR(500) = NULL,
    @LinkUrl      NVARCHAR(500) = NULL,
    @DisplayOrder INT,
    @IsActive     BIT,
    @StartsAt     DATETIME2 = NULL,
    @EndsAt       DATETIME2 = NULL,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblBanner
        SET Title = @Title, SubTitle = @SubTitle, ImageUrl = @ImageUrl, LinkUrl = @LinkUrl,
            DisplayOrder = @DisplayOrder, IsActive = @IsActive, StartsAt = @StartsAt, EndsAt = @EndsAt,
            ModifiedBy = @AdminId, ModifiedOn = GETUTCDATE()
        WHERE Id = @BannerId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblBanner', @BannerId, 'UPDATE', CONCAT('{"Title":"', @Title, '"}'), @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_UpdateBanner', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Admin_SoftDeleteBanner
-- =========================================================
CREATE PROCEDURE proc_Admin_SoftDeleteBanner
    @BannerId INT,
    @AdminId  INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE m.tblBanner
        SET IsDeleted = 1, RecordStatusId = 3, IsActive = 0, ModifiedBy = @AdminId, ModifiedOn = GETUTCDATE()
        WHERE Id = @BannerId AND IsDeleted = 0;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblBanner', @BannerId, 'DELETE', '{"IsDeleted":1}', @AdminId, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_SoftDeleteBanner', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V024')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V024', 'CreateAdminContentStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
