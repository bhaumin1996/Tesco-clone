using TescoClone.Domain.Enums;

namespace TescoClone.Application.Order.DTOs;

public sealed record OrderDto(
    int Id,
    string OrderNumber,
    OrderStatus Status,
    decimal Subtotal,
    decimal DeliveryCharge,
    decimal ClubcardSavings,
    decimal Total,
    string? DeliveryAddress,
    IReadOnlyList<OrderLineDto> Items,
    DateTime CreatedAt,
    string? CustomerName = null);
