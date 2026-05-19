using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Addresses.DTOs;
using TescoClone.Application.Addresses.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Addresses;

// ADO.NET repository for the user address book; ImportFromOrdersAsync seeds saved addresses from historic delivery addresses.
public sealed class AddressRepository : IAddressRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<AddressRepository> _logger;

    public AddressRepository(SqlConnectionFactory connectionFactory, ILogger<AddressRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<IReadOnlyList<AddressDto>> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Identity_GetUserAddresses",
                MapAddress,
                [SqlHelper.Input("@UserId", userId)],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetByUserIdAsync for userId: {UserId}", userId);
            throw;
        }
    }

    public async Task AddAsync(int userId, string line1, string? line2, string town, string postcode, bool isDefault, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Identity_AddUserAddress",
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@Line1", line1),
                    SqlHelper.Input("@Line2", line2),
                    SqlHelper.Input("@Town", town),
                    SqlHelper.Input("@Postcode", postcode),
                    SqlHelper.Input("@IsDefault", isDefault),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in AddAsync for userId: {UserId}", userId);
            throw;
        }
    }

    public async Task UpdateAsync(int addressId, int userId, string line1, string? line2, string town, string postcode, bool isDefault, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Identity_UpdateUserAddress",
                [
                    SqlHelper.Input("@AddressId", addressId),
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@Line1", line1),
                    SqlHelper.Input("@Line2", line2),
                    SqlHelper.Input("@Town", town),
                    SqlHelper.Input("@Postcode", postcode),
                    SqlHelper.Input("@IsDefault", isDefault),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in UpdateAsync for addressId: {AddressId}", addressId);
            throw;
        }
    }

    public async Task DeleteAsync(int addressId, int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Identity_DeleteUserAddress",
                [
                    SqlHelper.Input("@AddressId", addressId),
                    SqlHelper.Input("@UserId", userId),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in DeleteAsync for addressId: {AddressId}", addressId);
            throw;
        }
    }

    public async Task SetDefaultAsync(int addressId, int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Identity_SetDefaultAddress",
                [
                    SqlHelper.Input("@AddressId", addressId),
                    SqlHelper.Input("@UserId", userId),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in SetDefaultAsync for addressId: {AddressId}", addressId);
            throw;
        }
    }

    public async Task ImportFromOrdersAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await connection.OpenAsync(cancellationToken);

            // Fetch unique delivery addresses from orders
            const string sql = @"
                INSERT INTO t.tblUserAddress (UserId, AddressLine1, TownCity, Postcode, IsDefault, CreatedBy, CreatedOn)
                SELECT DISTINCT 
                    UserId, 
                    LEFT(DeliveryAddress, 200),
                    'Imported', 
                    'N/A', 
                    0, 
                    UserId, 
                    GETUTCDATE()
                FROM t.tblOrder
                WHERE UserId = @UserId 
                  AND DeliveryAddress IS NOT NULL
                  AND IsDeleted = 0
                  AND DeliveryAddress NOT IN (SELECT AddressLine1 FROM t.tblUserAddress WHERE UserId = @UserId AND IsDeleted = 0);
                
                -- Set default if none exists
                IF EXISTS (SELECT 1 FROM t.tblUserAddress WHERE UserId = @UserId AND IsDeleted = 0)
                   AND NOT EXISTS (SELECT 1 FROM t.tblUserAddress WHERE UserId = @UserId AND IsDefault = 1 AND IsDeleted = 0)
                BEGIN
                    UPDATE TOP (1) t.tblUserAddress SET IsDefault = 1 WHERE UserId = @UserId AND IsDeleted = 0;
                END";

            using var command = new SqlCommand(sql, connection);
            command.Parameters.AddWithValue("@UserId", userId);
            await command.ExecuteNonQueryAsync(cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in ImportFromOrdersAsync for userId: {UserId}", userId);
            throw;
        }
    }

    private static AddressDto MapAddress(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            UserId: SqlHelper.GetValue<int>(reader, "UserId"),
            AddressLine1: SqlHelper.GetValue<string>(reader, "AddressLine1"),
            AddressLine2: SqlHelper.GetNullableString(reader, "AddressLine2"),
            TownCity: SqlHelper.GetValue<string>(reader, "TownCity"),
            Postcode: SqlHelper.GetValue<string>(reader, "Postcode"),
            IsDefault: SqlHelper.GetValue<bool>(reader, "IsDefault")
        );
}
