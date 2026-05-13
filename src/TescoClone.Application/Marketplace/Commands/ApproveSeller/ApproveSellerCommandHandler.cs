using MediatR;
using TescoClone.Application.Marketplace.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Marketplace.Commands.ApproveSeller;

public sealed class ApproveSellerCommandHandler : IRequestHandler<ApproveSellerCommand>
{
    private readonly IMarketplaceRepository _marketplaceRepository;

    public ApproveSellerCommandHandler(IMarketplaceRepository marketplaceRepository)
    {
        _marketplaceRepository = marketplaceRepository;
    }

    public async Task Handle(ApproveSellerCommand request, CancellationToken cancellationToken)
    {
        var seller = await _marketplaceRepository.GetSellerByIdAsync(request.SellerId, cancellationToken)
            ?? throw new NotFoundException("Seller", request.SellerId.ToString());

        await _marketplaceRepository.ApproveSellerAsync(request.SellerId, request.AdminUserId, cancellationToken);
    }
}
