-- V053_CreateGetPageBySlugProcedure.sql
-- Author: Antigravity
-- Date: 2026-05-15
-- Description: Create procedure to get page by slug
-- Dependencies: V011

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

GO
CREATE OR ALTER PROCEDURE proc_Content_GetPageBySlug
    @Slug NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Id,
        Title,
        Slug,
        Content,
        IsPublished,
        CreatedOn,
        ModifiedOn
    FROM t.tblPage
    WHERE Slug = @Slug 
      AND IsPublished = 1
      AND IsDeleted = 0;
END
GO

IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V053')
    INSERT INTO t.tblMigration (Version, Description) VALUES ('V053', 'CreateGetPageBySlugProcedure');
