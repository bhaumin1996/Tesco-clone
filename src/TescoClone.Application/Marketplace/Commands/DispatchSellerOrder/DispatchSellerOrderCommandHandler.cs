using MediatR;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Commands.DispatchSellerOrder;

public sealed class DispatchSellerOrderCommandHandler(IMarketplaceRepository repository)
    : IRequestHandler<DispatchSellerOrderCommand>
{
    public Task Handle(DispatchSellerOrderCommand request, CancellationToken cancellationToken) =>
        repository.DispatchSellerOrderAsync(
            request.SellerOrderId, request.SellerId,
            request.CarrierName, request.TrackingNumber,
            request.ModifiedBy, cancellationToken);
}
