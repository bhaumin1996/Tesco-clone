namespace TescoClone.Application.Marketplace.DTOs;

public sealed record ListingDto(
    int Id,
    int SellerId,
    int? ProductId,
    string Title,
    string? Description,
    string? Slug,
    string? ImageUrl,
    decimal Price,
    int StockQuantity,
    string? EAN,
    decimal? Weight,
    int? CategoryId,
    string StatusName,
    bool IsActive,
    DateTime CreatedOn,
    DateTime? ModifiedOn);
