namespace TescoClone.Application.Order.DTOs;

public sealed record OrderLineDto(
    int Id,
    int ProductId,
    string ProductName,
    string? ImageUrl,
    decimal Price,
    int Quantity,
    decimal LineTotal);
