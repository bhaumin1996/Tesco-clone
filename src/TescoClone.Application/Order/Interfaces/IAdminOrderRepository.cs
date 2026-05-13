using TescoClone.Application.Common.Models;
using TescoClone.Application.Order.DTOs;
using TescoClone.Domain.Enums;

namespace TescoClone.Application.Order.Interfaces;

public interface IAdminOrderRepository
{
    Task<PaginatedResult<OrderDto>> GetAllOrdersAsync(OrderStatus? status, int pageNumber, int pageSize, CancellationToken cancellationToken = default);
    Task UpdateOrderStatusAsync(int orderId, OrderStatus status, int adminId, CancellationToken cancellationToken = default);
    Task ProcessRefundAsync(int orderId, decimal refundAmount, string reason, int adminId, CancellationToken cancellationToken = default);
}
