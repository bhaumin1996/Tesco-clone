using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.Interfaces;

namespace TescoClone.Application.Order.Commands.RemoveCartItem;

public sealed class RemoveCartItemCommandHandler : IRequestHandler<RemoveCartItemCommand>
{
    private readonly ICartRepository _cartRepository;
    private readonly ICurrentUser _currentUser;

    public RemoveCartItemCommandHandler(ICartRepository cartRepository, ICurrentUser currentUser)
    {
        _cartRepository = cartRepository;
        _currentUser = currentUser;
    }

    public Task Handle(RemoveCartItemCommand request, CancellationToken cancellationToken) =>
        _cartRepository.RemoveItemAsync(_currentUser.UserId, request.ProductVariantId, _currentUser.UserId, cancellationToken);
}
