-- V051_AddBrandsAndProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-15
-- Description: Add brands with specific URLs and proc_Catalogue_GetBrands
-- Dependencies: V006 (m.tblBrand)

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- 1. Drop procedure if exists
IF OBJECT_ID('proc_Catalogue_GetBrands', 'P') IS NOT NULL
    DROP PROCEDURE proc_Catalogue_GetBrands;
GO

-- 2. Create Procedure (Must be the first statement in its batch)
CREATE PROCEDURE proc_Catalogue_GetBrands
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT 
            Id,
            Name,
            Slug,
            LogoUrl
        FROM m.tblBrand
        WHERE IsDeleted = 0
        AND RecordStatusId = 1
        ORDER BY Name ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Catalogue_GetBrands', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- 3. Data Seeding and Migration Record
BEGIN TRY
    BEGIN TRANSACTION;

    -- Jacobs
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'jacobs')
        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, CreatedBy) VALUES ('Jacobs', 'jacobs', 'https://digitalcontent.api.tesco.com/v2/media/homepage/6121521f-2442-4f5e-b53f-8dfa9ff26004/2517-Brand-taxo-Jacob.jpeg?h=205&w=205', 1);
    ELSE
        UPDATE m.tblBrand SET LogoUrl = 'https://digitalcontent.api.tesco.com/v2/media/homepage/6121521f-2442-4f5e-b53f-8dfa9ff26004/2517-Brand-taxo-Jacob.jpeg?h=205&w=205' WHERE Slug = 'jacobs';

    -- Dylon
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'dylon')
        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, CreatedBy) VALUES ('Dylon', 'dylon', 'https://digitalcontent.api.tesco.com/v2/media/homepage/60f42924-6cd2-485b-a9eb-3b7ddec0e7a7/DYLON.jpeg?h=205&w=205', 1);
    ELSE
        UPDATE m.tblBrand SET LogoUrl = 'https://digitalcontent.api.tesco.com/v2/media/homepage/60f42924-6cd2-485b-a9eb-3b7ddec0e7a7/DYLON.jpeg?h=205&w=205' WHERE Slug = 'dylon';

    -- Whiskas
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'whiskas')
        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, CreatedBy) VALUES ('Whiskas', 'whiskas', 'https://digitalcontent.api.tesco.com/v2/media/homepage/08912ba8-e5d8-4ced-8ef5-4019721839cb/Brand-logo_Whiskas.jpeg?h=205&w=205', 1);
    ELSE
        UPDATE m.tblBrand SET LogoUrl = 'https://digitalcontent.api.tesco.com/v2/media/homepage/08912ba8-e5d8-4ced-8ef5-4019721839cb/Brand-logo_Whiskas.jpeg?h=205&w=205' WHERE Slug = 'whiskas';

    -- Nestle
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'nestle')
        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, CreatedBy) VALUES ('Nestle', 'nestle', 'https://digitalcontent.api.tesco.com/v2/media/homepage/51919db4-0f69-4cfb-b611-3b66d6db61ca/Brand-logo_Nestle.jpeg?h=205&w=205', 1);
    ELSE
        UPDATE m.tblBrand SET LogoUrl = 'https://digitalcontent.api.tesco.com/v2/media/homepage/51919db4-0f69-4cfb-b611-3b66d6db61ca/Brand-logo_Nestle.jpeg?h=205&w=205' WHERE Slug = 'nestle';

    -- Berocca
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'berocca')
        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, CreatedBy) VALUES ('Berocca', 'berocca', 'https://digitalcontent.api.tesco.com/v2/media/homepage/75640374-6c73-43eb-8899-67b29ffcd3e4/Beroca.png?h=205&w=205', 1);
    ELSE
        UPDATE m.tblBrand SET LogoUrl = 'https://digitalcontent.api.tesco.com/v2/media/homepage/75640374-6c73-43eb-8899-67b29ffcd3e4/Beroca.png?h=205&w=205' WHERE Slug = 'berocca';

    -- Haleon
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'haleon')
        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, CreatedBy) VALUES ('Haleon', 'haleon', 'https://digitalcontent.api.tesco.com/v2/media/homepage/24b5f505-a3b1-419c-9d28-a67e78ac822a/Haleon.png?h=205&w=205', 1);
    ELSE
        UPDATE m.tblBrand SET LogoUrl = 'https://digitalcontent.api.tesco.com/v2/media/homepage/24b5f505-a3b1-419c-9d28-a67e78ac822a/Haleon.png?h=205&w=205' WHERE Slug = 'haleon';

    -- Flora
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'flora')
        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, CreatedBy) VALUES ('Flora', 'flora', 'https://digitalcontent.api.tesco.com/v2/media/homepage/d389570a-1415-4f62-9b49-33c42220a0d1/Flora.jpeg?h=205&w=205', 1);
    ELSE
        UPDATE m.tblBrand SET LogoUrl = 'https://digitalcontent.api.tesco.com/v2/media/homepage/d389570a-1415-4f62-9b49-33c42220a0d1/Flora.jpeg?h=205&w=205' WHERE Slug = 'flora';

    -- CeraVe
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'cerave')
        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, CreatedBy) VALUES ('CeraVe', 'cerave', 'https://digitalcontent.api.tesco.com/v2/media/homepage/e420f773-214c-4198-b08b-eead4ab19100/2602-DCHP-Thumbnail-11D_Cerave.jpeg?h=205&w=205', 1);
    ELSE
        UPDATE m.tblBrand SET LogoUrl = 'https://digitalcontent.api.tesco.com/v2/media/homepage/e420f773-214c-4198-b08b-eead4ab19100/2602-DCHP-Thumbnail-11D_Cerave.jpeg?h=205&w=205' WHERE Slug = 'cerave';

    -- Wrigley's
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'wrigleys')
        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, CreatedBy) VALUES ('Wrigley''s', 'wrigleys', 'https://digitalcontent.api.tesco.com/v2/media/homepage/1eaf5acd-bd20-4e19-b84f-b179b05690c2/2602-DCHP-Thumbnail-11D_Wrigleys.jpeg?h=205&w=205', 1);
    ELSE
        UPDATE m.tblBrand SET LogoUrl = 'https://digitalcontent.api.tesco.com/v2/media/homepage/1eaf5acd-bd20-4e19-b84f-b179b05690c2/2602-DCHP-Thumbnail-11D_Wrigleys.jpeg?h=205&w=205' WHERE Slug = 'wrigleys';

    -- Canesten
    IF NOT EXISTS (SELECT 1 FROM m.tblBrand WHERE Slug = 'canesten')
        INSERT INTO m.tblBrand (Name, Slug, LogoUrl, CreatedBy) VALUES ('Canesten', 'canesten', 'https://digitalcontent.api.tesco.com/v2/media/homepage/94e480b7-6647-46bc-abff-72eb52c2fe99/2602_875493_Canesten.png?h=205&w=205', 1);
    ELSE
        UPDATE m.tblBrand SET LogoUrl = 'https://digitalcontent.api.tesco.com/v2/media/homepage/94e480b7-6647-46bc-abff-72eb52c2fe99/2602_875493_Canesten.png?h=205&w=205' WHERE Slug = 'canesten';

    -- Record migration
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V051')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V051', 'AddBrandsAndProcedure');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    RAISERROR(@ErrMsg, 16, 1);
END CATCH
GO
