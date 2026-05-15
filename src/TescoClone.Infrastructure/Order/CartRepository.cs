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
                reader => new CartItemDto(
                    SqlHelper.GetValue<int>(reader, "CartItemId"),
                    SqlHelper.GetValue<int>(reader, "ProductVariantId"),
                    SqlHelper.GetValue<string>(reader, "ProductName"),
                    SqlHelper.GetValue<string?>(reader, "ImageUrl"),
                    SqlHelper.GetValue<decimal>(reader, "UnitPrice"),
                    SqlHelper.GetValue<decimal?>(reader, "ClubcardPrice"),
                    SqlHelper.GetValue<int>(reader, "Quantity"),
                    SqlHelper.GetValue<string?>(reader, "UnitPriceLabel"),
                    SqlHelper.GetValue<string?>(reader, "PromotionLabel"),
                    SqlHelper.GetValue<decimal>(reader, "LineTotal")),
                [SqlHelper.Input("@UserId", userId)],
                cancellationToken);

            if (items.Count == 0) return null;

            // Get CartId and UserId from the first item (all items belong to the same cart)
            // Note: We need a way to get CartId even if there are no items, but GetByUserIdAsync 
            // usually returns items. If it's empty, we return null anyway above.
            // For a more robust solution, the SP could return multiple result sets.
            
            var subtotal = items.Sum(i => i.LineTotal);
            var clubcardSavings = items.Sum(i => (i.Price - (i.ClubcardPrice ?? i.Price)) * i.Quantity);
            var deliveryCharge = subtotal > 40 ? 0m : 4.50m; // Example logic
            var total = subtotal - clubcardSavings + deliveryCharge;
            var minimumOrderMet = subtotal >= 15;

            return new CartDto(
                0, // We don't have CartId easily if we don't select it separately, but 0 is fine for now or we can add it to SP
                userId,
                items,
                subtotal,
                clubcardSavings,
                0, // PromotionSavings (placeholder)
                deliveryCharge,
                total,
                minimumOrderMet);
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
