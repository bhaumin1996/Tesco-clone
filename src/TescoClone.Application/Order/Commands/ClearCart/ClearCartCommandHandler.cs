using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.Interfaces;

namespace TescoClone.Application.Order.Commands.ClearCart;

public sealed class ClearCartCommandHandler : IRequestHandler<ClearCartCommand>
{
    private readonly ICartRepository _cartRepository;
    private readonly ICurrentUser _currentUser;

    public ClearCartCommandHandler(ICartRepository cartRepository, ICurrentUser currentUser)
    {
        _cartRepository = cartRepository;
        _currentUser = currentUser;
    }

    public Task Handle(ClearCartCommand request, CancellationToken cancellationToken) =>
        _cartRepository.ClearAsync(_currentUser.UserId, _currentUser.UserId, cancellationToken);
}
