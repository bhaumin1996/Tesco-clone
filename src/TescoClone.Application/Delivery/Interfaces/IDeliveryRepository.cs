using TescoClone.Application.Delivery.DTOs;
using TescoClone.Domain.Enums;

namespace TescoClone.Application.Delivery.Interfaces;

public interface IDeliveryRepository
{
    Task<IReadOnlyList<DeliverySlotDto>> GetAvailableSlotsAsync(
        string postcode,
        DeliveryType? deliveryType,
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default);
    Task<DeliverySlotDto?> GetSlotByIdAsync(int id, CancellationToken cancellationToken = default);
    Task BookSlotAsync(int slotId, int orderId, int createdBy, CancellationToken cancellationToken = default);
}
