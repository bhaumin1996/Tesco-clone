using TescoClone.Domain.Enums;

namespace TescoClone.Application.Delivery.DTOs;

public sealed record DeliverySlotDto(
    int Id,
    int StoreId,
    string StoreName,
    DeliveryType DeliveryType,
    DateTime SlotStart,
    DateTime SlotEnd,
    bool HasCapacity,
    decimal DeliveryCharge);
