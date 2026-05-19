using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Order;

// Order module — server-side persistent shopping cart aggregate owned by one user.
public sealed class Cart : Entity
{
    private readonly List<CartItem> _items = [];

    public int UserId { get; private set; }
    public IReadOnlyList<CartItem> Items => _items.AsReadOnly();
    public RecordStatus RecordStatus { get; private set; }
    public DateTime CreatedOn { get; private set; }
    public DateTime? ModifiedOn { get; private set; }

    private Cart() { }

    public decimal Total => _items.Sum(i => i.UnitPrice * i.Quantity);

    public void AddItem(int productVariantId, string productName, decimal unitPrice, int quantity)
    {
        var existing = _items.FirstOrDefault(i => i.ProductVariantId == productVariantId);
        if (existing != null)
        {
            existing.UpdateQuantity(existing.Quantity + quantity);
        }
        else
        {
            _items.Add(CartItem.Create(Id, productVariantId, productName, unitPrice, quantity));
        }
        ModifiedOn = DateTime.UtcNow;
    }

    public void RemoveItem(int productVariantId)
    {
        var item = _items.FirstOrDefault(i => i.ProductVariantId == productVariantId)
            ?? throw new NotFoundException(nameof(CartItem), productVariantId);
        _items.Remove(item);
        ModifiedOn = DateTime.UtcNow;
    }

    public void Clear()
    {
        _items.Clear();
        ModifiedOn = DateTime.UtcNow;
    }
}
