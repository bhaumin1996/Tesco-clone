using Microsoft.Extensions.Logging;
using TescoClone.Application.Loyalty.DTOs;
using TescoClone.Application.Loyalty.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Loyalty;

// ADO.NET repository for Clubcard account reads, points earning, and points redemption.
public sealed class LoyaltyRepository : ILoyaltyRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<LoyaltyRepository> _logger;

    public LoyaltyRepository(SqlConnectionFactory connectionFactory, ILogger<LoyaltyRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<ClubcardDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderSingleAsync(
                connection,
                "proc_Loyalty_GetClubcardByUserId",
                reader => new ClubcardDto(
                    SqlHelper.GetValue<int>(reader, "Id"),
                    SqlHelper.GetValue<string>(reader, "ClubcardNumber"),
                    SqlHelper.GetValue<int>(reader, "PointsBalance")),
                [SqlHelper.Input("@UserId", userId)],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetByUserIdAsync for userId: {UserId}", userId);
            throw;
        }
    }

    public async Task AddPointsAsync(int userId, int points, string description, int createdBy, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Loyalty_AddPoints",
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@Points", points),
                    SqlHelper.Input("@Description", description),
                    SqlHelper.Input("@CreatedBy", createdBy),
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in AddPointsAsync for userId: {UserId}", userId);
            throw;
        }
    }

    public async Task<bool> RedeemPointsAsync(int userId, int points, string description, int createdBy, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            var result = await SqlHelper.ExecuteScalarAsync(
                connection,
                "proc_Loyalty_RedeemPoints",
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@Points", points),
                    SqlHelper.Input("@Description", description),
                    SqlHelper.Input("@CreatedBy", createdBy),
                ],
                cancellationToken);
            return result > 0;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in RedeemPointsAsync for userId: {UserId}", userId);
            throw;
        }
    }
}
