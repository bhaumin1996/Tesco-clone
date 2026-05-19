namespace TescoClone.Application.Catalogue.DTOs;

public sealed record FavouriteDto(
    int FavouriteId,
    int ProductId,
    string Name,
    string? BrandName,
    decimal BasePrice,
    decimal? ClubcardPrice,
    string? UnitPrice,
    string? ImageUrl,
    string CategoryName,
    string? PromotionLabel,
    decimal AverageRating,
    int ReviewCount,
    bool IsInStock,
    DateTime CreatedOn
);
