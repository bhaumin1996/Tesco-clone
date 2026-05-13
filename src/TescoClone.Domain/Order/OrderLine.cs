using TescoClone.Domain.Common;

namespace TescoClone.Domain.Order;

public sealed class OrderLine : Entity
{
    public int OrderId { get; private set; }
    public int ProductVariantId { get; private set; }
    public string ProductName { get; private set; } = string.Empty;
    public decimal UnitPrice { get; private set; }
    public int Quantity { get; private set; }
    public decimal LineTotal { get; private set; }
    public DateTime CreatedOn { get; private set; }

    private OrderLine() { }
}
