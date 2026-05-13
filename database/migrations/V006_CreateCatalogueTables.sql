-- V006_CreateCatalogueTables.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create catalogue tables: tblDepartment, tblCategory, tblBrand, tblProduct, tblProductVariant
-- Dependencies: V001-V005

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblDepartment')
    BEGIN
        CREATE TABLE m.tblDepartment (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Name           NVARCHAR(200) NOT NULL,
            Slug           NVARCHAR(200) NOT NULL,
            ImageUrl       NVARCHAR(500) NULL,
            DisplayOrder   INT NOT NULL DEFAULT 0,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblDepartment_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE UNIQUE INDEX IX_tblDepartment_Slug ON m.tblDepartment (Slug) WHERE IsDeleted = 0;
        PRINT 'Table [m].[tblDepartment] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblCategory')
    BEGIN
        CREATE TABLE m.tblCategory (
            Id               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            DepartmentId     INT NOT NULL,
            ParentCategoryId INT NULL,
            Name             NVARCHAR(200) NOT NULL,
            Slug             NVARCHAR(200) NOT NULL,
            ImageUrl         NVARCHAR(500) NULL,
            DisplayOrder     INT NOT NULL DEFAULT 0,
            RecordStatusId   TINYINT NOT NULL DEFAULT 1,
            CreatedBy        INT NOT NULL,
            CreatedOn        DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy       INT NULL,
            ModifiedOn       DATETIME2 NULL,
            IsDeleted        BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblCategory_tblDepartment FOREIGN KEY (DepartmentId) REFERENCES m.tblDepartment (Id),
            CONSTRAINT FK_tblCategory_ParentCategory FOREIGN KEY (ParentCategoryId) REFERENCES m.tblCategory (Id),
            CONSTRAINT FK_tblCategory_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblCategory_DepartmentId ON m.tblCategory (DepartmentId);
        CREATE UNIQUE INDEX IX_tblCategory_Slug ON m.tblCategory (Slug) WHERE IsDeleted = 0;
        PRINT 'Table [m].[tblCategory] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblBrand')
    BEGIN
        CREATE TABLE m.tblBrand (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Name           NVARCHAR(200) NOT NULL,
            Slug           NVARCHAR(200) NOT NULL,
            LogoUrl        NVARCHAR(500) NULL,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblBrand_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE UNIQUE INDEX IX_tblBrand_Slug ON m.tblBrand (Slug) WHERE IsDeleted = 0;
        PRINT 'Table [m].[tblBrand] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblProduct')
    BEGIN
        CREATE TABLE m.tblProduct (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            CategoryId     INT NOT NULL,
            BrandId        INT NULL,
            Name           NVARCHAR(500) NOT NULL,
            Slug           NVARCHAR(500) NOT NULL,
            Description    NVARCHAR(MAX) NULL,
            BasePrice      DECIMAL(10, 2) NOT NULL,
            ClubcardPrice  DECIMAL(10, 2) NULL,
            ImageUrl       NVARCHAR(500) NULL,
            IsAvailable    BIT NOT NULL DEFAULT 1,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblProduct_tblCategory FOREIGN KEY (CategoryId) REFERENCES m.tblCategory (Id),
            CONSTRAINT FK_tblProduct_tblBrand FOREIGN KEY (BrandId) REFERENCES m.tblBrand (Id),
            CONSTRAINT FK_tblProduct_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblProduct_CategoryId ON m.tblProduct (CategoryId);
        CREATE INDEX IX_tblProduct_BrandId ON m.tblProduct (BrandId);
        CREATE UNIQUE INDEX IX_tblProduct_Slug ON m.tblProduct (Slug) WHERE IsDeleted = 0;
        PRINT 'Table [m].[tblProduct] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblProductVariant')
    BEGIN
        CREATE TABLE m.tblProductVariant (
            Id             INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            ProductId      INT NOT NULL,
            Sku            NVARCHAR(100) NOT NULL,
            VariantName    NVARCHAR(200) NULL,
            PriceModifier  DECIMAL(10, 2) NOT NULL DEFAULT 0,
            StockQuantity  INT NOT NULL DEFAULT 0,
            Barcode        NVARCHAR(50) NULL,
            RecordStatusId TINYINT NOT NULL DEFAULT 1,
            CreatedBy      INT NOT NULL,
            CreatedOn      DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy     INT NULL,
            ModifiedOn     DATETIME2 NULL,
            IsDeleted      BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblProductVariant_tblProduct FOREIGN KEY (ProductId) REFERENCES m.tblProduct (Id),
            CONSTRAINT FK_tblProductVariant_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblProductVariant_ProductId ON m.tblProductVariant (ProductId);
        CREATE UNIQUE INDEX IX_tblProductVariant_Sku ON m.tblProductVariant (Sku) WHERE IsDeleted = 0;
        PRINT 'Table [m].[tblProductVariant] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V006')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V006', 'CreateCatalogueTables');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
