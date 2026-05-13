using MediatR;
using TescoClone.Domain.Enums;

namespace TescoClone.Application.Order.Commands.UpdateOrderStatus;

public sealed record UpdateOrderStatusCommand(
    int OrderId,
    OrderStatus NewStatus,
    int AdminUserId) : IRequest;
