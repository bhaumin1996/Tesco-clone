namespace TescoClone.Application.Order.DTOs;

public sealed record CartDto(
    int Id,
    int UserId,
    IReadOnlyList<CartItemDto> Items,
    decimal Subtotal,
    decimal ClubcardSavings,
    decimal PromotionSavings,
    decimal DeliveryCharge,
    decimal Total,
    bool MinimumOrderMet);
