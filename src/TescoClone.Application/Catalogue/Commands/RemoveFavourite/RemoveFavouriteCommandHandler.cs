using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.RemoveFavourite;

public sealed class RemoveFavouriteCommandHandler(IFavouriteRepository favouriteRepository)
    : IRequestHandler<RemoveFavouriteCommand>
{
    public async Task Handle(RemoveFavouriteCommand request, CancellationToken cancellationToken)
        => await favouriteRepository.RemoveFavouriteAsync(request.ProductId, request.UserId, cancellationToken);
}
