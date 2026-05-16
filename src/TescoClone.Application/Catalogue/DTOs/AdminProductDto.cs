namespace TescoClone.Application.Catalogue.DTOs;

public sealed record AdminProductDto(
    int Id,
    int CategoryId,
    string CategoryName,
    int? BrandId,
    string? BrandName,
    string Name,
    string Slug,
    string? Description,
    decimal BasePrice,
    decimal? ClubcardPrice,
    string? ImageUrl,
    bool IsAvailable,
    int StockQuantity,
    DateTime CreatedOn,
    DateTime? ModifiedOn,
    int PlacedAndConfirmedCount,
    int PendingOrderCount,
    int RemainingStock);
