using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;
using TescoClone.Domain.Identity;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Identity;

public sealed class UserRepository : IUserRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<UserRepository> _logger;

    public UserRepository(SqlConnectionFactory connectionFactory, ILogger<UserRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Identity_GetUserByEmail",
            MapUser,
            [SqlHelper.Input("@Email", email)],
            cancellationToken);
    }

    public async Task<User?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Identity_GetUserById",
            MapUser,
            [SqlHelper.Input("@UserId", id)],
            cancellationToken);
    }

    public async Task<bool> EmailExistsAsync(string email, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        var count = await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Identity_CheckEmailExists",
            [SqlHelper.Input("@Email", email)],
            cancellationToken);
        return count > 0;
    }

    public async Task<int> CreateAsync(User user, string passwordHash, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Identity_CreateUser",
            [
                SqlHelper.Input("@FirstName", user.FirstName),
                SqlHelper.Input("@LastName", user.LastName),
                SqlHelper.Input("@Email", user.Email),
                SqlHelper.Input("@PasswordHash", passwordHash),
                SqlHelper.Input("@PhoneNumber", user.PhoneNumber),
            ],
            cancellationToken);
    }

    public async Task UpdateAsync(User user, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Identity_UpdateUser",
            [
                SqlHelper.Input("@UserId", user.Id),
                SqlHelper.Input("@Status", (byte)user.Status),
                SqlHelper.Input("@FailedLoginAttempts", user.FailedLoginAttempts),
                SqlHelper.Input("@LockedUntil", user.LockedUntil),
            ],
            cancellationToken);
    }

    public async Task<IReadOnlyList<string>> GetRolesAsync(int userId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Identity_GetUserRoles",
            reader => SqlHelper.GetValue<string>(reader, "RoleName"),
            [SqlHelper.Input("@UserId", userId)],
            cancellationToken);
    }

    public async Task SaveRefreshTokenAsync(int userId, string tokenHash, DateTime expiresAt, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Identity_SaveRefreshToken",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@TokenHash", tokenHash),
                SqlHelper.Input("@ExpiresAt", expiresAt),
            ],
            cancellationToken);
    }

    public async Task<bool> ValidateRefreshTokenAsync(int userId, string tokenHash, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        var count = await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Identity_ValidateRefreshToken",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@TokenHash", tokenHash),
            ],
            cancellationToken);
        return count > 0;
    }

    public async Task RevokeRefreshTokenAsync(int userId, string tokenHash, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Identity_RevokeRefreshToken",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@TokenHash", tokenHash),
            ],
            cancellationToken);
    }

    private static User MapUser(SqlDataReader reader) =>
        User.Hydrate(
            id: SqlHelper.GetValue<int>(reader, "Id"),
            firstName: SqlHelper.GetValue<string>(reader, "FirstName"),
            lastName: SqlHelper.GetValue<string>(reader, "LastName"),
            email: SqlHelper.GetValue<string>(reader, "Email"),
            passwordHash: SqlHelper.GetValue<string>(reader, "PasswordHash"),
            phoneNumber: SqlHelper.GetNullableString(reader, "PhoneNumber"),
            status: (UserStatus)SqlHelper.GetValue<byte>(reader, "StatusId"),
            failedLoginAttempts: SqlHelper.GetValue<byte>(reader, "FailedLoginAttempts"),
            lockedUntil: SqlHelper.GetNullableValue<DateTime>(reader, "LockedUntil"),
            recordStatus: (RecordStatus)SqlHelper.GetValue<byte>(reader, "RecordStatusId"),
            createdOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            modifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"));
}
