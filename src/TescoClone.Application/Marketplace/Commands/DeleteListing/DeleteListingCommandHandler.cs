using MediatR;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Marketplace.Commands.DeleteListing;

public sealed class DeleteListingCommandHandler : IRequestHandler<DeleteListingCommand>
{
    private readonly IMarketplaceRepository _repository;

    public DeleteListingCommandHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public async Task Handle(DeleteListingCommand request, CancellationToken cancellationToken)
    {
        var existing = await _repository.GetListingByIdAsync(request.ListingId, request.SellerId, cancellationToken)
            ?? throw new NotFoundException("Listing", request.ListingId.ToString());

        await _repository.SoftDeleteListingAsync(request.ListingId, request.SellerId, request.ModifiedBy, cancellationToken);
    }
}
