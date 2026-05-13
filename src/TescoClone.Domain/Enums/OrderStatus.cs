namespace TescoClone.Domain.Enums;

public enum OrderStatus : byte
{
    Pending = 1,
    Confirmed = 2,
    PickingInProgress = 3,
    OutForDelivery = 4,
    Delivered = 5,
    Cancelled = 6,
    Refunded = 7
}
