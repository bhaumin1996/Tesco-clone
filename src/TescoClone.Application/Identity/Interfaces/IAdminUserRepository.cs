using TescoClone.Application.Identity.DTOs;
using TescoClone.Application.Common.Models;

namespace TescoClone.Application.Identity.Interfaces;

public interface IAdminUserRepository
{
    Task<PaginatedResult<AdminUserDto>> GetUsersAsync(string? search, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<AdminUserDto?> GetUserDetailAsync(int userId, CancellationToken cancellationToken = default);
    Task LockUserAsync(int userId, int adminId, CancellationToken cancellationToken = default);
    Task UnlockUserAsync(int userId, int adminId, CancellationToken cancellationToken = default);
    Task AssignRoleAsync(int userId, int roleId, int adminId, CancellationToken cancellationToken = default);
    Task RemoveRoleAsync(int userId, int roleId, int adminId, CancellationToken cancellationToken = default);
    Task ClearRolesAsync(int userId, int adminId, CancellationToken cancellationToken = default);
    Task SaveTwoFactorCodeAsync(int userId, string codeHash, DateTime expiresAt, CancellationToken cancellationToken = default);
    Task<bool> ValidateTwoFactorCodeAsync(int userId, string codeHash, CancellationToken cancellationToken = default);
    Task ConsumeTwoFactorCodeAsync(int userId, string codeHash, CancellationToken cancellationToken = default);
}
