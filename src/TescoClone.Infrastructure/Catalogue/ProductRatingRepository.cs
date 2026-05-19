using Microsoft.Extensions.Logging;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Catalogue;

public sealed class ProductRatingRepository : IProductRatingRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<ProductRatingRepository> _logger;

    public ProductRatingRepository(SqlConnectionFactory connectionFactory, ILogger<ProductRatingRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<UserRatingStatusDto> GetUserRatingStatusAsync(int productId, int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            var result = await SqlHelper.ExecuteReaderSingleAsync(
                connection,
                "proc_Catalogue_GetUserRatingStatus",
                reader => new UserRatingStatusDto(
                    SqlHelper.GetValue<bool>(reader, "CanRate"),
                    SqlHelper.GetValue<bool>(reader, "HasRated"),
                    SqlHelper.GetNullableValue<int>(reader, "ExistingRating")),
                [
                    SqlHelper.Input("@ProductId", productId),
                    SqlHelper.Input("@UserId", userId)
                ],
                cancellationToken);

            return result ?? new UserRatingStatusDto(false, false, null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetUserRatingStatusAsync for productId: {ProductId}, userId: {UserId}", productId, userId);
            throw;
        }
    }

    public async Task SubmitRatingAsync(int productId, int userId, int rating, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Catalogue_SubmitProductRating",
                [
                    SqlHelper.Input("@ProductId", productId),
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@Rating", (byte)rating)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in SubmitRatingAsync for productId: {ProductId}, userId: {UserId}", productId, userId);
            throw;
        }
    }
}
