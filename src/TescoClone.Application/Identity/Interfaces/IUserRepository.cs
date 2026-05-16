using TescoClone.Domain.Identity;

namespace TescoClone.Application.Identity.Interfaces;

public interface IUserRepository
{
    Task<User?> GetByEmailAsync(string email, CancellationToken cancellationToken = default);
    Task<User?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<bool> EmailExistsAsync(string email, CancellationToken cancellationToken = default);
    Task<int> CreateAsync(User user, string passwordHash, CancellationToken cancellationToken = default);
    Task UpdateAsync(User user, CancellationToken cancellationToken = default);
    Task UpdateProfileAsync(int userId, string firstName, string lastName, string email, string? phoneNumber, CancellationToken cancellationToken = default);
    Task UpdatePasswordAsync(int userId, string passwordHash, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<string>> GetRolesAsync(int userId, CancellationToken cancellationToken = default);
    Task SaveRefreshTokenAsync(int userId, string tokenHash, DateTime expiresAt, CancellationToken cancellationToken = default);
    Task<bool> ValidateRefreshTokenAsync(int userId, string tokenHash, CancellationToken cancellationToken = default);
    Task RevokeRefreshTokenAsync(int userId, string tokenHash, CancellationToken cancellationToken = default);
    Task UpdateStripeCustomerIdAsync(int userId, string stripeCustomerId, CancellationToken cancellationToken = default);
    Task SetPasswordResetTokenAsync(string email, string token, DateTime expiresAt, CancellationToken cancellationToken = default);
    Task<User?> GetByPasswordResetTokenAsync(string token, CancellationToken cancellationToken = default);
}
