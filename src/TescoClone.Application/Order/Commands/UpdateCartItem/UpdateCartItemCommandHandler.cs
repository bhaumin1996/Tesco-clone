using MediatR;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Order.Commands.UpdateCartItem;

public sealed class UpdateCartItemCommandHandler : IRequestHandler<UpdateCartItemCommand, CartDto>
{
    private readonly ICartRepository _cartRepository;
    private readonly IProductRepository _productRepository;
    private readonly ICurrentUser _currentUser;

    public UpdateCartItemCommandHandler(
        ICartRepository cartRepository,
        IProductRepository productRepository,
        ICurrentUser currentUser)
    {
        _cartRepository = cartRepository;
        _productRepository = productRepository;
        _currentUser = currentUser;
    }

    public async Task<CartDto> Handle(UpdateCartItemCommand request, CancellationToken cancellationToken)
    {
        var cart = await _cartRepository.GetByUserIdAsync(_currentUser.UserId, cancellationToken)
            ?? throw new NotFoundException("Cart", _currentUser.UserId);

        var exists = cart.Items.Any(i => i.ProductVariantId == request.ProductVariantId);
        if (!exists)
            throw new NotFoundException("CartItem", request.ProductVariantId);

        var product = await _productRepository.GetByIdAsync(request.ProductVariantId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Catalogue.Product), request.ProductVariantId);

        await _cartRepository.UpsertItemAsync(
            _currentUser.UserId,
            request.ProductVariantId,
            product.Name,
            product.BasePrice,
            request.Quantity,
            _currentUser.UserId,
            cancellationToken);

        return await _cartRepository.GetByUserIdAsync(_currentUser.UserId, cancellationToken)
            ?? throw new InvalidOperationException("Cart not found after update.");
    }
}
