using Microsoft.Extensions.Logging;
using TescoClone.Application.Delivery.DTOs;
using TescoClone.Application.Delivery.Interfaces;
using TescoClone.Domain.Enums;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Delivery;

public sealed class DeliveryRepository : IDeliveryRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<DeliveryRepository> _logger;

    public DeliveryRepository(SqlConnectionFactory connectionFactory, ILogger<DeliveryRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<IReadOnlyList<DeliverySlotDto>> GetAvailableSlotsAsync(
        string postcode,
        DeliveryType? deliveryType,
        DateTime fromDate,
        DateTime toDate,
        CancellationToken cancellationToken = default)
    {
        try
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
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetAvailableSlotsAsync for postcode: {Postcode}", postcode);
            throw;
        }
    }

    public async Task<DeliverySlotDto?> GetSlotByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderSingleAsync(
                connection,
                "proc_Delivery_GetSlotById",
                MapSlot,
                [SqlHelper.Input("@SlotId", id)],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetSlotByIdAsync for slotId: {SlotId}", id);
            throw;
        }
    }

    public async Task BookSlotAsync(int slotId, int orderId, int createdBy, CancellationToken cancellationToken = default)
    {
        try
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
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in BookSlotAsync for slotId: {SlotId}, orderId: {OrderId}", slotId, orderId);
            throw;
        }
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
