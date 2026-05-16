using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Logging;
using TescoClone.Application.Identity.Interfaces;
using TescoClone.Domain.Identity;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Identity;

public sealed class PaymentRepository : IPaymentRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<PaymentRepository> _logger;

    public PaymentRepository(SqlConnectionFactory connectionFactory, ILogger<PaymentRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task AddCardAsync(UserCard card, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "spAddUserCard",
                [
                    SqlHelper.Input("@UserId", card.UserId),
                    SqlHelper.Input("@PaymentMethodId", card.PaymentMethodId),
                    SqlHelper.Input("@Brand", card.Brand),
                    SqlHelper.Input("@Last4", card.Last4),
                    SqlHelper.Input("@ExpiryMonth", card.ExpiryMonth),
                    SqlHelper.Input("@ExpiryYear", card.ExpiryYear),
                    SqlHelper.Input("@IsDefault", card.IsDefault),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in AddCardAsync for userId: {UserId}", card.UserId);
            throw;
        }
    }

    public async Task<IReadOnlyList<UserCard>> GetCardsByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "spGetUserCards",
                MapCard,
                [SqlHelper.Input("@UserId", userId)],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetCardsByUserIdAsync for userId: {UserId}", userId);
            throw;
        }
    }

    public async Task DeleteCardAsync(int userId, int cardId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "spDeleteUserCard",
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@CardId", cardId),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in DeleteCardAsync for cardId: {CardId}", cardId);
            throw;
        }
    }

    private static UserCard MapCard(SqlDataReader reader) =>
        UserCard.Hydrate(
            id: SqlHelper.GetValue<int>(reader, "Id"),
            userId: 0, // Not returned by proc but could be passed if needed
            paymentMethodId: SqlHelper.GetValue<string>(reader, "PaymentMethodId"),
            brand: SqlHelper.GetValue<string>(reader, "Brand"),
            last4: SqlHelper.GetValue<string>(reader, "Last4"),
            expiryMonth: SqlHelper.GetValue<int>(reader, "ExpiryMonth"),
            expiryYear: SqlHelper.GetValue<int>(reader, "ExpiryYear"),
            isDefault: SqlHelper.GetValue<bool>(reader, "IsDefault"),
            createdOn: SqlHelper.GetValue<DateTime>(reader, "CreatedOn"));
}
