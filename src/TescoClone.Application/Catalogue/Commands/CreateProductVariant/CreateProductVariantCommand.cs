using MediatR;

namespace TescoClone.Application.Catalogue.Commands.CreateProductVariant;

public sealed record CreateProductVariantCommand(
    int ProductId,
    string Sku,
    string? VariantName,
    string? Barcode,
    int InitialQuantity,
    int LowStockThreshold,
    int AdminUserId) : IRequest<int>;
