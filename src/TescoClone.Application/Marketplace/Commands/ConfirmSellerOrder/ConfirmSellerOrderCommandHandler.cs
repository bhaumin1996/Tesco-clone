using MediatR;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Commands.ConfirmSellerOrder;

public sealed class ConfirmSellerOrderCommandHandler(IMarketplaceRepository repository)
    : IRequestHandler<ConfirmSellerOrderCommand>
{
    public Task Handle(ConfirmSellerOrderCommand request, CancellationToken cancellationToken) =>
        repository.ConfirmSellerOrderAsync(
            request.SellerOrderId, request.SellerId, request.ModifiedBy, cancellationToken);
}
