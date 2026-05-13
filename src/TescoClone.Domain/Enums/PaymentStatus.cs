namespace TescoClone.Domain.Enums;

public enum PaymentStatus : byte
{
    Pending = 1,
    Authorised = 2,
    Captured = 3,
    Failed = 4,
    Refunded = 5,
    PartiallyRefunded = 6
}
