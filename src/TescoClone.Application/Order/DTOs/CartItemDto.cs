namespace TescoClone.Application.Order.DTOs;

public sealed record CartItemDto(
    int Id,
    int ProductId,
    string ProductName,
    string? ImageUrl,
    decimal Price,
    decimal? ClubcardPrice,
    int Quantity,
    string? UnitPrice,
    string? PromotionLabel,
    decimal LineTotal);
