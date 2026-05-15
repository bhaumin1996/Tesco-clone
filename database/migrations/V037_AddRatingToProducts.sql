-- V037_AddRatingToProducts.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Add AverageRating and ReviewCount to m.tblProduct
-- Dependencies: V006

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblProduct' AND COLUMN_NAME = 'AverageRating')
BEGIN
    ALTER TABLE m.tblProduct ADD AverageRating DECIMAL(3, 2) NOT NULL DEFAULT 0;
    ALTER TABLE m.tblProduct ADD ReviewCount INT NOT NULL DEFAULT 0;
    PRINT 'Columns AverageRating and ReviewCount added to m.tblProduct.';
END
GO

-- Update existing products with some random ratings
UPDATE m.tblProduct SET AverageRating = 4.5, ReviewCount = 120 WHERE Name LIKE '%Tesco%';
UPDATE m.tblProduct SET AverageRating = 4.8, ReviewCount = 85  WHERE Name LIKE '%Finest%';
GO

IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V037')
    INSERT INTO t.tblMigration (Version, Description) VALUES ('V037', 'AddRatingToProducts');
GO
