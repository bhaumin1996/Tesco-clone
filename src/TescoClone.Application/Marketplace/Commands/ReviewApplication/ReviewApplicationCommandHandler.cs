using MediatR;
using TescoClone.Application.Marketplace.Interfaces;

namespace TescoClone.Application.Marketplace.Commands.ReviewApplication;

public sealed class ReviewApplicationCommandHandler : IRequestHandler<ReviewApplicationCommand>
{
    private readonly IMarketplaceRepository _repository;

    public ReviewApplicationCommandHandler(IMarketplaceRepository repository)
    {
        _repository = repository;
    }

    public Task Handle(ReviewApplicationCommand request, CancellationToken cancellationToken)
        => _repository.ReviewApplicationAsync(
            request.ApplicationId, request.Decision, request.ReviewNotes, request.AdminId, cancellationToken);
}
