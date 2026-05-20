using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Queries.GetSellerApplications;

public sealed class GetSellerApplicationsQueryHandler
    : IRequestHandler<GetSellerApplicationsQuery, PaginatedResult<SellerApplicationListDto>>
{
    private readonly IMarketplaceRepository _repository;

    public GetSellerApplicationsQueryHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public Task<PaginatedResult<SellerApplicationListDto>> Handle(
        GetSellerApplicationsQuery request, CancellationToken cancellationToken)
        => _repository.GetSellerApplicationsAsync(request.StatusFilter, request.PageNumber, request.PageSize, cancellationToken);
}
