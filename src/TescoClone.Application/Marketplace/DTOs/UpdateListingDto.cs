namespace TescoClone.Application.Marketplace.DTOs;

public sealed record UpdateListingDto(
    string Title,
    string? Description,
    string? Slug,
    string? ImageUrl,
    decimal Price,
    int StockQuantity,
    string? EAN,
    decimal? Weight,
    int? CategoryId);
