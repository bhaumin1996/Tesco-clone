using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Interfaces;

public interface IFavouriteRepository
{
    Task<IReadOnlyList<FavouriteDto>> GetUserFavouritesAsync(int userId, CancellationToken cancellationToken = default);
    Task<FavouriteStatusDto> GetFavouriteStatusAsync(int productId, int userId, CancellationToken cancellationToken = default);
    Task<int> AddFavouriteAsync(int productId, int userId, CancellationToken cancellationToken = default);
    Task RemoveFavouriteAsync(int productId, int userId, CancellationToken cancellationToken = default);
}
