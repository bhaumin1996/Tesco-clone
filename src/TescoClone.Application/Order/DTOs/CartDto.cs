namespace TescoClone.Application.Order.DTOs;

public sealed record CartDto(
    int Id,
    int UserId,
    IReadOnlyList<CartItemDto> Items,
    decimal Total);
