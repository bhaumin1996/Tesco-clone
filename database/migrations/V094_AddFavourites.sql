-- V094_AddFavourites.sql
-- Author: Tesco Clone
-- Date: 2026-05-19
-- Description: Add Favourites feature — creates t.tblFavourite table only.
--   Stored procedures are in V095_AddFavouriteStoredProcedures.sql because
--   the SP bodies depend on computed columns and correct schema references
--   that were clarified after this migration was initially written.
-- Dependencies: V007 (m.tblProduct), V009 (t.tblUser)

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- 1. Create t.tblFavourite
-- =========================================================
IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblFavourite'
)
BEGIN
    CREATE TABLE t.tblFavourite (
        Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        UserId         INT NOT NULL,
        ProductId      INT NOT NULL,
        RecordStatusId TINYINT   NOT NULL DEFAULT 1,
        CreatedBy      INT       NOT NULL,
        CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
        ModifiedBy     INT       NULL,
        ModifiedOn     DATETIME2 NULL,
        IsDeleted      BIT       NOT NULL DEFAULT 0,
        CONSTRAINT FK_tblFavourite_tblUser    FOREIGN KEY (UserId)    REFERENCES t.tblUser    (Id),
        CONSTRAINT FK_tblFavourite_tblProduct FOREIGN KEY (ProductId) REFERENCES m.tblProduct (Id)
    );

    -- Only one active favourite per user-product pair
    CREATE UNIQUE INDEX IX_tblFavourite_UserProduct
        ON t.tblFavourite (UserId, ProductId)
        WHERE IsDeleted = 0;

    CREATE INDEX IX_tblFavourite_UserId    ON t.tblFavourite (UserId);
    CREATE INDEX IX_tblFavourite_ProductId ON t.tblFavourite (ProductId);

    PRINT 'Table [t].[tblFavourite] created.';
END
ELSE
BEGIN
    PRINT 'Table [t].[tblFavourite] already exists — skipped.';
END
GO
