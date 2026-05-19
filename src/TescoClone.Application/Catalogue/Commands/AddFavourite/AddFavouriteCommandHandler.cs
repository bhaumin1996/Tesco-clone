using MediatR;
using TescoClone.Application.Catalogue.Interfaces;

namespace TescoClone.Application.Catalogue.Commands.AddFavourite;

public sealed class AddFavouriteCommandHandler(IFavouriteRepository favouriteRepository)
    : IRequestHandler<AddFavouriteCommand, int>
{
    public async Task<int> Handle(AddFavouriteCommand request, CancellationToken cancellationToken)
        => await favouriteRepository.AddFavouriteAsync(request.ProductId, request.UserId, cancellationToken);
}
