using MediatR;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Commands.SubmitApplication;

public sealed class SubmitApplicationCommandHandler : IRequestHandler<SubmitApplicationCommand>
{
    private readonly IMarketplaceRepository _repository;

    public SubmitApplicationCommandHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public Task Handle(SubmitApplicationCommand request, CancellationToken cancellationToken)
        => _repository.SubmitApplicationAsync(request.ApplicationId, request.UserId, cancellationToken);
}
