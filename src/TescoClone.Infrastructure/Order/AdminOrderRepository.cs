using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Domain.Enums;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Order;

// ADO.NET repository for admin order operations: paginated all-orders list, status update, and refund processing.
public sealed class AdminOrderRepository : IAdminOrderRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<AdminOrderRepository> _logger;

    public AdminOrderRepository(SqlConnectionFactory connectionFactory, ILogger<AdminOrderRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<PaginatedResult<OrderDto>> GetAllOrdersAsync(
        OrderStatus? status, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await connection.OpenAsync(cancellationToken);

        using var command = connection.CreateCommand();
        command.CommandType = System.Data.CommandType.StoredProcedure;
        command.CommandText = "proc_Admin_GetAllOrders";
        command.Parameters.AddRange(new[]
        {
            SqlHelper.InputNullable("@Status", status.HasValue ? (byte?)((byte)status.Value) : null),
            SqlHelper.Input("@PageNumber", pageNumber),
            SqlHelper.Input("@PageSize", pageSize)
        });

        using var reader = await command.ExecuteReaderAsync(cancellationToken);
        var orders = new List<OrderDto>();
        int totalCount = 0;

        while (await reader.ReadAsync(cancellationToken))
        {
            totalCount = SqlHelper.GetValue<int>(reader, "TotalCount");
            orders.Add(MapOrder(reader));
        }

        return new PaginatedResult<OrderDto>(orders, pageNumber, pageSize, totalCount);
    }

    public async Task UpdateOrderStatusAsync(int orderId, OrderStatus status, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_UpdateOrderStatus",
            [
                SqlHelper.Input("@OrderId", orderId),
                SqlHelper.Input("@Status", (byte)status),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    public async Task ProcessRefundAsync(int orderId, decimal refundAmount, string reason, int adminId, CancellationToken cancellationToken = default)
    {
        using var connection = _connectionFactory.CreateConnection();
        await SqlHelper.ExecuteNonQueryAsync(
            connection,
            "proc_Admin_ProcessRefund",
            [
                SqlHelper.Input("@OrderId", orderId),
                SqlHelper.Input("@RefundAmount", refundAmount),
                SqlHelper.Input("@Reason", reason),
                SqlHelper.Input("@AdminId", adminId)
            ],
            cancellationToken);
    }

    private static OrderDto MapOrder(SqlDataReader reader) =>
        new(
            Id: SqlHelper.GetValue<int>(reader, "Id"),
            OrderNumber: SqlHelper.GetValue<string>(reader, "OrderReference"),
            Status: (OrderStatus)SqlHelper.GetValue<byte>(reader, "StatusId"),
            Subtotal: SqlHelper.GetValue<decimal>(reader, "SubTotal"),
            DeliveryCharge: SqlHelper.GetValue<decimal>(reader, "DeliveryCharge"),
            ClubcardSavings: SqlHelper.GetValue<decimal>(reader, "DiscountTotal"),
            Total: SqlHelper.GetValue<decimal>(reader, "Total"),
            DeliveryAddress: null,
            Items: Array.Empty<OrderLineDto>(),
            CreatedAt: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
            CustomerName: SqlHelper.GetValue<string?>(reader, "CustomerName"));
}
