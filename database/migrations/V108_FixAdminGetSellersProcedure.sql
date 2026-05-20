-- V108_FixAdminGetSellersProcedure.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Harden admin marketplace sellers grid schema and proc_Admin_GetSellers.
-- Dependencies: V105

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'm' AND TABLE_NAME = 'tblSellerStatus')
    BEGIN
        CREATE TABLE m.tblSellerStatus (
            Id TINYINT NOT NULL PRIMARY KEY,
            Name NVARCHAR(50) NOT NULL
        );
    END

    IF NOT EXISTS (SELECT 1 FROM m.tblSellerStatus WHERE Id = 1)
        INSERT INTO m.tblSellerStatus (Id, Name) VALUES (1, 'Pending');
    IF NOT EXISTS (SELECT 1 FROM m.tblSellerStatus WHERE Id = 2)
        INSERT INTO m.tblSellerStatus (Id, Name) VALUES (2, 'Approved');
    IF NOT EXISTS (SELECT 1 FROM m.tblSellerStatus WHERE Id = 3)
        INSERT INTO m.tblSellerStatus (Id, Name) VALUES (3, 'Suspended');

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'StatusId')
        ALTER TABLE t.tblSeller ADD StatusId TINYINT NOT NULL CONSTRAINT DF_tblSeller_StatusId_V108 DEFAULT 1;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'ContactEmail')
        ALTER TABLE t.tblSeller ADD ContactEmail NVARCHAR(256) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'RegistrationNumber')
        ALTER TABLE t.tblSeller ADD RegistrationNumber NVARCHAR(50) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'VatNumber')
        ALTER TABLE t.tblSeller ADD VatNumber NVARCHAR(50) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'Phone')
        ALTER TABLE t.tblSeller ADD Phone NVARCHAR(30) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'Description')
        ALTER TABLE t.tblSeller ADD Description NVARCHAR(MAX) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'BankDetailsRef')
        ALTER TABLE t.tblSeller ADD BankDetailsRef NVARCHAR(200) NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'CommissionTierId')
        ALTER TABLE t.tblSeller ADD CommissionTierId INT NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'ApprovedOn')
        ALTER TABLE t.tblSeller ADD ApprovedOn DATETIME2 NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'SuspendedOn')
        ALTER TABLE t.tblSeller ADD SuspendedOn DATETIME2 NULL;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'Website')
        ALTER TABLE t.tblSeller ADD Website NVARCHAR(500) NULL;

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'BusinessEmail')
        EXEC(N'UPDATE t.tblSeller SET ContactEmail = BusinessEmail WHERE ContactEmail IS NULL;');

    IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 't' AND TABLE_NAME = 'tblSeller' AND COLUMN_NAME = 'IsApproved')
        EXEC(N'UPDATE t.tblSeller SET StatusId = CASE WHEN IsApproved = 1 THEN 2 ELSE StatusId END WHERE StatusId IS NULL OR StatusId = 1;');

    IF OBJECT_ID('proc_Admin_GetSellers', 'P') IS NOT NULL
        DROP PROCEDURE proc_Admin_GetSellers;

    IF OBJECT_ID('proc_Admin_GetSellerById', 'P') IS NOT NULL
        DROP PROCEDURE proc_Admin_GetSellerById;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

CREATE PROCEDURE proc_Admin_GetSellers
    @StatusFilter NVARCHAR(50) = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @SafePageNumber INT = CASE WHEN @PageNumber < 1 THEN 1 ELSE @PageNumber END;
        DECLARE @SafePageSize INT = CASE WHEN @PageSize < 1 THEN 20 WHEN @PageSize > 200 THEN 200 ELSE @PageSize END;
        DECLARE @Offset INT = (@SafePageNumber - 1) * @SafePageSize;

        SELECT
            s.Id,
            ISNULL(s.BusinessName, '') AS BusinessName,
            ISNULL(s.ContactEmail, '') AS ContactEmail,
            ISNULL(ss.Name, 'Pending') AS StatusName,
            ISNULL(s.CommissionRate, 0.00) AS CommissionRate,
            s.RegistrationNumber,
            s.VatNumber,
            s.Phone,
            s.Description,
            s.BankDetailsRef,
            s.ApprovedOn,
            s.SuspendedOn,
            s.CommissionTierId,
            s.CreatedOn,
            s.ModifiedOn,
            s.Website,
            (SELECT COUNT(1) FROM t.tblListing l WHERE l.SellerId = s.Id AND l.IsDeleted = 0) AS TotalListings,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblSeller s
        LEFT JOIN m.tblSellerStatus ss ON ss.Id = s.StatusId
        WHERE s.IsDeleted = 0
          AND (@StatusFilter IS NULL OR ISNULL(ss.Name, 'Pending') = @StatusFilter)
        ORDER BY s.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @SafePageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetSellers', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Admin_GetSellerById
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            s.Id,
            ISNULL(s.BusinessName, '') AS BusinessName,
            ISNULL(s.ContactEmail, '') AS ContactEmail,
            ISNULL(ss.Name, 'Pending') AS StatusName,
            ISNULL(s.CommissionRate, 0.00) AS CommissionRate,
            s.RegistrationNumber,
            s.VatNumber,
            s.Phone,
            s.Description,
            s.BankDetailsRef,
            s.ApprovedOn,
            s.SuspendedOn,
            s.CommissionTierId,
            s.CreatedOn,
            s.ModifiedOn,
            s.Website,
            (SELECT COUNT(1) FROM t.tblListing l WHERE l.SellerId = s.Id AND l.IsDeleted = 0) AS TotalListings
        FROM t.tblSeller s
        LEFT JOIN m.tblSellerStatus ss ON ss.Id = s.StatusId
        WHERE s.Id = @SellerId AND s.IsDeleted = 0;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Admin_GetSellerById', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V108')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V108', 'FixAdminGetSellersProcedure');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
