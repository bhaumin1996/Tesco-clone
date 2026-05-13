namespace TescoClone.Application.Order.DTOs;

public sealed record CartItemDto(
    int ProductVariantId,
    string ProductName,
    decimal UnitPrice,
    int Quantity,
    decimal LineTotal);
