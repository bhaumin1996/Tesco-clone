namespace TescoClone.Application.Catalogue.DTOs;

public sealed record AdminInventoryDto(
    int ProductVariantId,
    int ProductId,
    string ProductName,
    string Sku,
    int StockQuantity,
    int LowStockThreshold,
    bool IsLowStock,
    int PlacedAndConfirmedCount,
    int PendingOrderCount,
    int RemainingStock,
    string? VariantName = null);
