namespace TescoClone.Application.Catalogue.DTOs;

public sealed record BrandDto(
    int Id,
    string Name,
    string Slug,
    string? LogoUrl);
