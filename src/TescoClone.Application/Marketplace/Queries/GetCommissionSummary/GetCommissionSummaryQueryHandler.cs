using MediatR;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Queries.GetCommissionSummary;

public sealed class GetCommissionSummaryQueryHandler : IRequestHandler<GetCommissionSummaryQuery, CommissionSummaryDto?>
{
    private readonly IMarketplaceRepository _repository;

    public GetCommissionSummaryQueryHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public Task<CommissionSummaryDto?> Handle(GetCommissionSummaryQuery request, CancellationToken cancellationToken)
        => _repository.GetSellerCommissionSummaryAsync(request.SellerId, request.FromDate, request.ToDate, cancellationToken);
}
