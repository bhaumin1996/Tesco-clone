using TescoClone.Application.Order.DTOs;

namespace TescoClone.Application.Order.Interfaces;

public interface ICartRepository
{
    Task<CartDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default);
    Task<int?> GetVariantStockAsync(int productVariantId, CancellationToken cancellationToken = default);
    Task UpsertItemAsync(int userId, int productVariantId, string productName, decimal unitPrice, int quantity, int modifiedBy, CancellationToken cancellationToken = default);
    Task RemoveItemAsync(int userId, int productVariantId, int modifiedBy, CancellationToken cancellationToken = default);
    Task ClearAsync(int userId, int modifiedBy, CancellationToken cancellationToken = default);
}
