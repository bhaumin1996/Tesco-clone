namespace TescoClone.Application.Analytics.DTOs;

public sealed record TopProductDto(
    int ProductId,
    string ProductName,
    string? ImageUrl,
    int TotalUnitsSold,
    decimal TotalRevenue);
