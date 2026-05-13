using MediatR;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Marketplace.Commands.ResolveDispute;

public sealed class ResolveDisputeCommandHandler : IRequestHandler<ResolveDisputeCommand>
{
    private readonly IMarketplaceRepository _marketplaceRepository;

    public ResolveDisputeCommandHandler(IMarketplaceRepository marketplaceRepository)
    {
        _marketplaceRepository = marketplaceRepository;
    }

    public async Task Handle(ResolveDisputeCommand request, CancellationToken cancellationToken)
    {
        await _marketplaceRepository.ResolveDisputeAsync(request.DisputeId, request.Resolution, request.AdminUserId, cancellationToken);
    }
}
