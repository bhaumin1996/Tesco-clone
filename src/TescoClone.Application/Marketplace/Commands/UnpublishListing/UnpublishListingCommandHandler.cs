using MediatR;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Marketplace.Commands.UnpublishListing;

public sealed class UnpublishListingCommandHandler : IRequestHandler<UnpublishListingCommand>
{
    private readonly IMarketplaceRepository _repository;

    public UnpublishListingCommandHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public async Task Handle(UnpublishListingCommand request, CancellationToken cancellationToken)
    {
        var existing = await _repository.GetListingByIdAsync(request.ListingId, request.SellerId, cancellationToken)
            ?? throw new NotFoundException("Listing", request.ListingId.ToString());

        await _repository.UnpublishListingAsync(request.ListingId, request.SellerId, request.ModifiedBy, cancellationToken);
    }
}
