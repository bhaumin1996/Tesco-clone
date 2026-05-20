using MediatR;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Queries.GetListingById;

public sealed class GetListingByIdQueryHandler : IRequestHandler<GetListingByIdQuery, ListingDto?>
{
    private readonly IMarketplaceRepository _repository;

    public GetListingByIdQueryHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public Task<ListingDto?> Handle(GetListingByIdQuery request, CancellationToken cancellationToken)
        => _repository.GetListingByIdAsync(request.ListingId, request.SellerId, cancellationToken);
}
