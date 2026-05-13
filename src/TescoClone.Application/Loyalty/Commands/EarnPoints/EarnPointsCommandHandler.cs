using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Loyalty.Interfaces;

namespace TescoClone.Application.Loyalty.Commands.EarnPoints;

public sealed class EarnPointsCommandHandler : IRequestHandler<EarnPointsCommand>
{
    private readonly ILoyaltyRepository _loyaltyRepository;
    private readonly ICurrentUser _currentUser;

    public EarnPointsCommandHandler(ILoyaltyRepository loyaltyRepository, ICurrentUser currentUser)
    {
        _loyaltyRepository = loyaltyRepository;
        _currentUser = currentUser;
    }

    public Task Handle(EarnPointsCommand request, CancellationToken cancellationToken) =>
        _loyaltyRepository.AddPointsAsync(request.UserId, request.Points, request.Description, _currentUser.UserId, cancellationToken);
}
