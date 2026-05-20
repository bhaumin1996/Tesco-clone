using MediatR;
using TescoClone.Application.Marketplace.DTOs;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Queries.GetSellerApplication;

public sealed class GetSellerApplicationQueryHandler : IRequestHandler<GetSellerApplicationQuery, SellerApplicationDto?>
{
    private readonly IMarketplaceRepository _repository;

    public GetSellerApplicationQueryHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public Task<SellerApplicationDto?> Handle(GetSellerApplicationQuery request, CancellationToken cancellationToken)
        => _repository.GetApplicationByUserIdAsync(request.UserId, cancellationToken);
}
