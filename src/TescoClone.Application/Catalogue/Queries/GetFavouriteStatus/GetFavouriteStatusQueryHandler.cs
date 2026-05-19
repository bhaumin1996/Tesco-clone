using MediatR;
using TescoClone.Application.Catalogue.DTOs;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Queries.GetFavouriteStatus;

public sealed class GetFavouriteStatusQueryHandler(IFavouriteRepository favouriteRepository)
    : IRequestHandler<GetFavouriteStatusQuery, FavouriteStatusDto>
{
    public async Task<FavouriteStatusDto> Handle(GetFavouriteStatusQuery request, CancellationToken cancellationToken)
        => await favouriteRepository.GetFavouriteStatusAsync(request.ProductId, request.UserId, cancellationToken);
}
