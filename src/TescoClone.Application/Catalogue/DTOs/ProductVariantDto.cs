namespace TescoClone.Application.Catalogue.DTOs;

public sealed record ProductVariantDto(
    int Id,
    string Sku,
    string? VariantName,
    decimal PriceModifier,
    int StockQuantity,
    bool IsInStock);
