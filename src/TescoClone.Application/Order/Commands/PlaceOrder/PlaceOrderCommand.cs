using MediatR;
using TescoClone.Application.Order.DTOs;

namespace TescoClone.Application.Order.Commands.PlaceOrder;

public sealed record PlaceOrderCommand(
    int? DeliverySlotId,
    string? DeliveryAddress,
    decimal DeliveryCharge) : IRequest<OrderDto>;
