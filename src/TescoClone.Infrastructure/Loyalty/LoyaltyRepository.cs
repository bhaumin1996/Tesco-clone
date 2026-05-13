using TescoClone.Application.Loyalty.DTOs;
using TescoClone.Application.Loyalty.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Loyalty;

public sealed class LoyaltyRepository : ILoyaltyRepository
{
    private readonly SqlConnectionFactory _connectionFactory;

    public LoyaltyRepository(SqlConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<ClubcardDto?> GetByUserIdAsync(int userId, CancellationToken cancellationToken = default)
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

    public async Task AddPointsAsync(int userId, int points, string description, int createdBy, CancellationToken cancellationToken = default)
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

    public async Task<bool> RedeemPointsAsync(int userId, int points, string description, int createdBy, CancellationToken cancellationToken = default)
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
}
