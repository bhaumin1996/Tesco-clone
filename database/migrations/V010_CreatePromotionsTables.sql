-- V010_CreatePromotionsTables.sql
-- Author: Tesco Clone
-- Date: 2026-05-12
-- Description: Create promotions tables: tblPromotion, tblPromotionProduct
-- Dependencies: V001-V009

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblPromotion')
    BEGIN
        CREATE TABLE m.tblPromotion (
            Id               INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            Name             NVARCHAR(200) NOT NULL,
            TypeId           TINYINT NOT NULL,  -- maps to PromotionType enum
            DiscountValue    DECIMAL(10, 2) NOT NULL,
            MinimumQuantity  INT NULL,
            MinimumSpend     DECIMAL(10, 2) NULL,
            RequiresClubcard BIT NOT NULL DEFAULT 0,
            ValidFrom        DATETIME2 NOT NULL,
            ValidTo          DATETIME2 NULL,
            RecordStatusId   TINYINT NOT NULL DEFAULT 1,
            CreatedBy        INT NOT NULL,
            CreatedOn        DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy       INT NULL,
            ModifiedOn       DATETIME2 NULL,
            IsDeleted        BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblPromotion_tblRecordStatus FOREIGN KEY (RecordStatusId) REFERENCES m.tblRecordStatus (Id)
        );
        CREATE INDEX IX_tblPromotion_ValidFrom_ValidTo ON m.tblPromotion (ValidFrom, ValidTo);
        PRINT 'Table [m].[tblPromotion] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblPromotionProduct')
    BEGIN
        CREATE TABLE m.tblPromotionProduct (
            Id          INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
            PromotionId INT NOT NULL,
            ProductId   INT NOT NULL,
            IsDeleted   BIT NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblPromotionProduct_tblPromotion FOREIGN KEY (PromotionId) REFERENCES m.tblPromotion (Id),
            CONSTRAINT FK_tblPromotionProduct_tblProduct FOREIGN KEY (ProductId) REFERENCES m.tblProduct (Id)
        );
        CREATE INDEX IX_tblPromotionProduct_ProductId ON m.tblPromotionProduct (ProductId);
        PRINT 'Table [m].[tblPromotionProduct] created.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V010')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V010', 'CreatePromotionsTables');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
