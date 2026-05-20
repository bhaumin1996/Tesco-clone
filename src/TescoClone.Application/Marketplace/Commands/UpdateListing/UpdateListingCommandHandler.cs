using MediatR;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Marketplace.Commands.UpdateListing;

public sealed class UpdateListingCommandHandler : IRequestHandler<UpdateListingCommand>
{
    private readonly IMarketplaceRepository _repository;

    public UpdateListingCommandHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public async Task Handle(UpdateListingCommand request, CancellationToken cancellationToken)
    {
        var existing = await _repository.GetListingByIdAsync(request.ListingId, request.SellerId, cancellationToken)
            ?? throw new NotFoundException("Listing", request.ListingId.ToString());

        await _repository.UpdateListingAsync(request.ListingId, request.SellerId, request.Dto, request.ModifiedBy, cancellationToken);
    }
}
