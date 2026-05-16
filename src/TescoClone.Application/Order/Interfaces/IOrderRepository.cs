using TescoClone.Application.Common.Models;
using TescoClone.Application.Order.DTOs;
using TescoClone.Domain.Enums;

namespace TescoClone.Application.Order.Interfaces;

public interface IOrderRepository
{
    Task<OrderDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default);
    Task<OrderDto?> GetByReferenceAsync(string reference, CancellationToken cancellationToken = default);
    Task<PaginatedResult<OrderDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task<int> CreateFromCartAsync(int userId, int? deliverySlotId, string? deliveryAddress, decimal deliveryCharge, int createdBy, CancellationToken cancellationToken = default);
    Task UpdateStatusAsync(int orderId, OrderStatus status, int modifiedBy, CancellationToken cancellationToken = default);
    Task UpdateInvoicePathAsync(int orderId, string path, int modifiedBy, CancellationToken cancellationToken = default);
}
