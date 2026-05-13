using TescoClone.Application.Delivery.DTOs;
using TescoClone.Application.Delivery.Interfaces;
using TescoClone.Domain.Enums;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Delivery;

public sealed class DeliveryRepository : IDeliveryRepository
{
    private readonly SqlConnectionFactory _connectionFactory;

    public DeliveryRepository(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<IReadOnlyList<DeliverySlotDto>> GetAvailableSlotsAsync(
        string postcode,
        DeliveryType? deliveryType,
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderAsync(
            connection,
            "proc_Delivery_GetAvailableSlots",
            MapSlot,
            [
                SqlHelper.Input("@Postcode", postcode),
                SqlHelper.InputNullable("@DeliveryTypeId", deliveryType.HasValue ? (byte?)deliveryType.Value : null),
                SqlHelper.Input("@FromDate", fromDate),
                SqlHelper.Input("@ToDate", toDate),
            ],
            cancellationToken);
    }

    public async Task<DeliverySlotDto?> GetSlotByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        return await SqlHelper.ExecuteReaderSingleAsync(
            connection,
            "proc_Delivery_GetSlotById",
            MapSlot,
            [SqlHelper.Input("@SlotId", id)],
            cancellationToken);
    }

    public async Task BookSlotAsync(int slotId, int orderId, int createdBy, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Delivery_BookSlot",
            [
                SqlHelper.Input("@SlotId", slotId),
                SqlHelper.Input("@OrderId", orderId),
                SqlHelper.Input("@CreatedBy", createdBy),
            ],
            cancellationToken);
    }

    private static DeliverySlotDto MapSlot(Microsoft.Data.SqlClient.SqlDataReader reader) =>
        new(
            SqlHelper.GetValue<int>(reader, "Id"),
            SqlHelper.GetValue<int>(reader, "StoreId"),
            SqlHelper.GetValue<string>(reader, "StoreName"),
            (DeliveryType)SqlHelper.GetValue<byte>(reader, "DeliveryTypeId"),
            SqlHelper.GetValue<DateTime>(reader, "SlotStart"),
            SqlHelper.GetValue<DateTime>(reader, "SlotEnd"),
            SqlHelper.GetValue<bool>(reader, "HasCapacity"),
            SqlHelper.GetValue<decimal>(reader, "DeliveryCharge"));
}
