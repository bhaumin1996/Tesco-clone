using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Catalogue;

public sealed class ProductVariant : Entity
{
    public int ProductId { get; private set; }
    public string Sku { get; private set; } = string.Empty;
    public string? VariantName { get; private set; }
    public decimal PriceModifier { get; private set; }
    public int StockQuantity { get; private set; }
    public string? Barcode { get; private set; }
    public RecordStatus RecordStatus { get; private set; }
    public DateTime CreatedOn { get; private set; }

    private ProductVariant() { }

    public bool IsInStock() => StockQuantity > 0;
}
