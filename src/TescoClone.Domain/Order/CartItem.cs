using TescoClone.Domain.Common;

namespace TescoClone.Domain.Order;

// Order module — a single line within a cart scoped to one product variant.
public sealed class CartItem : Entity
{
    public int CartId { get; private set; }
    public int ProductVariantId { get; private set; }
    public string ProductName { get; private set; } = string.Empty;
    public decimal UnitPrice { get; private set; }
    public int Quantity { get; private set; }
    public DateTime CreatedOn { get; private set; }

    private CartItem() { }

    internal static CartItem Create(int cartId, int productVariantId, string productName, decimal unitPrice, int quantity) =>
        new()
        {
            CartId = cartId,
            ProductVariantId = productVariantId,
            ProductName = productName,
            UnitPrice = unitPrice,
            Quantity = quantity,
            CreatedOn = DateTime.UtcNow
        };

    internal void UpdateQuantity(int quantity)
    {
        ArgumentOutOfRangeException.ThrowIfNegativeOrZero(quantity);
        Quantity = quantity;
    }
}
