using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Queries.GetFavourites;

public sealed class GetFavouritesQueryHandler(IFavouriteRepository favouriteRepository)
    : IRequestHandler<GetFavouritesQuery, IReadOnlyList<FavouriteDto>>
{
    public async Task<IReadOnlyList<FavouriteDto>> Handle(GetFavouritesQuery request, CancellationToken cancellationToken)
        => await favouriteRepository.GetUserFavouritesAsync(request.UserId, cancellationToken);
}
