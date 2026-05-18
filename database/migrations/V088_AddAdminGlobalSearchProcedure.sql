-- V088_AddAdminGlobalSearchProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-18
-- Description: Create administrative global search stored procedure
-- Dependencies: V001-V087

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Admin_GlobalSearch', 'P') IS NOT NULL 
        DROP PROCEDURE proc_Admin_GlobalSearch;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Admin_GlobalSearch
-- =========================================================
CREATE PROCEDURE proc_Admin_GlobalSearch
    @SearchTerm NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @LikePattern NVARCHAR(110) = N'%' + @SearchTerm + N'%';

        -- 1. Products (Limit 5)
        SELECT TOP 5 
            Id AS ProductId, 
            Name, 
            Slug, 
            ImageUrl,
            BasePrice
        FROM m.tblProduct
        WHERE IsDeleted = 0
          AND (Name LIKE @LikePattern OR Slug LIKE @LikePattern)
        ORDER BY Name;

        -- 2. Categories (Limit 5)
        SELECT TOP 5 
            Id AS CategoryId, 
            Name, 
            Slug, 
            ImageUrl
        FROM m.tblCategory
        WHERE IsDeleted = 0
          AND (Name LIKE @LikePattern OR Slug LIKE @LikePattern)
        ORDER BY Name;

        -- 3. Departments (Limit 5)
        SELECT TOP 5 
            Id AS DepartmentId, 
            Name, 
            Slug, 
            ImageUrl
        FROM m.tblDepartment
        WHERE IsDeleted = 0
          AND (Name LIKE @LikePattern OR Slug LIKE @LikePattern)
        ORDER BY Name;

        -- 4. Brands (Limit 5)
        SELECT TOP 5 
            Id AS BrandId, 
            Name, 
            Slug, 
            LogoUrl
        FROM m.tblBrand
        WHERE IsDeleted = 0
          AND (Name LIKE @LikePattern OR Slug LIKE @LikePattern)
        ORDER BY Name;

        -- 5. Orders (Limit 5)
        SELECT TOP 5 
            Id AS OrderId, 
            OrderReference AS OrderNumber, 
            Total AS TotalAmount
        FROM t.tblOrder
        WHERE IsDeleted = 0
          AND (OrderReference LIKE @LikePattern OR DeliveryAddress LIKE @LikePattern)
        ORDER BY CreatedOn DESC;

        -- 6. Users (Limit 5)
        SELECT TOP 5 
            Id AS UserId, 
            FirstName, 
            LastName, 
            Email
        FROM t.tblUser
        WHERE IsDeleted = 0
          AND (FirstName LIKE @LikePattern OR LastName LIKE @LikePattern OR Email LIKE @LikePattern)
        ORDER BY FirstName, LastName;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GlobalSearch', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V088')
        INSERT INTO t.tblMigration (Version, Description) 
        VALUES ('V088', 'AddAdminGlobalSearchProcedure');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
