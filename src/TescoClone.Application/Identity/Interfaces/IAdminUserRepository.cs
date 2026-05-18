using TescoClone.Application.Identity.DTOs;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Identity.Interfaces;

public interface IAdminUserRepository
{
    Task<PaginatedResult<AdminUserDto>> GetUsersAsync(string? search, string? role, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<AdminUserDto?> GetUserDetailAsync(int userId, CancellationToken cancellationToken = default);
    Task LockUserAsync(int userId, int adminId, CancellationToken cancellationToken = default);
    Task UnlockUserAsync(int userId, int adminId, CancellationToken cancellationToken = default);
    Task DeactivateUserAsync(int userId, int adminId, CancellationToken cancellationToken = default);
    Task ActivateUserAsync(int userId, int adminId, CancellationToken cancellationToken = default);
    Task DeleteUserAsync(int userId, int adminId, CancellationToken cancellationToken = default);
    Task AssignRoleAsync(int userId, int roleId, int adminId, CancellationToken cancellationToken = default);
    Task RemoveRoleAsync(int userId, int roleId, int adminId, CancellationToken cancellationToken = default);
    Task ClearRolesAsync(int userId, int adminId, CancellationToken cancellationToken = default);
    Task SaveTwoFactorCodeAsync(int userId, string codeHash, DateTime expiresAt, CancellationToken cancellationToken = default);
    Task<bool> ValidateTwoFactorCodeAsync(int userId, string codeHash, CancellationToken cancellationToken = default);
    Task ConsumeTwoFactorCodeAsync(int userId, string codeHash, CancellationToken cancellationToken = default);
    Task<IEnumerable<AdminPermissionDto>> GetUserPermissionsAsync(int userId, CancellationToken cancellationToken = default);
    Task SaveUserPermissionsAsync(int userId, IEnumerable<AdminPermissionDto> permissions, int adminId, CancellationToken cancellationToken = default);
}
