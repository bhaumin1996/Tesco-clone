using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Queries.GetSellerListings;

public sealed class GetSellerListingsQueryHandler : IRequestHandler<GetSellerListingsQuery, PaginatedResult<ListingDto>>
{
    private readonly IMarketplaceRepository _repository;

    public GetSellerListingsQueryHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public Task<PaginatedResult<ListingDto>> Handle(GetSellerListingsQuery request, CancellationToken cancellationToken)
        => _repository.GetSellerListingsAsync(request.SellerId, request.StatusFilter, request.PageNumber, request.PageSize, cancellationToken);
}
