using Microsoft.Extensions.Logging;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Order;

public sealed class CartRepository : ICartRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<CartRepository> _logger;

    public CartRepository(SqlConnectionFactory connectionFactory, ILogger<CartRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<CartDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            var items = await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Order_GetCartByUserId",
                reader => new
                {
                    CartId = SqlHelper.GetValue<int>(reader, "CartId"),
                    UserId = SqlHelper.GetValue<int>(reader, "UserId"),
                    Item = new CartItemDto(
                        SqlHelper.GetValue<int>(reader, "ProductVariantId"),
                        SqlHelper.GetValue<string>(reader, "ProductName"),
                        SqlHelper.GetValue<decimal>(reader, "UnitPrice"),
                        SqlHelper.GetValue<int>(reader, "Quantity"),
                        SqlHelper.GetValue<decimal>(reader, "LineTotal"))
                },
                [SqlHelper.Input("@UserId", userId)],
                cancellationToken);

            if (items.Count == 0) return null;

            var cartItems = items.Select(x => x.Item).ToList();
            return new CartDto(
                items[0].CartId,
                items[0].UserId,
                cartItems,
                cartItems.Sum(i => i.LineTotal));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetByUserIdAsync for userId: {UserId}", userId);
            throw;
        }
    }

    public async Task UpsertItemAsync(int userId, int productVariantId, string productName, decimal unitPrice, int quantity, int modifiedBy, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Order_UpsertCartItem",
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@ProductVariantId", productVariantId),
                    SqlHelper.Input("@ProductName", productName),
                    SqlHelper.Input("@UnitPrice", unitPrice),
                    SqlHelper.Input("@Quantity", quantity),
                    SqlHelper.Input("@ModifiedBy", modifiedBy),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in UpsertItemAsync for userId: {UserId}, productVariantId: {ProductVariantId}", userId, productVariantId);
            throw;
        }
    }

    public async Task RemoveItemAsync(int userId, int productVariantId, int modifiedBy, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Order_RemoveCartItem",
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@ProductVariantId", productVariantId),
                    SqlHelper.Input("@ModifiedBy", modifiedBy),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in RemoveItemAsync for userId: {UserId}, productVariantId: {ProductVariantId}", userId, productVariantId);
            throw;
        }
    }

    public async Task ClearAsync(int userId, int modifiedBy, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Order_ClearCart",
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@ModifiedBy", modifiedBy),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in ClearAsync for userId: {UserId}", userId);
            throw;
        }
    }
}
