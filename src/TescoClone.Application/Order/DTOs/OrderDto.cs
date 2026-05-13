using TescoClone.Domain.Enums;

namespace TescoClone.Application.Order.DTOs;

public sealed record OrderDto(
    int Id,
    string OrderReference,
    OrderStatus Status,
    decimal SubTotal,
    decimal DeliveryCharge,
    decimal DiscountTotal,
    decimal Total,
    IReadOnlyList<OrderLineDto> Lines,
    DateTime CreatedOn);
