SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

BEGIN TRY
    BEGIN TRANSACTION;

    -- Seed tblUserAddress from unique DeliveryAddress entries in tblOrder for each user
    -- Since the format is a concatenated string, we'll store it in AddressLine1 
    -- and set placeholders for Town/Postcode which the user can then correct.
    
    INSERT INTO t.tblUserAddress (UserId, AddressLine1, AddressLine2, TownCity, Postcode, IsDefault, CreatedBy, CreatedOn)
    SELECT 
        UserId,
        MAX(LEFT(DeliveryAddress, 200)) AS AddressLine1,
        NULL AS AddressLine2,
        'Please Update' AS TownCity,
        'N/A' AS Postcode,
        0 AS IsDefault,
        UserId AS CreatedBy,
        GETUTCDATE() AS CreatedOn
    FROM t.tblOrder
    WHERE DeliveryAddress IS NOT NULL
      AND IsDeleted = 0
      AND UserId NOT IN (SELECT UserId FROM t.tblUserAddress WHERE IsDeleted = 0)
    GROUP BY UserId, DeliveryAddress;

    -- Set one address as default for each user who now has addresses
    UPDATE a
    SET IsDefault = 1
    FROM t.tblUserAddress a
    WHERE Id IN (
        SELECT MIN(Id) 
        FROM t.tblUserAddress 
        WHERE IsDefault = 0 
        GROUP BY UserId
    )
    AND NOT EXISTS (
        SELECT 1 
        FROM t.tblUserAddress a2 
        WHERE a2.UserId = a.UserId AND a2.IsDefault = 1 AND a2.IsDeleted = 0
    );

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V069')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V069', 'SeedUserAddressesFromOrders');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
