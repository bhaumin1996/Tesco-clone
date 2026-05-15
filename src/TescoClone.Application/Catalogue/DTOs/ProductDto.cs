namespace TescoClone.Application.Catalogue.DTOs;

public sealed record ProductDto(
    int Id,
    int CategoryId,
    string CategoryName,
    int? BrandId,
    string? BrandName,
    string Name,
    string Slug,
    string? Description,
    decimal Price,
    decimal? ClubcardPrice,
    string? ImageUrl,
    bool IsAvailable,
    bool IsInStock);
