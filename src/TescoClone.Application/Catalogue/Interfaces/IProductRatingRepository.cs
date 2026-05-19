using TescoClone.Application.Catalogue.DTOs;

namespace TescoClone.Application.Catalogue.Interfaces;

public interface IProductRatingRepository
{
    Task<UserRatingStatusDto> GetUserRatingStatusAsync(int productId, int userId, CancellationToken cancellationToken = default);
    Task SubmitRatingAsync(int productId, int userId, int rating, CancellationToken cancellationToken = default);
}
