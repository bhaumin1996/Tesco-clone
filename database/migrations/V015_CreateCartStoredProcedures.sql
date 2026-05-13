-- V015_CreateCartStoredProcedures.sql
-- Author: Tesco Clone
-- Date: 2026-05-13
-- Description: Create stored procedures for cart operations
-- Dependencies: V001-V007

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID('proc_Order_GetCartByUserId',  'P') IS NOT NULL DROP PROCEDURE proc_Order_GetCartByUserId;
    IF OBJECT_ID('proc_Order_UpsertCartItem',   'P') IS NOT NULL DROP PROCEDURE proc_Order_UpsertCartItem;
    IF OBJECT_ID('proc_Order_RemoveCartItem',   'P') IS NOT NULL DROP PROCEDURE proc_Order_RemoveCartItem;
    IF OBJECT_ID('proc_Order_ClearCart',        'P') IS NOT NULL DROP PROCEDURE proc_Order_ClearCart;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO

-- =========================================================
-- proc_Order_GetCartByUserId
-- Returns one row per cart item; CartId and UserId repeated on each row
-- =========================================================
CREATE PROCEDURE proc_Order_GetCartByUserId
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT
            c.Id          AS CartId,
            c.UserId,
            ci.ProductVariantId,
            ci.ProductName,
            ci.UnitPrice,
            ci.Quantity,
            CAST(ci.UnitPrice * ci.Quantity AS DECIMAL(10,2)) AS LineTotal
        FROM t.tblCart c
        INNER JOIN t.tblCartItem ci ON ci.CartId = c.Id AND ci.IsDeleted = 0
        WHERE c.UserId    = @UserId
          AND c.IsDeleted = 0
        ORDER BY ci.Id;
    END TRY
    BEGIN CATCH
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_GetCartByUserId', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Order_UpsertCartItem
-- Creates the cart if it does not exist, then upserts the item.
-- =========================================================
CREATE PROCEDURE proc_Order_UpsertCartItem
    @UserId          INT,
    @ProductVariantId INT,
    @ProductName     NVARCHAR(500),
    @UnitPrice       DECIMAL(10,2),
    @Quantity        INT,
    @ModifiedBy      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CartId INT;

        SELECT @CartId = Id FROM t.tblCart WHERE UserId = @UserId AND IsDeleted = 0;

        IF @CartId IS NULL
        BEGIN
            INSERT INTO t.tblCart (UserId, RecordStatusId, CreatedBy, CreatedOn)
            VALUES (@UserId, 1, @ModifiedBy, GETUTCDATE());
            SET @CartId = SCOPE_IDENTITY();
        END

        IF EXISTS (
            SELECT 1 FROM t.tblCartItem
            WHERE CartId = @CartId AND ProductVariantId = @ProductVariantId AND IsDeleted = 0
        )
        BEGIN
            UPDATE t.tblCartItem
            SET Quantity   = @Quantity,
                UnitPrice  = @UnitPrice,
                ModifiedBy = @ModifiedBy,
                ModifiedOn = GETUTCDATE()
            WHERE CartId = @CartId AND ProductVariantId = @ProductVariantId AND IsDeleted = 0;
        END
        ELSE
        BEGIN
            INSERT INTO t.tblCartItem (CartId, ProductVariantId, ProductName, UnitPrice, Quantity, CreatedBy, CreatedOn)
            VALUES (@CartId, @ProductVariantId, @ProductName, @UnitPrice, @Quantity, @ModifiedBy, GETUTCDATE());
        END

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCartItem', @CartId, 'UPSERT',
                CONCAT('{"ProductVariantId":', @ProductVariantId, ',"Quantity":', @Quantity, '}'),
                @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_UpsertCartItem', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Order_RemoveCartItem
-- Soft-deletes one item from the cart.
-- =========================================================
CREATE PROCEDURE proc_Order_RemoveCartItem
    @UserId          INT,
    @ProductVariantId INT,
    @ModifiedBy      INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CartId INT;
        SELECT @CartId = Id FROM t.tblCart WHERE UserId = @UserId AND IsDeleted = 0;

        IF @CartId IS NOT NULL
        BEGIN
            UPDATE t.tblCartItem
            SET IsDeleted  = 1,
                ModifiedBy = @ModifiedBy,
                ModifiedOn = GETUTCDATE()
            WHERE CartId = @CartId AND ProductVariantId = @ProductVariantId AND IsDeleted = 0;
        END

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCartItem', ISNULL(@CartId, 0), 'SOFT_DELETE',
                CONCAT('{"ProductVariantId":', @ProductVariantId, '}'),
                @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_RemoveCartItem', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- proc_Order_ClearCart
-- Soft-deletes all items and the cart row itself.
-- =========================================================
CREATE PROCEDURE proc_Order_ClearCart
    @UserId     INT,
    @ModifiedBy INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @CartId INT;
        SELECT @CartId = Id FROM t.tblCart WHERE UserId = @UserId AND IsDeleted = 0;

        IF @CartId IS NOT NULL
        BEGIN
            UPDATE t.tblCartItem
            SET IsDeleted  = 1,
                ModifiedBy = @ModifiedBy,
                ModifiedOn = GETUTCDATE()
            WHERE CartId = @CartId AND IsDeleted = 0;

            UPDATE t.tblCart
            SET IsDeleted  = 1,
                ModifiedBy = @ModifiedBy,
                ModifiedOn = GETUTCDATE()
            WHERE Id = @CartId;
        END

        INSERT INTO t.tblAuditLog (TableName, RecordId, Action, NewValues, ChangedBy, ChangedOn)
        VALUES ('tblCart', ISNULL(@CartId, 0), 'SOFT_DELETE',
                CONCAT('{"UserId":', @UserId, '}'),
                @ModifiedBy, GETUTCDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        INSERT INTO t.tblLog (Level, Source, Message, LoggedOn)
        VALUES ('Error', 'proc_Order_ClearCart', ERROR_MESSAGE(), GETUTCDATE());
        THROW;
    END CATCH
END
GO

-- =========================================================
-- Record migration
-- =========================================================
BEGIN TRY
    BEGIN TRANSACTION;
    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V015')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V015', 'CreateCartStoredProcedures');
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
