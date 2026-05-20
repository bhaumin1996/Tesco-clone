using MediatR;
using TescoClone.Application.Common.Models;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Queries.GetSellerOrders;

public sealed class GetSellerOrdersQueryHandler(IMarketplaceRepository repository)
    : IRequestHandler<GetSellerOrdersQuery, PaginatedResult<SellerOrderSummaryDto>>
{
    public Task<PaginatedResult<SellerOrderSummaryDto>> Handle(
        GetSellerOrdersQuery request, CancellationToken cancellationToken) =>
        repository.GetSellerOrdersAsync(
            request.SellerId, request.StatusFilter,
            request.PageNumber, request.PageSize, cancellationToken);
}
