using Microsoft.Extensions.Logging;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Infrastructure.Common;

namespace TescoClone.Infrastructure.Catalogue;

public sealed class FavouriteRepository : IFavouriteRepository
{
    private readonly SqlConnectionFactory _connectionFactory;
    private readonly ILogger<FavouriteRepository> _logger;

    public FavouriteRepository(SqlConnectionFactory connectionFactory, ILogger<FavouriteRepository> logger)
    {
        _connectionFactory = connectionFactory;
        _logger = logger;
    }

    public async Task<IReadOnlyList<FavouriteDto>> GetUserFavouritesAsync(int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            return await SqlHelper.ExecuteReaderAsync(
                connection,
                "proc_Catalogue_GetUserFavourites",
                reader => new FavouriteDto(
                    SqlHelper.GetValue<int>(reader, "FavouriteId"),
                    SqlHelper.GetValue<int>(reader, "ProductId"),
                    SqlHelper.GetValue<string>(reader, "Name"),
                    SqlHelper.GetNullableString(reader, "BrandName"),
                    SqlHelper.GetValue<decimal>(reader, "BasePrice"),
                    SqlHelper.GetNullableValue<decimal>(reader, "ClubcardPrice"),
                    SqlHelper.GetNullableString(reader, "UnitPrice"),
                    SqlHelper.GetNullableString(reader, "ImageUrl"),
                    SqlHelper.GetValue<string>(reader, "CategoryName"),
                    SqlHelper.GetNullableString(reader, "PromotionLabel"),
                    SqlHelper.GetValue<decimal>(reader, "AverageRating"),
                    SqlHelper.GetValue<int>(reader, "ReviewCount"),
                    SqlHelper.GetValue<bool>(reader, "IsInStock"),
                    SqlHelper.GetValue<DateTime>(reader, "CreatedOn")),
                [SqlHelper.Input("@UserId", userId)],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetUserFavouritesAsync for userId: {UserId}", userId);
            throw;
        }
    }

    public async Task<FavouriteStatusDto> GetFavouriteStatusAsync(int productId, int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            var result = await SqlHelper.ExecuteReaderSingleAsync(
                connection,
                "proc_Catalogue_GetFavouriteStatus",
                reader => new FavouriteStatusDto(
                    SqlHelper.GetValue<bool>(reader, "IsFavourited"),
                    SqlHelper.GetNullableValue<int>(reader, "FavouriteId")),
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@ProductId", productId)
                ],
                cancellationToken);

            return result ?? new FavouriteStatusDto(false, null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in GetFavouriteStatusAsync for productId: {ProductId}, userId: {UserId}", productId, userId);
            throw;
        }
    }

    public async Task<int> AddFavouriteAsync(int productId, int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            var result = await SqlHelper.ExecuteReaderSingleAsync(
                connection,
                "proc_Catalogue_AddFavourite",
                reader => SqlHelper.GetValue<int>(reader, "FavouriteId"),
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@ProductId", productId)
                ],
                cancellationToken);

            return result;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in AddFavouriteAsync for productId: {ProductId}, userId: {UserId}", productId, userId);
            throw;
        }
    }

    public async Task RemoveFavouriteAsync(int productId, int userId, CancellationToken cancellationToken = default)
    {
        try
        {
            using var connection = _connectionFactory.CreateConnection();
            await SqlHelper.ExecuteNonQueryAsync(
                connection,
                "proc_Catalogue_RemoveFavourite",
                [
                    SqlHelper.Input("@UserId", userId),
                    SqlHelper.Input("@ProductId", productId)
                ],
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error in RemoveFavouriteAsync for productId: {ProductId}, userId: {UserId}", productId, userId);
            throw;
        }
    }
}
