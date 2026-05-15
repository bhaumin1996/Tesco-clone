using MediatR;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Order.Commands.UpdateCartItem;

public sealed class UpdateCartItemCommandHandler : IRequestHandler<UpdateCartItemCommand, CartDto>
{
    private readonly ICartRepository _cartRepository;
    private readonly ICurrentUser _currentUser;

    public UpdateCartItemCommandHandler(
        ICartRepository cartRepository,
        ICurrentUser currentUser)
    {
        _cartRepository = cartRepository;
        _currentUser = currentUser;
    }

    public async Task<CartDto> Handle(UpdateCartItemCommand request, CancellationToken cancellationToken)
    {
        var cart = await _cartRepository.GetByUserIdAsync(_currentUser.UserId, cancellationToken)
            ?? throw new NotFoundException("Cart", _currentUser.UserId);

        var cartItem = cart.Items.FirstOrDefault(i => i.ProductId == request.ProductVariantId)
            ?? throw new NotFoundException("CartItem", request.ProductVariantId);

        var stock = await _cartRepository.GetVariantStockAsync(request.ProductVariantId, cancellationToken)
            ?? throw new NotFoundException("ProductVariant", request.ProductVariantId);

        if (request.Quantity > stock)
            throw new ConflictException($"Only {stock} unit(s) available for this item.");

        await _cartRepository.UpsertItemAsync(
            _currentUser.UserId,
            request.ProductVariantId,
            cartItem.ProductName,
            cartItem.Price,
            request.Quantity,
            _currentUser.UserId,
            cancellationToken);

        return await _cartRepository.GetByUserIdAsync(_currentUser.UserId, cancellationToken)
            ?? throw new InvalidOperationException("Cart not found after update.");
    }
}
