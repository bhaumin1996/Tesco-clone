using TescoClone.Application.Loyalty.DTOs;

namespace TescoClone.Application.Loyalty.Interfaces;

public interface ILoyaltyRepository
{
    Task<ClubcardDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task AddPointsAsync(int userId, int points, string description, int createdBy, CancellationToken cancellationToken = default);
    Task<bool> RedeemPointsAsync(int userId, int points, string description, int createdBy, CancellationToken cancellationToken = default);
}
