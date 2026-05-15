using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Domain.Enums;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Order;

public sealed class OrderRepository : IOrderRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<OrderRepository> _logger;

    public OrderRepository(SqlConnectionFactory connectionFactory, ILogger<OrderRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<OrderDto?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await BuildOrderAsync(connection, "proc_Order_GetOrderById",
                [SqlHelper.Input("@OrderId", id)], cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetByIdAsync for orderId: {OrderId}", id);
            throw;
        }
    }

    public async Task<OrderDto?> GetByReferenceAsync(string reference, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await BuildOrderAsync(connection, "proc_Order_GetOrderByReference",
                [SqlHelper.Input("@OrderReference", reference)], cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetByReferenceAsync for reference: {Reference}", reference);
            throw;
        }
    }

    public async Task<PaginatedResult<OrderDto>> GetByUserIdAsync(int userId, int pageNumber, int pageSize, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();

            var rows = await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Order_GetOrdersByUserId",
                reader => new
                {
                    OrderId = SqlHelper.GetValue<int>(reader, "OrderId"),
                    OrderNumber = SqlHelper.GetValue<string>(reader, "OrderReference"),
                    Status = (OrderStatus)SqlHelper.GetValue<byte>(reader, "StatusId"),
                    Subtotal = SqlHelper.GetValue<decimal>(reader, "SubTotal"),
                    DeliveryCharge = SqlHelper.GetValue<decimal>(reader, "DeliveryCharge"),
                    ClubcardSavings = SqlHelper.GetValue<decimal>(reader, "DiscountTotal"),
                    Total = SqlHelper.GetValue<decimal>(reader, "Total"),
                    CreatedAt = SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
                    TotalCount = SqlHelper.GetValue<int>(reader, "TotalCount"),
                    Item = new OrderLineDto(
                        SqlHelper.GetValue<int>(reader, "OrderLineId"),
                        SqlHelper.GetValue<int>(reader, "ProductVariantId"),
                        SqlHelper.GetValue<string>(reader, "ProductName"),
                        SqlHelper.GetValue<string?>(reader, "ImageUrl"),
                        SqlHelper.GetValue<decimal>(reader, "UnitPrice"),
                        SqlHelper.GetValue<int>(reader, "Quantity"),
                        SqlHelper.GetValue<decimal>(reader, "LineTotal"))
                },
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@PageNumber", pageNumber),
                    SqlHelper.Input("@PageSize", pageSize),
                ],
                cancellationToken);

            var totalCount = rows.Count > 0 ? rows[0].TotalCount : 0;
            var orders = rows
                .GroupBy(r => r.OrderId)
                .Select(g =>
                {
                    var first = g.First();
                    return new OrderDto(
                        g.Key,
                        first.OrderNumber,
                        first.Status,
                        first.Subtotal,
                        first.DeliveryCharge,
                        first.ClubcardSavings,
                        first.Total,
                        null,
                        g.Select(r => r.Item).ToList(),
                        first.CreatedAt);
                })
                .ToList();

            return new PaginatedResult<OrderDto>(orders, pageNumber, pageSize, totalCount);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetByUserIdAsync for userId: {UserId}", userId);
            throw;
        }
    }

    public async Task<int> CreateFromCartAsync(int userId, int? deliverySlotId, string? deliveryAddress, decimal deliveryCharge, int createdBy, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteScalarAsync(
                connection,
                "proc_Order_CreateFromCart",
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.InputNullable("@DeliverySlotId", deliverySlotId),
                    SqlHelper.Input("@DeliveryAddress", deliveryAddress),
                    SqlHelper.Input("@DeliveryCharge", deliveryCharge),
                    SqlHelper.Input("@CreatedBy", createdBy),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in CreateFromCartAsync for userId: {UserId}", userId);
            throw;
        }
    }

    public async Task UpdateStatusAsync(int orderId, OrderStatus status, int modifiedBy, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Order_UpdateStatus",
                [
                    SqlHelper.Input("@OrderId", orderId),
                    SqlHelper.Input("@StatusId", (byte)status),
                    SqlHelper.Input("@ModifiedBy", modifiedBy),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in UpdateStatusAsync for orderId: {OrderId}", orderId);
            throw;
        }
    }

    private static async Task<OrderDto?> BuildOrderAsync(SqlConnection connection, string procedure, IEnumerable<SqlParameter> parameters, CancellationToken cancellationToken)
    {
        var rows = await SqlHelper.ExecuteReaderAsync(
            connection,
            procedure,
            reader => new
            {
                OrderId = SqlHelper.GetValue<int>(reader, "OrderId"),
                OrderNumber = SqlHelper.GetValue<string>(reader, "OrderReference"),
                Status = (OrderStatus)SqlHelper.GetValue<byte>(reader, "StatusId"),
                Subtotal = SqlHelper.GetValue<decimal>(reader, "SubTotal"),
                DeliveryCharge = SqlHelper.GetValue<decimal>(reader, "DeliveryCharge"),
                ClubcardSavings = SqlHelper.GetValue<decimal>(reader, "DiscountTotal"),
                Total = SqlHelper.GetValue<decimal>(reader, "Total"),
                DeliveryAddress = SqlHelper.GetValue<string?>(reader, "DeliveryAddress"),
                CreatedAt = SqlHelper.GetValue<DateTime>(reader, "CreatedOn"),
                Item = new OrderLineDto(
                    SqlHelper.GetValue<int>(reader, "OrderLineId"),
                    SqlHelper.GetValue<int>(reader, "ProductVariantId"),
                    SqlHelper.GetValue<string>(reader, "ProductName"),
                    SqlHelper.GetValue<string?>(reader, "ImageUrl"),
                    SqlHelper.GetValue<decimal>(reader, "UnitPrice"),
                    SqlHelper.GetValue<int>(reader, "Quantity"),
                    SqlHelper.GetValue<decimal>(reader, "LineTotal"))
            },
            parameters,
            cancellationToken);

        if (rows.Count == 0) return null;

        var first = rows[0];
        return new OrderDto(
            first.OrderId,
            first.OrderNumber,
            first.Status,
            first.Subtotal,
            first.DeliveryCharge,
            first.ClubcardSavings,
            first.Total,
            first.DeliveryAddress,
            rows.Select(r => r.Item).ToList(),
            first.CreatedAt);
    }
}
