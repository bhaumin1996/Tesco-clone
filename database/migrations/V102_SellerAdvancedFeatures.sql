-- V102_SellerAdvancedFeatures.sql
-- Author: Tesco Clone
-- Date: 2026-05-20
-- Description: Phase 11 — seller advanced feature infrastructure.
--   ASN (advance shipping notices), performance scoring,
--   marketplace returns, seller invoicing, seller payouts,
--   seller-to-admin messaging, Clubcard points on marketplace,
--   per-seller delivery options.
-- Dependencies: V001-V101

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

-- =========================================================
-- PART 1: t.tblSellerASN — Advance Shipping Notices
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSellerASN')
    BEGIN
        CREATE TABLE t.tblSellerASN (
            Id                  INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
            SellerId            INT           NOT NULL,
            ExpectedArrivalDate DATE          NOT NULL,
            SkusJson            NVARCHAR(MAX) NOT NULL,   -- JSON array of SKUs / listing IDs
            Status              NVARCHAR(50)  NOT NULL DEFAULT 'Pending',
            Notes               NVARCHAR(500) NULL,
            RecordStatusId      TINYINT       NOT NULL DEFAULT 1,
            CreatedBy           INT           NOT NULL,
            CreatedOn           DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy          INT           NULL,
            ModifiedOn          DATETIME2     NULL,
            IsDeleted           BIT           NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSellerASN_tblSeller FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id)
        );
        CREATE INDEX IX_tblSellerASN_SellerId ON t.tblSellerASN (SellerId) WHERE IsDeleted = 0;
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V102_Part1')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V102_Part1', 'SellerAdvancedFeatures_ASN');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'V102_Part1', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 2: t.tblSellerPerformanceScore
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSellerPerformanceScore')
    BEGIN
        CREATE TABLE t.tblSellerPerformanceScore (
            Id                  INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
            SellerId            INT           NOT NULL,
            ScoreDate           DATE          NOT NULL,
            OnTimeDeliveryRate  DECIMAL(5,2)  NULL,
            ReturnRate          DECIMAL(5,2)  NULL,
            CancellationRate    DECIMAL(5,2)  NULL,
            AverageRating       DECIMAL(3,2)  NULL,
            OverallScore        DECIMAL(5,2)  NULL,
            BelowThreshold      BIT           NOT NULL DEFAULT 0,
            RecordStatusId      TINYINT       NOT NULL DEFAULT 1,
            CreatedBy           INT           NOT NULL DEFAULT 0,
            CreatedOn           DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy          INT           NULL,
            ModifiedOn          DATETIME2     NULL,
            IsDeleted           BIT           NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSellerPerformanceScore_tblSeller FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id),
            CONSTRAINT UQ_tblSellerPerformanceScore_SellerDate UNIQUE (SellerId, ScoreDate)
        );
        CREATE INDEX IX_tblSellerPerformanceScore_SellerId ON t.tblSellerPerformanceScore (SellerId, ScoreDate DESC);
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V102_Part2')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V102_Part2', 'SellerAdvancedFeatures_PerformanceScore');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'V102_Part2', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 3: t.tblMarketplaceReturn — Returns workflow
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblMarketplaceReturnStatus')
    BEGIN
        CREATE TABLE m.tblMarketplaceReturnStatus (
            Id   TINYINT      NOT NULL PRIMARY KEY,
            Name NVARCHAR(50) NOT NULL
        );
        INSERT INTO m.tblMarketplaceReturnStatus (Id, Name)
        VALUES (1,'Requested'), (2,'SellerAccepted'), (3,'SellerDisputed'), (4,'Resolved'), (5,'Escalated');
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblMarketplaceReturn')
    BEGIN
        CREATE TABLE t.tblMarketplaceReturn (
            Id              INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
            OrderLineId     INT           NOT NULL,
            SellerId        INT           NOT NULL,
            UserId          INT           NOT NULL,
            StatusId        TINYINT       NOT NULL DEFAULT 1,
            ReturnReason    NVARCHAR(500) NOT NULL,
            SellerResponse  NVARCHAR(500) NULL,
            Resolution      NVARCHAR(500) NULL,
            SlaDeadline     DATETIME2     NOT NULL,
            ResolvedOn      DATETIME2     NULL,
            RefundAmount    DECIMAL(18,4) NULL,
            RecordStatusId  TINYINT       NOT NULL DEFAULT 1,
            CreatedBy       INT           NOT NULL,
            CreatedOn       DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy      INT           NULL,
            ModifiedOn      DATETIME2     NULL,
            IsDeleted       BIT           NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblMarketplaceReturn_tblOrderLine FOREIGN KEY (OrderLineId) REFERENCES t.tblOrderLine (Id),
            CONSTRAINT FK_tblMarketplaceReturn_tblSeller    FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id),
            CONSTRAINT FK_tblMarketplaceReturn_Status       FOREIGN KEY (StatusId) REFERENCES m.tblMarketplaceReturnStatus (Id)
        );
        CREATE INDEX IX_tblMarketplaceReturn_SellerId ON t.tblMarketplaceReturn (SellerId) WHERE IsDeleted = 0;
        CREATE INDEX IX_tblMarketplaceReturn_UserId   ON t.tblMarketplaceReturn (UserId)   WHERE IsDeleted = 0;
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V102_Part3')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V102_Part3', 'SellerAdvancedFeatures_Returns');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'V102_Part3', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 4: t.tblSellerInvoice — Fee invoicing
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSellerInvoice')
    BEGIN
        CREATE TABLE t.tblSellerInvoice (
            Id                  INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
            SellerId            INT           NOT NULL,
            InvoiceNumber       NVARCHAR(50)  NOT NULL,
            PeriodStart         DATE          NOT NULL,
            PeriodEnd           DATE          NOT NULL,
            GrossSales          DECIMAL(18,4) NOT NULL DEFAULT 0,
            CommissionAmount    DECIMAL(18,4) NOT NULL DEFAULT 0,
            PlatformFee         DECIMAL(18,4) NOT NULL DEFAULT 0,
            TotalDue            DECIMAL(18,4) NOT NULL DEFAULT 0,
            PdfUrl              NVARCHAR(500) NULL,
            Status              NVARCHAR(50)  NOT NULL DEFAULT 'Generated',
            RecordStatusId      TINYINT       NOT NULL DEFAULT 1,
            CreatedBy           INT           NOT NULL DEFAULT 0,
            CreatedOn           DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy          INT           NULL,
            ModifiedOn          DATETIME2     NULL,
            IsDeleted           BIT           NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSellerInvoice_tblSeller FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id),
            CONSTRAINT UQ_tblSellerInvoice_Number UNIQUE (InvoiceNumber)
        );
        CREATE INDEX IX_tblSellerInvoice_SellerId ON t.tblSellerInvoice (SellerId, PeriodStart DESC);
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V102_Part4')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V102_Part4', 'SellerAdvancedFeatures_Invoice');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'V102_Part4', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 5: t.tblSellerPayout — Payout management
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSellerPayout')
    BEGIN
        CREATE TABLE t.tblSellerPayout (
            Id                  INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
            SellerId            INT           NOT NULL,
            PeriodStart         DATE          NOT NULL,
            PeriodEnd           DATE          NOT NULL,
            GrossSales          DECIMAL(18,4) NOT NULL DEFAULT 0,
            CommissionDeducted  DECIMAL(18,4) NOT NULL DEFAULT 0,
            NetPayout           DECIMAL(18,4) NOT NULL DEFAULT 0,
            Status              NVARCHAR(50)  NOT NULL DEFAULT 'Pending',
            ProcessedOn         DATETIME2     NULL,
            ProcessedBy         INT           NULL,
            Reference           NVARCHAR(100) NULL,
            RecordStatusId      TINYINT       NOT NULL DEFAULT 1,
            CreatedBy           INT           NOT NULL,
            CreatedOn           DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy          INT           NULL,
            ModifiedOn          DATETIME2     NULL,
            IsDeleted           BIT           NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSellerPayout_tblSeller FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id)
        );
        CREATE INDEX IX_tblSellerPayout_SellerId ON t.tblSellerPayout (SellerId, PeriodStart DESC);
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V102_Part5')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V102_Part5', 'SellerAdvancedFeatures_Payout');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'V102_Part5', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 6: t.tblSellerMessage — Seller-to-admin messaging
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSellerMessageThread')
    BEGIN
        CREATE TABLE t.tblSellerMessageThread (
            Id              INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
            SellerId        INT          NOT NULL,
            Subject         NVARCHAR(200) NOT NULL,
            IsResolved      BIT          NOT NULL DEFAULT 0,
            RecordStatusId  TINYINT      NOT NULL DEFAULT 1,
            CreatedBy       INT          NOT NULL,
            CreatedOn       DATETIME2    NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy      INT          NULL,
            ModifiedOn      DATETIME2    NULL,
            IsDeleted       BIT          NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSellerMessageThread_tblSeller FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id)
        );
        CREATE INDEX IX_tblSellerMessageThread_SellerId ON t.tblSellerMessageThread (SellerId) WHERE IsDeleted = 0;
    END

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='t' AND TABLE_NAME='tblSellerMessage')
    BEGIN
        CREATE TABLE t.tblSellerMessage (
            Id              INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
            ThreadId        INT           NOT NULL,
            SenderUserId    INT           NOT NULL,
            Body            NVARCHAR(MAX) NOT NULL,
            ReadAt          DATETIME2     NULL,
            RecordStatusId  TINYINT       NOT NULL DEFAULT 1,
            CreatedBy       INT           NOT NULL,
            CreatedOn       DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy      INT           NULL,
            ModifiedOn      DATETIME2     NULL,
            IsDeleted       BIT           NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSellerMessage_tblSellerMessageThread FOREIGN KEY (ThreadId) REFERENCES t.tblSellerMessageThread (Id)
        );
        CREATE INDEX IX_tblSellerMessage_ThreadId ON t.tblSellerMessage (ThreadId) WHERE IsDeleted = 0;
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V102_Part6')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V102_Part6', 'SellerAdvancedFeatures_Messaging');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'V102_Part6', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 7: m.tblSellerDeliveryOption
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='m' AND TABLE_NAME='tblSellerDeliveryOption')
    BEGIN
        CREATE TABLE m.tblSellerDeliveryOption (
            Id                    INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
            SellerId              INT           NOT NULL,
            DeliveryType          NVARCHAR(50)  NOT NULL,   -- Standard | Express
            Price                 DECIMAL(18,4) NOT NULL DEFAULT 0,
            FreeThresholdAmount   DECIMAL(18,4) NULL,
            EstimatedDaysMin      TINYINT       NOT NULL DEFAULT 3,
            EstimatedDaysMax      TINYINT       NOT NULL DEFAULT 5,
            IsActive              BIT           NOT NULL DEFAULT 1,
            RecordStatusId        TINYINT       NOT NULL DEFAULT 1,
            CreatedBy             INT           NOT NULL,
            CreatedOn             DATETIME2     NOT NULL DEFAULT GETUTCDATE(),
            ModifiedBy            INT           NULL,
            ModifiedOn            DATETIME2     NULL,
            IsDeleted             BIT           NOT NULL DEFAULT 0,
            CONSTRAINT FK_tblSellerDeliveryOption_tblSeller FOREIGN KEY (SellerId) REFERENCES t.tblSeller (Id)
        );
        CREATE INDEX IX_tblSellerDeliveryOption_SellerId ON m.tblSellerDeliveryOption (SellerId) WHERE IsDeleted = 0;
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V102_Part7')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V102_Part7', 'SellerAdvancedFeatures_DeliveryOptions');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'V102_Part7', ERROR_MESSAGE(), GETUTCDATE());
    THROW;
END CATCH
GO

-- =========================================================
-- PART 8: Stored procedures for ASN, returns, payout, messaging
-- =========================================================
IF OBJECT_ID('proc_Marketplace_CreateASN',               'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_CreateASN;
IF OBJECT_ID('proc_Marketplace_GetSellerASNs',           'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerASNs;
IF OBJECT_ID('proc_Marketplace_RaiseReturn',             'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_RaiseReturn;
IF OBJECT_ID('proc_Marketplace_RespondToReturn',         'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_RespondToReturn;
IF OBJECT_ID('proc_Admin_GetMarketplaceReturns',         'P') IS NOT NULL DROP PROCEDURE proc_Admin_GetMarketplaceReturns;
IF OBJECT_ID('proc_Admin_ResolveMarketplaceReturn',      'P') IS NOT NULL DROP PROCEDURE proc_Admin_ResolveMarketplaceReturn;
IF OBJECT_ID('proc_Admin_RunSellerPayout',               'P') IS NOT NULL DROP PROCEDURE proc_Admin_RunSellerPayout;
IF OBJECT_ID('proc_Marketplace_GetSellerPayouts',        'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerPayouts;
IF OBJECT_ID('proc_Marketplace_CreateMessageThread',     'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_CreateMessageThread;
IF OBJECT_ID('proc_Marketplace_SendMessage',             'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_SendMessage;
IF OBJECT_ID('proc_Marketplace_GetMessageThreads',       'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetMessageThreads;
IF OBJECT_ID('proc_Marketplace_GetMessagesByThread',     'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetMessagesByThread;
IF OBJECT_ID('proc_Marketplace_GetSellerDeliveryOptions','P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetSellerDeliveryOptions;
IF OBJECT_ID('proc_Marketplace_UpsertDeliveryOption',   'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_UpsertDeliveryOption;
IF OBJECT_ID('proc_Marketplace_GetLatestPerformance',   'P') IS NOT NULL DROP PROCEDURE proc_Marketplace_GetLatestPerformance;
GO

CREATE PROCEDURE proc_Marketplace_CreateASN
    @SellerId            INT,
    @ExpectedArrivalDate DATE,
    @SkusJson            NVARCHAR(MAX),
    @Notes               NVARCHAR(500) = NULL,
    @CreatedBy           INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO t.tblSellerASN (SellerId, ExpectedArrivalDate, SkusJson, Notes, Status, CreatedBy, CreatedOn)
        VALUES (@SellerId, @ExpectedArrivalDate, @SkusJson, @Notes, 'Pending', @CreatedBy, GETUTCDATE());
        DECLARE @NewId INT = SCOPE_IDENTITY();
        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSellerASN', @NewId, 'CREATE', NULL, @CreatedBy, GETUTCDATE());
        COMMIT TRANSACTION;
        SELECT @NewId AS Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_CreateASN', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_GetSellerASNs
    @SellerId   INT,
    @PageNumber INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        SELECT
            a.Id, a.SellerId, a.ExpectedArrivalDate, a.SkusJson,
            a.Status, a.Notes, a.CreatedOn,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblSellerASN a
        WHERE a.SellerId = @SellerId AND a.IsDeleted = 0
        ORDER BY a.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_GetSellerASNs', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_RaiseReturn
    @OrderLineId    INT,
    @UserId         INT,
    @ReturnReason   NVARCHAR(500),
    @CreatedBy      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @SellerId INT;
        SELECT @SellerId = SellerId FROM t.tblOrderLine WHERE Id = @OrderLineId AND IsMarketplace = 1;
        IF @SellerId IS NULL
            RAISERROR ('OrderLine not found or not a marketplace line.', 16, 1);

        INSERT INTO t.tblMarketplaceReturn
            (OrderLineId, SellerId, UserId, StatusId, ReturnReason, SlaDeadline, CreatedBy, CreatedOn)
        VALUES
            (@OrderLineId, @SellerId, @UserId, 1, @ReturnReason, DATEADD(HOUR, 72, GETUTCDATE()), @CreatedBy, GETUTCDATE());
        DECLARE @NewId INT = SCOPE_IDENTITY();
        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblMarketplaceReturn', @NewId, 'RAISE', NULL, @CreatedBy, GETUTCDATE());
        COMMIT TRANSACTION;
        SELECT @NewId AS Id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_RaiseReturn', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_RespondToReturn
    @ReturnId       INT,
    @SellerId       INT,
    @Accept         BIT,
    @SellerResponse NVARCHAR(500),
    @ModifiedBy     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM t.tblMarketplaceReturn WHERE Id = @ReturnId AND SellerId = @SellerId AND StatusId = 1 AND IsDeleted = 0)
            RAISERROR ('Return not found or not in Requested status.', 16, 1);

        UPDATE t.tblMarketplaceReturn
        SET StatusId        = CASE WHEN @Accept = 1 THEN 2 ELSE 3 END,
            SellerResponse  = @SellerResponse,
            ModifiedBy      = @ModifiedBy,
            ModifiedOn      = GETUTCDATE()
        WHERE Id = @ReturnId AND SellerId = @SellerId;

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblMarketplaceReturn', @ReturnId, CASE WHEN @Accept=1 THEN 'ACCEPT' ELSE 'DISPUTE' END, NULL, @ModifiedBy, GETUTCDATE());
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_RespondToReturn', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Admin_GetMarketplaceReturns
    @StatusFilter NVARCHAR(50) = NULL,
    @PageNumber   INT = 1,
    @PageSize     INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        SELECT
            r.Id, r.OrderLineId, r.SellerId, s.BusinessName AS SellerName,
            r.UserId, r.ReturnReason, r.SellerResponse, r.Resolution,
            rs.Name AS StatusName, r.SlaDeadline, r.ResolvedOn, r.RefundAmount,
            r.CreatedOn,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblMarketplaceReturn r
        INNER JOIN t.tblSeller                  s  ON s.Id  = r.SellerId
        INNER JOIN m.tblMarketplaceReturnStatus rs ON rs.Id = r.StatusId
        WHERE r.IsDeleted = 0
          AND (@StatusFilter IS NULL OR rs.Name = @StatusFilter)
        ORDER BY r.CreatedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Admin_GetMarketplaceReturns', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Admin_ResolveMarketplaceReturn
    @ReturnId     INT,
    @Resolution   NVARCHAR(500),
    @RefundAmount DECIMAL(18,4) = NULL,
    @AdminId      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        UPDATE t.tblMarketplaceReturn
        SET StatusId     = 4,
            Resolution   = @Resolution,
            RefundAmount = @RefundAmount,
            ResolvedOn   = GETUTCDATE(),
            ModifiedBy   = @AdminId,
            ModifiedOn   = GETUTCDATE()
        WHERE Id = @ReturnId AND IsDeleted = 0;
        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblMarketplaceReturn', @ReturnId, 'RESOLVE', NULL, @AdminId, GETUTCDATE());
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Admin_ResolveMarketplaceReturn', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Admin_RunSellerPayout
    @SellerId    INT,
    @PeriodStart DATE,
    @PeriodEnd   DATE,
    @AdminId     INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @GrossSales DECIMAL(18,4), @CommissionDeducted DECIMAL(18,4), @NetPayout DECIMAL(18,4);

        SELECT
            @GrossSales         = ISNULL(SUM(sc.SaleAmount), 0),
            @CommissionDeducted = ISNULL(SUM(sc.CommissionAmount), 0)
        FROM t.tblSellerCommission sc
        WHERE sc.SellerId  = @SellerId
          AND sc.IsDeleted = 0
          AND CAST(sc.CreatedOn AS DATE) BETWEEN @PeriodStart AND @PeriodEnd;

        SET @NetPayout = @GrossSales - @CommissionDeducted;

        INSERT INTO t.tblSellerPayout
            (SellerId, PeriodStart, PeriodEnd, GrossSales, CommissionDeducted, NetPayout, Status, ProcessedOn, ProcessedBy, CreatedBy, CreatedOn)
        VALUES
            (@SellerId, @PeriodStart, @PeriodEnd, @GrossSales, @CommissionDeducted, @NetPayout, 'Processed', GETUTCDATE(), @AdminId, @AdminId, GETUTCDATE());

        DECLARE @NewId INT = SCOPE_IDENTITY();
        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSellerPayout', @NewId, 'PROCESS', NULL, @AdminId, GETUTCDATE());
        COMMIT TRANSACTION;
        SELECT @NewId AS Id, @NetPayout AS NetPayout;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Admin_RunSellerPayout', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_GetSellerPayouts
    @SellerId   INT,
    @PageNumber INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        SELECT
            p.Id, p.SellerId, p.PeriodStart, p.PeriodEnd,
            p.GrossSales, p.CommissionDeducted, p.NetPayout,
            p.Status, p.ProcessedOn, p.Reference, p.CreatedOn,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblSellerPayout p
        WHERE p.SellerId = @SellerId AND p.IsDeleted = 0
        ORDER BY p.PeriodStart DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_GetSellerPayouts', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_CreateMessageThread
    @SellerId  INT,
    @Subject   NVARCHAR(200),
    @Body      NVARCHAR(MAX),
    @CreatedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        INSERT INTO t.tblSellerMessageThread (SellerId, Subject, CreatedBy, CreatedOn)
        VALUES (@SellerId, @Subject, @CreatedBy, GETUTCDATE());
        DECLARE @ThreadId INT = SCOPE_IDENTITY();

        INSERT INTO t.tblSellerMessage (ThreadId, SenderUserId, Body, CreatedBy, CreatedOn)
        VALUES (@ThreadId, @CreatedBy, @Body, @CreatedBy, GETUTCDATE());

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSellerMessageThread', @ThreadId, 'CREATE', NULL, @CreatedBy, GETUTCDATE());
        COMMIT TRANSACTION;
        SELECT @ThreadId AS ThreadId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_CreateMessageThread', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_SendMessage
    @ThreadId    INT,
    @SenderUserId INT,
    @Body        NVARCHAR(MAX),
    @CreatedBy   INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM t.tblSellerMessageThread WHERE Id = @ThreadId AND IsDeleted = 0)
            RAISERROR ('Message thread not found.', 16, 1);

        INSERT INTO t.tblSellerMessage (ThreadId, SenderUserId, Body, CreatedBy, CreatedOn)
        VALUES (@ThreadId, @SenderUserId, @Body, @CreatedBy, GETUTCDATE());

        UPDATE t.tblSellerMessageThread
        SET ModifiedBy = @CreatedBy, ModifiedOn = GETUTCDATE()
        WHERE Id = @ThreadId;
        COMMIT TRANSACTION;
        SELECT SCOPE_IDENTITY() AS MessageId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_SendMessage', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_GetMessageThreads
    @SellerId   INT,
    @PageNumber INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
        SELECT
            t.Id, t.SellerId, t.Subject, t.IsResolved, t.CreatedOn, t.ModifiedOn,
            (SELECT COUNT(1) FROM t.tblSellerMessage m WHERE m.ThreadId = t.Id AND m.IsDeleted = 0) AS MessageCount,
            (SELECT COUNT(1) FROM t.tblSellerMessage m WHERE m.ThreadId = t.Id AND m.ReadAt IS NULL AND m.SenderUserId <> (SELECT TOP 1 u.Id FROM t.tblUser u WHERE u.SellerId = @SellerId) AND m.IsDeleted = 0) AS UnreadCount,
            COUNT(1) OVER () AS TotalCount
        FROM t.tblSellerMessageThread t
        WHERE t.SellerId = @SellerId AND t.IsDeleted = 0
        ORDER BY t.ModifiedOn DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_GetMessageThreads', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_GetMessagesByThread
    @ThreadId INT,
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM t.tblSellerMessageThread WHERE Id = @ThreadId AND SellerId = @SellerId AND IsDeleted = 0)
            RAISERROR ('Thread not found.', 16, 1);

        SELECT m.Id, m.ThreadId, m.SenderUserId, m.Body, m.ReadAt, m.CreatedOn
        FROM t.tblSellerMessage m
        WHERE m.ThreadId = @ThreadId AND m.IsDeleted = 0
        ORDER BY m.CreatedOn ASC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_GetMessagesByThread', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_GetSellerDeliveryOptions
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT Id, SellerId, DeliveryType, Price, FreeThresholdAmount,
               EstimatedDaysMin, EstimatedDaysMax, IsActive, CreatedOn, ModifiedOn
        FROM m.tblSellerDeliveryOption
        WHERE SellerId = @SellerId AND IsDeleted = 0
        ORDER BY DeliveryType;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_GetSellerDeliveryOptions', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_UpsertDeliveryOption
    @SellerId            INT,
    @DeliveryType        NVARCHAR(50),
    @Price               DECIMAL(18,4),
    @FreeThresholdAmount DECIMAL(18,4) = NULL,
    @EstimatedDaysMin    TINYINT,
    @EstimatedDaysMax    TINYINT,
    @IsActive            BIT,
    @UserId              INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        IF EXISTS (SELECT 1 FROM m.tblSellerDeliveryOption WHERE SellerId=@SellerId AND DeliveryType=@DeliveryType AND IsDeleted=0)
        BEGIN
            UPDATE m.tblSellerDeliveryOption
            SET Price               = @Price,
                FreeThresholdAmount = @FreeThresholdAmount,
                EstimatedDaysMin    = @EstimatedDaysMin,
                EstimatedDaysMax    = @EstimatedDaysMax,
                IsActive            = @IsActive,
                ModifiedBy          = @UserId,
                ModifiedOn          = GETUTCDATE()
            WHERE SellerId=@SellerId AND DeliveryType=@DeliveryType AND IsDeleted=0;
        END
        ELSE
        BEGIN
            INSERT INTO m.tblSellerDeliveryOption
                (SellerId, DeliveryType, Price, FreeThresholdAmount, EstimatedDaysMin, EstimatedDaysMax, IsActive, CreatedBy, CreatedOn)
            VALUES
                (@SellerId, @DeliveryType, @Price, @FreeThresholdAmount, @EstimatedDaysMin, @EstimatedDaysMax, @IsActive, @UserId, GETUTCDATE());
        END
        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblSellerDeliveryOption', @SellerId, 'UPSERT', NULL, @UserId, GETUTCDATE());
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_UpsertDeliveryOption', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

CREATE PROCEDURE proc_Marketplace_GetLatestPerformance
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT TOP 1
            Id, SellerId, ScoreDate, OnTimeDeliveryRate, ReturnRate,
            CancellationRate, AverageRating, OverallScore, BelowThreshold, CreatedOn
        FROM t.tblSellerPerformanceScore
        WHERE SellerId = @SellerId AND IsDeleted = 0
        ORDER BY ScoreDate DESC;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn) VALUES ('Error', 'proc_Marketplace_GetLatestPerformance', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V102')
        INSERT INTO t.tblMigration (Version, Description)
        VALUES ('V102', 'SellerAdvancedFeatures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
