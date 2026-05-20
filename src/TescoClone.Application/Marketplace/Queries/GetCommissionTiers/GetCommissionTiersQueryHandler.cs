using MediatR;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Queries.GetCommissionTiers;

public sealed class GetCommissionTiersQueryHandler : IRequestHandler<GetCommissionTiersQuery, IReadOnlyList<CommissionTierDto>>
{
    private readonly IMarketplaceRepository _repository;

    public GetCommissionTiersQueryHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public Task<IReadOnlyList<CommissionTierDto>> Handle(GetCommissionTiersQuery request, CancellationToken cancellationToken)
        => _repository.GetCommissionTiersAsync(cancellationToken);
}
