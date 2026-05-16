using TescoClone.Domain.Identity;

namespace TescoClone.Application.Identity.Interfaces;

public interface IPaymentRepository
{
    Task AddCardAsync(UserCard card, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<UserCard>> GetCardsByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task DeleteCardAsync(int userId, int cardId, CancellationToken cancellationToken = default);
}
