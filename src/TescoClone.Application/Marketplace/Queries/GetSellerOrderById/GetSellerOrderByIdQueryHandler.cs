using MediatR;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Queries.GetSellerOrderById;

public sealed class GetSellerOrderByIdQueryHandler(IMarketplaceRepository repository)
    : IRequestHandler<GetSellerOrderByIdQuery, SellerOrderDto?>
{
    public Task<SellerOrderDto?> Handle(GetSellerOrderByIdQuery request, CancellationToken cancellationToken) =>
        repository.GetSellerOrderByIdAsync(request.SellerOrderId, request.SellerId, cancellationToken);
}
