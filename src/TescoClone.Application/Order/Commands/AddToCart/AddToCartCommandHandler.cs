using MediatR;
using TescoClone.Application.Catalogue.Interfaces;
using TescoClone.Application.Common.Abstractions;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;
using TescoClone.Domain.Common;

namespace TescoClone.Application.Order.Commands.AddToCart;

public sealed class AddToCartCommandHandler : IRequestHandler<AddToCartCommand, CartDto>
{
    private readonly ICartRepository _cartRepository;
    private readonly IProductRepository _productRepository;
    private readonly ICurrentUser _currentUser;

    public AddToCartCommandHandler(
        ICartRepository cartRepository,
        IProductRepository productRepository,
        ICurrentUser currentUser)
    {
        _cartRepository = cartRepository;
        _productRepository = productRepository;
        _currentUser = currentUser;
    }

    public async Task<CartDto> Handle(AddToCartCommand request, CancellationToken cancellationToken)
    {
        var product = await _productRepository.GetByIdAsync(request.ProductId, cancellationToken)
            ?? throw new NotFoundException(nameof(Domain.Catalogue.Product), request.ProductId);

        if (!product.IsAvailable)
            throw new ConflictException("Product is currently unavailable.");

        await _cartRepository.UpsertItemAsync(
            _currentUser.UserId,
            request.ProductId,
            product.Name,
            product.Price,
            request.Quantity,
            _currentUser.UserId,
            cancellationToken);

        return await _cartRepository.GetByUserIdAsync(_currentUser.UserId, cancellationToken)
            ?? throw new InvalidOperationException("Cart not found after update.");
    }
}
