using MediatR;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Marketplace.Commands.SuspendSeller;

public sealed class SuspendSellerCommandHandler : IRequestHandler<SuspendSellerCommand>
{
    private readonly IMarketplaceRepository _marketplaceRepository;

    public SuspendSellerCommandHandler(IMarketplaceRepository marketplaceRepository)
    {
        _marketplaceRepository = marketplaceRepository;
    }

    public async Task Handle(SuspendSellerCommand request, CancellationToken cancellationToken)
    {
        var seller = await _marketplaceRepository.GetSellerByIdAsync(request.SellerId, cancellationToken)
            ?? throw new NotFoundException("Seller", request.SellerId.ToString());

        await _marketplaceRepository.SuspendSellerAsync(request.SellerId, request.Reason, request.AdminUserId, cancellationToken);
    }
}
