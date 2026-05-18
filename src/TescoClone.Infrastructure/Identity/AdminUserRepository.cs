using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Identity.DTOs;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Identity;

public sealed class AdminUserRepository : IAdminUserRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<AdminUserRepository> _logger;

    public AdminUserRepository(SqlConnectionFactory connectionFactory, ILogger<AdminUserRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<PaginatedResult<AdminUserDto>> GetUsersAsync(
        string? search, string? role, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_GetUsers";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.Input("@Search", search),
            SqlHelper.Input("@Role", role),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var items = new List<AdminUserDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            items.Add(MapAdminUser(reader));
        }

        return new PaginatedResult<AdminUserDto>(items, pageNumber, pageSize, totalCount);
    }

    public async Task<AdminUserDto?> GetUserDetailAsync(int userId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        var user = await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Admin_GetUserDetail",
            MapAdminUser,
            [SqlHelper.Input("@UserId", userId)],
            cancellationToken);

        if (user == null) return null;

        using var rolesConnection = _connectionFactory.CreateConnection();
        var roles = await SqlHelper.ExecuteReaderAsync(
            rolesConnection,
            "proc_Identity_GetUserRoles",
            r => SqlHelper.GetValue<string>(r, "RoleName"),
            [SqlHelper.Input("@UserId", userId)],
            cancellationToken);

        return user with { Roles = roles };
    }

    public async Task LockUserAsync(int userId, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_LockUser",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task UnlockUserAsync(int userId, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_UnlockUser",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task AssignRoleAsync(int userId, int roleId, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_AssignRole",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@RoleId", roleId),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task RemoveRoleAsync(int userId, int roleId, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_RemoveRole",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@RoleId", roleId),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task ClearRolesAsync(int userId, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_ClearRoles",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task SaveTwoFactorCodeAsync(int userId, string codeHash, DateTime expiresAt, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_SaveTwoFactorCode",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@CodeHash", codeHash),
                SqlHelper.Input("@ExpiresAt", expiresAt)
            ],
            cancellationToken);
    }

    public async Task<bool> ValidateTwoFactorCodeAsync(int userId, string codeHash, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        var count = await SqlHelper.ExecuteScalarAsync(
            connection,
            "proc_Admin_ValidateTwoFactorCode",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@CodeHash", codeHash)
            ],
            cancellationToken);
        return count > 0;
    }

    public async Task ConsumeTwoFactorCodeAsync(int userId, string codeHash, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_ConsumeTwoFactorCode",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@CodeHash", codeHash)
            ],
            cancellationToken);
    }

    public async Task<IEnumerable<AdminPermissionDto>> GetUserPermissionsAsync(int userId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Admin_GetUserPermissions",
            reader => new AdminPermissionDto(
                ModuleName: SqlHelper.GetValue<string>(reader, "ModuleName"),
                CanView: SqlHelper.GetValue<bool>(reader, "CanView"),
                CanAdd: SqlHelper.GetValue<bool>(reader, "CanAdd"),
                CanEdit: SqlHelper.GetValue<bool>(reader, "CanEdit"),
                CanDelete: SqlHelper.GetValue<bool>(reader, "CanDelete")),
            [SqlHelper.Input("@UserId", userId)],
            cancellationToken);
    }

    public async Task SaveUserPermissionsAsync(int userId, IEnumerable<AdminPermissionDto> permissions, int adminId, CancellationToken cancellationToken = default)
    {
        var options = new System.Text.Json.JsonSerializerOptions { PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase };
        var json = System.Text.Json.JsonSerializer.Serialize(permissions, options);
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_SaveUserPermissions",
            [
                SqlHelper.Input("@UserId", userId),
                SqlHelper.Input("@AdminId", adminId),
                SqlHelper.Input("@PermissionsJson", json)
            ],
            cancellationToken);
    }

    private static AdminUserDto MapAdminUser(SqlDataReader reader)
    {
        var roleNames = SqlHelper.GetNullableString(reader, "RoleNames");
        var roles = string.IsNullOrWhiteSpace(roleNames) 
            ? Array.Empty<string>() 
            : roleNames.Split(',', StringSplitOptions.RemoveEmptyEntries);

        return new AdminUserDto(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            FirstName: SqlHelper.GetValue<string>(reader, "FirstName"),
            LastName: SqlHelper.GetValue<string>(reader, "LastName"),
            Email: SqlHelper.GetValue<string>(reader, "Email"),
            PhoneNumber: SqlHelper.GetNullableString(reader, "PhoneNumber"),
            StatusName: SqlHelper.GetValue<string>(reader, "StatusName"),
            FailedLoginAttempts: SqlHelper.GetValue<byte>(reader, "FailedLoginAttempts"),
            LockedUntil: SqlHelper.GetNullableValue<DateTime>(reader, "LockedUntil"),
            Roles: roles,
            CreatedOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            ModifiedOn: SqlHelper.GetNullableValue<DateTime>(reader, "ModifiedOn"));
    }
}
