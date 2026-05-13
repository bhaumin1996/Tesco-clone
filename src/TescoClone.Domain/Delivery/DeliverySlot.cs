using TescoClone.Domain.Common;
using TescoClone.Domain.Enums;

namespace TescoClone.Domain.Delivery;

public sealed class DeliverySlot : Entity
{
    public int StoreId { get; private set; }
    public DeliveryType DeliveryType { get; private set; }
    public DateTime SlotStart { get; private set; }
    public DateTime SlotEnd { get; private set; }
    public int Capacity { get; private set; }
    public int BookedCount { get; private set; }
    public decimal DeliveryCharge { get; private set; }
    public RecordStatus RecordStatus { get; private set; }
    public DateTime CreatedOn { get; private set; }

    private DeliverySlot() { }

    public bool HasCapacity() => BookedCount < Capacity;

    public void Book()
    {
        if (!HasCapacity())
            throw new ConflictException("Delivery slot is fully booked.");
        BookedCount++;
    }
}
