using MediatR;
using TescoClone.Application.Order.DTOs;
using TescoClone.Application.Order.Interfaces;

namespace TescoClone.Application.Order.Queries.GetCart;

public sealed class GetCartQueryHandler : IRequestHandler<GetCartQuery, CartDto?>
{
    private readonly ICartRepository _cartRepository;

    public GetCartQueryHandler(ICartRepository cartRepository)
    {
        _cartRepository = cartRepository;
    }

    public Task<CartDto?> Handle(GetCartQuery request, CancellationToken cancellationToken) =>
        _cartRepository.GetByUserIdAsync(request.UserId, cancellationToken);
}
