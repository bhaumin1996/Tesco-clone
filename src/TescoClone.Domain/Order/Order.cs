using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Order;

// Order module — placed order aggregate; enforces valid status transitions via Cancel/Confirm.
public sealed class Order : Entity
{
    private readonly List<OrderLine> _lines = [];

    public int UserId { get; private set; }
    public string OrderReference { get; private set; } = string.Empty;
    public OrderStatus Status { get; private set; }
    public decimal SubTotal { get; private set; }
    public decimal DeliveryCharge { get; private set; }
    public decimal DiscountTotal { get; private set; }
    public decimal Total { get; private set; }
    public int? DeliverySlotId { get; private set; }
    public string? DeliveryAddress { get; private set; }
    public IReadOnlyList<OrderLine> Lines => _lines.AsReadOnly();
    public string? InvoicePath { get; private set; }
    public RecordStatus RecordStatus { get; private set; }
    public DateTime CreatedOn { get; private set; }
    public DateTime? ModifiedOn { get; private set; }

    private Order() { }

    public void UpdateInvoicePath(string path)
    {
        InvoicePath = path;
        ModifiedOn = DateTime.UtcNow;
    }

    public void Cancel()
    {
        if (Status != OrderStatus.Placed && Status != OrderStatus.Confirmed)
            throw new ConflictException($"Order cannot be cancelled in status {Status}.");
        Status = OrderStatus.Cancelled;
        ModifiedOn = DateTime.UtcNow;
    }

    public void Confirm()
    {
        if (Status != OrderStatus.Placed)
            throw new ConflictException("Only placed orders can be confirmed.");
        Status = OrderStatus.Confirmed;
        ModifiedOn = DateTime.UtcNow;
    }
}
