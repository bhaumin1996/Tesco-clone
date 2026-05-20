using MediatR;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Commands.CreateListing;

public sealed class CreateListingCommandHandler : IRequestHandler<CreateListingCommand, int>
{
    private readonly IMarketplaceRepository _repository;

    public CreateListingCommandHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public Task<int> Handle(CreateListingCommand request, CancellationToken cancellationToken)
        => _repository.CreateListingAsync(request.SellerId, request.Dto, request.CreatedBy, cancellationToken);
}
