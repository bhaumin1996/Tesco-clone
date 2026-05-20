namespace TescoClone.Application.Marketplace.DTOs;

public sealed record CreateListingDto(
    int? ProductId,
    string Title,
    string? Description,
    string? Slug,
    string? ImageUrl,
    decimal Price,
    int StockQuantity,
    string? EAN,
    decimal? Weight,
    int? CategoryId);
