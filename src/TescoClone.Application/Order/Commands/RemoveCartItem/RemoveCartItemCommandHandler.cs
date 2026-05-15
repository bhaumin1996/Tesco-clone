using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;

namespace TescoClone.Application.Order.Commands.RemoveCartItem;

public sealed class RemoveCartItemCommandHandler : IRequestHandler<RemoveCartItemCommand, CartDto>
{
    private readonly ICartRepository _cartRepository;
    private readonly ICurrentUser _currentUser;

    public RemoveCartItemCommandHandler(ICartRepository cartRepository, ICurrentUser currentUser)
    {
        _cartRepository = cartRepository;
        _currentUser = currentUser;
    }

    public async Task<CartDto> Handle(RemoveCartItemCommand request, CancellationToken cancellationToken)
    {
        await _cartRepository.RemoveItemAsync(_currentUser.UserId, request.ProductVariantId, _currentUser.UserId, cancellationToken);
        
        return await _cartRepository.GetByUserIdAsync(_currentUser.UserId, cancellationToken)
            ?? new CartDto(0, _currentUser.UserId, [], 0, 0, 0, 0, 0, false);
    }
}
