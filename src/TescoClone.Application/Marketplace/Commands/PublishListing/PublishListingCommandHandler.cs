using MediatR;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Marketplace.Commands.PublishListing;

public sealed class PublishListingCommandHandler : IRequestHandler<PublishListingCommand>
{
    private readonly IMarketplaceRepository _repository;

    public PublishListingCommandHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public async Task Handle(PublishListingCommand request, CancellationToken cancellationToken)
    {
        var existing = await _repository.GetListingByIdAsync(request.ListingId, request.SellerId, cancellationToken)
            ?? throw new NotFoundException("Listing", request.ListingId.ToString());

        await _repository.PublishListingAsync(request.ListingId, request.SellerId, request.ModifiedBy, cancellationToken);
    }
}
